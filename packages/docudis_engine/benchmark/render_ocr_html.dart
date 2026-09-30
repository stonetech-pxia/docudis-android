// Renders HTML (and optionally Markdown) from a saved OCR benchmark run.
//
// Input may be a JSON file or a Flutter test log containing the
// `OCR_BENCHMARK_JSON ` marker printed by a device integration test.
//
//   dart run benchmark/render_ocr_html.dart <run.json|device.log> <out.html> [out.md]
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';

const marker = 'OCR_BENCHMARK_JSON ';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'usage: render_ocr_html.dart <run.json|log> <out.html> [out.md]',
    );
    exit(64);
  }

  var source = File(args[0]).readAsStringSync();
  if (!source.trimLeft().startsWith('{')) {
    final line = source
        .split('\n')
        .map((value) => value.trim())
        .firstWhere((value) => value.contains(marker), orElse: () => '');
    if (line.isEmpty) {
      stderr.writeln('no "$marker" line found in ${args[0]}');
      exit(1);
    }
    source = line.substring(line.indexOf(marker) + marker.length);
  }

  final run = OcrBenchmarkRun.fromJson(source);
  File(args[1]).writeAsStringSync(renderOcrHtml(run));
  stdout.writeln('HTML written to ${args[1]}');
  if (args.length > 2) {
    File(args[2]).writeAsStringSync(run.toMarkdown());
    stdout.writeln('Markdown written to ${args[2]}');
  }
}
