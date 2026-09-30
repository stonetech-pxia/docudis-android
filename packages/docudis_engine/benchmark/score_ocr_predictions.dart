// Scores predictions from a desktop/server OCR engine with the same metrics
// used by the on-device integration benchmark.
//
// Run from packages/docudis_engine:
//   dart run benchmark/score_ocr_predictions.dart \
//     ../../benchmark/ocr_cases.json \
//     ../../docs/benchmark/ocr-ppocrv6-small-predictions.json \
//     ../../docs/benchmark/ocr-ppocrv6-small
import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';

void main(List<String> arguments) {
  if (arguments.length != 3) {
    stderr.writeln(
      'usage: score_ocr_predictions.dart '
      '<manifest.json> <predictions.json> <output-base>',
    );
    exitCode = 64;
    return;
  }

  final manifestFile = File(arguments[0]).absolute;
  final manifestSource = manifestFile.readAsStringSync();
  final manifest = jsonDecode(manifestSource) as Map<String, dynamic>;
  final repositoryRoot = manifestFile.parent.parent;
  final groundTruthAssets = <String, String>{};
  for (final value in manifest['cases'] as List<dynamic>) {
    final kase = (value as Map).cast<String, Object?>();
    final path = kase['expectedTextPath'] as String?;
    if (path != null) {
      groundTruthAssets[path] = File.fromUri(
        repositoryRoot.uri.resolve(path.replaceAll('\\', '/')),
      ).readAsStringSync();
    }
  }
  final cases = OcrBenchmarkCase.parseDataset(
    manifestSource,
    expectedTextAssets: groundTruthAssets,
  );

  final predictions =
      jsonDecode(File(arguments[1]).readAsStringSync()) as Map<String, dynamic>;
  final predictionsById = <String, Map<String, Object?>>{
    for (final value in predictions['results'] as List<dynamic>)
      (value as Map)['id'] as String: value.cast<String, Object?>(),
  };
  final results = <OcrCaseResult>[];
  for (final kase in cases) {
    final prediction = predictionsById[kase.id];
    if (prediction == null) {
      throw FormatException('Missing prediction for ${kase.id}');
    }
    // VLM engines emit Markdown; strip it the same way as Markdown ground truth.
    final recognizedText = prediction['recognizedText'] as String;
    results.add(
      OcrBenchmarkScorer.score(
        kase,
        prediction['recognizedTextFormat'] == 'markdown'
            ? ocrGroundTruthMarkdownToText(recognizedText)
            : recognizedText,
        Duration(microseconds: prediction['elapsedMicros'] as int),
        error: prediction['error'] as String?,
      ),
    );
  }

  final run = OcrBenchmarkRun(
    title: predictions['title'] as String,
    platform: predictions['platform'] as String,
    recognizerName: predictions['recognizerName'] as String,
    results: results,
  );
  final outputBase = arguments[2];
  File('$outputBase.json').writeAsStringSync(run.toJson());
  File('$outputBase.md').writeAsStringSync(run.toMarkdown());
  File('$outputBase.html').writeAsStringSync(renderOcrHtml(run));

  for (final result in results) {
    stdout.writeln(
      '${result.kase.id.padRight(36)} '
      'accuracy ${(result.characterAccuracy * 100).toStringAsFixed(1)}%  '
      '${result.elapsed.inMilliseconds} ms'
      '${result.error == null ? '' : '  ERROR ${result.error}'}',
    );
  }
  stdout.write(run.toMarkdown());
}
