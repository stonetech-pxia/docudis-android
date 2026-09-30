import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../image_redaction.dart';
import '../output/document_redaction.dart';
import '../output/docx_redaction.dart';
import 'input_source.dart';

/// Extracted text, plus what is needed to redact the input itself: the OCR
/// layout of a single image, or the source of a PDF / Word document.
class Extraction {
  const Extraction(this.text, {this.image, this.document});

  final String text;

  /// The image that was OCR'd and where its words sit in [text].
  final ({String path, ImageLayout layout})? image;

  /// The document [text] came from; [pdf] says where each page's text is.
  final ({String path, DocumentKind kind, PdfLayout? pdf})? document;
}

/// Turns any [InputSource] into plain text. Everything runs on the phone.
class TextExtractor {
  static const textExtensions = {'txt', 'md', 'csv', 'text', 'log'};
  static const imageExtensions = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'bmp'};

  /// Extensions the file picker offers.
  static const pickableExtensions = [
    'txt', 'md', 'csv', 'pdf', 'docx', //
    'jpg', 'jpeg', 'png', 'webp', 'heic',
  ];

  Future<Extraction> extract(InputSource source) async {
    final result = await switch (source) {
      TextInput(:final text) => Future.value(Extraction(text)),
      CameraInput(:final path) => _ocr(path),
      FileInput() => _fromFile(source),
    };
    if (result.text.trim().isEmpty) throw const UnsupportedInputException('empty');
    return result;
  }

  Future<Extraction> _fromFile(FileInput file) async {
    final ext = file.extension;
    if (textExtensions.contains(ext)) return Extraction(await _readText(file.path));
    if (imageExtensions.contains(ext)) return _ocr(file.path);
    if (ext == 'pdf') return _pdf(file.path);
    if (ext == 'docx') return _docx(file.path);
    throw const UnsupportedInputException('extension');
  }

  Future<String> _readText(String path) async {
    final bytes = await File(path).readAsBytes();
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  Future<Extraction> _pdf(String path) async {
    await ensurePdfrx();
    final doc = await PdfDocument.openFile(path);
    TextRecognizer? recognizer;
    try {
      final buffer = StringBuffer();
      final pages = <PdfPageSpan>[];
      for (final page in doc.pages) {
        final offset = buffer.length;
        var text = (await page.loadText())?.fullText ?? '';
        ImageLayout? scan;
        if (text.trim().isEmpty) {
          // No text layer on this page: scanned. Render it and OCR it.
          recognizer ??= _recognizer();
          final read = await _ocrPage(page, recognizer);
          text = read.text;
          scan = read.layout.shifted(offset);
        }
        if (text.trim().isNotEmpty) {
          buffer
            ..writeln(text)
            ..writeln();
        }
        pages.add(PdfPageSpan(
          offset: offset,
          length: text.trim().isEmpty ? 0 : text.length,
          scan: scan,
        ));
      }
      return Extraction(
        buffer.toString(),
        document: (path: path, kind: DocumentKind.pdf, pdf: PdfLayout(pages)),
      );
    } finally {
      await recognizer?.close();
      await doc.dispose();
    }
  }

  /// Renders [page] to a temporary PNG at [PdfLayout.scanDpi] and runs OCR
  /// on it. The PNG is deleted afterwards; the raw bitmap is freed as soon
  /// as it is encoded.
  Future<({String text, ImageLayout layout})> _ocrPage(
    PdfPage page,
    TextRecognizer recognizer,
  ) async {
    const empty = (text: '', layout: ImageLayout(words: []));
    final scale = PdfLayout.scanDpi / 72;
    final rendered = await page.render(
      fullWidth: page.width * scale,
      fullHeight: page.height * scale,
      annotationRenderingMode: PdfAnnotationRenderingMode.none,
    );
    if (rendered == null) return empty;
    final ui.Image image;
    try {
      image = await rendered.createImage();
    } finally {
      rendered.dispose();
    }
    final Uint8List png;
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return empty;
      png = data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
    final tmp = await getTemporaryDirectory();
    final file = File(p.join(tmp.path, 'docudis-scan-${page.pageNumber}.png'));
    try {
      await file.writeAsBytes(png, flush: true);
      return ImageLayout.read(
        await recognizer.processImage(InputImage.fromFilePath(file.path)),
      );
    } finally {
      if (file.existsSync()) file.deleteSync();
    }
  }

  Future<Extraction> _docx(String path) async {
    final String text;
    try {
      text = docxText(await File(path).readAsBytes());
    } on FormatException {
      throw const UnsupportedInputException('extension');
    }
    return Extraction(
      text,
      document: (path: path, kind: DocumentKind.docx, pdf: null),
    );
  }

  Future<Extraction> _ocr(String path) async {
    final recognizer = _recognizer();
    try {
      final read = ImageLayout.read(
        await recognizer.processImage(InputImage.fromFilePath(path)),
      );
      return Extraction(read.text, image: (path: path, layout: read.layout));
    } finally {
      await recognizer.close();
    }
  }

  static TextRecognizer _recognizer() => TextRecognizer(script: _scriptForLocale());

  /// The Chinese recognizer also reads Latin text, so it is the default;
  /// Hindi users get the Devanagari one. See docs/anonymization-design.md.
  static TextRecognitionScript _scriptForLocale() {
    final lang = ui.PlatformDispatcher.instance.locale.languageCode;
    return lang == 'hi' || lang == 'mr' || lang == 'ne'
        ? TextRecognitionScript.devanagiri
        : TextRecognitionScript.chinese;
  }
}
