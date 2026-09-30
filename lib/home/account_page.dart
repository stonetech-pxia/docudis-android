import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../anonymize/anonymize_service.dart';
import '../anonymize/providers.dart';
import '../anonymize/ui/anonymize_messages.dart';
import '../l10n/app_localizations.dart';
import '../theme/clay_theme.dart';
import '../theme/clay_widgets.dart';
import 'app_locale.dart';
import 'dictionary_page.dart';

const privacyPolicyUrl =
    'https://stonetech-pxia.github.io/docudis-site/privacy/';
const contactEmail = 'stonetechdigital@gmail.com';

final _versionProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Account tab: the "Always hide" and "Never hide" lists, the interface
/// language, the on-device data control, then the privacy policy and a
/// contact address, and the app version at the bottom.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  /// Opens [uri] outside the app; with nothing to open it, copies [fallback].
  Future<void> _open(BuildContext context, Uri uri, String fallback) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      opened = false;
    }
    if (opened || !context.mounted) return;
    await Clipboard.setData(ClipboardData(text: fallback));
    if (context.mounted) {
      showSnack(context, AppLocalizations.of(context).copied);
    }
  }

  Future<void> _clearData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clearDataAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(anonymizeServiceProvider).clearLocalData();
    ref.invalidate(recordsProvider);
    if (context.mounted) showSnack(context, l10n.dataCleared);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<({Locale? locale})>(
      context: context,
      builder: (_) => _LanguageSheet(current: ref.read(appLocaleProvider)),
    );
    if (picked != null) {
      await ref.read(appLocaleProvider.notifier).set(picked.locale);
    }
  }

  String _terms(
    AppLocalizations l10n,
    int words,
    int suggestions, {
    required String empty,
  }) {
    if (words == 0 && suggestions == 0) return empty;
    if (suggestions == 0) return l10n.dictionaryWords(words);
    return '${l10n.dictionaryWords(words)} · ${l10n.dictionarySuggestions(suggestions)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final words = ref.watch(dictionaryProvider).value?.length ?? 0;
    final suggestions = ref.watch(manualBlocksProvider).value?.length ?? 0;
    final shownWords = ref.watch(neverHideProvider).value?.length ?? 0;
    final shownSuggestions =
        ref.watch(revealedBlocksProvider).value?.length ?? 0;
    return ClayPage(
      title: l10n.navAccount,
      showBack: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _AccountRow(
            icon: Icons.visibility_off_outlined,
            color: Clay.primaryTint,
            foreground: Clay.primary,
            title: l10n.dictionaryTitle,
            caption: ref.watch(listOnlyProvider) && words > 0
                ? '${l10n.dictionaryWords(words)} · ${l10n.listOnlyCaption}'
                : _terms(l10n, words, suggestions, empty: l10n.dictionaryEmpty),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DictionaryPage()),
            ),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.visibility_outlined,
            color: Clay.secondaryTint,
            foreground: Clay.secondaryText,
            title: l10n.neverHideTitle,
            caption: _terms(
              l10n,
              shownWords,
              shownSuggestions,
              empty: l10n.neverHideEmpty,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NeverHidePage()),
            ),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.translate_rounded,
            color: Clay.secondaryTint,
            foreground: Clay.secondaryText,
            title: l10n.languageTitle,
            caption:
                _languageName(ref.watch(appLocaleProvider)) ??
                l10n.languageSystem,
            onTap: () => _pickLanguage(context, ref),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.delete_sweep_outlined,
            color: Clay.tertiaryTint,
            foreground: Clay.tertiary,
            title: l10n.clearData,
            caption: l10n.clearDataHint(AnonymizeService.maxRecords),
            chevron: false,
            onTap: () => _clearData(context, ref),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.privacy_tip_outlined,
            color: Clay.secondaryTint,
            foreground: Clay.secondaryText,
            title: l10n.privacyPolicy,
            caption: l10n.privacyPolicyHint,
            onTap: () =>
                _open(context, Uri.parse(privacyPolicyUrl), privacyPolicyUrl),
          ),
          const SizedBox(height: 16),
          _AccountRow(
            icon: Icons.mail_outline_rounded,
            color: Clay.primaryTint,
            foreground: Clay.primary,
            title: l10n.contactUs,
            caption: contactEmail,
            onTap: () => _open(
              context,
              Uri(scheme: 'mailto', path: contactEmail),
              contactEmail,
            ),
          ),
          if (ref.watch(_versionProvider).value case final info?) ...[
            const SizedBox(height: 20),
            Text(
              l10n.appVersion(info.version, info.buildNumber),
              textAlign: TextAlign.center,
              style: Clay.body(12, color: Clay.inkPlaceholder),
            ),
          ],
        ],
      ),
    );
  }
}

/// Each language by its own name, so it can be found from any other.
const _languages = [
  (Locale('en'), 'English'),
  (Locale('es'), 'Español'),
  (Locale('fr'), 'Français'),
  (Locale('zh'), '中文'),
];

String? _languageName(Locale? locale) {
  for (final (l, name) in _languages) {
    if (l == locale) return name;
  }
  return null;
}

/// "System default" first, then the languages; the current one is ticked.
class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.current});

  final Locale? current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (locale, label) in [
              (null, l10n.languageSystem),
              ..._languages,
            ])
              ListTile(
                title: Text(
                  label,
                  style: Clay.body(15, weight: FontWeight.w500),
                ),
                trailing: locale == current
                    ? const Icon(Icons.check_rounded, color: Clay.primary)
                    : null,
                shape: shape,
                onTap: () => Navigator.of(context).pop((locale: locale)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Icon tile, title, one caption; a chevron when the row opens something.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.color,
    required this.foreground,
    required this.title,
    required this.caption,
    required this.onTap,
    this.chevron = true,
  });

  final IconData icon;
  final Color color;
  final Color foreground;
  final String title;
  final String caption;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) => ClayCard(
    padding: const EdgeInsets.all(16),
    onTap: onTap,
    child: Row(
      children: [
        ClayIconTile(icon: icon, color: color, foreground: foreground),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Clay.heading(15, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(caption, style: Clay.body(13, color: Clay.inkCaption)),
            ],
          ),
        ),
        if (chevron && onTap != null) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: Clay.inkPlaceholder,
          ),
        ],
      ],
    ),
  );
}
