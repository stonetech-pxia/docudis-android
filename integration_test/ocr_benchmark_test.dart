// On-device OCR benchmark. The image corpus and exact transcriptions live in
// benchmark/ocr_cases.json; recognition uses the real ML Kit plugin with the
// script declared by each case.
//
//   flutter test integration_test/ocr_benchmark_test.dart -d <device id>
//
// To compare recognizers for Latin-alphabet documents, rerun the en / fr / es
// cases with another script than the one they declare:
//
//   flutter test integration_test/ocr_benchmark_test.dart -d <device id> \n//     --dart-define=OCR_LATIN_SCRIPT=latin
//
// Text is read in page order, as the app does (ImageLayout.read). To score
// ML Kit's own block order instead, add --dart-define=OCR_ORDER=mlkit.
//
// The run is printed as one `OCR_BENCHMARK_JSON {...}` line. Markdown, HTML,
// and JSON copies are also written to the app support directory.
import 'dart:convert';
import 'dart:io';

import 'package:docudis/anonymize/image_redaction.dart';
import 'package:docudis_engine/benchmark.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OCR benchmark on device', (tester) async {
    final manifestSource = await rootBundle.loadString(
      'benchmark/ocr_cases.json',
    );
    final manifest = jsonDecode(manifestSource) as Map<String, dynamic>;
    final groundTruthAssets = <String, String>{};
    for (final value in manifest['cases'] as List<dynamic>) {
      final kase = (value as Map).cast<String, Object?>();
      final path = kase['expectedTextPath'] as String?;
      if (path != null) {
        groundTruthAssets[path] = await rootBundle.loadString(path);
      }
    }
    final cases = OcrBenchmarkCase.parseDataset(
      manifestSource,
      expectedTextAssets: groundTruthAssets,
    );
    expect(cases, isNotEmpty);
    expect(cases.map((kase) => kase.id).toSet(), hasLength(cases.length));

    final temporaryRoot = await getTemporaryDirectory();
    final runDirectory = await Directory(
      p.join(
        temporaryRoot.path,
        'ocr-benchmark-${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);
    final imageFiles = <String, File>{};
    final recognizers = <String, TextRecognizer>{};

    try {
      for (final kase in cases) {
        imageFiles[kase.id] = await _copyAssetImage(kase, runDirectory);
        for (final span in kase.criticalSpans) {
          expect(
            normalizeOcrText(kase.expectedText),
            contains(normalizeOcrText(span.value)),
            reason: '${kase.id}: critical span is absent from expectedText',
          );
        }
      }

      TextRecognizer recognizerFor(OcrBenchmarkCase kase) =>
          recognizers.putIfAbsent(
            _scriptFor(kase),
            () => TextRecognizer(script: _recognitionScript(_scriptFor(kase))),
          );

      Future<String> recognize(OcrBenchmarkCase kase) async {
        final result = await recognizerFor(kase)
            .processImage(InputImage.fromFilePath(imageFiles[kase.id]!.path));
        return _mlkitOrder ? result.text : ImageLayout.read(result).text;
      }

      // Exclude native model/session initialization from per-image timings,
      // matching the warm-up convention used by the NER benchmark.
      final warmedScripts = <String>{};
      for (final kase in cases) {
        if (!warmedScripts.add(_scriptFor(kase))) continue;
        try {
          await recognize(kase);
        } catch (error) {
          // Let the scored run record the error for every affected case.
          // ignore: avoid_print
          print('OCR warm-up failed for ${_scriptFor(kase)}: $error');
        }
      }

      final results = await OcrBenchmarkRunner(recognize: recognize)
          .runAll(cases);
      for (final result in results) {
        // ignore: avoid_print
        print(
          '${result.kase.id.padRight(28)} '
          'accuracy ${(result.characterAccuracy * 100).toStringAsFixed(1)}%  '
          '${result.elapsed.inMilliseconds} ms'
          '${result.error == null ? '' : '  ERROR ${result.error}'}',
        );
      }

      final scripts = cases.map(_scriptFor).toSet().toList()..sort();
      final run = OcrBenchmarkRun(
        title: 'OCR benchmark (device)',
        platform:
            '${Platform.operatingSystem} ${Platform.operatingSystemVersion}, '
            'Google ML Kit on-device text recognition',
        recognizerName: 'Google ML Kit (${scripts.join(', ')}; '
            '${_mlkitOrder ? 'ML Kit block order' : 'page order'})',
        results: results,
      );
      final markdown = run.toMarkdown();
      final json = run.toJson();
      // ignore: avoid_print
      print(markdown);
      // Keep this on one line so a desktop renderer can extract it from logs.
      // ignore: avoid_print
      print('OCR_BENCHMARK_JSON $json');

      final supportDirectory = await getApplicationSupportDirectory();
      final outputBase = p.join(supportDirectory.path, 'ocr-benchmark-device');
      await File('$outputBase.md').writeAsString(markdown);
      await File('$outputBase.html').writeAsString(renderOcrHtml(run));
      await File('$outputBase.json').writeAsString(json);

      final failures = results.where((result) => result.failed).toList();
      expect(
        failures,
        isEmpty,
        reason: failures
            .map((result) => '${result.kase.id}: ${result.error}')
            .join('\n'),
      );
    } finally {
      for (final recognizer in recognizers.values) {
        await recognizer.close();
      }
      if (await runDirectory.exists()) {
        await runDirectory.delete(recursive: true);
      }
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}

/// Set by `--dart-define=OCR_ORDER=mlkit`: score ML Kit's block order.
const _mlkitOrder = String.fromEnvironment('OCR_ORDER') == 'mlkit';

/// Set by `--dart-define=OCR_LATIN_SCRIPT=<script>`; empty keeps each case's
/// declared script.
const _latinScriptOverride = String.fromEnvironment('OCR_LATIN_SCRIPT');

String _scriptFor(OcrBenchmarkCase kase) =>
    _latinScriptOverride.isNotEmpty && const {'en', 'fr', 'es'}.contains(kase.lang)
        ? _latinScriptOverride
        : kase.script;

Future<File> _copyAssetImage(
  OcrBenchmarkCase kase,
  Directory destination,
) async {
  final data = await rootBundle.load(kase.imagePath);
  final extension = p.extension(kase.imagePath);
  final file = File(
    p.join(
      destination.path,
      '${kase.id}${extension.isEmpty ? '.png' : extension}',
    ),
  );
  return file.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    flush: true,
  );
}

TextRecognitionScript _recognitionScript(String name) {
  return switch (name.toLowerCase()) {
    'latin' => TextRecognitionScript.latin,
    'chinese' => TextRecognitionScript.chinese,
    'devanagari' || 'devanagiri' => TextRecognitionScript.devanagiri,
    'japanese' => TextRecognitionScript.japanese,
    'korean' => TextRecognitionScript.korean,
    _ => throw ArgumentError.value(name, 'script', 'Unsupported OCR script'),
  };
}
