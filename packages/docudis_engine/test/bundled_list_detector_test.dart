import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

void main() {
  group('BundledListDetector', () {
    final detector = BundledListDetector({
      EntityType.company: ['Alibaba Group', '阿里巴巴', 'El Corte Inglés', 'Russell McVeagh', 'AT&T', 'Airbus'],
      EntityType.address: ['深圳', '苏州工业园区'],
    });

    List<(EntityType, String)> found(String text) =>
        [for (final d in detector.detectSync(text)) (d.type, d.value)];

    test('Latin names match whole words, case-sensitively', () {
      expect(found('Contract reviewed by Russell McVeagh for AT&T.'), [
        (EntityType.company, 'Russell McVeagh'),
        (EntityType.company, 'AT&T'),
      ]);
      expect(found('airbus AIRBUS Airbusiness'), isEmpty);
      expect(found('chez Airbus depuis'), [(EntityType.company, 'Airbus')]);
    });

    test('accented names match as written', () {
      expect(found('su pedido en El Corte Inglés será entregado'),
          [(EntityType.company, 'El Corte Inglés')]);
    });

    test('CJK names match anywhere, and nested names are all reported', () {
      expect(found('样品寄往苏州工业园区，总部在深圳。'), [
        (EntityType.address, '苏州工业园区'),
        (EntityType.address, '深圳'),
      ]);
      expect(found('阿里巴巴西溪园区'), [(EntityType.company, '阿里巴巴')]);
    });

    test('a longer model span beats a list hit inside it', () {
      const text = '王芳 (深圳华强科技) 同意';
      final model = Detection(
        type: EntityType.company,
        value: '深圳华强科技',
        start: text.indexOf('深圳'),
        end: text.indexOf('深圳') + 6,
        confidence: 0.9,
        detector: 'ner',
        source: DetectionSource.model,
      );
      final merged = DetectionPipeline.merge(text, [...detector.detectSync(text), model]);
      expect(merged.map((d) => d.value), ['深圳华强科技']);
    });

    test('the shipped lists load and are not empty', () {
      final bundled = BundledListDetector.bundled();
      expect(bundled.termCount, greaterThan(1000));
      expect(bundled.detectSync('地点在阿里巴巴西溪园区').map((d) => d.value), contains('阿里巴巴'));
    });
  });

  test('a name that is an ordinary word or a place once its punctuation is stripped is not a company', () {
    // "'One'", "One+", "Anti-" and KFC's alias "Kentucky" hid "One Day Change",
    // "Anti Inflammatory" and a state in photographed documents (2026-09-26).
    final bundled = BundledListDetector.bundled();
    expect(bundled.detectSync('One Day Change\tAnti Inflammatory\nKentucky, 18382-7941\nMoved to Canada.'),
        isEmpty);
    expect(bundled.detectSync('Invoice from Iberdrola').map((h) => h.value), ['Iberdrola']);
  });
}
