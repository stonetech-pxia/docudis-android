import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:docudis_engine/docudis_engine.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// One OCR word (ML Kit element) or character (symbol): where its text sits
/// in the extracted string and where it sits on the image.
class WordBox {
  const WordBox({
    required this.start,
    required this.end,
    required this.corners,
    this.symbols = const [],
  });

  /// Character range in the extracted text.
  final int start;
  final int end;

  /// Four corners in image pixels, clockwise from top-left.
  final List<Point<int>> corners;

  /// Per-character boxes when ML Kit provides them; used when a detection
  /// covers only part of this word (a Chinese line is one element).
  final List<WordBox> symbols;

  /// This box with its text offsets moved by [by].
  WordBox shifted(int by) => WordBox(
        start: start + by,
        end: end + by,
        corners: corners,
        symbols: [for (final s in symbols) s.shifted(by)],
      );

  Map<String, Object?> toJson() => {
        'start': start,
        'end': end,
        'corners': [for (final c in corners) [c.x, c.y]],
        if (symbols.isNotEmpty) 'symbols': [for (final s in symbols) s.toJson()],
      };

  factory WordBox.fromJson(Map<String, Object?> j) => WordBox(
        start: j['start'] as int,
        end: j['end'] as int,
        corners: [
          for (final c in j['corners'] as List<dynamic>)
            Point((c as List<dynamic>)[0] as int, c[1] as int),
        ],
        symbols: [
          for (final s in (j['symbols'] as List<dynamic>?) ?? const [])
            WordBox.fromJson((s as Map).cast<String, Object?>()),
        ],
      );
}

/// Where each OCR word of an image landed in the extracted text.
class ImageLayout {
  const ImageLayout({required this.words});

  final List<WordBox> words;

  /// Reads [result] in page order and records where each word lands.
  ///
  /// ML Kit's own `text` goes block by block, so a table column, or a date
  /// set to the right of an address, comes out far from the row it sits on.
  /// Here lines are grouped into rows by their height on the (deskewed)
  /// page; a row's lines are joined left to right with a tab, rows with a
  /// newline. Each element and symbol is then found inside its own line's
  /// text, so the offsets match the text they are built with.
  static ({String text, ImageLayout layout}) read(RecognizedText result) {
    final rows = _rows(_withoutMisreadScript([for (final b in result.blocks) ...b.lines]));
    final out = StringBuffer();
    final words = <WordBox>[];
    for (final (r, row) in rows.indexed) {
      if (r > 0) out.write('\n');
      for (final (i, line) in row.indexed) {
        if (i > 0) out.write('\t');
        final base = out.length;
        out.write(line.text);
        var cursor = 0;
        for (final element in line.elements) {
          final at = line.text.indexOf(element.text, cursor);
          if (at == -1) continue;
          final start = base + at, end = start + element.text.length;
          final symbols = <WordBox>[];
          var sc = at;
          for (final symbol in element.symbols) {
            final s = line.text.indexOf(symbol.text, sc);
            if (s == -1 || base + s >= end) break;
            sc = s + symbol.text.length;
            symbols.add(WordBox(start: base + s, end: base + sc, corners: symbol.cornerPoints));
          }
          words.add(WordBox(
            start: start,
            end: end,
            corners: element.cornerPoints,
            symbols: symbols,
          ));
          cursor = at + element.text.length;
        }
      }
    }
    return (text: out.toString(), layout: ImageLayout(words: words));
  }

  /// This layout for text that starts [by] characters further on.
  ImageLayout shifted(int by) => ImageLayout(words: [for (final w in words) w.shifted(by)]);

  Map<String, Object?> toJson() => {'words': [for (final w in words) w.toJson()]};

  factory ImageLayout.fromJson(Map<String, Object?> j) => ImageLayout(words: [
        for (final w in j['words'] as List<dynamic>)
          WordBox.fromJson((w as Map).cast<String, Object?>()),
      ]);

  /// The boxes to paint over for the enabled [detections]: a word that is
  /// fully covered, or the covered characters of a partly covered word.
  List<WordBox> boxesFor(List<Detection> detections) {
    final spans = detections.where((d) => d.enabled).toList();
    bool covered(WordBox b) => spans.any((d) => d.start <= b.start && d.end >= b.end);
    bool touched(WordBox b) => spans.any((d) => d.start < b.end && d.end > b.start);
    final out = <WordBox>[];
    for (final w in words) {
      if (!touched(w)) continue;
      if (covered(w) || w.symbols.isEmpty) {
        out.add(w);
      } else {
        out.addAll(w.symbols.where(touched));
      }
    }
    return out;
  }
}

/// Groups [lines] into rows, top to bottom, each row left to right.
///
/// The page is first turned by the slope of its lines, so a tilted photo
/// does not slide the right end of a row into the next one. The slope is a
/// median weighted by line length: a short line's corners are a few pixels
/// apart, too few for a precise angle. A line joins the row above when the
/// two overlap by at least half the smaller one's height: two lines on one
/// baseline do, two stacked lines do not.
List<List<TextLine>> _rows(List<TextLine> lines) {
  final angle = _pageAngle(lines);
  final cosA = cos(angle), sinA = sin(angle);
  final placed = [
    for (final l in lines) (line: l, box: _extent(l.cornerPoints, cosA, sinA)),
  ]..sort((a, b) => a.box.centerY.compareTo(b.box.centerY));

  final rows = <List<({TextLine line, _Extent box})>>[];
  for (final p in placed) {
    final seed = rows.isEmpty ? null : rows.last.first.box;
    if (seed != null && seed.overlaps(p.box)) {
      rows.last.add(p);
    } else {
      rows.add([p]);
    }
  }
  return [
    for (final row in rows)
      [for (final p in row..sort((a, b) => a.box.left.compareTo(b.box.left))) p.line],
  ];
}

/// The slope of the page's text: the median of the lines' angles, weighted by
/// their length.
double _pageAngle(List<TextLine> lines) {
  final slopes = [
    for (final l in lines)
      (
        angle: atan2(l.cornerPoints[1].y - l.cornerPoints[0].y,
            l.cornerPoints[1].x - l.cornerPoints[0].x),
        weight: l.cornerPoints[1].distanceTo(l.cornerPoints[0]),
      ),
  ]..sort((a, b) => a.angle.compareTo(b.angle));
  var angle = 0.0;
  var half = slopes.fold(0.0, (sum, s) => sum + s.weight) / 2;
  for (final s in slopes) {
    angle = s.angle;
    if ((half -= s.weight) <= 0) break;
  }
  return angle;
}

final _han = RegExp(r'\p{Script=Han}', unicode: true);
final _latin = RegExp(r'\p{Script=Latin}', unicode: true);

/// Drops what the Chinese recognizer (the default, see TextExtractor) makes
/// of Latin text it cannot read: on a page that is Latin but for a few Han
/// characters, a Han line several times taller than the page's lines (a
/// column of short words read as one vertical line: "里E里恩目星" for the
/// tickers of a bank statement), with Han and Latin letters inside one word,
/// or whose only letter is one Han character. Such a line cannot be read,
/// would switch on the Chinese rule pack,
/// and anything detected in it is painted over the whole column. A Han line
/// of normal height ("王伟" on an English letter) stays, and so does every
/// line of a page with real Chinese on it.
List<TextLine> _withoutMisreadScript(List<TextLine> lines) {
  var han = 0, latin = 0;
  for (final l in lines) {
    han += _han.allMatches(l.text).length;
    latin += _latin.allMatches(l.text).length;
  }
  if (han == 0 || latin < 50 || han * 20 >= han + latin) return lines;
  final angle = _pageAngle(lines);
  final cosA = cos(angle), sinA = sin(angle);
  double height(TextLine l) {
    final e = _extent(l.cornerPoints, cosA, sinA);
    return e.bottom - e.top;
  }

  final heights = [for (final l in lines) height(l)]..sort();
  final median = heights[heights.length ~/ 2];
  bool mixedWord(String text) =>
      text.split(RegExp(r'\s+')).any((w) => _han.hasMatch(w) && _latin.hasMatch(w));
  // One Han character and no other letter (".的 ." among the dots of a badge).
  bool lone(String text) => _han.allMatches(text).length == 1 && !_latin.hasMatch(text);
  return [
    for (final l in lines)
      if (!_han.hasMatch(l.text) || (height(l) <= 3 * median && !mixedWord(l.text) && !lone(l.text))) l,
  ];
}

/// A line's left edge and vertical span, in page coordinates turned back by
/// the page's slope.
typedef _Extent = ({double left, double top, double bottom});

_Extent _extent(List<Point<int>> corners, double cosA, double sinA) {
  var left = double.infinity, top = double.infinity, bottom = double.negativeInfinity;
  for (final c in corners) {
    final x = c.x * cosA + c.y * sinA;
    final y = -c.x * sinA + c.y * cosA;
    left = min(left, x);
    top = min(top, y);
    bottom = max(bottom, y);
  }
  return (left: left, top: top, bottom: bottom);
}

extension on _Extent {
  double get centerY => (top + bottom) / 2;

  bool overlaps(_Extent other) =>
      min(bottom, other.bottom) - max(top, other.top) >=
      min(bottom - top, other.bottom - other.top) / 2;
}

/// Paints solid boxes over [boxes] and returns the result as PNG. The image
/// is decoded no larger than [maxSide] on its longest side; the boxes are
/// scaled to match.
Future<Uint8List> renderRedactedImage(
  Uint8List imageBytes,
  List<WordBox> boxes, {
  int maxSide = 2048,
}) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final scale = min(1.0, maxSide / max(descriptor.width, descriptor.height));
  final codec = await descriptor.instantiateCodec(
    targetWidth: (descriptor.width * scale).round(),
    targetHeight: (descriptor.height * scale).round(),
  );
  final image = (await codec.getNextFrame()).image;
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  try {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());
    final fill = ui.Paint()..color = const ui.Color(0xFF000000);
    for (final box in boxes) {
      if (box.corners.length < 3) continue;
      final path = ui.Path()
        ..moveTo(box.corners[0].x * scale, box.corners[0].y * scale);
      for (final c in box.corners.skip(1)) {
        path.lineTo(c.x * scale, c.y * scale);
      }
      path.close();
      // A little bleed around the glyphs, so anti-aliased edges never show.
      final height = _height(box.corners) * scale;
      canvas.drawPath(path, fill);
      canvas.drawPath(
        path,
        ui.Paint()
          ..color = fill.color
          ..style = ui.PaintingStyle.stroke
          ..strokeJoin = ui.StrokeJoin.round
          ..strokeWidth = max(2.0, height * 0.3),
      );
    }
    final picture = recorder.endRecording();
    final out = await picture.toImage(image.width, image.height);
    picture.dispose();
    try {
      final data = await out.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      out.dispose();
    }
  } finally {
    image.dispose();
  }
}

double _height(List<Point<int>> corners) {
  var top = corners.first.y, bottom = corners.first.y;
  for (final c in corners) {
    if (c.y < top) top = c.y;
    if (c.y > bottom) bottom = c.y;
  }
  return (bottom - top).toDouble();
}
