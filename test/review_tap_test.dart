// The review page is meant to work with one gesture: tap plain text to hide
// it, tap a placeholder to bring the value back. These tests drive real taps
// at real glyph positions and check what would be written to the record.
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/providers.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis/anonymize/ui/review_page.dart';
import 'package:docudis/l10n/app_localizations.dart';
import 'package:docudis/theme/clay_theme.dart';
import 'package:docudis/theme/clay_widgets.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _original = 'Please call Sarah Meyer at 06 12 34 56 78 about the invoice.';

final _phone = Detection(
  type: EntityType.phone,
  value: '06 12 34 56 78',
  start: _original.indexOf('06 12'),
  end: _original.indexOf('06 12') + '06 12 34 56 78'.length,
  confidence: 0.95,
  detector: 'test',
  source: DetectionSource.strongRule,
);

/// An invoice line as a fresh run leaves it: the name hidden, the amount and
/// the date found but switched off, the date of birth hidden.
const _invoice = 'Sarah Meyer, born 3 May 1987, owes €4,200 and €150 by 12 March 2026.';

Detection _found(String value, EntityType type, {bool enabled = true}) => Detection(
      type: type,
      value: value,
      start: _invoice.indexOf(value),
      end: _invoice.indexOf(value) + value.length,
      confidence: 0.9,
      detector: 'test',
      source: DetectionSource.strongRule,
      enabled: enabled,
    );

final _invoiceDetections = [
  _found('Sarah Meyer', EntityType.person),
  _found('3 May 1987', EntityType.birthDate),
  _found('€4,200', EntityType.amount, enabled: false),
  _found('€150', EntityType.amount, enabled: false),
  _found('12 March 2026', EntityType.date, enabled: false),
];

/// Keeps the record in memory and remembers what the page asked to save.
class _FakeService extends AnonymizeService {
  _FakeService({this.original = _original, List<Detection>? detections})
      : detections = detections ?? [_phone],
        super(
          store: RecordStore(),
          extractor: TextExtractor(),
          modelLocator: ModelLocator(),
          dictionaryTerms: () async => const [],
          neverHideTerms: () async => const [],
          listOnly: () => false,
        );

  final String original;
  List<Detection> detections;
  List<Detection>? saved;

  /// The stored map; a save numbers from it, as the real reapply does.
  PlaceholderMap? map;

  @override
  Future<void> warmUp() async {}

  @override
  Future<RecordDetail> reapply(String id, List<Detection> next) async {
    saved = next;
    detections = next;
    map = anonymize(original, next, previous: map).map;
    return detail;
  }

  RecordDetail get detail {
    final result = anonymize(original, detections, previous: map);
    map ??= result.map;
    return RecordDetail(
      record: AnonymizationRecord(
        id: 'r1',
        createdAt: DateTime(2026, 9, 17),
        updatedAt: DateTime(2026, 9, 17),
        kind: InputKind.text,
        sourceName: null,
        outputFileName: 'docudis.txt',
        detectionCount: detections.where((d) => d.enabled).length,
        preview: result.text,
      ),
      original: original,
      output: result.text,
      detections: detections,
      map: result.map,
      outputPath: 'unused',
    );
  }
}

void main() {
  late _FakeService service;

  Future<void> pumpPage(WidgetTester tester, {_FakeService? fake}) async {
    service = fake ?? _FakeService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          anonymizeServiceProvider.overrideWithValue(service),
          recordDetailProvider.overrideWith((ref, id) async => service.detail),
        ],
        child: MaterialApp(
          theme: clayTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReviewPage(recordId: 'r1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The document as it is painted right now: the longest text in the card.
  RenderParagraph paragraph(WidgetTester tester) => tester
      .renderObjectList<RenderParagraph>(find.descendant(
        of: find.byType(ClayDocumentCard),
        matching: find.byType(RichText),
      ))
      .reduce(
            (a, b) => a.text.toPlainText().length >= b.text.toPlainText().length
                ? a
                : b,
          );

  String rendered(WidgetTester tester) => paragraph(tester).text.toPlainText();

  /// Taps the middle of the glyph at [index] of the painted text.
  Future<void> tapCharacter(WidgetTester tester, int index) async {
    final p = paragraph(tester);
    final box = p.getBoxesForSelection(
      TextSelection(baseOffset: index, extentOffset: index + 1),
    );
    await tester.tapAt(p.localToGlobal(box.first.toRect().center));
    await tester.pumpAndSettle();
  }

  testWidgets('what the detector found is shown as its placeholder',
      (tester) async {
    await pumpPage(tester);
    expect(
      rendered(tester),
      'Please call Sarah Meyer at [PHONE_1] about the invoice.',
    );
  });

  testWidgets('tapping a name hides the whole name', (tester) async {
    await pumpPage(tester);
    await tapCharacter(tester, rendered(tester).indexOf('Meyer') + 2);

    expect(
      rendered(tester),
      'Please call [CUSTOM_1] at [PHONE_1] about the invoice.',
    );
    final added = service.saved!.where((d) => d.type == EntityType.custom);
    expect(added.map((d) => d.value), ['Sarah Meyer']);
  });

  testWidgets('tapping a placeholder brings the value back', (tester) async {
    await pumpPage(tester);
    await tapCharacter(tester, rendered(tester).indexOf('[PHONE_1]') + 3);

    expect(
      rendered(tester),
      'Please call Sarah Meyer at 06 12 34 56 78 about the invoice.',
    );
    expect(service.saved!.where((d) => d.enabled), isEmpty);
  });

  testWidgets('tapping it again hides it once more', (tester) async {
    await pumpPage(tester);
    await tapCharacter(tester, rendered(tester).indexOf('[PHONE_1]') + 3);
    await tapCharacter(tester, rendered(tester).indexOf('06 12') + 3);

    expect(
      rendered(tester),
      'Please call Sarah Meyer at [PHONE_1] about the invoice.',
    );
  });

  group('hide-all switches', () {
    Future<void> pumpInvoice(WidgetTester tester) => pumpPage(tester,
        fake: _FakeService(original: _invoice, detections: _invoiceDetections));

    Finder switchFor(String label) => find.descendant(
          of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
          matching: find.byType(Switch),
        );

    bool isOn(WidgetTester tester, String label) => tester.widget<Switch>(switchFor(label)).value;

    testWidgets('are not shown for a document without amounts or dates', (tester) async {
      await pumpPage(tester);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('start off, with amounts and dates readable', (tester) async {
      await pumpInvoice(tester);
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes €4,200 and €150 by 12 March 2026.');
      expect(isOn(tester, 'Hide all amounts'), isFalse);
      expect(isOn(tester, 'Hide all dates'), isFalse);
    });

    testWidgets('hide every amount, then show them again', (tester) async {
      await pumpInvoice(tester);
      await tester.tap(switchFor('Hide all amounts'));
      await tester.pumpAndSettle();
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes [AMOUNT_1] and [AMOUNT_2] by 12 March 2026.');
      expect(isOn(tester, 'Hide all amounts'), isTrue);
      expect(service.saved!.where((d) => d.type == EntityType.amount).every((d) => d.enabled), isTrue);

      await tester.tap(switchFor('Hide all amounts'));
      await tester.pumpAndSettle();
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes €4,200 and €150 by 12 March 2026.');
    });

    testWidgets('showing all dates leaves the date of birth hidden', (tester) async {
      await pumpInvoice(tester);
      await tester.tap(switchFor('Hide all dates'));
      await tester.pumpAndSettle();
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes €4,200 and €150 by [DATE_1].');
      await tester.tap(switchFor('Hide all dates'));
      await tester.pumpAndSettle();
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes €4,200 and €150 by 12 March 2026.');
    });

    testWidgets('bringing one amount back by hand turns the switch off', (tester) async {
      await pumpInvoice(tester);
      await tester.tap(switchFor('Hide all amounts'));
      await tester.pumpAndSettle();
      await tapCharacter(tester, rendered(tester).indexOf('[AMOUNT_2]') + 3);
      expect(rendered(tester),
          '[PERSON_1], born [BIRTH_DATE_1], owes [AMOUNT_1] and €150 by 12 March 2026.');
      expect(isOn(tester, 'Hide all amounts'), isFalse);
    });
  });

  testWidgets('a dictionary term can be brought back in this document', (tester) async {
    final term = Detection(
      type: EntityType.custom,
      value: 'Sarah Meyer',
      start: _original.indexOf('Sarah'),
      end: _original.indexOf('Sarah') + 'Sarah Meyer'.length,
      confidence: 1,
      detector: 'dictionary',
      source: DetectionSource.dictionary,
    );
    await pumpPage(tester, fake: _FakeService(detections: [term, _phone]));
    expect(rendered(tester), 'Please call [CUSTOM_1] at [PHONE_1] about the invoice.');

    await tapCharacter(tester, rendered(tester).indexOf('[CUSTOM_1]') + 3);
    expect(rendered(tester), 'Please call Sarah Meyer at [PHONE_1] about the invoice.');
    expect(service.saved!.singleWhere((d) => d.source == DetectionSource.dictionary).enabled, isFalse);
  });

  testWidgets('an ordinary word can be hidden on its own', (tester) async {
    await pumpPage(tester);
    await tapCharacter(tester, rendered(tester).indexOf('invoice') + 3);

    expect(
      rendered(tester),
      'Please call Sarah Meyer at [PHONE_1] about the [CUSTOM_1].',
    );
  });

  testWidgets('bringing one name back leaves the others their placeholders', (tester) async {
    const text = 'Marco Bianchi met Sophie Janssens and Luc Peeters.';
    Detection person(String value) => Detection(
          type: EntityType.person,
          value: value,
          start: text.indexOf(value),
          end: text.indexOf(value) + value.length,
          confidence: 0.9,
          detector: 'test',
          source: DetectionSource.model,
        );
    await pumpPage(tester,
        fake: _FakeService(
          original: text,
          detections: [person('Marco Bianchi'), person('Sophie Janssens'), person('Luc Peeters')],
        ));
    expect(rendered(tester), '[PERSON_1] met [PERSON_2] and [PERSON_3].');

    await tapCharacter(tester, rendered(tester).indexOf('[PERSON_1]') + 3);
    expect(rendered(tester), 'Marco Bianchi met [PERSON_2] and [PERSON_3].');
    expect(service.detail.output, rendered(tester));

    await tapCharacter(tester, rendered(tester).indexOf('Marco') + 2);
    expect(rendered(tester), '[PERSON_1] met [PERSON_2] and [PERSON_3].');
  });
}
