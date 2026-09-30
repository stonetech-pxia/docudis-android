// On-device NER benchmark: same dataset and scorer as the desktop harness,
// inference through the app's real ONNX Runtime classifier. Prints the
// markdown report to the console and writes it to the app's documents dir.
//
//   flutter test integration_test/ner_benchmark_test.dart -d <device id> \
//     [--dart-define=NER_MODEL_DIR=models/distilbert_ner_hrl] [--dart-define=NER_STRESS=true]
//   (a non-default model dir must also be synced by the Gradle model tasks)
//
// The run is printed as one `NER_BENCHMARK_JSON {...}` line; save the test
// output to a log and render it on the desktop:
//   cd packages/docudis_engine && dart run benchmark/render_html.dart <log> ../../docs/<name>.html ../../docs/<name>.md
import 'dart:io';

import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/model/onnx_token_classifier.dart';
import 'package:docudis_engine/benchmark.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NER benchmark on device', (tester) async {
    const modelDir = String.fromEnvironment(
      'NER_MODEL_DIR',
      defaultValue: 'models/xlmr_ner_docudis',
    );
    final located = await ModelLocator(assetDir: modelDir).locate();
    final tokenizer = NerTokenizer.fromSpec(
      located.spec.tokenizerKind,
      await File(located.tokenizerPath).readAsBytes(),
    );
    final classifier = await OnnxTokenClassifier.load(located.modelPath, located.spec);
    final ner = NerDetector(spec: located.spec, tokenizer: tokenizer, classifier: classifier);

    final dataset = BenchmarkCase.parseDataset(
      await rootBundle.loadString('benchmark/ner_cases.json'),
    );
    const stress = bool.fromEnvironment('NER_STRESS');
    final cases = [...dataset, if (stress) ...stressCases(dataset)];
    await ner.detect('Warm up with John Smith in Paris.');

    final runner = BenchmarkRunner(
      detectorsFor: (c) => [
        RegexDetector.bundled(regions: RegexDetector.regionsForLanguages(c.languageTags, c.text)),
        BundledListDetector.bundled(),
        ner,
      ],
    );
    final results = <CaseResult>[];
    for (final c in cases) {
      final r = await runner.run(c);
      results.add(r);
      // ignore: avoid_print
      print('${c.id.padRight(16)} F1 ${(r.f1 * 100).round()}%  ${r.elapsed.inMilliseconds} ms');
    }
    await classifier.close();

    final run = BenchmarkRun(
      title: 'NER benchmark (device)',
      platform: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}, '
          'ONNX Runtime CPU via flutter_onnxruntime',
      modelName: located.spec.name,
      results: results,
    );
    // ignore: avoid_print
    print(run.toMarkdown());
    // One line, so the desktop renderer can pick it out of the test log.
    // ignore: avoid_print
    print('NER_BENCHMARK_JSON ${run.toJson()}');
    final dir = await getApplicationSupportDirectory();
    await File(p.join(dir.path, 'ner-benchmark-device.md')).writeAsString(run.toMarkdown());
    await File(p.join(dir.path, 'ner-benchmark-device.html')).writeAsString(renderHtml(run));

    expect(results, isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 20)));
}
