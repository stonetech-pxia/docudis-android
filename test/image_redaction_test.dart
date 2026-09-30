import 'dart:math';
import 'dart:ui' as ui;

import 'package:docudis/anonymize/image_redaction.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Map<String, Object?> _box(String text, int x, int y, int w, int h,
        {List<Map<String, Object?>> children = const [], String key = '', double tilt = 0}) {
  // Corners turned by [tilt] radians about the page origin, like a photo
  // taken at a slant.
  Map<String, int> at(int px, int py) => {
        'x': (px * cos(tilt) - py * sin(tilt)).round(),
        'y': (px * sin(tilt) + py * cos(tilt)).round(),
      };
  return {
    'text': text,
    'rect': {'left': x, 'top': y, 'right': x + w, 'bottom': y + h},
    'points': [at(x, y), at(x + w, y), at(x + w, y + h), at(x, y + h)],
    'recognizedLanguages': const <String>[],
    'confidence': null,
    'angle': null,
    if (key.isNotEmpty) key: children,
  };
}

/// A one-word-per-element line.
Map<String, Object?> _line(String text, int x, int y, {double tilt = 0}) {
  final words = <Map<String, Object?>>[];
  var wx = x;
  for (final w in text.split(' ')) {
    words.add(_box(w, wx, y, w.length * 10, 20, key: 'symbols', tilt: tilt));
    wx += w.length * 10 + 10;
  }
  return _box(text, x, y, text.length * 10, 20, key: 'elements', children: words, tilt: tilt);
}

/// ML Kit's block order: each block's lines, then the next block.
RecognizedText _blocks(List<List<Map<String, Object?>>> blocks) => RecognizedText.fromJson({
      'text': blocks.map((b) => b.map((l) => l['text']).join('\n')).join('\n'),
      'blocks': [
        for (final lines in blocks)
          _box(lines.map((l) => l['text']).join('\n'), 0, 0, 1, 1, key: 'lines', children: lines),
      ],
    });

/// Two lines: "Name: Anna Meyer" as four words, and "电话13800138000" as one
/// element with per-character symbols.
RecognizedText _sample() {
  final line1 = _box('Name: Anna Meyer', 10, 10, 160, 20, key: 'elements', children: [
    _box('Name:', 10, 10, 50, 20, key: 'symbols'),
    _box('Anna', 70, 10, 40, 20, key: 'symbols'),
    _box('Meyer', 120, 10, 50, 20, key: 'symbols'),
  ]);
  const phone = '电话13800138000';
  final line2 = _box(phone, 10, 40, 130, 20, key: 'elements', children: [
    _box(phone, 10, 40, 130, 20, key: 'symbols', children: [
      for (var i = 0; i < phone.length; i++) _box(phone[i], 10 + i * 10, 40, 10, 20),
    ]),
  ]);
  return RecognizedText.fromJson({
    'text': 'Name: Anna Meyer\n$phone',
    'blocks': [
      _box('Name: Anna Meyer\n$phone', 10, 10, 160, 50, key: 'lines', children: [line1, line2]),
    ],
  });
}

Detection _det(int start, int end, {bool enabled = true}) => Detection(
      type: EntityType.person,
      value: '',
      start: start,
      end: end,
      confidence: 1,
      detector: 'test',
      source: DetectionSource.rule,
      enabled: enabled,
    );

void main() {
  test('words are located in the extracted text', () {
    final read = ImageLayout.read(_sample());
    expect(read.text, 'Name: Anna Meyer\n电话13800138000');
    final layout = read.layout;
    expect(layout.words.map((w) => (w.start, w.end)), [(0, 5), (6, 10), (11, 16), (17, 30)]);
    expect(layout.words.last.symbols.length, 13);
  });

  test('a line to the right of another block is read on its own row', () {
    // ML Kit puts the address block first and the right-aligned date last.
    final read = ImageLayout.read(_blocks([
      [_line('Anna Meyer', 10, 10), _line('14 rue de la Paix', 10, 40), _line('75002 Paris', 10, 70)],
      [_line('le 12 mars 2026', 400, 42)],
    ]));
    expect(read.text, 'Anna Meyer\n14 rue de la Paix\tle 12 mars 2026\n75002 Paris');
    for (final w in read.layout.words) {
      expect(read.text.substring(w.start, w.end), isNot(contains(RegExp(r'\s'))));
    }
    final date = read.text.indexOf('2026');
    expect(read.layout.words.singleWhere((w) => w.start == date).corners.first.x, 510);
  });

  test('a tilted photo keeps each row together', () {
    // Turned 6°: the right end of a row sits lower than the next row's left.
    const tilt = 6 * pi / 180;
    final read = ImageLayout.read(_blocks([
      [_line('Total', 10, 100, tilt: tilt), _line('IBAN', 10, 130, tilt: tilt)],
      [_line('1 250,00 EUR', 700, 100, tilt: tilt), _line('FR76 3000 6000', 700, 130, tilt: tilt)],
    ]));
    expect(read.text, 'Total\t1 250,00 EUR\nIBAN\tFR76 3000 6000');
  });

  test('a column of Latin words misread as one tall Han line is dropped on a Latin page', () {
    // A bank statement photographed on 2026-09-26: the Chinese recognizer read
    // the ticker column as "里E里恩目星", the model called it a PERSON, and one
    // box covered two columns; its Han characters also switched on the cn rules.
    final lines = [
      for (var i = 0; i < 12; i++) _line('Vanguard Growth ETF 414.19 0.339 Equity', 10, 10 + i * 30),
      _box('里E里恩目星', 300, 10, 30, 360, key: 'elements', children: [
        _box('里E里恩目星', 300, 10, 30, 360, key: 'symbols'),
      ]),
      _box('.的 .', 300, 430, 40, 20, key: 'elements', children: [
        _box('.的', 300, 430, 20, 20, key: 'symbols'),
        _box('.', 330, 430, 10, 20, key: 'symbols'),
      ]),
      _box('Contact: 王伟', 10, 400, 120, 20, key: 'elements', children: [
        _box('Contact:', 10, 400, 80, 20, key: 'symbols'),
        _box('王伟', 100, 400, 20, 20, key: 'symbols'),
      ]),
    ];
    final read = ImageLayout.read(_blocks([lines]));
    expect(read.text, isNot(contains('里E里恩目星')));
    expect(read.text, isNot(contains('的')), reason: 'a lone Han character amid dots is a misread');
    expect(read.text, contains('Contact:\t王伟'.replaceAll('\t', ' ')));
    expect('Vanguard'.allMatches(read.text).length, 12);
    expect(read.layout.words.where((w) => read.text.substring(w.start, w.end).contains('里')), isEmpty);
  });

  test('a tall Han line stays on a Chinese page: vertical Chinese is real text', () {
    final lines = [
      for (var i = 0; i < 6; i++) _line('联系人 王伟 电话 13800138000', 10, 10 + i * 30),
      _box('深圳市南山区', 400, 10, 30, 300, key: 'elements', children: [
        _box('深圳市南山区', 400, 10, 30, 300, key: 'symbols'),
      ]),
    ];
    expect(ImageLayout.read(_blocks([lines])).text, contains('深圳市南山区'));
  });

  test('a covered word is painted whole, a partly covered one by character', () {
    final layout = ImageLayout.read(_sample()).layout;
    // "Anna Meyer" and the digits only.
    final boxes = layout.boxesFor([_det(6, 16), _det(19, 30)]);
    expect(boxes.map((b) => b.corners.first.x), [70, 120, ...List.generate(11, (i) => 30 + i * 10)]);
  });

  test('disabled detections paint nothing', () {
    final layout = ImageLayout.read(_sample()).layout;
    expect(layout.boxesFor([_det(6, 16, enabled: false)]), isEmpty);
  });

  test('round-trips through json', () {
    final layout = ImageLayout.read(_sample()).layout;
    final back = ImageLayout.fromJson(layout.toJson());
    expect(back.words.length, layout.words.length);
    expect(back.words.last.symbols.length, 13);
    expect(back.words[1].corners, layout.words[1].corners);
  });

  test('renders black over the box and leaves the rest', () async {
    // A 200x100 white image.
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 200, 100),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final white = await recorder.endRecording().toImage(200, 100);
    final png = (await white.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

    final out = await renderRedactedImage(png, [
      WordBox(start: 0, end: 1, corners: const [
        Point(50, 20), Point(100, 20), Point(100, 40), Point(50, 40),
      ]),
    ]);
    final codec = await ui.instantiateImageCodec(out);
    final image = (await codec.getNextFrame()).image;
    expect(image.width, 200);
    final rgba = (await image.toByteData())!;
    int pixel(int x, int y) => rgba.getUint32((y * 200 + x) * 4);
    expect(pixel(75, 30), 0x000000FF, reason: 'inside the box');
    expect(pixel(10, 80), 0xFFFFFFFF, reason: 'far from the box');
  });

  test('downscales large images and their boxes together', () async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 400, 200),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final white = await recorder.endRecording().toImage(400, 200);
    final png = (await white.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final out = await renderRedactedImage(
      png,
      [
        WordBox(start: 0, end: 1, corners: const [
          Point(300, 100), Point(400, 100), Point(400, 200), Point(300, 200),
        ]),
      ],
      maxSide: 200,
    );
    final image = (await (await ui.instantiateImageCodec(out)).getNextFrame()).image;
    expect((image.width, image.height), (200, 100));
    final rgba = (await image.toByteData())!;
    expect(rgba.getUint32((75 * 200 + 175) * 4), 0x000000FF);
    expect(rgba.getUint32((25 * 200 + 25) * 4), 0xFFFFFFFF);
  });
}
