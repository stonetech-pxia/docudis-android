// Desktop NER benchmark: same engine code as the app, inference through
// benchmark/bench_server.py (Python onnxruntime). Speed numbers here are
// desktop numbers; run the phone integration test for device speed.
//
//   cd packages/docudis_engine
//   PYTHON=/path/to/python dart run benchmark/run_benchmark.dart \n//     [--model ../../assets/models/<dir>] [--stress] [--out ../../docs/ner-benchmark-desktop.md]
//   --stress appends the large-document boundary cases (10k / 50k / 150k chars).
//   Next to the .md it also writes .html (visual per-case comparison) and .json.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';
import 'package:docudis_engine/docudis_engine.dart';

const defaultModelDir = '../../assets/models/distilbert_ner_hrl';

/// Set from `--model <dir>`; the distilbert folder by default.
String modelDir = defaultModelDir;
const defaultDatasetPath = '../../benchmark/ner_cases.json';
const serverScript = '../../benchmark/bench_server.py';

class PythonClassifier implements TokenClassifier {
  PythonClassifier._(this._process, this._lines, this._stderr);

  final Process _process;
  final StreamIterator<String> _lines;
  final StreamSubscription<String> _stderr;

  static Future<PythonClassifier> start(String modelPath, NerModelSpec spec) async {
    final python = Platform.environment['PYTHON'] ?? 'python';
    final process = await Process.start(python, [
      serverScript,
      modelPath,
      spec.inputIdsName,
      spec.attentionMaskName,
      spec.outputName,
    ]);
    final errors = process.stderr.transform(utf8.decoder).listen(stderr.write);
    final lines = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final ready = await lines.moveNext().timeout(const Duration(seconds: 120));
    if (!ready || lines.current != 'ready') {
      throw StateError('bench_server.py did not start: ${lines.current}');
    }
    return PythonClassifier._(process, lines, errors);
  }

  @override
  Future<List<List<double>>> classify(List<int> inputIds, List<int> attentionMask) async {
    _process.stdin.writeln(jsonEncode({'ids': inputIds, 'mask': attentionMask}));
    await _process.stdin.flush();
    if (!await _lines.moveNext()) throw StateError('bench_server.py closed');
    final rows = jsonDecode(_lines.current) as List<dynamic>;
    return [
      for (final r in rows) [for (final v in r as List<dynamic>) (v as num).toDouble()],
    ];
  }

  @override
  Future<void> close() async {
    await _process.stdin.close();
    _process.kill();
    await _lines.cancel();
    await _stderr.cancel();
    // Without this the VM can linger on Windows waiting for the child's pipes.
    await _process.exitCode.timeout(const Duration(seconds: 5), onTimeout: () => -1);
  }
}

Future<void> main(List<String> args) async {
  final outIndex = args.indexOf('--out');
  final outPath = outIndex == -1 ? null : args[outIndex + 1];
  final modelIndex = args.indexOf('--model');
  if (modelIndex != -1) modelDir = args[modelIndex + 1];
  final datasetIndex = args.indexOf('--dataset');
  final datasetPath = datasetIndex == -1 ? defaultDatasetPath : args[datasetIndex + 1];

  final spec = NerModelSpec.fromJson(File('$modelDir/model.json').readAsStringSync());
  final tokenizer = NerTokenizer.fromSpec(
    spec.tokenizerKind,
    File('$modelDir/${spec.tokenizerFile}').readAsBytesSync(),
  );
  final classifier = await PythonClassifier.start('$modelDir/${spec.modelFile}', spec);
  final ner = NerDetector(spec: spec, tokenizer: tokenizer, classifier: classifier);
  final lists = BundledListDetector.bundled();

  final dataset = BenchmarkCase.parseDataset(File(datasetPath).readAsStringSync());
  final cases = [...dataset, if (args.contains('--stress')) ...stressCases(dataset)];
  // Warm-up so the first case does not pay for session start.
  await ner.detect('Warm up with John Smith in Paris.');

  final runner = BenchmarkRunner(
    detectorsFor: (c) => [
      RegexDetector.bundled(regions: RegexDetector.regionsForLanguages(c.languageTags, c.text)),
      lists,
      ner,
    ],
  );
  final results = <CaseResult>[];
  for (final c in cases) {
    final r = await runner.run(c);
    results.add(r);
    stdout.writeln('${c.id.padRight(16)} F1 ${(r.f1 * 100).round().toString().padLeft(3)}%  '
        '${r.elapsed.inMilliseconds.toString().padLeft(5)} ms');
  }
  await classifier.close();

  final run = BenchmarkRun(
    title: 'NER benchmark (desktop, Python onnxruntime)',
    platform: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}, '
        'CPU, onnxruntime via bench_server.py',
    modelName: spec.name,
    results: results,
  );
  final report = run.toMarkdown();
  stdout
    ..writeln()
    ..writeln(report);
  if (outPath != null) {
    final base = outPath.replaceFirst(RegExp(r'\.md$'), '');
    File(outPath).writeAsStringSync(report);
    File('$base.html').writeAsStringSync(renderHtml(run));
    File('$base.json').writeAsStringSync(run.toJson());
    stdout.writeln('Report written to $outPath, $base.html, $base.json');
  }
  exit(0);
}
