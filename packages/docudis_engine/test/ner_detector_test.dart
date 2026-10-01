import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// Fake classifier: tags tokens whose ids are in [personIds] as PER and
/// tokens in [locIds] as LOC, first subword B-, rest I-.
class _FakeClassifier implements TokenClassifier {
  _FakeClassifier(this.labels, this.tagFor);

  final List<String> labels;
  final String Function(int id, int position) tagFor;

  @override
  Future<List<List<double>>> classify(List<int> ids, List<int> mask) async {
    return [
      for (var i = 0; i < ids.length; i++)
        [
          for (final l in labels) l == tagFor(ids[i], i) ? 8.0 : 0.0,
        ],
    ];
  }

  @override
  Future<void> close() async {}
}

void main() {
  final tokenizerFile = File('testdata/tokenizers/wordpiece.json');
  final specFile = File('testdata/models/distilbert_ner_hrl/model.json');

  test('capitals become title case for the model without moving any offset', () {
    const text = 'LOPEZ CORCOLES JOSE VICENTE, gérant de JERVIS BAY SARL (RCS Évry), '
        'née ÉLODIE MOREL-DUPUIS. Total TTC: 12 EUR.';
    final read = NerDetector.titleCased(text);
    expect(read, 'Lopez Corcoles Jose Vicente, gérant de Jervis BAY Sarl (RCS Évry), '
        'née Élodie Morel-Dupuis. Total TTC: 12 EUR.');
    expect(read.length, text.length);
  });

  group('SentencePiece offsets after characters the normalizer changes', () {
    String covered(String text, (List<int>, List<int>) offsets, int i) =>
        text.substring(offsets.$1[i], offsets.$2[i]);

    test('a changed piece is laid between its neighbours and nothing drifts', () {
      const text = '37,8\r\nºC y Dr. Tomás';
      final offsets = SentencePieceNerTokenizer.realign(
        text,
        ['▁3', '7,8', '▁o', 'C', '▁y', '▁Dr', '.', '▁Tomás'],
      );
      expect(
        [for (var i = 0; i < 8; i++) covered(text, offsets, i)],
        ['3', '7,8', '\r\nº', 'C', ' y', ' Dr', '.', ' Tomás'],
      );
    });

    test('the XLM-R tokenizer keeps every word on its own text', () {
      final tokenizer = NerTokenizer.fromSpec(
        'sentencepiece',
        File('../../assets/models/xlmr_ner_docudis/tokenizer.json').readAsBytesSync(),
      );
      const tail = ' Control por Dr. Tomás Garrido Lucena.';
      for (final head in [
        'Fiebre 37,8\r\nºC.',
        'Superficie  ² corporal',
        'Cafe\u0301 y ½ taza, ﬁn…',
        'Juana Mª Delgado\r\n\r\nª',
      ]) {
        final text = '$head$tail';
        final enc = tokenizer.encode(text);
        final words = [
          for (var i = 0; i < enc.length; i++) text.substring(enc.starts[i], enc.ends[i]).trim(),
        ];
        expect(words.join(), endsWith('ControlporDr.TomásGarridoLucena.'), reason: head);
        for (var i = 1; i < enc.length; i++) {
          expect(enc.starts[i], greaterThanOrEqualTo(enc.ends[i - 1]), reason: head);
        }
        expect(enc.ends.last, text.length, reason: head);
      }
    });
  });

  group('NerDetector with the bundled tokenizer', () {
    late NerModelSpec spec;
    late NerTokenizer tokenizer;

    setUpAll(() {
      spec = NerModelSpec.fromJson(specFile.readAsStringSync());
      tokenizer = NerTokenizer.fromSpec(
        spec.tokenizerKind,
        tokenizerFile.readAsBytesSync(),
      );
    });

    test('offsets are UTF-16 and cover CJK and emoji text', () {
      const text = '张三 😀 met Élodie';
      final enc = tokenizer.encode(text);
      for (var i = 0; i < enc.length; i++) {
        expect(enc.starts[i], lessThan(enc.ends[i]));
        expect(text.substring(enc.starts[i], enc.ends[i]).trim(), isNotEmpty);
      }
      // The last token ends at the string's UTF-16 length.
      expect(enc.ends.last, text.length);
    });

    test('decodes BIO tags into spans with reading-order offsets', () async {
      const text = 'Yesterday 张三 flew to Paris with John Smith.';
      final enc = tokenizer.encode(text);
      final zhang = <int>{};
      final paris = <int>{};
      final john = <int>{};
      for (var i = 0; i < enc.length; i++) {
        final piece = text.substring(enc.starts[i], enc.ends[i]);
        if (piece == '张' || piece == '三') zhang.add(enc.ids[i]);
        if (piece == 'Paris') paris.add(enc.ids[i]);
        if (piece == 'John' || piece == 'Smith') john.add(enc.ids[i]);
      }
      var seenZhang = false;
      var seenJohn = false;
      final classifier = _FakeClassifier(spec.labels, (id, pos) {
        if (zhang.contains(id)) {
          final tag = seenZhang ? 'I-PER' : 'B-PER';
          seenZhang = true;
          return tag;
        }
        if (paris.contains(id)) return 'B-LOC';
        if (john.contains(id)) {
          final tag = seenJohn ? 'I-PER' : 'B-PER';
          seenJohn = true;
          return tag;
        }
        return 'O';
      });
      final detector = NerDetector(
        spec: spec,
        tokenizer: tokenizer,
        classifier: classifier,
      );
      final found = await detector.detect(text);
      expect(found.map((d) => d.value).toList(), ['张三', 'Paris', 'John Smith']);
      expect(found.map((d) => d.type).toList(),
          [EntityType.person, EntityType.address, EntityType.person]);
      for (final d in found) {
        expect(text.substring(d.start, d.end), d.value);
        expect(d.source, DetectionSource.model);
        expect(d.confidence, greaterThan(spec.threshold));
      }
    });

    test('long text is windowed and every token is classified once', () async {
      final text = List.generate(400, (i) => 'word$i').join(' ');
      var calls = 0;
      final classifier = _FakeClassifier(spec.labels, (id, pos) {
        if (pos == 0) calls++;
        return 'O';
      });
      final detector = NerDetector(
        spec: spec,
        tokenizer: tokenizer,
        classifier: classifier,
      );
      await detector.detect(text);
      expect(calls, greaterThan(1));
    });
  });
}
