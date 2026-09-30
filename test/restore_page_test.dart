// Restore puts real values back with one record's key. A reply to another
// document must not come back filled with this document's names.
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/restore_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A record whose [values] were hidden in [original], in that order.
RecordDetail _record(String id, String name, String original, List<(String, EntityType)> values) {
  final detections = [
    for (final (value, type) in values)
      Detection(
        type: type,
        value: value,
        start: original.indexOf(value),
        end: original.indexOf(value) + value.length,
        confidence: 0.9,
        detector: 'test',
        source: DetectionSource.model,
      ),
  ];
  final result = anonymize(original, detections);
  return RecordDetail(
    record: AnonymizationRecord(
      id: id,
      createdAt: DateTime(2026, 9, 24, 0, 54),
      updatedAt: DateTime(2026, 9, 24, 0, 54),
      kind: InputKind.text,
      sourceName: name,
      outputFileName: '$name-anonymized.txt',
      detectionCount: detections.length,
      preview: result.text,
    ),
    original: original,
    output: result.text,
    detections: detections,
    map: result.map,
    outputPath: 'unused',
  );
}

final _detail = _record(
  'r1',
  'client_email.txt',
  'Julien Roussel from Studio Verbena SAS disputes invoice FAC-042 for the logo redesign.',
  [('Julien Roussel', EntityType.person), ('Studio Verbena SAS', EntityType.company)],
);

/// Another record with the same labels: a tenancy deposit dispute.
final _deposit = _record(
  'r2',
  'deposit_dispute.txt',
  'Dear Donna Keel, Harrow Lettings still holds the deposit for the flat; the check-in '
      'inventory shows the carpet marks were already there.',
  [('Donna Keel', EntityType.person), ('Harrow Lettings', EntityType.company)],
);

final _records = {'r1': _detail, 'r2': _deposit};

class _FakeService extends AnonymizeService {
  _FakeService()
      : super(
          store: RecordStore(),
          extractor: TextExtractor(),
          modelLocator: ModelLocator(),
          dictionaryTerms: () async => const [],
          neverHideTerms: () async => const [],
          listOnly: () => false,
        );

  @override
  Future<void> warmUp() async {}

  @override
  Future<String> restore(String id, String text) async => _records[id]!.map.restore(text);
}

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          anonymizeServiceProvider.overrideWithValue(_FakeService()),
          recordDetailProvider.overrideWith((ref, id) async => _records[id]!),
          recordsProvider.overrideWith((ref) async => [for (final d in _records.values) d.record]),
          replyMatcherProvider.overrideWith((ref) async => ReplyMatcher({
                for (final MapEntry(:key, :value) in _records.entries)
                  key: ReplyCandidate(output: value.output, map: value.map),
              })),
        ],
        child: MaterialApp(
          theme: clayTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RestorePage(recordId: 'r1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> reply(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('names the document whose key it uses', (tester) async {
    await pumpPage(tester);
    expect(find.text('client_email.txt'), findsOneWidget);
  });

  testWidgets('a reply to this document is restored', (tester) async {
    await pumpPage(tester);
    await reply(tester, 'Dear [PERSON_1], [COMPANY_1] will pay.');

    expect(find.text("This reply doesn't fit this document"), findsNothing);
    expect(find.text('Copy restored text'), findsOneWidget);
  });

  testWidgets('a reply with labels this document never used is held back', (tester) async {
    await pumpPage(tester);
    await reply(tester, 'Dear [PERSON_1], your number [ID_1] and IBAN [IBAN_1].');

    expect(find.text("This reply doesn't fit this document"), findsOneWidget);
    expect(find.textContaining('[ID_1], [IBAN_1]'), findsOneWidget);
    expect(find.textContaining('Julien Roussel'), findsNothing);
    expect(find.text('Copy restored text'), findsNothing);

    await tester.tap(find.text('Show anyway'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Julien Roussel'), findsOneWidget);
    expect(find.text('Copy restored text'), findsOneWidget);
    expect(find.text('Not in this document, left as is: [ID_1], [IBAN_1]'), findsOneWidget);
  });

  testWidgets('editing the reply asks again', (tester) async {
    await pumpPage(tester);
    await reply(tester, 'Dear [PERSON_1], see [ID_1].');
    await tester.tap(find.text('Show anyway'));
    await tester.pumpAndSettle();

    await reply(tester, 'Dear [PERSON_1], see [ID_1] and [ID_2].');
    expect(find.text("This reply doesn't fit this document"), findsOneWidget);
  });

  testWidgets('a label the AI made up is noted, not held back', (tester) async {
    await pumpPage(tester);
    await reply(tester, 'Dear [PERSON_1], [COMPANY_1] will pay. Cc [PERSON_2].');

    expect(find.text("This reply doesn't fit this document"), findsNothing);
    expect(find.textContaining('Julien Roussel'), findsOneWidget);
    expect(find.text('Not in this document, left as is: [PERSON_2]'), findsOneWidget);
    expect(find.text('Copy restored text'), findsOneWidget);
  });

  testWidgets('a reply to another document is held back, and can be restored with it', (tester) async {
    await pumpPage(tester);
    await reply(
      tester,
      'Dear [PERSON_1], I have checked the check-in inventory again: the carpet marks were '
      'already there, so [COMPANY_1] should return the whole deposit for the flat.',
    );

    expect(find.text('This reply seems to be for another document'), findsOneWidget);
    expect(find.textContaining('deposit_dispute.txt'), findsOneWidget);
    expect(find.textContaining('Julien Roussel'), findsNothing);
    expect(find.text('Copy restored text'), findsNothing);

    await tester.tap(find.text('Restore with that document'));
    await tester.pumpAndSettle();
    expect(find.text('deposit_dispute.txt'), findsOneWidget, reason: 'the document row follows');
    expect(find.textContaining('Donna Keel'), findsOneWidget);
    expect(find.text('This reply seems to be for another document'), findsNothing);
    expect(find.text('Copy restored text'), findsOneWidget);
  });

  testWidgets('shown anyway, a reply to another document keeps its warning', (tester) async {
    await pumpPage(tester);
    await reply(
      tester,
      'Dear [PERSON_1], I have checked the check-in inventory again: the carpet marks were '
      'already there, so [COMPANY_1] should return the whole deposit for the flat.',
    );
    await tester.tap(find.text('Show anyway'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Julien Roussel'), findsOneWidget);
    expect(
      find.text("Restored with this document's key, although the reply fits “deposit_dispute.txt” better."),
      findsOneWidget,
    );
  });
}
