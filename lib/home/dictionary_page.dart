import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../anonymize/manual_blocks.dart';
import '../anonymize/providers.dart';
import '../l10n/app_localizations.dart';
import '../theme/clay_theme.dart';
import '../theme/clay_widgets.dart';

/// Adds [term] to [list]. Returns true when the operation completes.
Future<bool> _addToList(TermListNotifier list, String term) async {
  await list.add(term);
  return true;
}

Future<bool> _addTerm(WidgetRef ref, String term) =>
    _addToList(ref.read(dictionaryProvider.notifier), term);

/// Switches "Hide only this list"; it goes on only once the user has read
/// what stays visible.
Future<void> _setListOnly(BuildContext context, WidgetRef ref, bool on) async {
  if (on) {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(l10n.listOnlyConfirmTitle),
        content: Text(l10n.listOnlyConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.listOnlyConfirmAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  await ref.read(listOnlyProvider.notifier).set(on);
}

/// The custom dictionary, opened from the Account tab: a field to type what
/// is always hidden (the user's own name, company, address), the list, the
/// "Hide only this list" switch (locked while the list is empty), and under
/// it a few pieces of text the user hid by hand lately, one tap away from
/// being added. "All" opens the full list.
class DictionaryPage extends ConsumerWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final terms = ref.watch(dictionaryProvider).value ?? const <String>[];
    final suggested = mostRepeated(
      ref.watch(manualBlocksProvider).value ?? const <ManualBlock>[],
    );
    final dictionary = ref.read(dictionaryProvider.notifier);

    return ClayPage(
      title: l10n.dictionaryTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            l10n.dictionaryHint,
            style: Clay.body(14, color: Clay.inkMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          _TermField(
            hint: l10n.dictionaryInputHint,
            onAdd: (term) => _addTerm(ref, term),
          ),
          const SizedBox(height: 16),
          if (terms.isEmpty && suggested.isEmpty) ...[
            Text(
              l10n.dictionaryEmpty,
              style: Clay.body(14, color: Clay.inkCaption),
            ),
            const SizedBox(height: 16),
          ],
          if (terms.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in terms)
                  _TermChip(
                    label: term,
                    icon: Icons.close_rounded,
                    semanticLabel: l10n.dictionaryRemove(term),
                    color: Clay.primaryTint,
                    foreground: Clay.primaryPressed,
                    onTap: () => dictionary.remove(term),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _ListOnlySwitch(
            value: ref.watch(listOnlyProvider) && terms.isNotEmpty,
            onChanged: terms.isEmpty
                ? null
                : (on) => _setListOnly(context, ref, on),
          ),
          if (suggested.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ClayLabel(l10n.dictionarySuggested)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ManualBlocksPage(),
                    ),
                  ),
                  child: Text(l10n.dictionarySeeAll),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final block in suggested)
                  _TermChip(
                    label: block.value,
                    icon: Icons.add_rounded,
                    semanticLabel: l10n.dictionaryAdd(block.value),
                    color: Clay.surface,
                    foreground: Clay.ink,
                    outlined: true,
                    onTap: () => _addTerm(ref, block.value),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Never hide", opened from the Account tab: public names the detectors
/// take for private ones (a council, a bank, a brand), typed in or picked
/// from what the user showed again by hand lately. Applied from the next
/// run on (see [NeverHide]).
class NeverHidePage extends ConsumerWidget {
  const NeverHidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final terms = ref.watch(neverHideProvider).value ?? const <String>[];
    final suggested = mostRepeated(
      ref.watch(revealedBlocksProvider).value ?? const <ManualBlock>[],
      limit: 8,
    );
    final list = ref.read(neverHideProvider.notifier);
    Future<bool> add(String term) => _addToList(list, term);

    return ClayPage(
      title: l10n.neverHideTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            l10n.neverHideHint,
            style: Clay.body(14, color: Clay.inkMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          _TermField(hint: l10n.neverHideInputHint, onAdd: add),
          const SizedBox(height: 16),
          if (terms.isEmpty && suggested.isEmpty)
            Text(
              l10n.neverHideEmpty,
              style: Clay.body(14, color: Clay.inkCaption),
            ),
          if (terms.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in terms)
                  _TermChip(
                    label: term,
                    icon: Icons.close_rounded,
                    semanticLabel: l10n.neverHideRemove(term),
                    color: Clay.secondaryTint,
                    foreground: Clay.secondaryText,
                    onTap: () => list.remove(term),
                  ),
              ],
            ),
          if (suggested.isNotEmpty) ...[
            if (terms.isNotEmpty) const SizedBox(height: 20),
            ClayLabel(l10n.neverHideSuggested),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final block in suggested)
                  _TermChip(
                    label: block.value,
                    icon: Icons.add_rounded,
                    semanticLabel: l10n.neverHideAdd(block.value),
                    color: Clay.surface,
                    foreground: Clay.ink,
                    outlined: true,
                    onTap: () => add(block.value),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Up to [maxManualBlocks] pieces of text hidden by hand, most recent first.
/// A tap adds the line to the dictionary, which takes it off the list.
class ManualBlocksPage extends ConsumerWidget {
  const ManualBlocksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recent =
        ref.watch(manualBlocksProvider).value ?? const <ManualBlock>[];
    return ClayPage(
      title: l10n.dictionaryAllTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            recent.isEmpty
                ? l10n.dictionaryAllEmpty
                : l10n.dictionaryAllHint(maxManualBlocks),
            style: Clay.body(14, color: Clay.inkMuted, height: 1.5),
          ),
          const SizedBox(height: 16),
          for (final block in recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClayCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                shadow: false,
                border: Border.all(color: Clay.divider),
                onTap: () => _addTerm(ref, block.value),
                child: Semantics(
                  button: true,
                  label: l10n.dictionaryAdd(block.value),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          block.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Clay.body(15, weight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: Clay.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Hide only this list" and what it does; greyed out, with a line saying
/// why, while the list is empty ([onChanged] null).
class _ListOnlySwitch extends StatelessWidget {
  const _ListOnlySwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.listOnlyTitle,
                  style: Clay.body(
                    15,
                    weight: FontWeight.w600,
                    color: enabled ? Clay.ink : Clay.inkPlaceholder,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled ? l10n.listOnlyHint : l10n.listOnlyNeedsWords,
                  style: Clay.body(13, color: Clay.inkCaption, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Types a term in and clears the field once it is in the dictionary.
class _TermField extends StatefulWidget {
  const _TermField({required this.hint, required this.onAdd});

  final String hint;
  final Future<bool> Function(String term) onAdd;

  @override
  State<_TermField> createState() => _TermFieldState();
}

class _TermFieldState extends State<_TermField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final term = _controller.text.trim();
    if (term.isEmpty) return;
    if (await widget.onAdd(term) && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: widget.hint),
            onSubmitted: (_) => _add(),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(onPressed: _add, child: Text(l10n.dictionaryAddButton)),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({
    required this.label,
    required this.icon,
    required this.semanticLabel,
    required this.color,
    required this.foreground,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final String semanticLabel;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    excludeSemantics: true,
    child: ClayPressScale(
      child: Material(
        color: color,
        shape: StadiumBorder(
          side: outlined
              ? const BorderSide(color: Clay.divider)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Clay.body(
                      14,
                      weight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: foreground),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
