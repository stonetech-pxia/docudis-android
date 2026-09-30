import Flutter
import Foundation

/// iOS side of the `model_assets` channel (Android: MainActivity.kt).
///
/// The NER model is copied into the app bundle under `models/` by the
/// "Bundle NER model" build phase, from assets/models. Asset names are the
/// same as on Android (`models/xlmr_ner_docudis/model.json`), so
/// ModelLocator does not know which platform it runs on.
enum ModelAssets {
  private static let queue = DispatchQueue(label: "com.stonetech.docudis.model_assets", qos: .utility)

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.stonetech.docudis/model_assets", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard let args = call.arguments as? [String: Any],
            let asset = args["asset"] as? String else {
        result(FlutterError(code: "bad_args", message: "asset is required", details: nil))
        return
      }
      let source = url(for: asset)
      switch call.method {
      case "length":
        let size = (try? FileManager.default.attributesOfItem(atPath: source.path)[.size] as? NSNumber)?.int64Value
        result(size ?? -1)
      case "readString":
        do {
          result(try String(contentsOf: source, encoding: .utf8))
        } catch {
          result(FlutterError(code: "not_found", message: error.localizedDescription, details: nil))
        }
      // Copies asset -> dest off the main thread, through dest.part and a
      // rename so a present file is complete. On APFS the copy is a clone,
      // so the 278 MB model does not take its size twice.
      case "copy":
        guard let dest = args["dest"] as? String else {
          result(FlutterError(code: "bad_args", message: "dest is required", details: nil))
          return
        }
        queue.async {
          do {
            let fm = FileManager.default
            let target = URL(fileURLWithPath: dest)
            let part = URL(fileURLWithPath: dest + ".part")
            try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? fm.removeItem(at: part)
            try fm.copyItem(at: source, to: part)
            try? fm.removeItem(at: target)
            try fm.moveItem(at: part, to: target)
            let size = (try fm.attributesOfItem(atPath: target.path)[.size] as? NSNumber)?.int64Value ?? -1
            DispatchQueue.main.async { result(size) }
          } catch {
            DispatchQueue.main.async {
              result(FlutterError(code: "copy_failed", message: error.localizedDescription, details: nil))
            }
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func url(for asset: String) -> URL {
    Bundle.main.resourceURL!.appendingPathComponent(asset)
  }
}
