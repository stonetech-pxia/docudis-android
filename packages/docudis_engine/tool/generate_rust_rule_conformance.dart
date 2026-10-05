// Copyright 2026 Pengda Xia (stonetech). Licensed under AGPL-3.0.
//
// Generates the shared Rust/Dart regex conformance fixture from the current
// working-tree rule packs. Rule definitions derive from DocCloak.Core;
// preserve LICENSE-DocCloak.Core and NOTICE-DocCloak.Core.

import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';

int utf8Offset(String text, int utf16) =>
    utf8.encode(text.substring(0, utf16)).length;

void main() {
  final cases = <Map<String, Object?>>[];
  for (final pack in bundledRulePackSources.entries) {
    for (final rule in parseRulePack(pack.value)) {
      for (var index = 0; index < rule.examples.length; index++) {
        final text = rule.examples[index];
        cases.add(_case('${rule.id}:example:$index', rule, text));
      }
    }
  }
  final rules = [
    for (final source in bundledRulePackSources.values)
      ...parseRulePack(source),
  ];
  for (final negative in const [
    ('regex:universal:credit_card', '4111 1111 1111 1112'),
    ('regex:universal:ipv4', '999.1.1.1'),
    ('regex:universal:email', 'not-an-email@example'),
    ('regex:us:ssn', '000-00-0000'),
    ('regex:gb:nhs', '943 476 5918'),
    ('regex:universal:iban', 'GB29 NWBK 6016 1331 9268 18'),
  ]) {
    final rule = rules.singleWhere((rule) => rule.id == negative.$1);
    cases.add(_case('${rule.id}:hard-negative', rule, negative.$2));
  }
  final document = {
    'schema_version': 1,
    'license': 'Apache-2.0',
    'source': 'packages/docudis_engine/rules/*.json (DocCloak.Core + Docudis working-tree changes)',
    'generated_by':
        'packages/docudis_engine/tool/generate_rust_rule_conformance.dart',
    'offset_contract': {
      'utf8': 'Rust/C half-open bytes',
      'utf16': 'Dart half-open code units',
    },
    'cases': cases,
  };
  final output = File('testdata/core-v1/rules.json');
  output.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(document)}\n',
  );
  stdout.writeln('Wrote ${cases.length} rule cases to ${output.path}');
}

Map<String, Object?> _case(String name, RegexRule rule, String text) {
  final detections = RegexDetector([rule]).detectSync(text);
  return {
    'name': name,
    'rule_id': rule.id,
    'text': text,
    'expected': [
      for (final detection in detections)
        {
          'type': detection.type.placeholderName,
          'value': detection.value,
          'start_utf8': utf8Offset(text, detection.start),
          'end_utf8': utf8Offset(text, detection.end),
          'start_utf16': detection.start,
          'end_utf16': detection.end,
          'confidence': detection.confidence,
          'detector': detection.detector,
          'source': detection.source.name,
          'enabled': detection.enabled,
        },
    ],
  };
}
