// End-to-end smoke test of the anonymization pipeline on a real device:
// every input kind (pasted text, txt, docx, pdf, scanned pdf, image via OCR) goes through
// AnonymizeService.process, is stored, regenerated after a toggle, and
// restored. Exercises the real plugins: ONNX Runtime, ML Kit language ID,
// entity extraction, text recognition, pdfrx.
//
//   flutter test integration_test/anonymize_flow_test.dart -d <device id>
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:docudis/anonymize/anonymize_service.dart';
import 'package:docudis/anonymize/input/input_source.dart';
import 'package:docudis/anonymize/input/text_extractor.dart';
import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/storage/record_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const sample =
    'Dear Ms. Patel, your appointment with Dr. Alan Turing at Manchester Royal '
    'Infirmary is confirmed for 4 June 2024. Call 0161 276 1234 or write to '
    'alan.turing@example.org. 联系人张三，手机13812345678。';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late AnonymizeService service;
  final timings = <String, int>{};

  setUpAll(() async {
    tmp = await Directory(
      p.join((await getTemporaryDirectory()).path, 'flow-test'),
    ).create(recursive: true);
    service = AnonymizeService(
      store: RecordStore(),
      extractor: TextExtractor(),
      modelLocator: ModelLocator(),
      dictionaryTerms: () async => ['星辰科技'],
      neverHideTerms: () async => const [],
      listOnly: () => false,
    );
    final sw = Stopwatch()..start();
    await service.warmUp();
    timings['model warm-up'] = sw.elapsedMilliseconds;
  });

  Future<void> check(String label, InputSource source) async {
    final sw = Stopwatch()..start();
    final record = await service.process(source);
    timings[label] = sw.elapsedMilliseconds;
    final detail = await service.store.load(record.id);
    // ignore: avoid_print
    print('[$label] ${sw.elapsedMilliseconds} ms, ${detail.detections.length} detections\n'
        '${detail.output}');
    expect(detail.output, contains('[PERSON_'), reason: '$label: no person placeholder');
    expect(detail.output, contains('[PHONE_'), reason: '$label: no phone placeholder');
    expect(detail.output, contains('[EMAIL_'), reason: '$label: no e-mail placeholder');
    expect(detail.output, isNot(contains('13812345678')));
    expect(File(detail.outputPath).existsSync(), isTrue);

    // Toggle the first detection off and regenerate in place.
    final toggled = [
      detail.detections.first.copyWith(enabled: false),
      ...detail.detections.skip(1),
    ];
    final again = await service.reapply(record.id, toggled);
    expect(again.output, contains(detail.detections.first.value));
    expect(again.record.updatedAt.isAfter(detail.record.updatedAt), isTrue);

    // Restore a mangled reply.
    final restored = await service.restore(record.id, 'Reply for **[person 1]**, ok?');
    expect(restored, isNot(contains('[person 1]')));
  }

  testWidgets('pasted text', (tester) async {
    await check('paste', const TextInput(sample));
  });

  testWidgets('txt file', (tester) async {
    final f = File(p.join(tmp.path, 'note.txt'))..writeAsStringSync(sample);
    await check('txt', FileInput(path: f.path, name: 'note.txt'));
  });

  testWidgets('docx file', (tester) async {
    final f = File(p.join(tmp.path, 'letter.docx'))..writeAsBytesSync(_docx(sample));
    await check('docx', FileInput(path: f.path, name: 'letter.docx'));
  });

  testWidgets('pdf file', (tester) async {
    final f = File(p.join(tmp.path, 'letter.pdf'))..writeAsBytesSync(_pdf(sample));
    await check('pdf', FileInput(path: f.path, name: 'letter.pdf'));
  });

  testWidgets('scanned pdf via OCR', (tester) async {
    final f = File(p.join(tmp.path, 'scan.pdf'))
      ..writeAsBytesSync(await _scannedPdf(sample));
    await check('scanned pdf', FileInput(path: f.path, name: 'scan.pdf'));
  });

  testWidgets('image via OCR', (tester) async {
    final f = File(p.join(tmp.path, 'photo.png'))
      ..writeAsBytesSync(await _textImage(sample));
    await check('image', FileInput(path: f.path, name: 'photo.png'));
  });

  testWidgets('unsupported and empty inputs fail cleanly', (tester) async {
    final f = File(p.join(tmp.path, 'sheet.xlsx'))..writeAsBytesSync([0, 1, 2]);
    await expectLater(
      service.process(FileInput(path: f.path, name: 'sheet.xlsx')),
      throwsA(isA<UnsupportedInputException>()),
    );
    await expectLater(
      service.process(const TextInput('   \n')),
      throwsA(isA<UnsupportedInputException>()),
    );
  });

  tearDownAll(() {
    // ignore: avoid_print
    print('TIMINGS ${jsonEncode(timings)}');
  });
}

/// Minimal .docx: one paragraph per line of [text].
List<int> _docx(String text) {
  final paragraphs = text
      .split('\n')
      .map((l) => '<w:p><w:r><w:t xml:space="preserve">${_xml(l)}</w:t></w:r></w:p>')
      .join();
  final document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:body>$paragraphs</w:body></w:document>';
  const contentTypes = '<?xml version="1.0" encoding="UTF-8"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/word/document.xml" '
      'ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
      '</Types>';
  final archive = Archive()
    ..addFile(ArchiveFile.string('[Content_Types].xml', contentTypes))
    ..addFile(ArchiveFile.string('word/document.xml', document));
  return ZipEncoder().encode(archive);
}

String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

/// Minimal text PDF (Latin text only; pdfium rebuilds the xref itself).
/// Non-Latin characters are dropped because the base font is WinAnsi.
List<int> _pdf(String text) {
  final latin = text.replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
  final escaped = latin.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
  final content = 'BT /F1 11 Tf 40 760 Td ($escaped) Tj ET';
  final objects = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R '
        '/Resources << /Font << /F1 5 0 R >> >> >>',
    '<< /Length ${content.length} >>\nstream\n$content\nendstream',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
  ];
  final buf = StringBuffer('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(buf.length);
    buf.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
  }
  final xref = buf.length;
  buf.write('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    buf.write('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  buf.write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n');
  return latin1.encode(buf.toString());
}

/// One-page PDF whose only content is a picture of [text]: no text layer,
/// like a scanner's output. The bitmap is stored as a Flate-compressed RGB
/// image XObject, drawn to fill an A4 page.
Future<List<int>> _scannedPdf(String text) async {
  final image = await _textImageRaw(text);
  final rgb = Uint8List(1400 * 600 * 3);
  for (var i = 0, j = 0; i < rgb.length; i += 3, j += 4) {
    rgb[i] = image[j];
    rgb[i + 1] = image[j + 1];
    rgb[i + 2] = image[j + 2];
  }
  final compressed = zlib.encode(rgb);
  const content = 'q 595 0 0 255 0 587 cm /Im1 Do Q';
  final objects = <List<int>>[
    latin1.encode('<< /Type /Catalog /Pages 2 0 R >>'),
    latin1.encode('<< /Type /Pages /Kids [3 0 R] /Count 1 >>'),
    latin1.encode('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R '
        '/Resources << /XObject << /Im1 5 0 R >> >> >>'),
    latin1.encode('<< /Length ${content.length} >>\nstream\n$content\nendstream'),
    [
      ...latin1.encode('<< /Type /XObject /Subtype /Image /Width 1400 /Height 600 '
          '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode '
          '/Length ${compressed.length} >>\nstream\n'),
      ...compressed,
      ...latin1.encode('\nendstream'),
    ],
  ];
  final out = BytesBuilder();
  out.add(latin1.encode('%PDF-1.4\n'));
  final offsets = <int>[];
  for (var i = 0; i < objects.length; i++) {
    offsets.add(out.length);
    out.add(latin1.encode('${i + 1} 0 obj\n'));
    out.add(objects[i]);
    out.add(latin1.encode('\nendobj\n'));
  }
  final xref = out.length;
  final trailer = StringBuffer('xref\n0 ${objects.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    trailer.write('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  trailer.write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n');
  out.add(latin1.encode(trailer.toString()));
  return out.takeBytes();
}

/// Renders [text] onto a white 1400x600 PNG, like a photographed note.
Future<List<int>> _textImage(String text) async {
  final image = await _textImageUi(text);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

/// Same picture as [_textImage], as raw RGBA bytes.
Future<Uint8List> _textImageRaw(String text) async {
  final image = await _textImageUi(text);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return bytes!.buffer.asUint8List();
}

Future<ui.Image> _textImageUi(String text) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 1400, 600), Paint()..color = Colors.white);
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(color: Colors.black, fontSize: 34, height: 1.6),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 1320);
  painter.paint(canvas, const Offset(40, 40));
  return recorder.endRecording().toImage(1400, 600);
}
