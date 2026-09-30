import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/clay_theme.dart';
import '../../theme/clay_widgets.dart';
import '../input/input_source.dart';
import '../input/text_extractor.dart';
import '../providers.dart';
import '../shared_input.dart';
import 'anonymize_messages.dart';
import 'native_paste_button.dart';
import 'result_page.dart';

/// Shortens [text] for the staged preview: the whole text when it is short,
/// otherwise the first [headChars] characters, an ellipsis, and the last
/// [tailWords] words (or the last 20 characters for text without spaces).
String compactPreview(String text, {int headChars = 150, int tailWords = 6}) {
  final flat = text.trim();
  if (flat.length <= headChars + 40) return flat;
  var head = flat.substring(0, headChars);
  final cut = head.lastIndexOf(RegExp(r'\s'));
  if (cut > headChars ~/ 2) head = head.substring(0, cut);
  final words = flat.split(RegExp(r'\s+'));
  var tail = words.length > tailWords
      ? words.sublist(words.length - tailWords).join(' ')
      : '';
  if (tail.isEmpty || tail.length > 60) tail = flat.substring(flat.length - 20);
  return '${head.trimRight()} … $tail';
}

IconData fileIcon(String extension) => switch (extension) {
  'pdf' => Icons.picture_as_pdf_outlined,
  'doc' || 'docx' => Icons.description_outlined,
  'txt' || 'md' || 'csv' || 'text' || 'log' => Icons.article_outlined,
  'jpg' || 'jpeg' || 'png' || 'webp' || 'heic' || 'bmp' => Icons.image_outlined,
  _ => Icons.insert_drive_file_outlined,
};

enum _Entry { paste, file, photo }

/// Home tab: a headline, then the three ways in, with "paste" as the
/// primary one. Picking an input stages it on the page (preview, cancel,
/// anonymize) while the other entries shrink to chips. What another app
/// shares goes straight to the result.
class ProtectPage extends ConsumerStatefulWidget {
  const ProtectPage({super.key, @visibleForTesting this.initialStaged});

  final InputSource? initialStaged;

  @override
  ConsumerState<ProtectPage> createState() => _ProtectPageState();
}

class _ProtectPageState extends ConsumerState<ProtectPage> {
  late InputSource? _staged = widget.initialStaged;

  @override
  void initState() {
    super.initState();
    // Copy + load the NER model now so the first run is as fast as the rest.
    ref.read(anonymizeServiceProvider).warmUp();
  }

  Future<void> _confirm() async {
    final source = _staged;
    if (source == null) return;
    final l10n = AppLocalizations.of(context);
    unawaited(showClayProgressDialog(context, l10n.processing));
    final id = await ref.read(processControllerProvider.notifier).run(source);
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (id == null) {
      final err = ref.read(processControllerProvider).error;
      if (err != null) showSnack(context, processErrorMessage(l10n, err));
      return;
    }
    setState(() => _staged = null);
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ResultPage(recordId: id)));
  }

  void _cancel() => setState(() => _staged = null);

  Future<void> _pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    _stageText(data?.text);
  }

  /// Stages pasted text, from the clipboard read above or from the iOS
  /// system paste button.
  void _stageText(String? text) {
    if (ref.read(processControllerProvider).isLoading) return;
    if (text == null || text.trim().isEmpty) {
      showSnack(context, AppLocalizations.of(context).clipboardEmpty);
      return;
    }
    setState(() => _staged = TextInput(text));
  }

  /// Anonymizes what another app shared at once: the user already picked
  /// it over there. Dropped while a run is in progress.
  void _takeShared(InputSource source) {
    Future.microtask(ref.read(sharedInputProvider.notifier).taken);
    if (ref.read(processControllerProvider).isLoading) return;
    if (source is FileInput) {
      if (!TextExtractor.pickableExtensions.contains(source.extension)) {
        showSnack(
          context,
          processErrorMessage(
            AppLocalizations.of(context),
            const UnsupportedInputException('extension'),
          ),
        );
        return;
      }
    }
    setState(() => _staged = source);
    // Staged first, so a failed run leaves the input on the page with the
    // reason. Started after HomePage has closed open pages and switched to
    // this tab: it hears the same share, before or after this listener.
    Future.microtask(() {
      if (mounted) unawaited(_confirm());
    });
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: TextExtractor.pickableExtensions,
    );
    if (picked == null || !mounted) return;
    var path = picked.path;
    if (path == null) {
      // content:// URI: copy into our cache so extractors get a real file.
      final tmp = await getTemporaryDirectory();
      final file = File(p.join(tmp.path, picked.name));
      await file.writeAsBytes(await picked.readAsBytes(), flush: true);
      path = file.path;
    }
    if (!mounted) return;
    setState(() => _staged = FileInput(path: path!, name: picked.name));
  }

  /// "Scan a photo": take one with the camera or pick one from the library.
  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null || !mounted) return;
    final photo = await ImagePicker().pickImage(source: source);
    if (photo == null || !mounted) return;
    // Library files come with meaningless names ("image_picker_<uuid>.jpg",
    // "3548.jpg"), so both are named by the time they came in.
    final at = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    setState(
      () => _staged = CameraInput(
        path: photo.path,
        name: '$at${p.extension(photo.path)}',
      ),
    );
  }

  VoidCallback _action(_Entry e) => switch (e) {
    _Entry.paste => _pasteText,
    _Entry.file => _pickFile,
    _Entry.photo => _pickPhoto,
  };

  ({IconData icon, Color color, String title}) _look(
    _Entry e,
    AppLocalizations l10n,
  ) => switch (e) {
    _Entry.paste => (
      icon: Icons.content_paste_rounded,
      color: Clay.primary,
      title: l10n.inputPasteText,
    ),
    _Entry.file => (
      icon: Icons.upload_file_outlined,
      color: Clay.secondary,
      title: l10n.inputPickFile,
    ),
    _Entry.photo => (
      icon: Icons.photo_camera_outlined,
      color: Clay.tertiary,
      title: l10n.inputTakePhoto,
    ),
  };

  @override
  Widget build(BuildContext context) {
    ref.listen(sharedInputProvider, (_, shared) {
      if (shared != null) _takeShared(shared);
    });
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(processControllerProvider).isLoading;
    final staged = _staged;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeHeadline,
          style: Clay.heading(27, letterSpacing: -0.54, height: 1.18),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 15,
              color: Clay.secondaryText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.homeCaption,
                style: Clay.body(
                  14,
                  weight: FontWeight.w500,
                  color: Clay.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final stagedPaste = staged is TextInput;
    final stagedOther = staged is FileInput || staged is CameraInput;
    final paste = _look(_Entry.paste, l10n);
    final file = _look(_Entry.file, l10n);
    final photo = _look(_Entry.photo, l10n);
    final current = switch (staged) {
      null => null,
      TextInput() => _Entry.paste,
      FileInput() => _Entry.file,
      CameraInput() => _Entry.photo,
    };
    final Widget? preview = switch (staged) {
      null => null,
      TextInput(:final text) => _TextPreview(text),
      FileInput() => _FilePreview(staged),
      CameraInput() => _PhotoPreview(staged),
    };

    // Four slots that grow and shrink together: the paste card (which
    // morphs into its staged form), the two secondary cards, a staged card
    // for a file or photo, and the chips for the entries not in use.
    final entries = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClayReveal(
          visible: staged == null || stagedPaste,
          child: _PasteCard(
            icon: paste.icon,
            title: paste.title,
            preview: stagedPaste ? preview : null,
            confirmLabel: l10n.anonymizeButton,
            onTap: busy ? null : _pasteText,
            onPasted: _stageText,
            onConfirm: busy ? null : _confirm,
            onCancel: _cancel,
          ),
        ),
        ClayReveal(
          visible: staged == null,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _SecondaryCard(
                          icon: file.icon,
                          color: file.color,
                          title: file.title,
                          onTap: busy ? null : _pickFile,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryCard(
                          icon: photo.icon,
                          color: photo.color,
                          title: photo.title,
                          onTap: busy ? null : _pickPhoto,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ClayReveal(
          visible: stagedOther,
          child: stagedOther && current != null && preview != null
              ? _StagedCard(
                  icon: _look(current, l10n).icon,
                  color: _look(current, l10n).color,
                  preview: preview,
                  confirmLabel: l10n.anonymizeButton,
                  onConfirm: busy ? null : _confirm,
                  onCancel: _cancel,
                )
              : null,
        ),
        ClayReveal(
          visible: staged != null,
          child: current == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      for (final e in _Entry.values)
                        if (e == _Entry.paste &&
                            e != current &&
                            NativePasteButton.isSupported)
                          _NativePasteChip(onText: _stageText)
                        else if (e != current)
                          _EntryChip(
                            icon: _look(e, l10n).icon,
                            label: _look(e, l10n).title,
                            onTap: busy ? null : _action(e),
                          ),
                    ],
                  ),
                ),
        ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(bottom: -110, right: -90, child: _Blob()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
              // Headline and cards form one block, centred on the screen.
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [header, const SizedBox(height: 32), entries],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The organic sand-coloured shape behind the cards.
class _Blob extends StatelessWidget {
  const _Blob();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: Clay.blob,
      borderRadius: BorderRadius.only(
        topLeft: Radius.elliptical(150, 120),
        topRight: Radius.elliptical(130, 110),
        bottomRight: Radius.elliptical(150, 120),
        bottomLeft: Radius.elliptical(130, 110),
      ),
    ),
    child: SizedBox(width: 280, height: 230),
  );
}

/// Paste text: the main path, a filled terracotta card. With a [preview]
/// it morphs in place into its staged form: cream, cancel cross, preview,
/// Anonymize button. On iOS the unstaged card is the system paste button
/// ([NativePasteButton]) filling the card, so pasting asks no permission.
class _PasteCard extends StatelessWidget {
  const _PasteCard({
    required this.icon,
    required this.title,
    required this.preview,
    required this.confirmLabel,
    required this.onTap,
    required this.onPasted,
    required this.onConfirm,
    required this.onCancel,
  });

  /// The Flutter card's height: 18 padding above and below the icon tile.
  static const _nativeHeight = 18 + 46 + 18.0;

  final IconData icon;
  final String title;
  final Widget? preview;
  final String confirmLabel;
  final VoidCallback? onTap;
  final ValueChanged<String> onPasted;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = this.preview;
    final staged = preview != null;
    final native = !staged && NativePasteButton.isSupported;
    return ClayCard(
      color: staged ? Clay.surface : Clay.primary,
      padding: native ? EdgeInsets.zero : const EdgeInsets.all(18),
      onTap: staged || native ? null : onTap,
      child: AnimatedSize(
        duration: Clay.motion,
        curve: Clay.motionCurve,
        alignment: Alignment.topCenter,
        child: native
            ? SizedBox(
                height: _nativeHeight,
                child: NativePasteButton(
                  onText: onPasted,
                  foreground: Colors.white,
                  background: Clay.primary,
                  cornerRadius: Clay.radius,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ClayIconTile(
                        icon: icon,
                        color: staged ? Clay.primary : const Color(0x33FFFFFF),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: staged ? 0 : 1,
                          duration: Clay.motion,
                          curve: Clay.motionCurve,
                          child: Text(
                            title,
                            style: Clay.heading(
                              18,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Clay.motion,
                        switchInCurve: Clay.motionCurve,
                        switchOutCurve: Clay.motionCurve,
                        child: staged
                            ? _RoundAction(
                                key: const ValueKey('cancel'),
                                icon: Icons.close_rounded,
                                background: Clay.divider,
                                foreground: Clay.inkMuted,
                                tooltip: l10n.cancel,
                                onTap: onCancel,
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                key: ValueKey('go'),
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ],
                  ),
                  if (preview != null)
                    _StagedBody(
                      preview: preview,
                      confirmLabel: confirmLabel,
                      onConfirm: onConfirm,
                    ),
                ],
              ),
      ),
    );
  }
}

/// Upload / scan: half-width cream cards, icon above the label.
class _SecondaryCard extends StatelessWidget {
  const _SecondaryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ClayCard(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClayIconTile(icon: icon, color: color, size: 42),
        const SizedBox(height: 14),
        Text(
          title,
          maxLines: 2,
          style: Clay.heading(15, weight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// A staged file or photo: icon, cancel, preview, Anonymize button.
class _StagedCard extends StatelessWidget {
  const _StagedCard({
    required this.icon,
    required this.color,
    required this.preview,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  final IconData icon;
  final Color color;
  final Widget preview;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClayIconTile(icon: icon, color: color),
              const Spacer(),
              _RoundAction(
                icon: Icons.close_rounded,
                background: Clay.divider,
                foreground: Clay.inkMuted,
                tooltip: l10n.cancel,
                onTap: onCancel,
              ),
            ],
          ),
          _StagedBody(
            preview: preview,
            confirmLabel: confirmLabel,
            onConfirm: onConfirm,
          ),
        ],
      ),
    );
  }
}

/// Preview (at most twice a card's height) and the Anonymize button,
/// sliding down into place when they appear.
class _StagedBody extends StatelessWidget {
  const _StagedBody({
    required this.preview,
    required this.confirmLabel,
    required this.onConfirm,
  });

  static const _cardHeight = 82.0;

  final Widget preview;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Clay.motion,
    curve: Clay.motionCurve,
    builder: (_, t, child) => Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * -12),
        child: child,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: _cardHeight * 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Clay.bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: preview,
        ),
        const SizedBox(height: 14),
        FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
      ],
    ),
  );
}

/// iOS: the paste chip is the system paste button, dressed like the other
/// chips (label and font stay the system's). Fixed width: the control
/// reports no size, and its label can only be "Paste", "Coller" or "粘贴"
/// (CFBundleLocalizations), which all fit.
class _NativePasteChip extends StatelessWidget {
  const _NativePasteChip({required this.onText});

  final ValueChanged<String> onText;

  @override
  Widget build(BuildContext context) => Container(
    width: 100,
    height: 40,
    decoration: BoxDecoration(
      border: Border.all(color: Clay.divider),
      borderRadius: BorderRadius.circular(999),
    ),
    child: NativePasteButton(
      onText: onText,
      foreground: Clay.inkMuted,
      background: Clay.surface,
    ),
  );
}

/// The entries not in use while one is staged.
class _EntryChip extends StatelessWidget {
  const _EntryChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ClayPressScale(
    scale: 0.95,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Clay.surface,
            border: Border.all(color: Clay.divider),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Clay.inkCaption),
              const SizedBox(width: 8),
              Text(
                label,
                style: Clay.body(
                  13,
                  weight: FontWeight.w700,
                  color: Clay.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: foreground),
        ),
      ),
    ),
  );
}

class _TextPreview extends StatelessWidget {
  const _TextPreview(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    compactPreview(text),
    maxLines: 6,
    overflow: TextOverflow.ellipsis,
    style: Clay.body(14, color: Clay.inkMuted, height: 1.45),
  );
}

class _FilePreview extends StatelessWidget {
  const _FilePreview(this.input);

  final FileInput input;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(fileIcon(input.extension), size: 30, color: Clay.secondary),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          input.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Clay.body(14, weight: FontWeight.w500),
        ),
      ),
    ],
  );
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview(this.input);

  final CameraInput input;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(input.path),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.image_outlined, size: 30, color: Clay.tertiary),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          input.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Clay.body(14, weight: FontWeight.w500),
        ),
      ),
    ],
  );
}

/// Camera or photo library; returns the chosen source.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (source, icon, label) in [
              (ImageSource.camera, Icons.photo_camera_outlined, l10n.photoFromCamera),
              (ImageSource.gallery, Icons.photo_library_outlined, l10n.photoFromLibrary),
            ])
              ListTile(
                leading: Icon(icon, color: Clay.ink),
                title: Text(label, style: Clay.body(15, weight: FontWeight.w500)),
                shape: shape,
                onTap: () => Navigator.of(context).pop(source),
              ),
          ],
        ),
      ),
    );
  }
}
