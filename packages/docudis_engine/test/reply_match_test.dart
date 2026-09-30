import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// A document as the AI received it, with the key its labels came from.
ReplyCandidate _doc(String output, Map<String, String> values) => ReplyCandidate(
      output: output,
      map: PlaceholderMap()
        ..import([
          for (final MapEntry(key: placeholder, value: original) in values.entries)
            MappingEntry(
              original: original,
              placeholder: placeholder,
              type: EntityType.fromName(placeholder.substring(1, placeholder.lastIndexOf('_'))) ??
                  EntityType.other,
            ),
        ]),
    );

// Two documents of one gestoría, numbered from 1 like every document: a
// client's WhatsApp chat and a tax office letter about another client.
final _chat = _doc(
  '[PERSON_1]: Buenos días [PERSON_2], para la renta de tu madre me faltan unos datos.\n'
  '[PERSON_2]: Mi madre es [PERSON_3], DNI [ID_1], nº de la Seguridad Social [NUMBER_1].\n'
  '[PERSON_2]: La cuenta para la devolución es [IBAN_1] (BBVA).\n'
  '[PERSON_2]: Si necesitas algo llámame al [PHONE_1]. Bizum enviado, concepto: renta mamá [PERSON_3].',
  {
    '[PERSON_1]': 'Javier Molina',
    '[PERSON_2]': 'Lucía Soriano',
    '[PERSON_3]': 'Ana Belén Soriano Cuesta',
    '[ID_1]': '73018254Q',
    '[NUMBER_1]': '46/28719034/90',
    '[IBAN_1]': 'ES83 0182 6035 4402 0151 9870',
    '[PHONE_1]': '612 345 678',
  },
);

final _letter = _doc(
  'Nº de referencia: [ID_1]\n'
  'D. [PERSON_1], con NIF [ID_2]: en relación con su declaración del Impuesto sobre la Renta, '
  'figura como cuenta para la devolución la cuenta [IBAN_1], de la que no consta que sea titular.\n'
  'Puede dirigirse a la funcionaria responsable del expediente, Dña. [PERSON_2], Técnico de '
  'Hacienda, en el teléfono [PHONE_1], indicando el número de referencia [ID_1].\n'
  'Fdo.: [PERSON_3]',
  {
    '[ID_1]': '2026GRC46012345P',
    '[PERSON_1]': 'Javier Molina Esteve',
    '[ID_2]': '20456813S',
    '[IBAN_1]': 'ES06 0049 1500 0327 1012 3456',
    '[PERSON_2]': 'María Teresa Llorens Ferrer',
    '[PHONE_1]': '963 104 587',
    '[PERSON_3]': 'Rosa Martí Pons',
  },
);

/// Written for the chat. Every label in it also exists in the letter.
const _chatReply = 'Hola [PERSON_2], ya tengo todo lo necesario para la renta de [PERSON_3] '
    '(DNI [ID_1]). La devolución se ingresará en la cuenta [IBAN_1]. Si falta algo te llamo '
    'al [PHONE_1]. Un saludo, [PERSON_1].';

void main() {
  final matcher = ReplyMatcher({'chat': _chat, 'letter': _letter});

  test('a reply restored with the wrong document points to the right one', () {
    expect(matcher.check(_chatReply, 'letter').betterMatch, 'chat');
  });

  test('the right document passes', () {
    final check = matcher.check(_chatReply, 'chat');
    expect(check.betterMatch, isNull);
    expect(check.unknown, isEmpty);
    expect(check.invented, isEmpty);
  });

  test('a label the AI made up does not make the right document wrong', () {
    const reply = 'Para cualquier aclaración, puede contactar con Dña. [Person_2] en el '
        'teléfono [PHONE_1], indicando el número de referencia [ID_1]. Su cónyuge, '
        '[PERSON_4], es titular de la cuenta [IBAN_1]. Fdo.: PERSON_1';
    final check = matcher.check(reply, 'letter');
    expect(check.betterMatch, isNull);
    expect(check.invented, ['[PERSON_4]']);
    expect(check.unknown, isEmpty);
  });

  test('a label of a type no document ever has is made up too', () {
    final check = matcher.check(
      'Expediente [EXPEDIENTE_1]: llama a [PERSON_2] al [PHONE_4] por la renta de [PERSON_3].',
      'chat',
    );
    expect(check.betterMatch, isNull);
    expect(check.unknown, isEmpty);
    expect(check.invented, ['[EXPEDIENTE_1]', '[PHONE_4]']);
  });

  test('a label of a type the document never had is unknown', () {
    final check = matcher.check('Escríbele a [EMAIL_1] sobre la cuenta [IBAN_1].', 'chat');
    expect(check.unknown, ['[EMAIL_1]']);
    expect(check.invented, isEmpty);
  });

  test('the same document saved twice is not a better match', () {
    final twice = ReplyMatcher({'chat': _chat, 'again': _chat, 'letter': _letter});
    expect(twice.check(_chatReply, 'chat').betterMatch, isNull);
    expect(twice.check(_chatReply, 'letter').betterMatch, isIn(['chat', 'again']));
  });

  test('a reply with no words of its own gives no evidence either way', () {
    expect(matcher.check('Gracias [PERSON_1].', 'letter').betterMatch, isNull);
  });
}
