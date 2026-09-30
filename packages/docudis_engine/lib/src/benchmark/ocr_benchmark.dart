import 'dart:convert';
import 'dart:math' as math;

/// A value whose OCR accuracy matters to the downstream anonymization flow.
class OcrCriticalSpan {
  const OcrCriticalSpan({required this.value, required this.type});

  final String value;
  final String type;

  factory OcrCriticalSpan.fromJson(Map<String, Object?> json) =>
      OcrCriticalSpan(
        value: json['value'] as String,
        type: json['type'] as String,
      );

  Map<String, Object?> toJson() => {'value': value, 'type': type};
}

/// One image and its exact expected transcription.
class OcrBenchmarkCase {
  const OcrBenchmarkCase({
    required this.id,
    required this.lang,
    required this.category,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.expectedText,
    required this.expectedLines,
    required this.criticalSpans,
    this.script = 'unknown',
    this.difficulty = 'unspecified',
    this.deviceLocale,
    this.generationPrompt,
    this.expectedTextPath,
    this.expectedTextFormat = 'plain',
    this.sourceUrl,
    this.sourceAuthor,
    this.sourceLicense,
  }) : assert(width > 0),
       assert(height > 0);

  final String id;
  final String lang;
  final String category;
  final String imagePath;
  final int width;
  final int height;
  final String expectedText;
  final List<String> expectedLines;
  final List<OcrCriticalSpan> criticalSpans;
  final String script;
  final String difficulty;
  final String? deviceLocale;

  /// Optional provenance for generated fixtures. It is not used for scoring.
  final String? generationPrompt;

  /// Optional Flutter asset containing long reference text. Dataset loaders
  /// hydrate it before constructing the case so run JSON remains standalone.
  final String? expectedTextPath;
  final String expectedTextFormat;

  /// Optional provenance for real-world fixtures. These fields are not used
  /// for scoring, but are preserved in device-run JSON and rendered reports.
  final String? sourceUrl;
  final String? sourceAuthor;
  final String? sourceLicense;

  double get megapixels => width * height / 1000000;

  static List<OcrBenchmarkCase> parseDataset(
    String source, {
    Map<String, String> expectedTextAssets = const {},
  }) {
    final document = jsonDecode(source) as Map<String, dynamic>;
    return [
      for (final value in document['cases'] as List<dynamic>)
        _caseFromDatasetJson(
          (value as Map).cast<String, Object?>(),
          expectedTextAssets,
        ),
    ];
  }

  static OcrBenchmarkCase _caseFromDatasetJson(
    Map<String, Object?> source,
    Map<String, String> expectedTextAssets,
  ) {
    final json = Map<String, Object?>.of(source);
    var expectedText = json['expectedText'] as String?;
    final expectedTextPath = json['expectedTextPath'] as String?;
    if (expectedText == null && expectedTextPath != null) {
      expectedText = expectedTextAssets[expectedTextPath];
      if (expectedText == null) {
        throw FormatException(
          'Missing OCR ground-truth asset: $expectedTextPath',
        );
      }
    }
    if (expectedText == null) {
      throw const FormatException(
        'OCR case requires expectedText or expectedTextPath',
      );
    }
    final format = json['expectedTextFormat'] as String? ?? 'plain';
    json['expectedText'] = switch (format) {
      'plain' => expectedText,
      'markdown' => ocrGroundTruthMarkdownToText(expectedText),
      _ => throw FormatException(
        'Unsupported OCR ground-truth format: $format',
      ),
    };
    return OcrBenchmarkCase.fromJson(json);
  }

  factory OcrBenchmarkCase.fromJson(Map<String, Object?> json) {
    final expectedText = json['expectedText'] as String;
    final lines = json['expectedLines'] as List<dynamic>?;
    return OcrBenchmarkCase(
      id: json['id'] as String,
      lang: json['lang'] as String,
      category: json['category'] as String,
      imagePath: json['imagePath'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      expectedText: expectedText,
      expectedLines: lines == null
          ? splitOcrLines(expectedText)
          : [for (final line in lines) line as String],
      criticalSpans: [
        for (final span in json['criticalSpans'] as List<dynamic>? ?? const [])
          OcrCriticalSpan.fromJson((span as Map).cast<String, Object?>()),
      ],
      script: json['script'] as String? ?? 'unknown',
      difficulty: json['difficulty'] as String? ?? 'unspecified',
      deviceLocale: json['deviceLocale'] as String?,
      generationPrompt: json['generationPrompt'] as String?,
      expectedTextPath: json['expectedTextPath'] as String?,
      expectedTextFormat: json['expectedTextFormat'] as String? ?? 'plain',
      sourceUrl: json['sourceUrl'] as String?,
      sourceAuthor: json['sourceAuthor'] as String?,
      sourceLicense: json['sourceLicense'] as String?,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'lang': lang,
    'category': category,
    'imagePath': imagePath,
    'width': width,
    'height': height,
    'expectedText': expectedText,
    'expectedLines': expectedLines,
    'criticalSpans': [for (final span in criticalSpans) span.toJson()],
    if (script != 'unknown') 'script': script,
    if (difficulty != 'unspecified') 'difficulty': difficulty,
    if (deviceLocale != null) 'deviceLocale': deviceLocale,
    if (generationPrompt != null) 'generationPrompt': generationPrompt,
    if (expectedTextPath != null) 'expectedTextPath': expectedTextPath,
    if (expectedTextFormat != 'plain') 'expectedTextFormat': expectedTextFormat,
    if (sourceUrl != null) 'sourceUrl': sourceUrl,
    if (sourceAuthor != null) 'sourceAuthor': sourceAuthor,
    if (sourceLicense != null) 'sourceLicense': sourceLicense,
  };
}

/// Converts the lightweight Markdown used by public document datasets into
/// the visible plain text an OCR engine is expected to emit.
String ocrGroundTruthMarkdownToText(String markdown) {
  final output = <String>[];
  final tableSeparator = RegExp(r'^[\s|:-]+$');
  final heading = RegExp(r'^#{1,6}\s*');
  final bullet = RegExp(r'^-\s+');
  final image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
  final link = RegExp(r'\[([^\]]+)\]\([^)]*\)');
  final escapedPunctuation = RegExp(r'\\([\\\[\]_.])');

  for (var line in normalizeStrictOcrText(markdown).split('\n')) {
    var trimmed = line.trim();
    if (trimmed.contains('|') && tableSeparator.hasMatch(trimmed)) continue;
    trimmed = trimmed.replaceFirst(heading, '').replaceFirst(bullet, '');
    trimmed = trimmed
        .replaceAllMapped(image, (match) => match.group(1) ?? '')
        .replaceAllMapped(link, (match) => match.group(1) ?? '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAllMapped(escapedPunctuation, (match) => match.group(1) ?? '');
    if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
      trimmed = trimmed
          .substring(1, trimmed.length - 1)
          .split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .join(' ');
    }
    output.add(trimmed);
  }
  return output.join('\n').trim();
}

final _ocrWhitespace = RegExp(r'[\s\u00a0]+', unicode: true);

/// Normalizes only platform line endings. Strict CER otherwise compares the
/// transcription code-point-for-code-point.
String normalizeStrictOcrText(String text) =>
    text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

/// Normalizes layout-only differences while retaining case, punctuation,
/// accents, symbols and digits.
///
/// Normalized CER and WER use this form. Newlines and runs of horizontal
/// whitespace are both represented by one ASCII space. This leaves line
/// layout to line-F1.
String normalizeOcrText(String text) => text
    .replaceAll('\r\n', '\n')
    .replaceAll('\r', '\n')
    .replaceAll(_ocrWhitespace, ' ')
    .trim();

/// Normalizes one OCR line for exact line and critical-span matching.
String normalizeOcrLine(String line) =>
    line.replaceAll(_ocrWhitespace, ' ').trim();

/// Splits text into non-empty, normalized lines.
List<String> splitOcrLines(String text) => [
  for (final line
      in text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n'))
    if (normalizeOcrLine(line).isNotEmpty) normalizeOcrLine(line),
];

/// Scored output for one image.
class OcrCaseResult {
  OcrCaseResult({
    required this.kase,
    required this.recognizedText,
    required this.elapsed,
    this.error,
  });

  final OcrBenchmarkCase kase;
  final String recognizedText;
  final Duration elapsed;
  final String? error;

  late final String strictExpectedText = normalizeStrictOcrText(
    kase.expectedText,
  );
  late final String strictRecognizedText = normalizeStrictOcrText(
    recognizedText,
  );
  late final String normalizedExpectedText = normalizeOcrText(
    kase.expectedText,
  );
  late final String normalizedRecognizedText = normalizeOcrText(recognizedText);
  late final List<int> _strictExpectedCharacters = strictExpectedText.runes
      .toList(growable: false);
  late final List<int> _strictRecognizedCharacters = strictRecognizedText.runes
      .toList(growable: false);
  late final List<int> _normalizedExpectedCharacters = normalizedExpectedText
      .runes
      .toList(growable: false);
  late final List<int> _normalizedRecognizedCharacters =
      normalizedRecognizedText.runes.toList(growable: false);
  late final List<String> _expectedWords = _words(normalizedExpectedText);
  late final List<String> _recognizedWords = _words(normalizedRecognizedText);
  late final List<String> normalizedExpectedLines = [
    for (final line in kase.expectedLines)
      if (normalizeOcrLine(line).isNotEmpty) normalizeOcrLine(line),
  ];
  late final List<String> normalizedRecognizedLines = splitOcrLines(
    recognizedText,
  );

  int get strictExpectedCharacterCount => _strictExpectedCharacters.length;
  int get strictRecognizedCharacterCount => _strictRecognizedCharacters.length;

  /// Character counts use Unicode code points (`String.runes`), not UTF-16
  /// code units or extended grapheme clusters.
  int get expectedCharacterCount => _normalizedExpectedCharacters.length;
  int get recognizedCharacterCount => _normalizedRecognizedCharacters.length;

  late final int strictCharacterEditDistance = _editDistance(
    _strictExpectedCharacters,
    _strictRecognizedCharacters,
  );

  double get strictCharacterErrorRate =>
      strictCharacterEditDistance / math.max(1, strictExpectedCharacterCount);

  late final int characterEditDistance = _editDistance(
    _normalizedExpectedCharacters,
    _normalizedRecognizedCharacters,
  );

  double get normalizedCharacterErrorRate =>
      characterEditDistance / math.max(1, expectedCharacterCount);

  /// The default CER is normalized CER. Use [strictCharacterErrorRate] when
  /// whitespace and line layout must count as recognition errors.
  double get characterErrorRate => normalizedCharacterErrorRate;

  double get characterAccuracy =>
      (1 - normalizedCharacterErrorRate).clamp(0, 1).toDouble();

  int get expectedWordCount => _expectedWords.length;
  int get recognizedWordCount => _recognizedWords.length;

  late final int wordEditDistance = _editDistance(
    _expectedWords,
    _recognizedWords,
  );

  double get wordErrorRate => wordEditDistance / math.max(1, expectedWordCount);

  int get expectedLineCount => normalizedExpectedLines.length;
  int get recognizedLineCount => normalizedRecognizedLines.length;

  /// Exact normalized line matches, counted as a multiset.
  late final int matchingLineCount = _matchingLineCount(
    normalizedExpectedLines,
    normalizedRecognizedLines,
  );

  double get linePrecision {
    if (recognizedLineCount == 0) return expectedLineCount == 0 ? 1 : 0;
    return matchingLineCount / recognizedLineCount;
  }

  double get lineRecall {
    if (expectedLineCount == 0) return recognizedLineCount == 0 ? 1 : 0;
    return matchingLineCount / expectedLineCount;
  }

  double get lineF1 {
    final precision = linePrecision;
    final recall = lineRecall;
    return precision + recall == 0
        ? 0
        : 2 * precision * recall / (precision + recall);
  }

  late final List<OcrCriticalSpan> foundCriticalSpans = [
    for (final span in kase.criticalSpans)
      if (normalizedRecognizedText.contains(normalizeOcrText(span.value))) span,
  ];

  late final List<OcrCriticalSpan> missedCriticalSpans = [
    for (final span in kase.criticalSpans)
      if (!normalizedRecognizedText.contains(normalizeOcrText(span.value)))
        span,
  ];

  int get expectedCriticalSpanCount => kase.criticalSpans.length;
  int get foundCriticalSpanCount => foundCriticalSpans.length;

  double get criticalSpanRecall => expectedCriticalSpanCount == 0
      ? 1
      : foundCriticalSpanCount / expectedCriticalSpanCount;

  bool get exactMatch => normalizedExpectedText == normalizedRecognizedText;

  bool get failed => error != null;

  double get msPerMegapixel => elapsed.inMicroseconds / 1000 / kase.megapixels;

  Map<String, Object?> toJson() => {
    'case': kase.toJson(),
    'recognizedText': recognizedText,
    'elapsedMicros': elapsed.inMicroseconds,
    if (error != null) 'error': error,
  };

  factory OcrCaseResult.fromJson(Map<String, Object?> json) => OcrCaseResult(
    kase: OcrBenchmarkCase.fromJson(
      (json['case'] as Map).cast<String, Object?>(),
    ),
    recognizedText: json['recognizedText'] as String,
    elapsed: Duration(microseconds: json['elapsedMicros'] as int),
    error: json['error'] as String?,
  );
}

/// A serializable OCR run produced on a desktop or device.
class OcrBenchmarkRun {
  const OcrBenchmarkRun({
    required this.title,
    required this.platform,
    required this.recognizerName,
    required this.results,
  });

  final String title;
  final String platform;
  final String recognizerName;
  final List<OcrCaseResult> results;

  String toJson() => jsonEncode({
    'title': title,
    'platform': platform,
    'recognizerName': recognizerName,
    'results': [for (final result in results) result.toJson()],
  });

  factory OcrBenchmarkRun.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return OcrBenchmarkRun(
      title: json['title'] as String,
      platform: json['platform'] as String,
      recognizerName: json['recognizerName'] as String,
      results: [
        for (final result in json['results'] as List<dynamic>)
          OcrCaseResult.fromJson((result as Map).cast<String, Object?>()),
      ],
    );
  }

  String toMarkdown() => renderOcrMarkdown(this);
}

typedef OcrRecognizer = Future<String> Function(OcrBenchmarkCase kase);

/// Times an injected recognizer without introducing a Flutter dependency.
class OcrBenchmarkRunner {
  OcrBenchmarkRunner({required this.recognize});

  final OcrRecognizer recognize;

  Future<OcrCaseResult> run(OcrBenchmarkCase kase) async {
    final stopwatch = Stopwatch()..start();
    try {
      final text = await recognize(kase);
      stopwatch.stop();
      return OcrBenchmarkScorer.score(kase, text, stopwatch.elapsed);
    } catch (exception) {
      stopwatch.stop();
      return OcrBenchmarkScorer.score(
        kase,
        '',
        stopwatch.elapsed,
        error: exception.toString(),
      );
    }
  }

  Future<List<OcrCaseResult>> runAll(Iterable<OcrBenchmarkCase> cases) async {
    final results = <OcrCaseResult>[];
    for (final kase in cases) {
      results.add(await run(kase));
    }
    return results;
  }
}

class OcrBenchmarkScorer {
  const OcrBenchmarkScorer._();

  static OcrCaseResult score(
    OcrBenchmarkCase kase,
    String recognizedText,
    Duration elapsed, {
    String? error,
  }) => OcrCaseResult(
    kase: kase,
    recognizedText: recognizedText,
    elapsed: elapsed,
    error: error,
  );
}

/// Aggregate metrics for one language, category, or the complete run.
class OcrGroupSummary {
  OcrGroupSummary(this.key);

  final String key;
  final List<OcrCaseResult> results = [];

  int get cases => results.length;
  int get strictCharacterEdits => results.fold(
    0,
    (total, result) => total + result.strictCharacterEditDistance,
  );
  int get strictExpectedCharacters => results.fold(
    0,
    (total, result) => total + result.strictExpectedCharacterCount,
  );
  int get characterEdits =>
      results.fold(0, (total, result) => total + result.characterEditDistance);
  int get expectedCharacters =>
      results.fold(0, (total, result) => total + result.expectedCharacterCount);
  int get wordEdits =>
      results.fold(0, (total, result) => total + result.wordEditDistance);
  int get expectedWords =>
      results.fold(0, (total, result) => total + result.expectedWordCount);
  int get matchingLines =>
      results.fold(0, (total, result) => total + result.matchingLineCount);
  int get expectedLines =>
      results.fold(0, (total, result) => total + result.expectedLineCount);
  int get recognizedLines =>
      results.fold(0, (total, result) => total + result.recognizedLineCount);
  int get expectedCriticalSpans => results.fold(
    0,
    (total, result) => total + result.expectedCriticalSpanCount,
  );
  int get foundCriticalSpans =>
      results.fold(0, (total, result) => total + result.foundCriticalSpanCount);
  int get exactMatches => results.where((result) => result.exactMatch).length;
  int get errors => results.where((result) => result.failed).length;

  double get strictCharacterErrorRate =>
      strictCharacterEdits / math.max(1, strictExpectedCharacters);
  double get normalizedCharacterErrorRate =>
      characterEdits / math.max(1, expectedCharacters);
  double get characterErrorRate => normalizedCharacterErrorRate;
  double get characterAccuracy =>
      (1 - normalizedCharacterErrorRate).clamp(0, 1).toDouble();
  double get wordErrorRate => wordEdits / math.max(1, expectedWords);

  double get linePrecision {
    if (recognizedLines == 0) return expectedLines == 0 ? 1 : 0;
    return matchingLines / recognizedLines;
  }

  double get lineRecall {
    if (expectedLines == 0) return recognizedLines == 0 ? 1 : 0;
    return matchingLines / expectedLines;
  }

  double get lineF1 {
    final precision = linePrecision;
    final recall = lineRecall;
    return precision + recall == 0
        ? 0
        : 2 * precision * recall / (precision + recall);
  }

  double get criticalSpanRecall => expectedCriticalSpans == 0
      ? 1
      : foundCriticalSpans / expectedCriticalSpans;

  double get exactMatchRate => cases == 0 ? 1 : exactMatches / cases;

  Duration get elapsed =>
      results.fold(Duration.zero, (total, result) => total + result.elapsed);

  double get megapixels =>
      results.fold(0, (total, result) => total + result.kase.megapixels);

  double get msPerMegapixel =>
      megapixels == 0 ? 0 : elapsed.inMicroseconds / 1000 / megapixels;
}

String ocrReliabilityGrade(double characterErrorRate) {
  if (characterErrorRate <= 0.01) return 'A';
  if (characterErrorRate <= 0.03) return 'B';
  if (characterErrorRate <= 0.08) return 'C';
  return 'D';
}

String renderOcrMarkdown(OcrBenchmarkRun run) {
  final all = OcrGroupSummary('all')..results.addAll(run.results);
  final byLanguage = <String, OcrGroupSummary>{};
  final byCategory = <String, OcrGroupSummary>{};
  for (final result in run.results) {
    byLanguage
        .putIfAbsent(result.kase.lang, () => OcrGroupSummary(result.kase.lang))
        .results
        .add(result);
    byCategory
        .putIfAbsent(
          result.kase.category,
          () => OcrGroupSummary(result.kase.category),
        )
        .results
        .add(result);
  }

  final output = StringBuffer()
    ..writeln('# ${run.title}')
    ..writeln()
    ..writeln('- Recognizer: ${run.recognizerName}')
    ..writeln('- Platform: ${run.platform}')
    ..writeln('- Cases: ${all.cases}, errors: ${all.errors}')
    ..writeln(
      '- Overall: strict CER ${_percent(all.strictCharacterErrorRate)}, '
      'normalized CER ${_percent(all.normalizedCharacterErrorRate)}, '
      'WER ${_percent(all.wordErrorRate)}, line F1 ${_percent(all.lineF1)}, '
      'critical-span recall ${_percent(all.criticalSpanRecall)}, '
      'exact ${all.exactMatches}/${all.cases}, '
      '${all.msPerMegapixel.toStringAsFixed(0)} ms/MP, '
      'reliability **${ocrReliabilityGrade(all.normalizedCharacterErrorRate)}**',
    )
    ..writeln()
    ..writeln(
      'Strict CER preserves whitespace after line-ending canonicalization. '
      'Normalized CER and WER collapse whitespace but remain case-, '
      'punctuation-, diacritic-, symbol-, and digit-sensitive. CER counts '
      'Unicode code points (`String.runes`), not grapheme clusters. Line F1 '
      'uses exact normalized line matches.',
    )
    ..writeln()
    ..write(_ocrMarkdownSummary('By language', byLanguage.values))
    ..writeln()
    ..write(_ocrMarkdownSummary('By category', byCategory.values))
    ..writeln()
    ..writeln('## Per case')
    ..writeln()
    ..writeln(
      '| Case | Language | Category | Size | Strict CER | Normalized CER | WER | '
      'Line F1 | Critical | Exact | ms | ms/MP | Notes |',
    )
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|---|---|');
  for (final result in run.results) {
    final notes = <String>[
      if (result.error != null) 'error: ${result.error}',
      if (result.missedCriticalSpans.isNotEmpty)
        'missed: ${_compactCriticalSpans(result.missedCriticalSpans)}',
    ];
    output.writeln(
      '| ${_markdownCell(result.kase.id)} | ${_markdownCell(result.kase.lang)} | '
      '${_markdownCell(result.kase.category)} | '
      '${result.kase.width}×${result.kase.height} | '
      '${_percent(result.strictCharacterErrorRate)} | '
      '${_percent(result.normalizedCharacterErrorRate)} | '
      '${_percent(result.wordErrorRate)} | ${_percent(result.lineF1)} | '
      '${result.foundCriticalSpanCount}/${result.expectedCriticalSpanCount} | '
      '${result.exactMatch ? 'yes' : 'no'} | '
      '${result.elapsed.inMilliseconds} | '
      '${result.msPerMegapixel.toStringAsFixed(0)} | '
      '${_markdownCell(notes.join('; '))} |',
    );
  }
  return output.toString();
}

String _ocrMarkdownSummary(String title, Iterable<OcrGroupSummary> groups) {
  final output = StringBuffer()
    ..writeln('## $title')
    ..writeln()
    ..writeln(
      '| Group | Cases | Strict CER | Normalized CER | WER | Line F1 | '
      'Critical recall | Exact | Errors | ms/MP | Grade |',
    )
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final group in groups) {
    output.writeln(
      '| ${_markdownCell(group.key)} | ${group.cases} | '
      '${_percent(group.strictCharacterErrorRate)} | '
      '${_percent(group.normalizedCharacterErrorRate)} | '
      '${_percent(group.wordErrorRate)} | ${_percent(group.lineF1)} | '
      '${_percent(group.criticalSpanRecall)} | '
      '${group.exactMatches}/${group.cases} | ${group.errors} | '
      '${group.msPerMegapixel.toStringAsFixed(0)} | '
      '${ocrReliabilityGrade(group.normalizedCharacterErrorRate)} |',
    );
  }
  return output.toString();
}

List<String> _words(String normalizedText) =>
    normalizedText.isEmpty ? const [] : normalizedText.split(' ');

int _matchingLineCount(List<String> expected, List<String> recognized) {
  final remaining = <String, int>{};
  for (final line in expected) {
    remaining[line] = (remaining[line] ?? 0) + 1;
  }
  var matches = 0;
  for (final line in recognized) {
    final count = remaining[line] ?? 0;
    if (count == 0) continue;
    matches++;
    if (count == 1) {
      remaining.remove(line);
    } else {
      remaining[line] = count - 1;
    }
  }
  return matches;
}

int _editDistance<T>(List<T> expected, List<T> recognized) {
  if (expected.isEmpty) return recognized.length;
  if (recognized.isEmpty) return expected.length;

  var previous = List<int>.generate(recognized.length + 1, (index) => index);
  for (
    var expectedIndex = 0;
    expectedIndex < expected.length;
    expectedIndex++
  ) {
    final current = List<int>.filled(recognized.length + 1, 0);
    current[0] = expectedIndex + 1;
    for (
      var recognizedIndex = 0;
      recognizedIndex < recognized.length;
      recognizedIndex++
    ) {
      final substitution =
          previous[recognizedIndex] +
          (expected[expectedIndex] == recognized[recognizedIndex] ? 0 : 1);
      final insertion = current[recognizedIndex] + 1;
      final deletion = previous[recognizedIndex + 1] + 1;
      current[recognizedIndex + 1] = math.min(
        substitution,
        math.min(insertion, deletion),
      );
    }
    previous = current;
  }
  return previous.last;
}

String _percent(double value) => '${(value * 100).toStringAsFixed(1)}%';

String _markdownCell(String value) =>
    value.replaceAll('|', r'\|').replaceAll('\r', ' ').replaceAll('\n', ' ');

String _compactCriticalSpans(Iterable<OcrCriticalSpan> spans) =>
    spans.map((span) => '${span.value}(${span.type})').join(', ');
