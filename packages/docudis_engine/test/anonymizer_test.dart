import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

Detection span(String text, String value, EntityType type, {int from = 0}) {
  final start = text.indexOf(value, from);
  return Detection(
    type: type,
    value: value,
    start: start,
    end: start + value.length,
    confidence: 1,
    detector: 'test',
    source: DetectionSource.manual,
  );
}

void main() {
  group('anonymize', () {
    test('numbers placeholders in reading order and reuses them', () {
      const text = 'Bob emailed Alice, then Alice called Bob at 555-1234.';
      final result = anonymize(text, [
        span(text, 'Alice', EntityType.person, from: 20),
        span(text, 'Bob', EntityType.person),
        span(text, 'Alice', EntityType.person),
        span(text, 'Bob', EntityType.person, from: 30),
        span(text, '555-1234', EntityType.phone),
      ]);
      expect(
        result.text,
        '[PERSON_1] emailed [PERSON_2], then [PERSON_2] called [PERSON_1] at [PHONE_1].',
      );
      expect(result.map.length, 3);
    });

    test('replacements, applied to the original, give the output', () {
      const text = 'Call Bob, 555-1234; Alice.';
      final result = anonymize(text, [
        span(text, 'Bob, ', EntityType.person),
        span(text, '555-1234', EntityType.phone),
        span(text, 'Alice', EntityType.person).copyWith(enabled: false),
      ]);
      var rebuilt = text;
      for (final r in result.replacements.reversed) {
        rebuilt = rebuilt.replaceRange(r.start, r.end, r.placeholder);
      }
      expect(rebuilt, result.text);
      expect(result.replacements.map((r) => text.substring(r.start, r.end)), ['Bob', '555-1234']);
    });

    test('disabled detections are left alone', () {
      const text = 'Bob and Alice';
      final result = anonymize(text, [
        span(text, 'Bob', EntityType.person).copyWith(enabled: false),
        span(text, 'Alice', EntityType.person),
      ]);
      expect(result.text, 'Bob and [PERSON_1]');
    });

    test('person variants share a placeholder; restore gives the longest', () {
      const text = 'John Smith met John. Smith left.';
      final result = anonymize(text, [
        span(text, 'John Smith', EntityType.person),
        span(text, 'John', EntityType.person, from: 15),
        span(text, 'Smith', EntityType.person, from: 20),
      ]);
      expect(result.text, '[PERSON_1] met [PERSON_1]. [PERSON_1] left.');
      expect(result.map.restore('[PERSON_1] wins'), 'John Smith wins');
    });

    test('a surname two people share is not given to either', () {
      const text = 'Ana García y Luis García. García firmó.';
      final result = anonymize(text, [
        span(text, 'Ana García', EntityType.person),
        span(text, 'Luis García', EntityType.person),
        span(text, 'García', EntityType.person, from: 26),
      ]);
      expect(result.text, '[PERSON_1] y [PERSON_2]. [PERSON_3] firmó.');
    });

    test('Chinese honorific variants unify', () {
      const text = '张三先生来了，张三签了字。';
      final result = anonymize(text, [
        span(text, '张三先生', EntityType.person),
        span(text, '张三', EntityType.person, from: 5),
      ]);
      expect(result.text, '[PERSON_1]来了，[PERSON_1]签了字。');
    });

    test('edits after sending keep the placeholders an AI reply already uses', () {
      const text = 'Bob met Alice and Carol.';
      final sent = anonymize(text, [
        span(text, 'Alice', EntityType.custom),
        span(text, 'Carol', EntityType.person),
      ]);
      expect(sent.text, 'Bob met [CUSTOM_1] and [PERSON_1].');
      const reply = '[CUSTOM_1] and [PERSON_1] agree.';

      // Later: Bob hidden by hand before Alice, Carol un-hidden.
      final edited = anonymize(text, [
        span(text, 'Bob', EntityType.custom),
        span(text, 'Alice', EntityType.custom),
        span(text, 'Carol', EntityType.person).copyWith(enabled: false),
      ], previous: sent.map);
      expect(edited.text, '[CUSTOM_2] met [CUSTOM_1] and Carol.');
      expect(edited.map.restore(reply), 'Alice and Carol agree.');
    });
  });

  group('restore', () {
    late PlaceholderMap map;
    setUp(() {
      map = PlaceholderMap()
        ..placeholderFor('张三', EntityType.person)
        ..placeholderFor('13812345678', EntityType.phone);
    });

    test('exact placeholders', () {
      expect(map.restore('请联系[PERSON_1]，电话[PHONE_1]。'),
          '请联系张三，电话13812345678。');
    });

    test('mangled placeholders that are unambiguous', () {
      expect(map.restore('**[person 1]** and PERSON_1 and [PHONE-1.]'),
          '**张三** and 张三 and 13812345678');
    });

    test('unknown tokens are left untouched', () {
      expect(map.restore('[PERSON_9] and [citation_1]'),
          '[PERSON_9] and [citation_1]');
    });

    test('round-trips through JSON', () {
      final copy = PlaceholderMap.fromJson(map.toJson());
      expect(copy.restore('[PERSON_1]/[PHONE_1]'), '张三/13812345678');
      // Counters continue after import.
      expect(copy.placeholderFor('李四', EntityType.person), '[PERSON_2]');
    });
  });
  group('phone walkthrough (2026-09-23)', () {
    test('a separator at the edge of a span stays outside the placeholder', () {
      const text = 'au 12 rue des Tanneurs, 69007 Lyon et 12 rue des Tanneurs.';
      final result = anonymize(text, [
        span(text, '12 rue des Tanneurs, ', EntityType.address),
        span(text, '69007 Lyon', EntityType.address),
        span(text, '12 rue des Tanneurs', EntityType.address, from: 30),
      ]);
      expect(result.text, 'au [ADDRESS_1], [ADDRESS_2] et [ADDRESS_1].');
      expect(result.map.restore('[ADDRESS_1]'), '12 rue des Tanneurs');
    });

    test('a surname under another honorific is another person', () {
      const text = 'Bonjour Mme Garnier, votre conjoint M. Julien Garnier. Mme Garnier signe.';
      final result = anonymize(text, [
        span(text, 'Garnier', EntityType.person),
        span(text, 'Julien Garnier', EntityType.person),
        span(text, 'Garnier', EntityType.person, from: text.lastIndexOf('Garnier')),
      ]);
      expect(result.text, 'Bonjour Mme [PERSON_1], votre conjoint M. [PERSON_2]. Mme [PERSON_1] signe.');
    });

    test('without a conflicting honorific the short form still joins the full name', () {
      const text = 'Mr John Smith called. Later Smith wrote, and Mr Smith paid.';
      final result = anonymize(text, [
        span(text, 'John Smith', EntityType.person),
        span(text, 'Smith', EntityType.person, from: 20),
        span(text, 'Smith', EntityType.person, from: 45),
      ]);
      expect(result.text, 'Mr [PERSON_1] called. Later [PERSON_1] wrote, and Mr [PERSON_1] paid.');
    });
  });
}
