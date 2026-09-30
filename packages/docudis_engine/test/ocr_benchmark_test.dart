import 'dart:convert';
import 'dart:io';

import 'package:docudis_engine/benchmark.dart';
import 'package:test/test.dart';

OcrBenchmarkCase benchmarkCase({
  String expectedText = 'cat\nsat',
  List<String>? expectedLines,
  List<OcrCriticalSpan>? criticalSpans,
  int width = 2000,
  int height = 1000,
}) => OcrBenchmarkCase(
  id: 'ocr-test-01',
  lang: 'en',
  category: 'clean',
  imagePath: 'benchmark/ocr/images/ocr-test-01.png',
  width: width,
  height: height,
  expectedText: expectedText,
  expectedLines: expectedLines ?? splitOcrLines(expectedText),
  criticalSpans:
      criticalSpans ??
      const [
        OcrCriticalSpan(value: 'cat', type: 'ANIMAL'),
        OcrCriticalSpan(value: 'sat', type: 'ACTION'),
      ],
  script: 'chinese',
  difficulty: 'easy',
);

void main() {
  group('OCR dataset model', () {
    test('parses compact cases and derives lines when omitted', () {
      final cases = OcrBenchmarkCase.parseDataset(
        jsonEncode({
          'version': 1,
          'ignored': 'metadata is forward compatible',
          'cases': [
            {
              'id': 'zh-clean-01',
              'lang': 'zh-Hans',
              'category': 'clean_document',
              'imagePath': 'benchmark/ocr/images/zh-clean-01.png',
              'width': 1400,
              'height': 900,
              'expectedText': '客户资料\n姓名：张伟',
              'criticalSpans': [
                {'value': '张伟', 'type': 'PERSON'},
              ],
              'script': 'chinese',
              'difficulty': 'easy',
              'deviceLocale': 'zh-CN',
              'generationPrompt': 'deterministic fixture',
              'sourceUrl': 'https://example.test/photo',
              'sourceAuthor': 'Example photographer',
              'sourceLicense': 'CC0 1.0',
              'unknownFutureField': true,
            },
          ],
        }),
      );

      expect(cases, hasLength(1));
      final kase = cases.single;
      expect(kase.expectedLines, ['客户资料', '姓名：张伟']);
      expect(kase.megapixels, closeTo(1.26, 0.000001));
      expect(kase.criticalSpans.single.type, 'PERSON');
      expect(kase.generationPrompt, 'deterministic fixture');
      expect(kase.sourceUrl, 'https://example.test/photo');
      expect(kase.sourceAuthor, 'Example photographer');
      expect(kase.sourceLicense, 'CC0 1.0');

      final roundTrip = OcrBenchmarkCase.fromJson(kase.toJson());
      expect(roundTrip.imagePath, kase.imagePath);
      expect(roundTrip.expectedText, kase.expectedText);
      expect(roundTrip.expectedLines, kase.expectedLines);
      expect(roundTrip.deviceLocale, 'zh-CN');
      expect(roundTrip.sourceUrl, kase.sourceUrl);
      expect(roundTrip.sourceAuthor, kase.sourceAuthor);
      expect(roundTrip.sourceLicense, kase.sourceLicense);
    });

    test('hydrates and cleans external Markdown ground truth', () {
      const path = 'benchmark/ocr/ground_truth/a4-sample.md';
      final cases = OcrBenchmarkCase.parseDataset(
        jsonEncode({
          'cases': [
            {
              'id': 'a4-sample',
              'lang': 'en',
              'category': 'a4_document',
              'imagePath': 'benchmark/ocr/images/documents/a4-sample.jpg',
              'width': 100,
              'height': 140,
              'expectedTextPath': path,
              'expectedTextFormat': 'markdown',
            },
          ],
        }),
        expectedTextAssets: const {
          path: '# Statement\n\n| Name | Amount |\n|---|---:|\n| Alice | **\$12** |\n\n- Total',
        },
      );

      expect(
        cases.single.expectedText,
        'Statement\n\nName Amount\nAlice \$12\n\nTotal',
      );
      expect(cases.single.expectedTextPath, path);
      expect(cases.single.expectedTextFormat, 'markdown');
      expect(cases.single.expectedLines, [
        'Statement',
        'Name Amount',
        'Alice \$12',
        'Total',
      ]);
    });

    test('reports a missing external ground-truth asset', () {
      expect(
        () => OcrBenchmarkCase.parseDataset(
          jsonEncode({
            'cases': [
              {
                'id': 'missing-ground-truth',
                'lang': 'en',
                'category': 'a4_document',
                'imagePath': 'missing.jpg',
                'width': 1,
                'height': 1,
                'expectedTextPath': 'missing.md',
              },
            ],
          }),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('repository manifest hydrates every external ground truth', () {
      final manifestFile = File('../../benchmark/ocr_cases.json');
      final source = manifestFile.readAsStringSync();
      final document = jsonDecode(source) as Map<String, dynamic>;
      final assets = <String, String>{};
      for (final value in document['cases'] as List<dynamic>) {
        final json = (value as Map).cast<String, Object?>();
        final path = json['expectedTextPath'] as String?;
        if (path != null) assets[path] = File('../../$path').readAsStringSync();
      }

      final cases = OcrBenchmarkCase.parseDataset(
        source,
        expectedTextAssets: assets,
      );
      expect(cases, hasLength(15));
      expect(
        cases.where((kase) => kase.expectedTextPath != null),
        hasLength(3),
      );
      for (final kase in cases) {
        for (final span in kase.criticalSpans) {
          expect(
            normalizeOcrText(kase.expectedText),
            contains(normalizeOcrText(span.value)),
            reason: '${kase.id}: missing critical span ${span.value}',
          );
        }
      }
    });
  });

  group('OCR normalization and scoring', () {
    test('normalizes line endings and layout whitespace only', () {
      expect(normalizeStrictOcrText('A\r\nB\rC'), 'A\nB\nC');
      expect(normalizeOcrText(' A  B\r\n\tC '), 'A B C');
      expect(splitOcrLines(' A  B\r\n\r\n C '), ['A B', 'C']);
      expect(normalizeOcrText('ÉLAN'), isNot(normalizeOcrText('élan')));
      expect(normalizeOcrText('84,90 €'), '84,90 €');
    });

    test('computes CER, WER, line F1, critical recall and ms/MP', () {
      final result = OcrBenchmarkScorer.score(
        benchmarkCase(),
        'cut  \r\n sat',
        const Duration(milliseconds: 400),
      );

      expect(result.normalizedExpectedText, 'cat sat');
      expect(result.normalizedRecognizedText, 'cut sat');
      expect(result.characterEditDistance, 1);
      expect(result.characterErrorRate, closeTo(1 / 7, 0.000001));
      expect(result.normalizedCharacterErrorRate, closeTo(1 / 7, 0.000001));
      expect(
        result.strictCharacterErrorRate,
        greaterThan(result.normalizedCharacterErrorRate),
      );
      expect(result.wordEditDistance, 1);
      expect(result.wordErrorRate, 0.5);
      expect(result.matchingLineCount, 1);
      expect(result.linePrecision, 0.5);
      expect(result.lineRecall, 0.5);
      expect(result.lineF1, 0.5);
      expect(result.foundCriticalSpans.map((span) => span.value), ['sat']);
      expect(result.missedCriticalSpans.map((span) => span.value), ['cat']);
      expect(result.criticalSpanRecall, 0.5);
      expect(result.exactMatch, isFalse);
      expect(result.msPerMegapixel, 200);
    });

    test('ignores whitespace-only differences for CER and exact match', () {
      final result = OcrBenchmarkScorer.score(
        benchmarkCase(expectedText: 'A  B\nC', criticalSpans: const []),
        ' A\tB C ',
        Duration.zero,
      );

      expect(result.characterErrorRate, 0);
      expect(result.strictCharacterErrorRate, greaterThan(0));
      expect(result.wordErrorRate, 0);
      expect(result.exactMatch, isTrue);
      expect(result.criticalSpanRecall, 1);
    });

    test('line matching treats repeated lines as a multiset', () {
      final result = OcrBenchmarkScorer.score(
        benchmarkCase(
          expectedText: 'same\nsame',
          expectedLines: const ['same', 'same'],
          criticalSpans: const [],
        ),
        'same',
        Duration.zero,
      );

      expect(result.matchingLineCount, 1);
      expect(result.linePrecision, 1);
      expect(result.lineRecall, 0.5);
      expect(result.lineF1, closeTo(2 / 3, 0.000001));
    });
  });

  group('OCR runner and reports', () {
    test(
      'runner injects a recognizer and captures recognizer errors',
      () async {
        final successful = OcrBenchmarkRunner(
          recognize: (kase) async => kase.expectedText,
        );
        final success = await successful.run(benchmarkCase());
        expect(success.exactMatch, isTrue);
        expect(success.error, isNull);

        final failing = OcrBenchmarkRunner(
          recognize: (_) async => throw StateError('model unavailable'),
        );
        final failure = await failing.run(benchmarkCase());
        expect(failure.failed, isTrue);
        expect(failure.recognizedText, isEmpty);
        expect(failure.error, contains('model unavailable'));
        expect(failure.characterErrorRate, 1);
      },
    );

    test('run JSON round-trips and renders Markdown and HTML', () {
      final kase = benchmarkCase(
        expectedText: '<tag> & value',
        expectedLines: const ['<tag> & value'],
        criticalSpans: const [OcrCriticalSpan(value: 'value', type: 'OTHER')],
      );
      final run = OcrBenchmarkRun(
        title: 'OCR <benchmark>',
        platform: 'test device',
        recognizerName: 'fake & deterministic',
        results: [
          OcrBenchmarkScorer.score(
            kase,
            '<tag> & value',
            const Duration(milliseconds: 20),
          ),
        ],
      );

      final decoded = OcrBenchmarkRun.fromJson(run.toJson());
      expect(decoded.title, run.title);
      expect(decoded.results.single.exactMatch, isTrue);
      expect(decoded.results.single.elapsed, const Duration(milliseconds: 20));

      final markdown = decoded.toMarkdown();
      expect(markdown, contains('## By language'));
      expect(markdown, contains('strict CER'));
      expect(markdown, contains('normalized CER'));
      expect(markdown, contains('Unicode code points'));
      expect(markdown, contains('critical-span recall 100.0%'));
      expect(markdown, contains('ocr-test-01'));

      final html = renderOcrHtml(decoded);
      expect(html, contains('<!DOCTYPE html>'));
      expect(html, contains('OCR &lt;benchmark&gt;'));
      expect(html, contains('&lt;tag&gt; &amp; value'));
      expect(html, contains('strict CER'));
      expect(html, contains('normalized CER'));
      expect(
        html,
        contains('src="../../benchmark/ocr/images/ocr-test-01.png"'),
      );
      expect(
        html,
        contains('data-fallback="benchmark/ocr/images/ocr-test-01.png"'),
      );
      expect(html, contains('Problems only'));
    });

    test('HTML links document attribution when provenance is present', () {
      final kase = OcrBenchmarkCase(
        id: 'real-photo',
        lang: 'en',
        category: 'real_photo',
        imagePath: 'benchmark/ocr/images/documents/photo.jpg',
        width: 100,
        height: 100,
        expectedText: 'SIGN',
        expectedLines: const ['SIGN'],
        criticalSpans: const [],
        sourceUrl: 'https://example.test/photo?a=1&b=2',
        sourceAuthor: 'A & B',
        sourceLicense: 'CC BY-SA 3.0',
      );
      final html = renderOcrHtml(
        OcrBenchmarkRun(
          title: 'Real photos',
          platform: 'test',
          recognizerName: 'fake',
          results: [OcrBenchmarkScorer.score(kase, 'SIGN', Duration.zero)],
        ),
      );

      expect(html, contains('https://example.test/photo?a=1&amp;b=2'));
      expect(html, contains('A &amp; B · CC BY-SA 3.0'));
    });

    test('group summary micro-aggregates edits and pixels', () {
      final summary = OcrGroupSummary('all')
        ..results.addAll([
          OcrBenchmarkScorer.score(
            benchmarkCase(expectedText: 'abc', criticalSpans: const []),
            'abc',
            const Duration(milliseconds: 100),
          ),
          OcrBenchmarkScorer.score(
            benchmarkCase(expectedText: 'def', criticalSpans: const []),
            'dex',
            const Duration(milliseconds: 300),
          ),
        ]);

      expect(summary.characterEdits, 1);
      expect(summary.strictCharacterEdits, 1);
      expect(summary.expectedCharacters, 6);
      expect(summary.characterErrorRate, closeTo(1 / 6, 0.000001));
      expect(summary.strictCharacterErrorRate, closeTo(1 / 6, 0.000001));
      expect(summary.exactMatches, 1);
      expect(summary.msPerMegapixel, 100);
      expect(ocrReliabilityGrade(summary.characterErrorRate), 'D');
    });
  });
}
