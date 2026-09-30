import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

/// A detector that reports fixed values, wherever they first occur.
class _Fixed implements Detector {
  _Fixed(this.spans);

  final List<(EntityType, String, DetectionSource)> spans;

  @override
  String get name => 'fixed';

  @override
  Future<List<Detection>> detect(String text) async => [
        for (final (type, value, source) in spans)
          Detection(
            type: type,
            value: value,
            start: text.indexOf(value),
            end: text.indexOf(value) + value.length,
            confidence: 0.9,
            detector: 'fixed',
            source: source,
          ),
      ];
}

const _model = DetectionSource.model;

Future<List<String>> _hidden(
  String text,
  List<(EntityType, String, DetectionSource)> spans, {
  bool rules = false,
}) async {
  final found = await DetectionPipeline([
    if (rules) RegexDetector.bundled(regions: RegexDetector.defaultRegions),
    _Fixed(spans),
  ]).run(text);
  return [
    for (final d in found)
      if (d.enabled) '${d.type.placeholderName}:${d.value}',
  ];
}

void main() {
  group('a span that loses an overlap never leaves its text showing', () {
    test('a phone found inside a longer digit string hides the whole string as NUMBER', () async {
      // ML Kit reads the tail as a phone number and outranks the loose rule
      // that had the whole thing.
      const text = 'Mon numéro est le 2 88 03 44 109 042 17 et merci.';
      expect(
        await _hidden(text, [(EntityType.phone, '109 042 17', _model)], rules: true),
        ['NUMBER:2 88 03 44 109 042 17'],
      );
    });

    test('a company rule and a longer model span of the same company are joined', () async {
      const text = 'Cession à FINANCIERE JL SAS le 3 mai.';
      expect(
        await _hidden(text, [
          (EntityType.company, 'JL SAS', DetectionSource.strongRule),
          (EntityType.company, 'FINANCIERE JL', _model),
        ]),
        ['COMPANY:FINANCIERE JL SAS'],
      );
    });

    test('a junk model span of another type still loses whole', () async {
      const text = 'write to jane.doe@acme.co or call';
      expect(
        await _hidden(text, [(EntityType.address, text, _model)], rules: true),
        ['EMAIL:jane.doe@acme.co'],
      );
    });
  });

  group('capitals next to a name in capitals belong to it', () {
    test('person', () async {
      const text = 'Apoderado: MARIA GADOR CANO ENCISO. Revocado: DEL AGUILA CAZORLA MARIA.';
      expect(
        await _hidden(text, [
          (EntityType.person, 'MARIA GADOR CANO', _model),
          (EntityType.person, 'AGUILA CAZORLA MARIA', _model),
        ]),
        ['PERSON:MARIA GADOR CANO ENCISO', 'PERSON:DEL AGUILA CAZORLA MARIA'],
      );
    });

    test('company', () async {
      const text = 'Fonds vendu par JERVIS BAY, exploitant.';
      expect(
        await _hidden(text, [(EntityType.company, 'JERVIS', _model)]),
        ['COMPANY:JERVIS BAY'],
      );
    });

    test('a name in ordinary case takes nothing with it', () async {
      const text = 'Thanks Tom Baker for the NDA.';
      expect(
        await _hidden(text, [(EntityType.person, 'Tom Baker', _model)]),
        ['PERSON:Tom Baker'],
      );
    });

    test('stops at punctuation, digits, titles and the end of the line', () async {
      const text = 'ANA LLANO DIRECTORA, ANA LLANA: 2024\nARIAS';
      expect(
        await _hidden(text, [
          (EntityType.person, 'ANA LLANO', _model),
          (EntityType.person, 'ANA LLANA', _model),
        ]),
        ['PERSON:ANA LLANO', 'PERSON:ANA LLANA'],
      );
    });

    test('a sentence in capitals in front of the name is not part of it', () async {
      const text = 'UNIPERSONAL, SIENDO SOCIO UNICO MARIA DOLORES PEÑA CADIZ Datos registrales.';
      expect(
        await _hidden(text, [(EntityType.person, 'MARIA DOLORES PEÑA', _model)]),
        ['PERSON:MARIA DOLORES PEÑA CADIZ'],
      );
    });
  });

  group('name particles between two halves of one name', () {
    test('person', () async {
      const text = 'Nombrado ANA DE LLANO ARIAS como vocal.';
      expect(
        await _hidden(text, [
          (EntityType.person, 'ANA', _model),
          (EntityType.person, 'LLANO ARIAS', _model),
        ]),
        ['PERSON:ANA DE LLANO ARIAS'],
      );
    });

    test('"and" keeps two people apart', () async {
      const text = 'Juan Pérez y María Gil firmaron.';
      expect(
        await _hidden(text, [
          (EntityType.person, 'Juan Pérez', _model),
          (EntityType.person, 'María Gil', _model),
        ]),
        ['PERSON:Juan Pérez', 'PERSON:María Gil'],
      );
    });
  });

  group('one address on one line is one span', () {
    test('unit, number and the pieces between two address parts', () async {
      const text = 'Siège : Appartement 3, 409 rue Florent Evrard, BP 633, 62430 Sallaumines\nsuite';
      expect(
        await _hidden(text, [
          (EntityType.address, 'rue Florent Evrard', _model),
          (EntityType.address, '62430 Sallaumines', DetectionSource.strongRule),
        ]),
        ['ADDRESS:Appartement 3, 409 rue Florent Evrard, BP 633, 62430 Sallaumines'],
      );
    });

    test('places in a sentence stay apart', () async {
      const text = 'Trains from Bristol to Bath, then Paris, Lyon.';
      expect(
        await _hidden(text, [
          (EntityType.address, 'Bristol', _model),
          (EntityType.address, 'Bath', _model),
          (EntityType.address, 'Paris', _model),
          (EntityType.address, 'Lyon', _model),
        ]),
        ['ADDRESS:Bristol', 'ADDRESS:Bath', 'ADDRESS:Paris', 'ADDRESS:Lyon'],
      );
    });

    test('the rest of the line comes with it', () async {
      const text = 'I only moved into Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 XK72 in March.';
      expect(
        await _hidden(text, [(EntityType.address, 'D08 XK72', _model)]),
        ['ADDRESS:Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 XK72'],
      );
    });

    test('but not the sentence the address sits in', () async {
      const text = 'Please post the keys to 4 Rectory Lane before Friday.';
      expect(
        await _hidden(text, [(EntityType.address, 'Rectory Lane', _model)]),
        ['ADDRESS:4 Rectory Lane'],
      );
    });
  });

  group('a firm name cut short keeps its end', () {
    test('words in capitals that finish the name', () async {
      const text = 'Invoice from JTS Haulage for the September run.';
      expect(
        await _hidden(text, [(EntityType.company, 'JTS', _model)]),
        ['COMPANY:JTS Haulage'],
      );
    });

    test('a particle in front of a place already hidden', () async {
      const text = 'Elle est infirmière au CHU de Montpellier depuis 2019.';
      expect(
        await _hidden(text, [
          (EntityType.company, 'CHU', _model),
          (EntityType.address, 'Montpellier', _model),
        ]),
        ['COMPANY:CHU de', 'ADDRESS:Montpellier'],
      );
    });

    test('a department after it is not part of it', () async {
      const text = 'Signed for Wrenfield Glazing Finance on 3 May.';
      expect(
        await _hidden(text, [(EntityType.company, 'Wrenfield', _model)]),
        ['COMPANY:Wrenfield Glazing'],
      );
    });
  });

  group('digit groups cut off a hidden number', () {
    test('are hidden with it', () async {
      const text = 'Llame al 954 21 07 65. Gracias.';
      expect(
        await _hidden(text, [(EntityType.phone, '954 21 07', _model)]),
        ['NUMBER:954 21 07 65'],
      );
    });

    test('an amount or a date next to it is left alone', () async {
      const text = 'Tel 06 12 34 56 78 12/03/2024 puis 06 12 34 56 79 12 500,00 €';
      expect(
        await _hidden(text, [
          (EntityType.phone, '06 12 34 56 78', _model),
          (EntityType.phone, '06 12 34 56 79', _model),
        ]),
        ['PHONE:06 12 34 56 78', 'PHONE:06 12 34 56 79'],
      );
    });
  });

  group('a line of an address block that nothing hides', () {
    test('is hidden between the street and the postcode', () async {
      const text = 'PO Box 4402\nLeicester\nLE87 9AB';
      expect(
        await _hidden(text, [
          (EntityType.address, 'PO Box 4402', _model),
          (EntityType.address, 'LE87 9AB', _model),
        ]),
        ['ADDRESS:PO Box 4402', 'ADDRESS:Leicester', 'ADDRESS:LE87 9AB'],
      );
    });

    test('takes the tail of a street that wrapped, and the town under it', () async {
      const text = '27 Brambleside Court, Nether Parkfield\nRoad\nSheffield\nS11 8QT';
      expect(
        await _hidden(text, [
          (EntityType.address, '27 Brambleside Court, Nether Parkfield', _model),
          (EntityType.address, 'S11 8QT', _model),
        ]),
        [
          'ADDRESS:27 Brambleside Court, Nether Parkfield',
          'ADDRESS:Road',
          'ADDRESS:Sheffield',
          'ADDRESS:S11 8QT',
        ],
      );
    });

    test('a trading name under the company is not part of the block', () async {
      // What stands above it is the bank, not an address: the line is the
      // letterhead, not the town.
      const text = 'National Westminster Bank plc\nPersonal Lending Services\nPO Box 4402\nLeicester\nLE87 9AB';
      expect(
        await _hidden(text, [
          (EntityType.company, 'National Westminster Bank plc', _model),
          (EntityType.address, 'PO Box 4402', _model),
          (EntityType.address, 'LE87 9AB', _model),
        ]),
        [
          'COMPANY:National Westminster Bank plc',
          'ADDRESS:PO Box 4402',
          'ADDRESS:Leicester',
          'ADDRESS:LE87 9AB',
        ],
      );
    });

    test('a date between two address lines stays readable', () async {
      const text = '14 Sackville Row\n3 September 2026\nM1 6EX';
      expect(
        await _hidden(text, [
          (EntityType.address, '14 Sackville Row', _model),
          (EntityType.date, '3 September 2026', _model),
          (EntityType.address, 'M1 6EX', _model),
        ]),
        ['ADDRESS:14 Sackville Row', 'ADDRESS:M1 6EX'],
      );
    });

    test('a job title between a line that ends in a place and a sentence naming more', () async {
      // A CV: neither line around it is a line of address, so the title stays.
      const text = 'Severnside Logistics Ltd, Avonmouth      March 2021 - present\n'
          'Transport Supervisor\n'
          '- Plan daily routes covering Bristol, Bath and Weston-super-Mare';
      final hidden = await _hidden(text, [
        (EntityType.company, 'Severnside Logistics Ltd', _model),
        (EntityType.address, 'Avonmouth', _model),
        (EntityType.address, 'Bristol', _model),
        (EntityType.address, 'Bath', _model),
        (EntityType.address, 'Weston-super-Mare', _model),
      ]);
      expect(hidden, isNot(contains('ADDRESS:Transport Supervisor')));
    });

    test('a sentence between two addresses is not swallowed', () async {
      const text = '14 Sackville Row\nplease send the keys back to us before you leave\nM1 6EX';
      expect(
        await _hidden(text, [
          (EntityType.address, '14 Sackville Row', _model),
          (EntityType.address, 'M1 6EX', _model),
        ]),
        ['ADDRESS:14 Sackville Row', 'ADDRESS:M1 6EX'],
      );
    });
  });

  test('what the user switched off is not switched back on by a later merge', () async {
    const text = 'Apoderado: MARIA GADOR CANO ENCISO.';
    final found = await DetectionPipeline([
      _Fixed([(EntityType.person, 'MARIA GADOR CANO', _model)]),
    ]).run(text);
    final toggled = [for (final d in found) d.copyWith(enabled: false)];
    expect(DetectionPipeline.merge(text, toggled).where((d) => d.enabled), isEmpty);
  });
  group('phone walkthrough (2026-09-23)', () {
    Future<String> output(String text, List<(EntityType, String, DetectionSource)> spans) async {
      final found = await DetectionPipeline([
        RegexDetector.bundled(regions: RegexDetector.defaultRegions),
        _Fixed(spans),
      ]).run(text);
      return anonymize(text, found).text;
    }

    test('an ML Kit address over two rule spans leaves the text between them to the join', () async {
      // Rules alone gave these outputs; ML Kit's one span over the street and
      // the postcode used to glue them into "[ADDRESS_1][ADDRESS_2]".
      expect(
        await output('Visite au 12 rue des Tanneurs, 69007 Lyon.', [
          (EntityType.address, '12 rue des Tanneurs, 69007 Lyon', _model),
        ]),
        'Visite au [ADDRESS_1], [ADDRESS_2].',
      );
      expect(
        await output('Our address is 27 Harrowgate Lane, Leeds LS7 4QN and my mobile is 07700 900461.', [
          (EntityType.address, '27 Harrowgate Lane, Leeds LS7 4QN', _model),
        ]),
        'Our address is [ADDRESS_1] and my mobile is [PHONE_1].',
      );
      expect(
        await output('vivo en Calle Alcalá 214, 3ºB, 28028 Madrid. Mi teléfono', [
          (EntityType.address, 'Calle Alcalá 214, 3ºB, 28028 Madrid', _model),
        ]),
        'vivo en [ADDRESS_1]. Mi teléfono',
      );
    });

    test('the same street keeps its placeholder when it comes back', () async {
      expect(
        await output('Objet : appartement 12 rue des Tanneurs\nVisite au 12 rue des Tanneurs, 69007 Lyon.', [
          (EntityType.address, '12 rue des Tanneurs, 69007 Lyon', _model),
        ]),
        'Objet : appartement [ADDRESS_1]\nVisite au [ADDRESS_1], [ADDRESS_2].',
      );
    });

    test('an address does not take the small word after it', () async {
      expect(
        await output("Since her discharge from St Luke's on 9 September she has been confused.", [
          (EntityType.address, "St Luke's", _model),
          (EntityType.date, '9 September', _model),
        ]),
        "Since her discharge from [ADDRESS_1] on 9 September she has been confused.",
      );
      expect(
        await _hidden('She lives in Newcastle upon Tyne now.', [(EntityType.address, 'Newcastle', _model)]),
        ['ADDRESS:Newcastle upon Tyne'],
      );
    });

    test('a model span across a line break drops the job title, keeps a wrapped name', () async {
      expect(
        await _hidden('Kind regards,\nPriya Raman\nHuman Resources', [
          (EntityType.company, 'Priya Raman\nHuman Resources', _model),
        ]),
        ['COMPANY:Priya Raman'],
      );
      expect(
        await _hidden('Patient: Jean-Baptiste\nDelacroix-Moreau', [
          (EntityType.person, 'Jean-Baptiste\nDelacroix-Moreau', _model),
        ]),
        ['PERSON:Jean-Baptiste\nDelacroix-Moreau'],
      );
    });
  });
}
