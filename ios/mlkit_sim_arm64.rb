# Lets the app run on Apple Silicon iOS 26+ simulators, which are arm64 only.
#
# Google ships the ML Kit pods as static fat frameworks with an x86_64
# simulator slice and an arm64 *device* slice, and their podspecs exclude
# arm64 from simulator builds. The arm64 objects are fine on the simulator;
# only their LC_BUILD_VERSION says "iOS". This makes a copy of each framework
# under <pod>/FrameworksSimArm64 whose arm64 objects say "iOS Simulator", and
# points simulator builds (only) at that copy. Device builds link Google's
# original binaries.
#
# Called from post_integrate in the Podfile; reruns after every pod install.
require "fileutils"
require "tmpdir"

module MlkitSimArm64
  PLATFORM_IOS = 2
  PLATFORM_IOS_SIMULATOR = 7
  LC_BUILD_VERSION = 0x32
  LC_VERSION_MIN_IPHONEOS = 0x25
  MH_MAGIC_64 = 0xfeedfacf
  SIM_DIR = 'FrameworksSimArm64'
  EXCLUDE_LINE = /^EXCLUDED_ARCHS\[sdk=iphonesimulator\*\]\s*=.*arm64.*\n/

  def self.run(pods_root)
    patched = []
    Dir.glob(File.join(pods_root, '{MLKit*,MLImage}', 'Frameworks', '*.framework')).each do |fw|
      pod_dir = File.dirname(File.dirname(fw))
      name = File.basename(fw, '.framework')
      binary = File.join(fw, name)
      next unless File.file?(binary)
      archs = `lipo -archs "#{binary}"`.split
      next unless archs.include?('arm64')

      out_fw = File.join(pod_dir, SIM_DIR, File.basename(fw))
      out_bin = File.join(out_fw, name)
      unless File.exist?(out_bin) && File.mtime(out_bin) >= File.mtime(binary)
        FileUtils.rm_rf(out_fw)
        FileUtils.mkdir_p(File.dirname(out_fw))
        FileUtils.cp_r(fw, out_fw)
        Dir.mktmpdir do |tmp|
          arm = File.join(tmp, 'arm64.a')
          system('lipo', '-thin', 'arm64', binary, '-output', arm, exception: true)
          patch_archive(arm)
          slices = [arm]
          if archs.include?('x86_64')
            x86 = File.join(tmp, 'x86_64.a')
            system('lipo', '-thin', 'x86_64', binary, '-output', x86, exception: true)
            slices << x86
          end
          FileUtils.rm_f(out_bin)
          system('lipo', '-create', *slices, '-output', out_bin, exception: true)
        end
      end
      patched << File.basename(pod_dir)
    end
    rewrite_xcconfigs(pods_root, patched.uniq)
    Pod::UI.puts "ML Kit arm64 simulator slices: #{patched.uniq.sort.join(', ')}" if defined?(Pod::UI)
  end

  # Flips LC_BUILD_VERSION from iOS to iOS Simulator in a thin slice: either
  # one prelinked object or a BSD ar archive of objects (walked in place;
  # sizes do not change, so the archive's symbol table stays valid).
  def self.patch_archive(path)
    data = File.binread(path)
    if data.byteslice(0, 4).unpack1('V') == MH_MAGIC_64
      patch_object(data, 0)
      File.binwrite(path, data)
      return
    end
    raise "#{path}: neither a Mach-O object nor an ar archive" unless data.start_with?("!<arch>\n")
    pos = 8
    while pos + 60 <= data.bytesize
      header = data.byteslice(pos, 60)
      ident = header[0, 16].strip
      size = header[48, 10].to_i
      body = pos + 60
      if ident.start_with?('#1/')
        name_len = ident[3..].to_i
        member = body + name_len
        member_size = size - name_len
      else
        member = body
        member_size = size
      end
      patch_object(data, member) if member_size >= 32 && data.byteslice(member, 4).unpack1('V') == MH_MAGIC_64
      pos = body + size
      pos += 1 if pos.odd?
    end
    File.binwrite(path, data)
  end

  def self.patch_object(data, base)
    ncmds = data.byteslice(base + 16, 4).unpack1('V')
    off = base + 32
    ncmds.times do
      cmd, cmdsize = data.byteslice(off, 8).unpack('VV')
      if cmd == LC_VERSION_MIN_IPHONEOS
        raise 'object uses LC_VERSION_MIN_IPHONEOS; cannot retag it in place'
      elsif cmd == LC_BUILD_VERSION
        platform = data.byteslice(off + 8, 4).unpack1('V')
        data[off + 8, 4] = [PLATFORM_IOS_SIMULATOR].pack('V') if platform == PLATFORM_IOS
      end
      off += cmdsize
    end
  end

  # Pods xcconfigs name "${PODS_ROOT}/<pod>/Frameworks"; send simulator builds
  # to the patched copy and stop excluding arm64 there.
  def self.rewrite_xcconfigs(pods_root, pods)
    Dir.glob(File.join(pods_root, 'Target Support Files', '*', '*.xcconfig')).each do |file|
      text = File.read(file)
      new_text = text.gsub(EXCLUDE_LINE, '')
      pods.each do |pod|
        new_text = new_text.gsub("\"${PODS_ROOT}/#{pod}/Frameworks\"", "\"${PODS_ROOT}/#{pod}/$(MLKIT_FRAMEWORKS_DIR)\"")
      end
      next if new_text == text
      unless new_text.include?('MLKIT_FRAMEWORKS_DIR =')
        new_text += "MLKIT_FRAMEWORKS_DIR = Frameworks\nMLKIT_FRAMEWORKS_DIR[sdk=iphonesimulator*] = #{SIM_DIR}\n"
      end
      File.write(file, new_text)
    end
  end
end
