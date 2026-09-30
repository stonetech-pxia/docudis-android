// History is where a record is found again: by a name that says what it is,
// a date written the reader's way, and a menu to rename or delete it.
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/history_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Records in memory; only what History calls.
class _MemoryStore extends RecordStore {
  _MemoryStore(this.records);

  final List<AnonymizationRecord> records;

  @override
  Future<List<AnonymizationRecord>> list() async => List.of(records);

  @override
  Future<void> rename(String id, String title) async {
    final i = records.indexWhere((r) => r.id == id);
    final r = records[i];
    records[i] = AnonymizationRecord(
      id: r.id,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      kind: r.kind,
      sourceName: r.sourceName,
      outputFileName: r.outputFileName,
      detectionCount: r.detectionCount,
      preview: r.preview,
      title: title,
    );
  }

  @override
  Future<void> delete(String id) async => records.removeWhere((r) => r.id == id);
}

AnonymizationRecord _record(String id, {String? title, String? sourceName}) => AnonymizationRecord(
      id: id,
      createdAt: DateTime(2026, 9, 24, 12, 19),
      updatedAt: DateTime(2026, 9, 24, 12, 19),
      kind: sourceName == null ? InputKind.text : InputKind.file,
      sourceName: sourceName,
      outputFileName: 'docudis-20260924-1219.txt',
      detectionCount: 12,
      preview: 'From: [PERSON_1] <[EMAIL_1]> Subject: Re: Deposit - [ADDRESS_1]',
      title: title,
    );

void main() {
  late _MemoryStore store;

  setUpAll(initializeDateFormatting);

  Future<void> pumpHistory(WidgetTester tester, {Locale? locale}) async {
    store = _MemoryStore([
      _record('thread', title: 'From: Priya Nandakumar <priya.n@example.com>'),
      _record('quote', sourceName: 'Firth_quote_Q-2026-0918.docx'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [recordStoreProvider.overrideWithValue(store)],
        child: MaterialApp(
          theme: clayTheme(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HistoryPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String action, {int row = 0}) async {
    await tester.tap(find.byTooltip('More').at(row));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action).last);
    await tester.pumpAndSettle();
  }

  testWidgets('pasted text goes by its first line, a document by its file', (tester) async {
    await pumpHistory(tester);
    expect(find.text('From: Priya Nandakumar <priya.n@example.com>'), findsOneWidget);
    expect(find.text('Firth_quote_Q-2026-0918.docx'), findsOneWidget);
    expect(find.textContaining('docudis-'), findsNothing);
  });

  testWidgets('a record can be renamed', (tester) async {
    await pumpHistory(tester);
    await open(tester, 'Rename');
    await tester.enterText(find.byType(TextField), 'Priya – deposit, flat 2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Priya – deposit, flat 2'), findsOneWidget);
    expect(store.records.first.title, 'Priya – deposit, flat 2');
  });

  testWidgets('one record can be deleted, after a confirmation', (tester) async {
    await pumpHistory(tester);
    await open(tester, 'Delete', row: 1);
    expect(find.text('Delete this record and its restore key?'), findsOneWidget);
    expect(find.text('Firth_quote_Q-2026-0918.docx\n9/24/2026 12:19'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Firth_quote_Q-2026-0918.docx'), findsNothing);
    expect(find.text('From: Priya Nandakumar <priya.n@example.com>'), findsOneWidget);
    expect(store.records.map((r) => r.id), ['thread']);
  });

  testWidgets('dates follow the phone region: day first on a UK phone', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'GB');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await pumpHistory(tester, locale: const Locale('en'));
    expect(find.textContaining('24/09/2026 12:19'), findsNWidgets(2));
  });

  testWidgets('and the interface language when the phone speaks another one', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('zh', 'CN');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await pumpHistory(tester, locale: const Locale('es'));
    expect(find.textContaining('24/9/2026 12:19'), findsNWidgets(2));
  });
}
