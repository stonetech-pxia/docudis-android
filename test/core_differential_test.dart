import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:docudis/anonymize/core_differential.dart';

void main() {
  test(
    'disabled differential mode returns the Dart reference result',
    () async {
      const text = 'Alice: alice@example.com';
      final detections = [
        Detection(
          type: EntityType.email,
          value: 'alice@example.com',
          start: 7,
          end: text.length,
          confidence: 1,
          detector: 'test',
          source: DetectionSource.manual,
        ),
      ];
      final reference = anonymize(text, detections);
      final outcome = await DocudisCoreDifferential(enabled: false).process(
        text: text,
        dartDetections: detections,
        dartResult: reference,
        rustRequest: const {'schema_version': 1, 'text': text},
      );

      expect(outcome.anonymized.text, reference.text);
      expect(outcome.anonymized.map.toJson(), reference.map.toJson());
      expect(outcome.detections.single.toJson(), detections.single.toJson());
    },
  );
}
