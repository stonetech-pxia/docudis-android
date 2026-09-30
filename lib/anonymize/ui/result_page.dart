import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../../theme/clay_theme.dart';
import '../../theme/clay_widgets.dart';
import '../ai_apps.dart';
import '../providers.dart';
import '../storage/anonymization_record.dart';
import 'anonymize_messages.dart';
import 'highlights.dart';
import 'restore_page.dart';
import 'review_page.dart';

/// "Protected copy": the anonymized text ready to hand to an AI app, and a
/// look at the original. The pencil opens [ReviewPage] to change what is
/// hidden; the restore icon opens [RestorePage] for the AI's reply.
///
/// Hidden for now: per-record delete.
class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key, required this.recordId});

  final String recordId;

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(recordDetailProvider(widget.recordId));
    final loaded = detail.value;

    return ClayPage(
      title: l10n.resultTitle,
      actions: [
        ClayIconButton(
          icon: Icons.edit_outlined,
          tooltip: l10n.reviewTitle,
          onPressed: loaded == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReviewPage(recordId: widget.recordId),
                  ),
                ),
          color: loaded == null ? Clay.inkPlaceholder : Clay.ink,
        ),
        ClayIconButton(
          icon: Icons.settings_backup_restore_rounded,
          tooltip: l10n.restoreTitle,
          onPressed: loaded == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => RestorePage(recordId: widget.recordId),
                  ),
                ),
          color: loaded == null ? Clay.inkPlaceholder : Clay.ink,
        ),
      ],
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            ClaySegmented(
              labels: [l10n.tabAnonymized, l10n.tabOriginal],
              index: _showOriginal ? 1 : 0,
              onChanged: (i) => setState(() => _showOriginal = i == 1),
            ),
            const SizedBox(height: 16),
            if (!_showOriginal) ...[
              ClaySuccessBanner(
                text: l10n.resultBanner(d.record.detectionCount),
              ),
              const SizedBox(height: 16),
            ],
            if (d.record.listOnly) ...[
              ClayWarningNote(text: l10n.resultListOnlyNote),
              const SizedBox(height: 16),
            ],
            if (d.image case final image?) ...[
              _ImageCard(
                path: _showOriginal ? image.sourcePath : image.redactedPath,
                version: d.record.updatedAt,
              ),
              const SizedBox(height: 16),
            ],
            ClayDocumentCard(
              caption: d.record.displayName,
              trailing: Text(
                l10n.detectionCount(d.record.detectionCount),
                style: Clay.body(12, color: Clay.inkPlaceholder),
              ),
              child: SelectableText.rich(
                _showOriginal
                    ? HighlightedText.detections(
                        d.original,
                        d.detections.where((x) => x.enabled).toList(),
                      ).span
                    : HighlightedText.placeholders(d.output),
              ),
            ),
          ],
        ),
      ),
      bottom: loaded == null ? null : _Actions(detail: loaded),
    );
  }
}

/// The photo, or its painted-over copy. The copy is rewritten in place after
/// every edit, so the cached decode is dropped whenever the record changes.
class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.path, required this.version});

  final String path;
  final DateTime version;

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    FileImage(file).evict();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        file,
        key: ValueKey('$path@$version'),
        cacheWidth: 1200,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// "Send to" logos, then copy / share as two small matching buttons. Only
/// installed AI apps are offered; with none, the "Send to" row is left out.
class _Actions extends ConsumerWidget {
  const _Actions({required this.detail});

  final RecordDetail detail;

  /// A photo or a document with a redacted copy, as opposed to plain text.
  bool get _hasFile =>
      detail.image != null || detail.document?.redactedPath != null;

  /// What goes out, as a copy named for the reader ("匿名化文本.txt"), since
  /// receiving apps show the file's own name: the redacted file of a photo,
  /// PDF or Word document when [asFile], else the text.
  Future<({String path, String name, String mimeType})> _sharedFile(
    AppLocalizations l10n, {
    required bool asFile,
  }) async {
    final out = switch (detail) {
      RecordDetail(image: final image?) when asFile => (
        source: image.redactedPath,
        name: '${l10n.sharedImageName}.png',
        mimeType: 'image/png',
      ),
      RecordDetail(
        document: RecordDocument(:final kind, redactedPath: final path?),
      )
          when asFile =>
        (
          source: path,
          name: '${l10n.sharedDocumentName}.${kind.extension}',
          mimeType: kind.mimeType,
        ),
      _ => (
        source: detail.outputPath,
        name: '${l10n.sharedFileName}.txt',
        mimeType: 'text/plain',
      ),
    };
    final file = File(p.join(p.dirname(detail.outputPath), 'share', out.name));
    await file.parent.create(recursive: true);
    await File(out.source).copy(file.path);
    return (path: file.path, name: out.name, mimeType: out.mimeType);
  }

  /// AI apps get the redacted file when the input produced one, otherwise
  /// they get the anonymized text.
  Future<void> _send(BuildContext context, WidgetRef ref, AiApp app) async {
    final l10n = AppLocalizations.of(context);
    final file = await _sharedFile(l10n, asFile: _hasFile);
    await ref
        .read(aiAppServiceProvider)
        .sendFile(app, file.path, file.name, mimeType: file.mimeType);
  }

  Future<void> _pickOther(
    BuildContext context,
    WidgetRef ref,
    List<AiApp> apps,
  ) async {
    final app = await showModalBottomSheet<AiApp>(
      context: context,
      builder: (_) => _OtherAppsSheet(apps: apps),
    );
    if (app != null && context.mounted) await _send(context, ref, app);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final share = ref.read(shareServiceProvider);
    final installed = ref.watch(installedAiAppsProvider).value ?? const [];
    final featured = installed.where((a) => a.featured).toList();
    final others = installed.where((a) => !a.featured).toList();
    final small = OutlinedButton.styleFrom(
      minimumSize: const Size(0, Clay.tapTarget),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: Clay.heading(14, weight: FontWeight.w600),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (installed.isNotEmpty) ...[
          Row(
            children: [
              Text(
                l10n.sendToLabel,
                style: Clay.body(
                  13,
                  weight: FontWeight.w700,
                  color: Clay.inkCaption,
                ),
              ),
              const SizedBox(width: 12),
              for (final app in featured) ...[
                _LogoButton(app: app, onTap: () => _send(context, ref, app)),
                const SizedBox(width: 10),
              ],
              if (others.isNotEmpty)
                ClayPressScale(
                  scale: 0.95,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickOther(context, ref, others),
                    style: small,
                    icon: const Icon(Icons.apps_rounded, size: 18),
                    label: Text(l10n.otherApps),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await share.copy(detail.output);
                  if (context.mounted) showSnack(context, l10n.copied);
                },
                style: small,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(l10n.copyText),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await _sharedFile(l10n, asFile: _hasFile);
                  await share.shareFile(
                    file.path,
                    file.name,
                    mimeType: file.mimeType,
                  );
                },
                style: small,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: Text(l10n.shareFile),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Brand logo from `assets/ai_logos`, tinted when the glyph is mono.
class AiAppLogo extends StatelessWidget {
  const AiAppLogo({super.key, required this.app, this.size = 22});

  final AiApp app;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    app.logoAsset,
    width: size,
    height: size,
    colorFilter: app.monoLogo
        ? const ColorFilter.mode(Clay.ink, BlendMode.srcIn)
        : null,
  );
}

/// 44px round button with an app logo.
class _LogoButton extends StatelessWidget {
  const _LogoButton({required this.app, required this.onTap});

  final AiApp app;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: AppLocalizations.of(context).sendTo(app.label),
    child: ClayPressScale(
      scale: 0.92,
      child: Material(
        color: Clay.surface,
        shape: const CircleBorder(
          side: BorderSide(color: Clay.divider, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: Clay.tapTarget,
            height: Clay.tapTarget,
            child: Center(child: AiAppLogo(app: app)),
          ),
        ),
      ),
    ),
  );
}

/// The installed non-featured apps; returns the chosen one.
class _OtherAppsSheet extends StatelessWidget {
  const _OtherAppsSheet({required this.apps});

  final List<AiApp> apps;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l10n.otherAppsTitle,
              style: Clay.heading(17, weight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              children: [
                for (final app in apps)
                  ListTile(
                    leading: AiAppLogo(app: app, size: 28),
                    title: Text(
                      app.label,
                      style: Clay.body(15, weight: FontWeight.w500),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onTap: () => Navigator.of(context).pop(app),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
