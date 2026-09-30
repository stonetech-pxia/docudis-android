import 'dart:io';

import 'package:docudis/anonymize/core_differential.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:docudis_ffi/docudis_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final library = Platform.environment['DOCUDIS_LIBRARY'];
  test(
    'enabled differential mode calls and parses the real Core library',
    () async {
      const text = '😀 Alice';
      final detection = Detection(
        type: EntityType.person,
        value: 'Alice',
        start: 3,
        end: 8,
        confidence: 1,
        detector: 'integration',
        source: DetectionSource.manual,
      );
      final reference = anonymize(text, [detection]);
      final outcome =
          await DocudisCoreDifferential(
            enabled: true,
            native: DocudisNative.open(library),
          ).process(
            text: text,
            dartDetections: [detection],
            dartResult: reference,
            rustRequest: {
              'schema_version': 1,
              'text': text,
              'regions': <String>[],
              'selection': {'categories': <String>[]},
              'dictionary': <String>[],
              'never_hide': <String>[],
              'include_bundled_lists': false,
              'detections': [detection.toJson()],
            },
          );

      expect(outcome.anonymized.text, '😀 [PERSON_1]');
      expect(outcome.anonymized.map.restore(outcome.anonymized.text), text);
      expect(outcome.detections.single.start, 3);
      expect(outcome.detections.single.end, 8);
    },
    skip: library == null ? 'Set DOCUDIS_LIBRARY to the Core dylib' : false,
  );
}
