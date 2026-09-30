// Copyright 2026 the Docudis contributors. Licensed under Apache-2.0.

import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';

class _Fixed implements Detector {
  _Fixed(this.values);
  final List<Detection> values;
  @override
  String get name => 'fixture';
  @override
  Future<List<Detection>> detect(String text) async => values;
}

Detection _d(
  String text,
  String value,
  EntityType type,
  DetectionSource source, {
  int occurrence = 0,
  double confidence = 0.9,
  bool enabled = true,
}) {
  var start = -1;
  for (var i = 0; i <= occurrence; i++) {
    start = text.indexOf(value, start + 1);
  }
  return Detection(
    type: type,
    value: value,
    start: start,
    end: start + value.length,
    confidence: confidence,
    detector: 'fixture:${source.name}',
    source: source,
    enabled: enabled,
  );
}

Future<void> main() async {
  final definitions =
      <
        ({
          String name,
          String text,
          List<Detection> detections,
          List<String> neverHide,
        })
      >[];
  void add(
    String name,
    String text,
    List<Detection> detections, {
    List<String> neverHide = const [],
  }) => definitions.add((
    name: name,
    text: text,
    detections: detections,
    neverHide: neverHide,
  ));

  var text = 'Call alice@example.com now';
  add('strong_rule_beats_ner', text, [
    _d(text, 'alice@example.com now', EntityType.person, DetectionSource.model),
    _d(
      text,
      'alice@example.com',
      EntityType.email,
      DetectionSource.strongRule,
      confidence: 0.95,
    ),
  ]);
  text = 'Jean Dupont signed';
  add('dictionary_yields_to_longer_hidden_name', text, [
    _d(text, 'Jean Dupont', EntityType.person, DetectionSource.model),
    _d(
      text,
      'Dupont',
      EntityType.custom,
      DetectionSource.dictionary,
      confidence: 1,
    ),
  ]);
  text = 'Leeds City Council and Alice';
  add(
    'never_hide_removes_covered_detection',
    text,
    [
      _d(text, 'Leeds City Council', EntityType.address, DetectionSource.model),
      _d(text, 'Alice', EntityType.person, DetectionSource.model),
    ],
    neverHide: ['Leeds City Council'],
  );
  text = 'Project Zephyr';
  add('user_dictionary_custom_entity', text, [
    _d(
      text,
      'Zephyr',
      EntityType.custom,
      DetectionSource.dictionary,
      confidence: 1,
    ),
  ]);
  text = 'Born: 12/03/1990. Repeat 12/03/1990. Total €20';
  add('birth_date_and_detect_only_defaults', text, [
    _d(
      text,
      '12/03/1990',
      EntityType.date,
      DetectionSource.strongRule,
      occurrence: 0,
    ),
    _d(
      text,
      '12/03/1990',
      EntityType.date,
      DetectionSource.strongRule,
      occurrence: 1,
    ),
    _d(text, '€20', EntityType.amount, DetectionSource.strongRule),
  ]);
  text = '1234 5678 9012';
  add('repair_grows_validated_number_winner', text, [
    _d(
      text,
      '5678',
      EntityType.card,
      DetectionSource.validatedRule,
      confidence: 1,
    ),
    _d(text, text, EntityType.number, DetectionSource.model),
  ]);
  text = 'Mon numéro est le 2 88 03 44 109 042 17 et merci.';
  add('repair_loser_text_is_not_exposed', text, [
    _d(text, '109 042 17', EntityType.phone, DetectionSource.model),
    _d(text, '2 88 03 44 109 042 17', EntityType.number, DetectionSource.rule),
  ]);
  text = 'Cession à FINANCIERE JL SAS le 3 mai.';
  add('repair_joins_overlapping_company_parts', text, [
    _d(text, 'JL SAS', EntityType.company, DetectionSource.strongRule),
    _d(text, 'FINANCIERE JL', EntityType.company, DetectionSource.model),
  ]);
  text =
      'Apoderado: MARIA GADOR CANO ENCISO. Revocado: DEL AGUILA CAZORLA MARIA.';
  add('repair_capitals_and_name_particle', text, [
    _d(text, 'MARIA GADOR CANO', EntityType.person, DetectionSource.model),
    _d(text, 'AGUILA CAZORLA MARIA', EntityType.person, DetectionSource.model),
  ]);
  text = 'ANA LLANO DIRECTORA, ANA LLANA: 2024\nARIAS';
  add('repair_capitals_stop_at_title_punctuation_and_line', text, [
    _d(text, 'ANA LLANO', EntityType.person, DetectionSource.model),
    _d(text, 'ANA LLANA', EntityType.person, DetectionSource.model),
  ]);
  text = 'Nombrado ANA DE LLANO ARIAS como vocal.';
  add('repair_joins_person_name_particle', text, [
    _d(text, 'ANA', EntityType.person, DetectionSource.model),
    _d(text, 'LLANO ARIAS', EntityType.person, DetectionSource.model),
  ]);
  text = 'Siège : Appartement 3, 409 rue Florent Evrard, BP 633, 62430 Sallaumines\nsuite';
  add('repair_one_address_on_one_line', text, [
    _d(text, 'rue Florent Evrard', EntityType.address, DetectionSource.model),
    _d(
      text,
      '62430 Sallaumines',
      EntityType.address,
      DetectionSource.strongRule,
    ),
  ]);
  text = 'Trains from Bristol to Bath, then Paris, Lyon.';
  add('repair_places_in_prose_stay_apart', text, [
    _d(text, 'Bristol', EntityType.address, DetectionSource.model),
    _d(text, 'Bath', EntityType.address, DetectionSource.model),
    _d(text, 'Paris', EntityType.address, DetectionSource.model),
    _d(text, 'Lyon', EntityType.address, DetectionSource.model),
  ]);
  text = 'I only moved into Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 XK72 in March.';
  add('repair_address_takes_rest_of_line', text, [
    _d(text, 'D08 XK72', EntityType.address, DetectionSource.model),
  ]);
  text = 'Please post the keys to 4 Rectory Lane before Friday.';
  add('repair_address_does_not_take_sentence', text, [
    _d(text, 'Rectory Lane', EntityType.address, DetectionSource.model),
  ]);
  text = 'Signed for Wrenfield Glazing Finance on 3 May.';
  add('repair_company_tail_stops_at_department', text, [
    _d(text, 'Wrenfield', EntityType.company, DetectionSource.model),
  ]);
  text = 'Elle est infirmière au CHU de Montpellier depuis 2019.';
  add('repair_company_keeps_particle_before_next_span', text, [
    _d(text, 'CHU', EntityType.company, DetectionSource.model),
    _d(text, 'Montpellier', EntityType.address, DetectionSource.model),
  ]);
  text = 'The College of Nursing opened today.';
  add('repair_company_keeps_connector_and_tail', text, [
    _d(text, 'College', EntityType.company, DetectionSource.model),
  ]);
  text = 'Llame al 954 21 07 65. Gracias.';
  add('repair_number_takes_trailing_digit_group', text, [
    _d(text, '954 21 07', EntityType.phone, DetectionSource.model),
  ]);
  text = 'Tel 06 12 34 56 78 12/03/2024 puis 06 12 34 56 79 12 500,00 €';
  add('repair_number_stops_before_date_and_amount', text, [
    _d(text, '06 12 34 56 78', EntityType.phone, DetectionSource.model),
    _d(text, '06 12 34 56 79', EntityType.phone, DetectionSource.model),
  ]);
  text = 'PO Box 4402\nLeicester\nLE87 9AB';
  add('repair_address_block_town_line', text, [
    _d(text, 'PO Box 4402', EntityType.address, DetectionSource.model),
    _d(text, 'LE87 9AB', EntityType.address, DetectionSource.model),
  ]);
  text = '27 Brambleside Court, Nether Parkfield\nRoad\nSheffield\nS11 8QT';
  add('repair_address_block_two_lines', text, [
    _d(
      text,
      '27 Brambleside Court, Nether Parkfield',
      EntityType.address,
      DetectionSource.model,
    ),
    _d(text, 'S11 8QT', EntityType.address, DetectionSource.model),
  ]);
  text = '14 Sackville Row\n28 February 2024\nM1 6EX';
  add('repair_address_block_respects_other_detection', text, [
    _d(text, '14 Sackville Row', EntityType.address, DetectionSource.model),
    _d(text, '28 February 2024', EntityType.date, DetectionSource.model),
    _d(text, 'M1 6EX', EntityType.address, DetectionSource.model),
  ]);
  text = "Since her discharge from St Luke's on 9 September she has been confused.";
  add('repair_address_drops_trailing_particle', text, [
    _d(text, "St Luke's", EntityType.address, DetectionSource.model),
    _d(text, '9 September', EntityType.date, DetectionSource.model),
  ]);
  text = 'She lives in Newcastle upon Tyne now.';
  add('repair_address_keeps_particle_between_places', text, [
    _d(text, 'Newcastle', EntityType.address, DetectionSource.model),
  ]);
  text = 'Kind regards,\nPriya Raman\nHuman Resources';
  add('repair_multiline_company_drops_title_line', text, [
    _d(
      text,
      'Priya Raman\nHuman Resources',
      EntityType.company,
      DetectionSource.model,
    ),
  ]);
  text = 'Patient: Jean-Baptiste\nDelacroix-Moreau';
  add('repair_multiline_person_keeps_wrapped_name', text, [
    _d(
      text,
      'Jean-Baptiste\nDelacroix-Moreau',
      EntityType.person,
      DetectionSource.model,
    ),
  ]);
  text = '张三见过张三 😀';
  add('cjk_propagation_and_utf_offsets', text, [
    _d(text, '张三', EntityType.person, DetectionSource.model),
  ]);
  text = 'Bob\u00a0and Alice';
  add('disabled_detection_stays_disabled', text, [
    _d(text, 'Bob', EntityType.person, DetectionSource.manual, enabled: false),
    _d(text, 'Alice', EntityType.person, DetectionSource.manual),
  ]);

  final cases = <Map<String, Object?>>[];
  for (final definition in definitions) {
    final result = await DetectionPipeline([
      _Fixed(definition.detections),
    ], neverHide: definition.neverHide).run(definition.text);
    cases.add({
      'name': definition.name,
      'text': definition.text,
      'never_hide': definition.neverHide,
      'candidates': definition.detections
          .map((d) => _json(definition.text, d))
          .toList(),
      'expected': result.map((d) => _json(definition.text, d)).toList(),
    });
  }
  final document = {
    'schema_version': 1,
    'license': 'Apache-2.0',
    'source': 'current Dart DetectionPipeline reference implementation',
    'generated_by':
        'packages/docudis_engine/tool/generate_rust_pipeline_conformance.dart',
    'cases': cases,
  };
  final output = File('testdata/core-v1/pipeline.json');
  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(document)}\n',
  );
  stdout.writeln('Wrote ${cases.length} pipeline cases');
}

Map<String, Object?> _json(String text, Detection d) => {
  'type': d.type.placeholderName,
  'value': d.value,
  'start_utf8': utf8.encode(text.substring(0, d.start)).length,
  'end_utf8': utf8.encode(text.substring(0, d.end)).length,
  'start_utf16': d.start,
  'end_utf16': d.end,
  'confidence': d.confidence,
  'detector': d.detector,
  'source': d.source.name,
  'enabled': d.enabled,
};
