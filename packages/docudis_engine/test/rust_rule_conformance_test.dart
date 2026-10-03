// Copyright 2026 stonetech. Licensed under AGPL-3.0.

import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

void main() {
  test('Dart rules reproduce the shared UTF-8/UTF-16 fixture', () {
    final fixture = (jsonDecode(
      File('testdata/core-v1/rules.json').readAsStringSync(),
    ) as Map).cast<String, Object?>();
    final rules = {
      for (final source in bundledRulePackSources.values)
        for (final rule in parseRulePack(source)) rule.id: rule,
    };
    for (final rawCase in fixture['cases']! as List<Object?>) {
      final fixtureCase = (rawCase! as Map).cast<String, Object?>();
      final text = fixtureCase['text']! as String;
      final found = RegexDetector([rules[fixtureCase['rule_id']]!])
          .detectSync(text);
      final actual = [
        for (final d in found)
          {
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
          },
      ];
      expect(
        actual,
        fixtureCase['expected'],
        reason: fixtureCase['name']! as String,
      );
    }
  });
}
