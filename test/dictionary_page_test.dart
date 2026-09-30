// The custom dictionary page: it starts empty, takes the user's own details
// typed in, suggests what was hidden by hand, and one tap moves a suggestion
// into the dictionary. "Hide only this list" is locked while the list is
// empty and says what stays visible before it goes on.
import 'package:docudis/anonymize/manual_blocks.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/home/dictionary_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/preferences.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the dictionary in memory instead of `dictionary.json`.
class _MemoryDictionary extends DictionaryNotifier {
  _MemoryDictionary(this.terms);

  List<String> terms;

  @override
  Future<List<String>> read() async => terms;

  @override
  Future<void> write(List<String> next) async => terms = next;
}

class _MemoryNeverHide extends NeverHideNotifier {
  _MemoryNeverHide(this.terms);

  List<String> terms;

  @override
  Future<List<String>> read() async => terms;

  @override
  Future<void> write(List<String> next) async => terms = next;
}

void main() {
  late _MemoryDictionary dictionary;
  late SharedPreferences prefs;

  Future<void> pumpPage(
    WidgetTester tester, {
    List<String> terms = const [],
    List<ManualBlock> hiddenByHand = const [],
    bool listOnly = false,
  }) async {
    dictionary = _MemoryDictionary(terms);
    SharedPreferences.setMockInitialValues({if (listOnly) 'list_only': true});
    prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          dictionaryProvider.overrideWith(() => dictionary),
          manualBlocksProvider.overrideWith((ref) async {
            final known = await ref.watch(dictionaryProvider.future);
            return hiddenByHand.where((b) => !known.contains(b.value)).toList();
          }),
        ],
        child: MaterialApp(
          theme: clayTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DictionaryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const byHand = [
    ManualBlock(value: 'Rue Haute', documents: 1),
    ManualBlock(value: 'Sarah Meyer', documents: 2),
  ];

  testWidgets('starts empty and says where suggestions will come from', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.textContaining('Nothing yet'), findsOneWidget);
    expect(find.text('All'), findsNothing);
  });

  testWidgets('suggests what was hidden by hand, the most repeated first', (
    tester,
  ) async {
    await pumpPage(tester, hiddenByHand: byHand);
    expect(find.textContaining('Nothing yet'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Sarah Meyer')).dx,
      lessThan(tester.getTopLeft(find.text('Rue Haute')).dx),
    );
  });

  testWidgets('one tap moves a suggestion into the dictionary', (tester) async {
    await pumpPage(tester, hiddenByHand: byHand);
    await tester.tap(find.bySemanticsLabel('Always hide Sarah Meyer'));
    await tester.pumpAndSettle();

    expect(dictionary.terms, ['Sarah Meyer']);
    expect(find.bySemanticsLabel('Always hide Sarah Meyer'), findsNothing);
    expect(find.bySemanticsLabel('Stop hiding Sarah Meyer'), findsOneWidget);
  });

  testWidgets('the user types their own details in once', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), '  Ashworth Lettings Ltd ');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(dictionary.terms, ['Ashworth Lettings Ltd']);
    expect(
      find.bySemanticsLabel('Stop hiding Ashworth Lettings Ltd'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('an empty field adds nothing', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(dictionary.terms, isEmpty);
  });

  testWidgets('a term can be taken out again', (tester) async {
    await pumpPage(tester, terms: ['Sarah Meyer'], hiddenByHand: byHand);
    // Alone on its line, the chip shares its semantics node with the list
    // item, which is as wide as the page: tap the chip itself.
    await tester.tap(find.text('Sarah Meyer'));
    await tester.pumpAndSettle();

    expect(dictionary.terms, isEmpty);
    expect(find.bySemanticsLabel('Always hide Sarah Meyer'), findsOneWidget);
  });

  testWidgets('"All" lists every block and adds one with a tap', (
    tester,
  ) async {
    final many = [
      for (var i = 1; i <= 8; i++) ManualBlock(value: 'Name $i', documents: 1),
    ];
    await pumpPage(tester, hiddenByHand: many);
    expect(
      find.text('Name 8'),
      findsNothing,
      reason: 'the page puts only a few forward',
    );

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Hidden by hand'), findsOneWidget);
    expect(find.text('Name 8'), findsOneWidget);

    await tester.tap(find.text('Name 8'));
    await tester.pumpAndSettle();
    expect(dictionary.terms, ['Name 8']);
    expect(find.text('Name 8'), findsNothing);
  });

  group('hide only this list', () {
    Switch listOnlySwitch(WidgetTester tester) =>
        tester.widget<Switch>(find.byType(Switch));

    testWidgets('is off, and locked while the list is empty', (tester) async {
      await pumpPage(tester);
      expect(listOnlySwitch(tester).value, isFalse);
      expect(listOnlySwitch(tester).onChanged, isNull);
      expect(find.text('Add a word to the list first.'), findsOneWidget);
    });

    testWidgets(
      'says what stays visible before it goes on; Cancel leaves it off',
      (tester) async {
        await pumpPage(tester, terms: ['Tariq Al-Masri']);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text('Hide only this list?'), findsOneWidget);
        expect(find.textContaining('other spellings do'), findsOneWidget);
        expect(find.textContaining("other people's names"), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(listOnlySwitch(tester).value, isFalse);
        expect(prefs.getBool('list_only'), isNull);
      },
    );

    testWidgets('goes on once confirmed, and stays on', (tester) async {
      await pumpPage(tester, terms: ['Tariq Al-Masri']);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide only my list'));
      await tester.pumpAndSettle();
      expect(listOnlySwitch(tester).value, isTrue);
      expect(prefs.getBool('list_only'), isTrue);
    });

    testWidgets('taking the last word off switches it off', (tester) async {
      await pumpPage(tester, terms: ['Sarah Meyer'], listOnly: true);
      expect(listOnlySwitch(tester).value, isTrue);

      await tester.tap(find.text('Sarah Meyer'));
      await tester.pumpAndSettle();
      expect(listOnlySwitch(tester).value, isFalse);
      expect(listOnlySwitch(tester).onChanged, isNull);
      expect(prefs.getBool('list_only'), isFalse);
    });

    testWidgets('a word added to an empty list does not bring it back', (
      tester,
    ) async {
      // What a restored backup leaves: the switch, without the list.
      await pumpPage(tester, listOnly: true);
      await tester.enterText(find.byType(TextField), 'Sarah Meyer');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(dictionary.terms, ['Sarah Meyer']);
      expect(listOnlySwitch(tester).value, isFalse);
      expect(prefs.getBool('list_only'), isFalse);
    });
  });

  group('never hide', () {
    late _MemoryNeverHide neverHide;

    Future<void> pumpNeverHide(
      WidgetTester tester, {
      List<ManualBlock> shownByHand = const [],
    }) async {
      neverHide = _MemoryNeverHide([]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            neverHideProvider.overrideWith(() => neverHide),
            revealedBlocksProvider.overrideWith((ref) async {
              final known = await ref.watch(neverHideProvider.future);
              return shownByHand
                  .where((b) => !known.contains(b.value))
                  .toList();
            }),
          ],
          child: MaterialApp(
            theme: clayTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const NeverHidePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('starts empty and says where suggestions will come from', (
      tester,
    ) async {
      await pumpNeverHide(tester);
      expect(
        find.text(
          'Nothing yet. Names you show again by hand will be suggested here.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a public name is typed in once', (tester) async {
      await pumpNeverHide(tester);
      await tester.enterText(find.byType(TextField), 'Leeds City Council');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(neverHide.terms, ['Leeds City Council']);
      expect(
        find.bySemanticsLabel('Hide Leeds City Council again'),
        findsOneWidget,
      );
    });

    testWidgets(
      'what was shown again by hand is one tap away, and can be taken off',
      (tester) async {
        await pumpNeverHide(
          tester,
          shownByHand: const [
            ManualBlock(value: 'DPS', documents: 3),
            ManualBlock(value: 'Worcester Bosch', documents: 1),
          ],
        );
        expect(find.text('SHOWN AGAIN BY HAND LATELY'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Never hide DPS'));
        await tester.pumpAndSettle();
        expect(neverHide.terms, ['DPS']);

        await tester.tap(find.text('DPS'));
        await tester.pumpAndSettle();
        expect(neverHide.terms, isEmpty);
      },
    );
  });
}
