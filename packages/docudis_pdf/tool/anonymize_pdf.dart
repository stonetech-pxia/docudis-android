// Runs the Docudis detection engine over a PDF's text, the way the app
// does, replaces what it finds with the app's placeholders, and checks the
// result.
//
//   dart run tool/anonymize_pdf.dart [--share] <in.pdf> <out.pdf> <lang> [<term> ...]
//
// --share makes the copy the app hands to other apps (anonymizePdf) instead
// of only taking the text out.
//
// <lang> (fr, en, es, ...) picks the regional rule packs; the app gets it from
// ML Kit language id. The NER model and ML Kit only run on a phone, so names
// they would find are given as terms here: those go through the dictionary
// detector, like the user's own word list in the app.

import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:pdfrx_engine/pdfrx_engine.dart';

import 'src/check.dart';

Future<void> main(List<String> arguments) async {
  final args = [...arguments];
  final share = args.remove('--share');
  if (args.length < 3) {
    stderr.writeln('usage: anonymize_pdf [--share] <in.pdf> <out.pdf> <lang> [<term> ...]');
    exit(64);
  }
  final input = File(args[0]).readAsBytesSync();
  await pdfrxInitialize();
  final original = await PdfDocument.openData(input, sourceName: 'original');

  // The document text exactly as TextExtractor._pdf builds it, remembering
  // where each page starts.
  final pages = <({int offset, PdfPageRawText text})>[];
  final buffer = StringBuffer();
  for (final page in original.pages) {
    final text = (await page.loadText())!;
    pages.add((offset: buffer.length, text: text));
    if (text.fullText.trim().isNotEmpty) {
      buffer
        ..writeln(text.fullText)
        ..writeln();
    }
  }
  final document = buffer.toString();

  final detections = await DetectionPipeline([
    DictionaryDetector(args.skip(3)),
    RegexDetector.bundled(regions: RegexDetector.regionsForLanguages([args[2]], document)),
    BundledListDetector.bundled(),
  ]).run(document);

  // Placeholders numbered in reading order, as anonymize() does.
  final map = PlaceholderMap();
  final plan = Plan();
  for (final d in detections.where((d) => d.enabled)) {
    final label = map.placeholderFor(d.value, d.type);
    final p = pages.lastIndexWhere((page) => page.offset <= d.start);
    final length = pages[p].text.fullText.length;
    final start = d.start - pages[p].offset;
    final end = d.end - pages[p].offset;
    stdout.writeln('page ${p + 1} $label ${d.detector}: ${d.value.replaceAll(RegExp(r'\s+'), ' ')}');
    if (start >= length) continue; // in the separator written after the page
    plan.add(p, pages[p].text, start, end < length ? end : length, label);
  }
  exit(await redactAndCheck(input, original, plan, args[1], share: share) ? 0 : 1);
}
