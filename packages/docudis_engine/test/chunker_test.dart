import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// The chunks of [text], as their own strings.
List<String> values(String text, {Iterable<Detection> taken = const []}) => [
      for (final c in chunkText(text, taken: taken))
        text.substring(c.start, c.end),
    ];

/// [text] with every chunk wrapped, for readable failures.
String marked(String text) {
  final out = StringBuffer();
  var cursor = 0;
  for (final c in chunkText(text)) {
    out
      ..write(text.substring(cursor, c.start))
      ..write('[${text.substring(c.start, c.end)}]');
    cursor = c.end;
  }
  return (out..write(text.substring(cursor))).toString();
}

Detection span(String text, String value, EntityType type) {
  final start = text.indexOf(value);
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
  group('chunkText', () {
    test('a full name is one chunk, prose words are one each', () {
      expect(
        marked('Contact Laura Bennett about the invoice'),
        '[Contact Laura Bennett] [about] [the] [invoice]',
      );
    });

    test('a spaced-out phone number is one chunk', () {
      expect(values('Téléphone : 06 12 34 56 78'), [
        'Téléphone',
        '06 12 34 56 78',
      ]);
    });

    test('an amount keeps its separators and its currency sign', () {
      expect(values('Total : £1,250.00'), ['Total', '£1,250.00']);
      expect(values('montant total 12 450,00 €'), [
        'montant',
        'total',
        '12 450,00 €',
      ]);
    });

    test('an e-mail and a URL survive their dots and slashes', () {
      expect(values('e-mail : pierre.martin@exemple.fr'), [
        'e-mail',
        'pierre.martin@exemple.fr',
      ]);
      expect(values('see https://acme.co/a/b now'), [
        'see',
        'https://acme.co/a/b',
        'now',
      ]);
    });

    test('a street address bridges its short lower-case words', () {
      expect(values('Adresse : 14 rue de la Paix, 75002 Paris'), [
        'Adresse',
        '14 rue de la Paix',
        '75002 Paris',
      ]);
    });

    test('an ordinary verb does not bridge a name to the word before it', () {
      expect(values('Please call Sarah Meyer'), [
        'Please',
        'call',
        'Sarah Meyer',
      ]);
      expect(values('Ludwig van Beethoven wrote it'), [
        'Ludwig van Beethoven',
        'wrote',
        'it',
      ]);
    });

    test('a title keeps its dot, a sentence end does not', () {
      expect(values('Dr. Alan Turing is here. Ms. Patel called'), [
        'Dr. Alan Turing',
        'is',
        'here',
        'Ms. Patel',
        'called',
      ]);
    });

    test('invoice columns are cut apart, lines are not merged', () {
      expect(values('Bill to :  Robert Johnson\nTotal :  £12.50'), [
        'Bill',
        'to',
        'Robert Johnson',
        'Total',
        '£12.50',
      ]);
    });

    test('a CJK run is cut at punctuation only', () {
      expect(values('尊敬的王建国先生：您的账户已变更，如有疑问请致电13900001111。'), [
        '尊敬的王建国先生',
        '您的账户已变更',
        '如有疑问请致电13900001111',
      ]);
    });

    test('no chunk runs past 60 characters', () {
      final long = List.filled(30, 'Aa').join(' ');
      for (final c in chunkText(long)) {
        expect(c.length, lessThanOrEqualTo(60));
      }
    });

    test('lone punctuation is not tappable', () {
      expect(values('a , b ; c'), ['a', 'b', 'c']);
    });

    test('chunks are sorted, non-empty and inside the text', () {
      const text = 'Facture n° 202603 pour la commande 450012 : trois '
          'ordinateurs, 12 450,00 €. Contact : Claire Dubois, 01 42 68 53 00.';
      var previous = 0;
      for (final c in chunkText(text)) {
        expect(c.start, greaterThanOrEqualTo(previous));
        expect(c.end, greaterThan(c.start));
        expect(c.end, lessThanOrEqualTo(text.length));
        expect(text.substring(c.start, c.end).trim(), isNotEmpty);
        previous = c.end;
      }
    });

    test('what the detectors already found is cut out', () {
      const text = 'Contact Claire Dubois at 01 42 68 53 00 today';
      expect(
        values(
          text,
          taken: [
            span(text, 'Claire Dubois', EntityType.person),
            span(text, '01 42 68 53 00', EntityType.phone),
          ],
        ),
        ['Contact', 'at', 'today'],
      );
    });

    test('a detection inside a chunk leaves the rest tappable', () {
      const text = 'Adresse : 75002 Paris';
      expect(
        values(text, taken: [span(text, '75002', EntityType.id)]),
        ['Adresse', 'Paris'],
      );
    });
  });
}
