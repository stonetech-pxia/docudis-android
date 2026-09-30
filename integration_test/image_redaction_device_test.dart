// Paints over OCR'd words on a few benchmark photos, on a real phone, so
// the box alignment and the end-to-end effect can be looked at.
//
//   flutter test integration_test/image_redaction_device_test.dart -d <device id>
//
// Two PNGs per case go to <app support>/image-redaction/: `<id>-all.png`
// (every recognized word painted: anything still legible was missed or
// misaligned) and `<id>-detected.png` (what the app would produce). Pull
// them with:
//
//   adb exec-out run-as com.stonetech.docudis cat files/image-redaction/<name> > <name>
import 'dart:io';

import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/image_redaction.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _cases = [
  'benchmark/ocr/images/en-perspective-invoice.png',
  'benchmark/ocr/images/fr-low-contrast-receipt.png',
  'benchmark/ocr/images/zh-clean-notice.png',
  'benchmark/ocr/images/documents/doc-en-business-card.jpg',
  'benchmark/ocr/images/documents/doc-zh-boarding-card.jpg',
  'benchmark/ocr/images/documents/a4-en-bank-statement.jpg',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('image redaction on device', (tester) async {
    final support = await getApplicationSupportDirectory();
    final out = await Directory(p.join(support.path, 'image-redaction')).create(recursive: true);
    final tmp = await getTemporaryDirectory();
    final extractor = TextExtractor();
    final service = AnonymizeService(
      store: RecordStore(),
      extractor: extractor,
      modelLocator: ModelLocator(),
      dictionaryTerms: () async => const [],
      neverHideTerms: () async => const [],
      listOnly: () => false,
    );
    await service.warmUp();

    for (final asset in _cases) {
      final id = p.basenameWithoutExtension(asset);
      final data = await rootBundle.load(asset);
      final file = File(p.join(tmp.path, p.basename(asset)));
      await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));

      final sw = Stopwatch()..start();
      final extraction = await extractor.extract(FileInput(path: file.path, name: p.basename(asset)));
      final ocrMs = sw.elapsedMilliseconds;
      final image = extraction.image!;
      final detections = await service.detect(extraction.text);
      final detectMs = sw.elapsedMilliseconds - ocrMs;

      final all = [
        Detection(
          type: EntityType.custom,
          value: extraction.text,
          start: 0,
          end: extraction.text.length,
          confidence: 1,
          detector: 'all',
          source: DetectionSource.manual,
        ),
      ];
      final bytes = await file.readAsBytes();
      final allPng = await renderRedactedImage(bytes, image.layout.boxesFor(all));
      final detPng = await renderRedactedImage(bytes, image.layout.boxesFor(detections));
      final paintMs = sw.elapsedMilliseconds - ocrMs - detectMs;
      await File(p.join(out.path, '$id-all.png')).writeAsBytes(allPng, flush: true);
      await File(p.join(out.path, '$id-detected.png')).writeAsBytes(detPng, flush: true);

      // Characters (spaces aside) that no word box covers: text ML Kit
      // returned but whose element could not be placed.
      var covered = 0;
      for (final w in image.layout.words) {
        covered += extraction.text.substring(w.start, w.end).replaceAll(RegExp(r'\s'), '').length;
      }
      final uncovered = extraction.text.replaceAll(RegExp(r'\s'), '').length - covered;
      // ignore: avoid_print
      print('IMAGE_REDACTION $id words=${image.layout.words.length} uncoveredChars=$uncovered '
          'detections=${detections.where((d) => d.enabled).length} '
          'boxes=${image.layout.boxesFor(detections).length} '
          'ocr=${ocrMs}ms detect=${detectMs}ms paint=${paintMs}ms '
          'text=${extraction.text.length} chars');
      for (final d in detections.where((d) => d.enabled)) {
        // ignore: avoid_print
        print('  ${d.type.name.padRight(10)} ${d.value.replaceAll('\n', '⏎')}');
      }
    }
    // ignore: avoid_print
    print('IMAGE_REDACTION output ${out.path}');
  });
}
