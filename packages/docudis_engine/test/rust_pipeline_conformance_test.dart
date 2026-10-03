// Copyright 2026 stonetech. Licensed under AGPL-3.0.

import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

class _Fixed implements Detector {
  _Fixed(this.values);
  final List<Detection> values;
  @override
  String get name => 'fixture';
  @override
  Future<List<Detection>> detect(String text) async => values;
}

void main() {
  test('Dart pipeline reproduces the shared Rust fixture', () async {
    final fixture = (jsonDecode(
      File('testdata/core-v1/pipeline.json').readAsStringSync(),
    ) as Map).cast<String, Object?>();
    for (final raw in fixture['cases']! as List<Object?>) {
      final c = (raw! as Map).cast<String, Object?>();
      final text = c['text']! as String;
      Detection detection(Object? raw) {
        final d = (raw! as Map).cast<String, Object?>();
        return Detection(
          type: EntityType.fromName(d['type']! as String)!,
          value: d['value']! as String,
          start: d['start_utf16']! as int,
          end: d['end_utf16']! as int,
          confidence: (d['confidence']! as num).toDouble(),
          detector: d['detector']! as String,
          source: DetectionSource.values.byName(d['source']! as String),
          enabled: d['enabled']! as bool,
        );
      }

      final result = await DetectionPipeline(
        [_Fixed((c['candidates']! as List<Object?>).map(detection).toList())],
        neverHide: (c['never_hide']! as List<Object?>).cast<String>(),
      ).run(text);
      final actual = [
        for (final d in result)
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
      expect(actual, c['expected'], reason: c['name']! as String);
    }
  });
}
