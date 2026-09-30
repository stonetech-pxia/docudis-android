// The custom dictionary's suggestions are read back from the stored records:
// what the user hid by hand, most recent document first.
import 'dart:io';

import 'package:docudis/anonymize/manual_blocks.dart';
import 'package:docudis/anonymize/storage/anonymization_record.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Detection _hit(
  String text,
  String value, {
  DetectionSource source = DetectionSource.manual,
  bool enabled = true,
  EntityType type = EntityType.custom,
}) =>
    Detection(
      type: type,
      value: value,
      start: text.indexOf(value),
      end: text.indexOf(value) + value.length,
      confidence: 1,
      detector: 'test',
      source: source,
      enabled: enabled,
    );

void main() {
  late Directory root;
  late RecordStore store;

  setUp(() {
    root = Directory.systemTemp.createTempSync('docudis_manual_blocks');
    store = RecordStore(root: root);
  });

  tearDown(() => root.deleteSync(recursive: true));

  /// Saves a record updated on day [day] of September 2026.
  Future<void> save(int day, String text, List<Detection> detections) {
    final at = DateTime(2026, 9, day);
    final result = anonymize(text, detections);
    return store.save(
      record: AnonymizationRecord(
        id: 'r$day',
        createdAt: at,
        updatedAt: at,
        kind: InputKind.text,
        sourceName: null,
        outputFileName: 'r$day.txt',
        detectionCount: detections.length,
        preview: result.text,
      ),
      original: text,
      output: result.text,
      detections: detections,
      map: result.map,
    );
  }

  Future<List<(String, int)>> blocks({List<String> dictionary = const [], int limit = 100}) async => [
        for (final b in await recentManualBlocks(store, dictionary: dictionary, limit: limit))
          (b.value, b.documents),
      ];

  test('most recent document first, one entry per text, counted per document', () async {
    const old = 'Acme Ltd wrote to Sarah Meyer. Sarah Meyer replied.';
    await save(1, old, [_hit(old, 'Acme Ltd'), _hit(old, 'Sarah Meyer')]);
    const recent = 'Invoice for SARAH MEYER, Rue Haute';
    await save(2, recent, [_hit(recent, 'SARAH MEYER'), _hit(recent, 'Rue Haute')]);

    expect(await blocks(), [('SARAH MEYER', 2), ('Rue Haute', 1), ('Acme Ltd', 1)]);
  });

  test('only what is still hidden by hand counts', () async {
    const text = 'Sarah Meyer, Acme Ltd, Rue Haute';
    await save(1, text, [
      _hit(text, 'Sarah Meyer', source: DetectionSource.model),
      _hit(text, 'Acme Ltd', enabled: false),
      _hit(text, 'Rue Haute'),
    ]);
    expect(await blocks(), [('Rue Haute', 1)]);
  });

  test('dictionary terms and text too short to be a safe term are left out', () async {
    const text = 'Li and 张三 met Sarah Meyer at Acme Ltd';
    await save(1, text, [
      _hit(text, 'Li'),
      _hit(text, '张三'),
      _hit(text, 'Sarah Meyer'),
      _hit(text, 'Acme Ltd'),
    ]);
    expect(await blocks(dictionary: ['sarah meyer']), [('张三', 1), ('Acme Ltd', 1)]);
  });

  test('a block that spans a line break becomes a one-line term', () async {
    const text = 'at 12 rue de\nla Paix';
    await save(1, text, [_hit(text, '12 rue de\nla Paix')]);
    expect(await blocks(), [('12 rue de la Paix', 1)]);
  });

  test('stops at the limit', () async {
    const text = 'alpha bravo charlie';
    await save(1, text, [_hit(text, 'alpha'), _hit(text, 'bravo'), _hit(text, 'charlie')]);
    expect(await blocks(limit: 2), [('alpha', 1), ('bravo', 1)]);
  });

  test('mostRepeated puts forward what was hidden in the most documents', () {
    const recent = [
      ManualBlock(value: 'once, lately', documents: 1),
      ManualBlock(value: 'three times', documents: 3),
      ManualBlock(value: 'once, before', documents: 1),
      ManualBlock(value: 'twice', documents: 2),
    ];
    expect(
      mostRepeated(recent, limit: 3).map((b) => b.value),
      ['three times', 'twice', 'once, lately'],
    );
  });

  group('what the never-hide list suggests', () {
    Future<List<String>> revealed({List<String> neverHide = const []}) async => [
          for (final b in await recentRevealed(store, neverHide: neverHide)) b.value,
        ];

    test('names found and then shown again by hand, most recent first', () async {
      const old = 'Leeds City Council wrote to Tom Ashworth about DPS.';
      await save(1, old, [
        _hit(old, 'Leeds City Council', source: DetectionSource.model, enabled: false, type: EntityType.address),
        _hit(old, 'Tom Ashworth', source: DetectionSource.model, type: EntityType.person),
      ]);
      const recent = 'DPS holds the deposit; Leeds City Council is copied.';
      await save(2, recent, [
        _hit(recent, 'DPS', source: DetectionSource.model, enabled: false, type: EntityType.company),
        _hit(recent, 'Leeds City Council', source: DetectionSource.propagated, enabled: false, type: EntityType.address),
      ]);

      expect(await revealed(), ['DPS', 'Leeds City Council']);
    });

    test('amounts and dates are readable by default, and own choices do not count', () async {
      const text = '€1,300 on 3 May 2026 for Ashworth Lettings, see Bogus Brand';
      await save(1, text, [
        _hit(text, '€1,300', source: DetectionSource.strongRule, enabled: false, type: EntityType.amount),
        _hit(text, '3 May 2026', source: DetectionSource.strongRule, enabled: false, type: EntityType.date),
        _hit(text, 'Ashworth Lettings', source: DetectionSource.dictionary, enabled: false),
        _hit(text, 'Bogus Brand', enabled: false),
      ]);
      expect(await revealed(), isEmpty);
    });

    test('what is already on the list is not suggested again', () async {
      const text = 'Leeds City Council';
      await save(1, text, [
        _hit(text, 'Leeds City Council', source: DetectionSource.model, enabled: false, type: EntityType.address),
      ]);
      expect(await revealed(neverHide: ['leeds city council']), isEmpty);
    });
  });
}
