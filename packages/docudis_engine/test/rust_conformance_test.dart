// Copyright 2026 stonetech. Licensed under AGPL-3.0.

import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:test/test.dart';

File _fixtureFile() {
  for (final path in [
    'testdata/core-v1/anonymization.json',
    'conformance/fixtures/v1/anonymization.json',
  ]) {
    final file = File(path);
    if (file.existsSync()) return file;
  }
  throw StateError('Could not find the shared anonymization fixture');
}

int _utf8FromUtf16(String text, int utf16Offset) =>
    utf8.encode(text.substring(0, utf16Offset)).length;

int _utf16FromUtf8(String text, int utf8Offset) {
  final bytes = utf8.encode(text);
  return utf8.decode(bytes.sublist(0, utf8Offset)).length;
}

void main() {
  test(
    'Dart and Rust use the same language-neutral anonymization fixtures',
    () {
      final fixture = (jsonDecode(_fixtureFile().readAsStringSync()) as Map)
          .cast<String, Object?>();
      expect(fixture['schema_version'], 1);
      final cases = fixture['cases']! as List<dynamic>;

      for (final rawCase in cases) {
        final fixtureCase = (rawCase as Map).cast<String, Object?>();
        final name = fixtureCase['name']! as String;
        final text = fixtureCase['text']! as String;
        final detections = <Detection>[];

        for (final rawDetection
            in fixtureCase['detections']! as List<dynamic>) {
          final detection = (rawDetection as Map).cast<String, Object?>();
          final startUtf8 = detection['start_utf8']! as int;
          final endUtf8 = detection['end_utf8']! as int;
          final startUtf16 = detection['start_utf16']! as int;
          final endUtf16 = detection['end_utf16']! as int;
          expect(
            _utf8FromUtf16(text, startUtf16),
            startUtf8,
            reason: '$name start offset',
          );
          expect(
            _utf8FromUtf16(text, endUtf16),
            endUtf8,
            reason: '$name end offset',
          );
          expect(
            _utf16FromUtf8(text, startUtf8),
            startUtf16,
            reason: '$name reverse start offset',
          );
          expect(
            _utf16FromUtf8(text, endUtf8),
            endUtf16,
            reason: '$name reverse end offset',
          );
          expect(
            text.substring(startUtf16, endUtf16),
            detection['value'],
            reason: '$name detection value',
          );
          detections.add(
            Detection(
              type: EntityType.fromName(detection['type']! as String)!,
              value: detection['value']! as String,
              start: startUtf16,
              end: endUtf16,
              confidence: (detection['confidence']! as num).toDouble(),
              detector: detection['detector']! as String,
              source: DetectionSource.values.byName(
                detection['source']! as String,
              ),
              enabled: detection['enabled']! as bool,
            ),
          );
        }

        PlaceholderMap? previous;
        final previousEntries = fixtureCase['previous_map'] as List<dynamic>?;
        if (previousEntries != null) {
          previous = PlaceholderMap()
            ..import(
              previousEntries.map(
                (rawEntry) => MappingEntry.fromJson(
                  (rawEntry as Map).cast<String, Object?>(),
                ),
              ),
            );
        }
        final actual = anonymize(text, detections, previous: previous);
        final expected = (fixtureCase['expected']! as Map)
            .cast<String, Object?>();
        expect(actual.text, expected['text'], reason: '$name text');
        expect(
          actual.map.entries.map((entry) => entry.toJson()).toList(),
          expected['mappings'],
          reason: '$name mappings',
        );
        final expectedReplacements = expected['replacements']! as List<dynamic>;
        expect(
          actual.replacements.length,
          expectedReplacements.length,
          reason: '$name replacement count',
        );
        for (var index = 0; index < actual.replacements.length; index++) {
          final replacement = actual.replacements[index];
          final expectedReplacement = (expectedReplacements[index] as Map)
              .cast<String, Object?>();
          expect(
            replacement.start,
            expectedReplacement['start_utf16'],
            reason: '$name replacement $index UTF-16 start',
          );
          expect(
            replacement.end,
            expectedReplacement['end_utf16'],
            reason: '$name replacement $index UTF-16 end',
          );
          expect(
            replacement.placeholder,
            expectedReplacement['placeholder'],
            reason: '$name replacement $index placeholder',
          );
          expect(
            _utf8FromUtf16(text, replacement.start),
            expectedReplacement['start_utf8'],
            reason: '$name replacement $index UTF-8 start',
          );
          expect(
            _utf8FromUtf16(text, replacement.end),
            expectedReplacement['end_utf8'],
            reason: '$name replacement $index UTF-8 end',
          );
        }
        for (final rawRestore in expected['restore_cases']! as List<dynamic>) {
          final restore = (rawRestore as Map).cast<String, Object?>();
          expect(
            actual.map.restore(restore['input']! as String),
            restore['output'],
            reason: '$name restore ${restore['input']}',
          );
        }
      }
    },
  );
}
