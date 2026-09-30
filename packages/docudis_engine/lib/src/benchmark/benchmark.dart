import 'dart:convert';
import 'dart:io' show ProcessInfo;

import '../detection.dart';
import '../detector.dart';
import '../entity_type.dart';
import '../pipeline.dart';

/// One expected entity of a benchmark case.
class ExpectedEntity {
  const ExpectedEntity(this.value, this.type);

  final String value;
  final EntityType type;

  Map<String, Object?> toJson() => {'value': value, 'type': type.placeholderName};

  factory ExpectedEntity.fromJson(Map<String, Object?> j) => ExpectedEntity(
        j['value'] as String,
        EntityType.fromName(j['type'] as String) ?? EntityType.other,
      );
}

class BenchmarkCase {
  const BenchmarkCase({
    required this.id,
    required this.lang,
    required this.category,
    required this.text,
    required this.expected,
    required this.rulesOnly,
  });

  final String id;
  final String lang;
  final String category;
  final String text;
  final List<ExpectedEntity> expected;

  /// True when the case only exercises regex rules (no model needed).
  final bool rulesOnly;

  /// Language tags to hand to the region gating, derived from [lang]
  /// (the app gets them from ML Kit language identification instead).
  List<String> get languageTags => switch (lang) {
        'multi' => const ['en', 'zh', 'fr', 'es'],
        'zh-Hant' => const ['zh'],
        _ => [lang],
      };

  static List<BenchmarkCase> parseDataset(String json) {
    final doc = jsonDecode(json) as Map<String, dynamic>;
    return [
      for (final c in doc['cases'] as List<dynamic>)
        BenchmarkCase.fromJson((c as Map).cast<String, Object?>()),
    ];
  }

  factory BenchmarkCase.fromJson(Map<String, Object?> c) => BenchmarkCase(
        id: c['id'] as String,
        lang: c['lang'] as String,
        category: c['category'] as String,
        text: c['text'] as String,
        rulesOnly: (c['rulesOnly'] as bool?) ?? false,
        expected: [
          for (final e in c['expected'] as List<dynamic>)
            ExpectedEntity.fromJson((e as Map).cast<String, Object?>()),
        ],
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'lang': lang,
        'category': category,
        'text': text,
        if (rulesOnly) 'rulesOnly': true,
        'expected': [for (final e in expected) e.toJson()],
      };
}

/// Outcome of one case.
class CaseResult {
  const CaseResult({
    required this.kase,
    required this.detections,
    required this.hits,
    required this.partialHits,
    required this.misses,
    required this.falsePositives,
    required this.typeMismatches,
    required this.elapsed,
    this.rssAfterBytes,
  });

  final BenchmarkCase kase;
  final List<Detection> detections;

  /// Expected entities found with exact value and type.
  final List<ExpectedEntity> hits;

  /// Expected entities found with overlapping value (same type).
  final List<ExpectedEntity> partialHits;
  final List<ExpectedEntity> misses;
  final List<Detection> falsePositives;

  /// Expected value found but tagged with another type.
  final List<ExpectedEntity> typeMismatches;
  final Duration elapsed;

  /// Resident set size of the process right after the case, when the
  /// runner measured it (boundary tests).
  final int? rssAfterBytes;

  int get expectedCount => kase.expected.length;
  int get found => hits.length + partialHits.length;

  double get recall => expectedCount == 0 ? 1 : found / expectedCount;

  double get precision {
    final reported = detections.length;
    if (reported == 0) return 1;
    return (reported - falsePositives.length - typeMismatches.length) / reported;
  }

  double get f1 {
    final p = precision;
    final r = recall;
    return p + r == 0 ? 0 : 2 * p * r / (p + r);
  }

  double get msPerThousandChars =>
      kase.text.isEmpty ? 0 : elapsed.inMicroseconds / 1000 / kase.text.length * 1000;

  Map<String, Object?> toJson() => {
        'case': kase.toJson(),
        'detections': [for (final d in detections) d.toJson()],
        'hits': [for (final e in hits) e.toJson()],
        'partialHits': [for (final e in partialHits) e.toJson()],
        'misses': [for (final e in misses) e.toJson()],
        'falsePositives': [for (final d in falsePositives) d.toJson()],
        'typeMismatches': [for (final e in typeMismatches) e.toJson()],
        'elapsedMicros': elapsed.inMicroseconds,
        if (rssAfterBytes != null) 'rssAfterBytes': rssAfterBytes,
      };

  factory CaseResult.fromJson(Map<String, Object?> j) {
    List<ExpectedEntity> ents(String key) => [
          for (final e in j[key] as List<dynamic>)
            ExpectedEntity.fromJson((e as Map).cast<String, Object?>()),
        ];
    List<Detection> dets(String key) => [
          for (final d in j[key] as List<dynamic>)
            Detection.fromJson((d as Map).cast<String, Object?>()),
        ];
    return CaseResult(
      kase: BenchmarkCase.fromJson((j['case'] as Map).cast<String, Object?>()),
      detections: dets('detections'),
      hits: ents('hits'),
      partialHits: ents('partialHits'),
      misses: ents('misses'),
      falsePositives: dets('falsePositives'),
      typeMismatches: ents('typeMismatches'),
      elapsed: Duration(microseconds: j['elapsedMicros'] as int),
      rssAfterBytes: j['rssAfterBytes'] as int?,
    );
  }
}

/// A whole benchmark run: metadata plus every case result. Serializable so
/// the phone can hand its run to the desktop renderer.
class BenchmarkRun {
  const BenchmarkRun({
    required this.title,
    required this.platform,
    required this.modelName,
    required this.results,
  });

  final String title;
  final String platform;
  final String modelName;
  final List<CaseResult> results;

  String toJson() => jsonEncode({
        'title': title,
        'platform': platform,
        'modelName': modelName,
        'results': [for (final r in results) r.toJson()],
      });

  factory BenchmarkRun.fromJson(String json) {
    final j = jsonDecode(json) as Map<String, dynamic>;
    return BenchmarkRun(
      title: j['title'] as String,
      platform: j['platform'] as String,
      modelName: j['modelName'] as String,
      results: [
        for (final r in j['results'] as List<dynamic>)
          CaseResult.fromJson((r as Map).cast<String, Object?>()),
      ],
    );
  }

  String toMarkdown() => renderReport(
        title: title,
        platform: platform,
        modelName: modelName,
        results: results,
      );
}

/// Runs cases through detectors and scores them.
class BenchmarkRunner {
  BenchmarkRunner({required this.detectorsFor});

  /// Detectors for one case (typically region-gated regex + NER; ML Kit is
  /// excluded so the numbers are deterministic).
  final List<Detector> Function(BenchmarkCase kase) detectorsFor;

  Future<CaseResult> run(BenchmarkCase kase) async {
    final pipeline = DetectionPipeline(detectorsFor(kase));
    final sw = Stopwatch()..start();
    final detections = await pipeline.run(kase.text);
    sw.stop();
    return score(kase, detections, sw.elapsed, rssAfterBytes: ProcessInfo.currentRss);
  }

  static CaseResult score(
    BenchmarkCase kase,
    List<Detection> detections,
    Duration elapsed, {
    int? rssAfterBytes,
  }) {
    final hits = <ExpectedEntity>[];
    final partial = <ExpectedEntity>[];
    final misses = <ExpectedEntity>[];
    final typeMismatch = <ExpectedEntity>[];
    final matched = <Detection>{};
    for (final e in kase.expected) {
      Detection? exact;
      Detection? overlap;
      Detection? wrongType;
      for (final d in detections) {
        if (matched.contains(d)) continue;
        final sameType = _sameFamily(d.type, e.type);
        final v = d.value.trim();
        if (v == e.value) {
          if (sameType) {
            exact = d;
            break;
          }
          wrongType ??= d;
        } else if (sameType && _overlaps(v, e.value)) {
          overlap ??= d;
        }
      }
      if (exact != null) {
        hits.add(e);
        matched.add(exact);
      } else if (overlap != null) {
        partial.add(e);
        matched.add(overlap);
      } else if (wrongType != null) {
        typeMismatch.add(e);
        matched.add(wrongType);
      } else {
        misses.add(e);
      }
    }
    final falsePositives = [
      for (final d in detections)
        if (!matched.contains(d) && !_coveredByExpected(d, kase.expected)) d,
    ];
    return CaseResult(
      kase: kase,
      detections: detections,
      hits: hits,
      partialHits: partial,
      misses: misses,
      falsePositives: falsePositives,
      typeMismatches: typeMismatch,
      elapsed: elapsed,
      rssAfterBytes: rssAfterBytes,
    );
  }

  /// ID-like types are interchangeable for scoring (rule packs tag bank
  /// cards as OTHER, national IDs as ID, loose digit rules as NUMBER), and
  /// NUMBER is also a fair answer for a phone number.
  /// DATE and BIRTH_DATE are not: one is left visible, the other is hidden,
  /// so mixing them up is a real error.
  static bool _sameFamily(EntityType detected, EntityType expected) {
    final a = detected, b = expected;
    if (a == b) return true;
    if (a == EntityType.number && b == EntityType.phone) return true;
    const ids = {
      EntityType.id,
      EntityType.number,
      EntityType.card,
      EntityType.iban,
      EntityType.other,
    };
    return ids.contains(a) && ids.contains(b);
  }

  static bool _overlaps(String a, String b) {
    final short = a.length <= b.length ? a : b;
    final long = a.length <= b.length ? b : a;
    if (!long.contains(short)) return false;
    return short.length / long.length >= 0.5;
  }

  /// A detection that is a sub-span of an expected value of the same type
  /// (e.g. "Smith" when "John Smith" was expected and already matched) is
  /// not counted as a false positive.
  static bool _coveredByExpected(Detection d, List<ExpectedEntity> expected) {
    for (final e in expected) {
      if (_sameFamily(d.type, e.type) && e.value.contains(d.value.trim())) return true;
    }
    return false;
  }
}

/// Boundary cases for large inputs: documents of roughly [sizes] characters
/// built by repeating the dataset's `long` and `mixed` cases, so every
/// expected entity is known. Category `stress`, language `multi`.
List<BenchmarkCase> stressCases(
  List<BenchmarkCase> dataset, {
  List<int> sizes = const [10000, 50000, 150000],
}) {
  final sources = dataset
      .where((c) => c.category == 'long' || c.category == 'mixed')
      .toList();
  if (sources.isEmpty) return const [];
  return [for (final size in sizes) _buildStressCase(sources, size)];
}

BenchmarkCase _buildStressCase(List<BenchmarkCase> sources, int size) {
  final text = StringBuffer();
  final expected = <ExpectedEntity>[];
  var i = 0;
  while (text.length < size) {
    final src = sources[i % sources.length];
    if (text.isNotEmpty) text.write('\n\n');
    text.write(src.text);
    expected.addAll(src.expected);
    i++;
  }
  final kb = (size / 1000).round();
  return BenchmarkCase(
    id: 'stress-${kb}k',
    lang: 'multi',
    category: 'stress',
    text: text.toString(),
    expected: expected,
    rulesOnly: false,
  );
}

/// "a, b×3, c" — distinct values with repeat counts, at most [limit] shown.
String compactValues(Iterable<String> values, {int limit = 12}) {
  final counts = <String, int>{};
  for (final v in values) {
    counts[v] = (counts[v] ?? 0) + 1;
  }
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final shown = entries.take(limit).map((e) => e.value > 1 ? '${e.key}×${e.value}' : e.key);
  final rest = entries.length - limit;
  return rest > 0 ? '${shown.join(', ')} … +$rest more' : shown.join(', ');
}

/// Letter grades used in the report.
String reliabilityGrade(double f1) {
  if (f1 >= 0.90) return 'A';
  if (f1 >= 0.75) return 'B';
  if (f1 >= 0.50) return 'C';
  return 'D';
}

String speedGrade(double msPerThousandChars) {
  if (msPerThousandChars < 300) return 'A';
  if (msPerThousandChars < 1000) return 'B';
  if (msPerThousandChars < 3000) return 'C';
  return 'D';
}

/// Aggregates results per (lang, category) group.
class GroupSummary {
  GroupSummary(this.key);

  final String key;
  final List<CaseResult> results = [];

  int get expected => results.fold(0, (s, r) => s + r.expectedCount);
  int get found => results.fold(0, (s, r) => s + r.found);
  int get falsePositives => results.fold(0, (s, r) => s + r.falsePositives.length);
  int get reported => results.fold(0, (s, r) => s + r.detections.length);
  int get chars => results.fold(0, (s, r) => s + r.kase.text.length);
  Duration get elapsed =>
      results.fold(Duration.zero, (s, r) => s + r.elapsed);

  double get recall => expected == 0 ? 1 : found / expected;
  double get precision => reported == 0 ? 1 : (reported - falsePositives) / reported;
  double get f1 {
    final p = precision;
    final r = recall;
    return p + r == 0 ? 0 : 2 * p * r / (p + r);
  }

  double get msPerThousandChars => chars == 0 ? 0 : elapsed.inMicroseconds / 1000 / chars * 1000;
}

/// Renders the markdown report.
String renderReport({
  required String title,
  required String platform,
  required String modelName,
  required List<CaseResult> results,
}) {
  final byLang = <String, GroupSummary>{};
  final byCategory = <String, GroupSummary>{};
  final all = GroupSummary('all');
  for (final r in results) {
    byLang.putIfAbsent(r.kase.lang, () => GroupSummary(r.kase.lang)).results.add(r);
    byCategory.putIfAbsent(r.kase.category, () => GroupSummary(r.kase.category)).results.add(r);
    all.results.add(r);
  }
  String pct(double v) => '${(v * 100).round()}%';
  String ms(double v) => v.toStringAsFixed(0);

  final out = StringBuffer()
    ..writeln('# $title')
    ..writeln()
    ..writeln('- Model: $modelName')
    ..writeln('- Platform: $platform')
    ..writeln('- Cases: ${results.length}, expected entities: ${all.expected}')
    ..writeln('- Overall: recall ${pct(all.recall)}, precision ${pct(all.precision)}, '
        'F1 ${pct(all.f1)} → reliability **${reliabilityGrade(all.f1)}**; '
        '${ms(all.msPerThousandChars)} ms per 1000 chars → speed **${speedGrade(all.msPerThousandChars)}**')
    ..writeln()
    ..writeln('Grades: reliability by F1 (A ≥ 90%, B ≥ 75%, C ≥ 50%, D below); '
        'speed by ms per 1000 characters on this platform (A < 300, B < 1000, C < 3000, D above).')
    ..writeln()
    ..writeln('## By language')
    ..writeln()
    ..writeln('| Language | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |')
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final g in byLang.values) {
    out.writeln('| ${g.key} | ${g.results.length} | ${g.expected} | ${g.found} | ${g.falsePositives} | '
        '${pct(g.recall)} | ${pct(g.precision)} | ${pct(g.f1)} | ${reliabilityGrade(g.f1)} | '
        '${ms(g.msPerThousandChars)} | ${speedGrade(g.msPerThousandChars)} |');
  }
  out
    ..writeln()
    ..writeln('## By category')
    ..writeln()
    ..writeln('| Category | Cases | Expected | Found | False pos. | Recall | Precision | F1 | Reliability | ms/1000 chars | Speed |')
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final g in byCategory.values) {
    out.writeln('| ${g.key} | ${g.results.length} | ${g.expected} | ${g.found} | ${g.falsePositives} | '
        '${pct(g.recall)} | ${pct(g.precision)} | ${pct(g.f1)} | ${reliabilityGrade(g.f1)} | '
        '${ms(g.msPerThousandChars)} | ${speedGrade(g.msPerThousandChars)} |');
  }
  out
    ..writeln()
    ..writeln('## Per case')
    ..writeln()
    ..writeln('| Case | Chars | Expected | Hit | Partial | Missed | Wrong type | False pos. | F1 | ms | Notes |')
    ..writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final r in results) {
    final rss = r.rssAfterBytes;
    final notes = <String>[
      if (r.kase.category == 'stress' && rss != null) 'RSS ${(rss / 1048576).round()} MB',
      if (r.misses.isNotEmpty) 'missed: ${compactValues(r.misses.map((e) => e.value))}',
      if (r.typeMismatches.isNotEmpty)
        'wrong type: ${compactValues(r.typeMismatches.map((e) => e.value))}',
      if (r.falsePositives.isNotEmpty)
        'extra: ${compactValues(r.falsePositives.map((d) => '${d.value}(${d.type.placeholderName})'))}',
    ];
    out.writeln('| ${r.kase.id} | ${r.kase.text.length} | ${r.expectedCount} | ${r.hits.length} | '
        '${r.partialHits.length} | ${r.misses.length} | ${r.typeMismatches.length} | '
        '${r.falsePositives.length} | ${pct(r.f1)} | ${r.elapsed.inMilliseconds} | '
        '${notes.join('; ').replaceAll('|', '\\|')} |');
  }
  return out.toString();
}
