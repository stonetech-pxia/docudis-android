import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../anonymize/providers.dart';
import '../anonymize/shared_input.dart';
import '../anonymize/ui/history_page.dart';
import '../anonymize/ui/protect_page.dart';
import '../l10n/app_localizations.dart';
import '../theme/clay_widgets.dart';
import 'account_page.dart';

/// App shell, no sign-in: Protect / History / Account behind a bottom bar.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Answer the text-selection menu from the app's own engine while it runs.
    ref.watch(processTextProvider);
    // A share from another app goes to the Protect tab, which anonymizes it
    // at once.
    ref.listen(sharedInputProvider, (_, shared) {
      if (shared == null || ref.read(processControllerProvider).isLoading) {
        return;
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (_index != 0) setState(() => _index = 0);
    });
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const ProtectPage(),
          const HistoryPage(),
          const AccountPage(),
        ],
      ),
      bottomNavigationBar: ClayNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
        items: [
          (Icons.verified_user_outlined, l10n.anonymizeTitle),
          (Icons.history_rounded, l10n.historyTitle),
          (Icons.person_outline_rounded, l10n.navAccount),
        ],
      ),
    );
  }
}
