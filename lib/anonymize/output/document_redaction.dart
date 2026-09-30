import 'dart:io';
import 'dart:math';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:docudis_pdf/docudis_pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

import '../image_redaction.dart';
import 'docx_redaction.dart';

/// Documents that go out as a redacted copy of themselves rather than as
/// plain text.
enum DocumentKind {
  pdf('pdf', 'application/pdf'),
  docx(
    'docx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  );

  const DocumentKind(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

/// Where one PDF page's text sits in the extracted text. A scanned page
/// (no text layer) also has the OCR layout of its rendering at
/// [PdfLayout.scanDpi], with offsets into the whole text.
class PdfPageSpan {
  const PdfPageSpan({required this.offset, required this.length, this.scan});

  final int offset;

  /// Characters the page contributed; 0 for a page with nothing on it.
  final int length;
  final ImageLayout? scan;

  Map<String, Object?> toJson() => {
    'offset': offset,
    'length': length,
    if (scan != null) 'scan': scan!.toJson(),
  };

  factory PdfPageSpan.fromJson(Map<String, Object?> j) => PdfPageSpan(
    offset: j['offset'] as int,
    length: j['length'] as int,
    scan: j['scan'] == null
        ? null
        : ImageLayout.fromJson((j['scan'] as Map).cast<String, Object?>()),
  );
}

class PdfLayout {
  const PdfLayout(this.pages);

  /// Scanned pages are rendered at this resolution for OCR.
  static const scanDpi = 200.0;

  final List<PdfPageSpan> pages;

  List<Object?> toJson() => [for (final p in pages) p.toJson()];

  factory PdfLayout.fromJson(List<dynamic> j) => PdfLayout([
    for (final p in j) PdfPageSpan.fromJson((p as Map).cast<String, Object?>()),
  ]);
}

bool _pdfrxReady = false;

/// pdfrx must be initialized once before any PDF is opened or redacted.
Future<void> ensurePdfrx() async {
  if (_pdfrxReady) return;
  await pdfrxFlutterInitialize();
  _pdfrxReady = true;
}

/// The redacted copy of the document at [sourcePath]: the same edits as
/// [result] made to the file itself (see [redactDocx], [anonymizePdf]).
Future<Uint8List> redactDocument({
  required DocumentKind kind,
  required String sourcePath,
  required PdfLayout? pdf,
  required List<Detection> detections,
  required AnonymizedText result,
}) async {
  final bytes = await File(sourcePath).readAsBytes();
  switch (kind) {
    case DocumentKind.docx:
      return compute(
        (m) => redactDocx(m.bytes, m.replacements),
        (bytes: bytes, replacements: result.replacements),
      );
    case DocumentKind.pdf:
      await ensurePdfrx();
      final layout = pdf!;
      final out = await anonymizePdf(
        bytes,
        redactions: _pdfRedactions(layout, result),
        scannedPages: {
          for (final (i, page) in layout.pages.indexed)
            if (page.scan case final scan?) i: _quads(scan, detections),
        },
      );
      if (out.rasterPages.isNotEmpty) {
        debugPrint('[anonymize] PDF pages sent as pictures: ${out.rasterPages}');
      }
      return out.bytes;
  }
}

/// [result]'s replacements on the text pages, in each page's own character
/// numbering. A replacement running over a page break is cut in two; the
/// placeholder goes on the first part.
List<PdfRedaction> _pdfRedactions(PdfLayout layout, AnonymizedText result) {
  final out = <PdfRedaction>[];
  for (final r in result.replacements) {
    var first = true;
    for (final (i, page) in layout.pages.indexed) {
      if (page.scan != null) continue;
      final start = max(r.start, page.offset);
      final end = min(r.end, page.offset + page.length);
      if (start >= end) continue;
      out.add(PdfRedaction(
        pageIndex: i,
        start: start - page.offset,
        end: end - page.offset,
        label: first ? r.placeholder : null,
      ));
      first = false;
    }
  }
  return out;
}

/// The OCR boxes to black out on a scanned page, in points.
List<PdfQuad> _quads(ImageLayout scan, List<Detection> detections) {
  const toPoints = 72 / PdfLayout.scanDpi;
  return [
    for (final box in scan.boxesFor(detections))
      [for (final c in box.corners) Point(c.x * toPoints, c.y * toPoints)],
  ];
}
