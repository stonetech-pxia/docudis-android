import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// Returns the same detections for any text.
class _Fixed implements Detector {
  _Fixed(this.found);

  final List<Detection> found;

  @override
  String get name => 'fixed';

  @override
  Future<List<Detection>> detect(String text) async => found;
}

Detection _at(String text, String value, EntityType type,
        {DetectionSource source = DetectionSource.model, int from = 0}) =>
    Detection(
      type: type,
      value: value,
      start: text.indexOf(value, from),
      end: text.indexOf(value, from) + value.length,
      confidence: 0.9,
      detector: 'test',
      source: source,
    );

Future<List<String>> _hidden(String text, List<Detection> found, List<String> neverHide) async => [
      for (final d in await DetectionPipeline([_Fixed(found)], neverHide: neverHide).run(text))
        if (d.enabled) d.value,
    ];

void main() {
  test('a public name on the list stays readable, the rest is hidden', () async {
    const bill = 'Account holder: Tom Ashworth. Leeds City Council collects the charge.';
    final found = [
      _at(bill, 'Leeds City Council', EntityType.address),
      _at(bill, 'Tom Ashworth', EntityType.person),
    ];
    expect(await _hidden(bill, found, ['Leeds City Council']), ['Tom Ashworth']);
    expect(await _hidden(bill, found, []), ['Tom Ashworth', 'Leeds City Council']);
  });

  test("a letterhead's pieces go too, the tenant's own city stays hidden", () async {
    // As on the phone: the letterhead breaks the name, the detectors find
    // the pieces, never the whole name.
    const bill = 'Leeds\nCITY COUNCIL\nCouncil Tax\nFAO Mr Thomas Ashworth\n14 Cardigan Road\nLeeds\nLS6 3AG';
    final found = [
      _at(bill, 'Leeds', EntityType.address),
      _at(bill, 'CITY COUNCIL', EntityType.address),
      _at(bill, 'Thomas Ashworth', EntityType.person),
      _at(bill, '14 Cardigan Road', EntityType.address, source: DetectionSource.strongRule),
      _at(bill, 'Leeds', EntityType.address, from: 10),
    ];
    expect(await _hidden(bill, found, ['Leeds City Council']),
        ['Thomas Ashworth', '14 Cardigan Road', 'Leeds']);
  });

  test('case, accents and edge punctuation do not matter', () async {
    const text = 'Paid to BOGOTÁ D.C., as agreed.';
    final found = [_at(text, 'BOGOTÁ D.C.,', EntityType.address)];
    expect(await _hidden(text, found, ['Bogota D.C.']), isEmpty);
  });

  test('a longer span that contains a term stays hidden whole', () async {
    const text = 'Write to Leeds City Council, Merrion House, 110 Merrion Centre, Leeds LS2 8BB.';
    final found = [_at(text, 'Leeds City Council, Merrion House, 110 Merrion Centre, Leeds LS2 8BB', EntityType.address)];
    expect(await _hidden(text, found, ['Leeds City Council']), hasLength(1));
  });

  test('dropping a term uncovers nothing a longer span would have hidden', () async {
    const text = 'Worcester Bosch Greenstar 30i boiler';
    final found = [
      _at(text, 'Worcester Bosch', EntityType.company),
      _at(text, 'Worcester Bosch Greenstar 30i', EntityType.company, source: DetectionSource.rule),
    ];
    expect(await _hidden(text, found, ['Worcester Bosch']), ['Worcester Bosch Greenstar 30i']);
  });

  test("the user's own choices win: always-hide terms and text hidden by hand", () async {
    const text = 'DPS certificate 7788 from DPS';
    final found = [
      _at(text, 'DPS', EntityType.custom, source: DetectionSource.dictionary),
      _at(text, 'DPS', EntityType.custom, source: DetectionSource.manual, from: 5),
    ];
    expect(await _hidden(text, found, ['DPS']), hasLength(2));
  });

  test('a name part on the list does not spread, the full name is still hidden', () async {
    const text = 'Jane Leeds moved to Leeds.';
    final found = [_at(text, 'Jane Leeds', EntityType.person)];
    expect(await _hidden(text, found, []), ['Jane Leeds', 'Leeds']);
    expect(await _hidden(text, found, ['Leeds']), ['Jane Leeds']);
  });
}
