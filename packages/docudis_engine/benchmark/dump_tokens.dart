// Prints per-token model labels for one benchmark case, to tell model
// behaviour apart from decoding bugs.
//
//   PYTHON=... dart run benchmark/dump_tokens.dart [--model <dir>] <case-id>...
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';
import 'package:docudis_engine/docudis_engine.dart';

import 'run_benchmark.dart' show PythonClassifier, defaultDatasetPath, modelDir;

Future<void> main(List<String> args) async {
  final modelIndex = args.indexOf('--model');
  if (modelIndex != -1) modelDir = args[modelIndex + 1];
  final caseIds = [for (var i = 0; i < args.length; i++) if (i != modelIndex && i != modelIndex + 1) args[i]];
  final spec = NerModelSpec.fromJson(File('$modelDir/model.json').readAsStringSync());
  final tokenizer = NerTokenizer.fromSpec(
    spec.tokenizerKind,
    File('$modelDir/${spec.tokenizerFile}').readAsBytesSync(),
  );
  final classifier = await PythonClassifier.start('$modelDir/${spec.modelFile}', spec);
  final cases = BenchmarkCase.parseDataset(File(defaultDatasetPath).readAsStringSync());
  for (final id in caseIds) {
    final kase = cases.firstWhere((c) => c.id == id);
    final enc = tokenizer.encode(kase.text);
    final ids = [tokenizer.startId, ...enc.ids, tokenizer.endId];
    final logits = await classifier.classify(ids, List.filled(ids.length, 1));
    stdout.writeln('== $id');
    for (var t = 0; t < enc.length; t++) {
      final row = logits[t + 1];
      var best = 0;
      for (var i = 1; i < row.length; i++) {
        if (row[i] > row[best]) best = i;
      }
      final piece = kase.text.substring(enc.starts[t], enc.ends[t]);
      stdout.writeln('${piece.padRight(14)} w=${enc.wordIds[t]}  ${spec.labels[best]}');
    }
  }
  await classifier.close();
}
