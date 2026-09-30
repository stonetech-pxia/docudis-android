// Renders the HTML (and Markdown) report from a saved benchmark run.
//
// Input is either a `*.json` written by a runner, or a `flutter test` log
// containing the `NER_BENCHMARK_JSON ` line the device test prints.
//
//   dart run benchmark/render_html.dart <run.json | device.log> <out.html> [out.md]
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';

const marker = 'NER_BENCHMARK_JSON ';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('usage: render_html.dart <run.json|log> <out.html> [out.md]');
    exit(64);
  }
  var source = File(args[0]).readAsStringSync();
  if (!source.trimLeft().startsWith('{')) {
    final line = source
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.contains(marker), orElse: () => '');
    if (line.isEmpty) {
      stderr.writeln('no "$marker" line found in ${args[0]}');
      exit(1);
    }
    source = line.substring(line.indexOf(marker) + marker.length);
  }
  final run = BenchmarkRun.fromJson(source);
  File(args[1]).writeAsStringSync(renderHtml(run));
  stdout.writeln('HTML written to ${args[1]}');
  if (args.length > 2) {
    File(args[2]).writeAsStringSync(run.toMarkdown());
    stdout.writeln('Markdown written to ${args[2]}');
  }
}
