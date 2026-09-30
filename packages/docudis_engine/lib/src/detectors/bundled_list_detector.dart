import 'dart:convert';

import '../detection.dart';
import '../detector.dart';
import '../entity_type.dart';
import '../lists/bundled_lists_data.dart';

/// Names shipped with the app (well-known companies, Chinese places) that
/// the NER model tends to miss when they carry no suffix such as 有限公司
/// or Ltd: 阿里巴巴, El Corte Inglés, Russell McVeagh, 深圳.
///
/// Latin terms match whole words, case-sensitively (so "apple" in prose is
/// not Apple Inc.); CJK terms match anywhere. Lookup is by hash, not by one
/// regex per term, so tens of thousands of names cost one pass over the
/// text. Spans have [DetectionSource.bundledList] priority: equal to the
/// model's, so a longer model span ("深圳华强科技") still wins over a list
/// hit inside it ("深圳").
class BundledListDetector implements Detector {
  BundledListDetector(Map<EntityType, Iterable<String>> lists) {
    for (final entry in lists.entries) {
      for (final raw in entry.value) {
        final term = raw.replaceAll(_edge, '');
        if (term.isEmpty) continue;
        if (_cjk.hasMatch(term)) {
          if (term.length < 2) continue;
          _cjkTerms[term] = entry.key;
          _cjkFirst.add(term.codeUnitAt(0));
          _cjkLengths.add(term.length);
        } else {
          final words = _word.allMatches(term).toList();
          if (words.isEmpty || term.length < 3) continue;
          _latinTerms[term] = entry.key;
          _latinFirst.add(words.first.group(0)!);
          if (words.length > _maxWords) _maxWords = words.length;
        }
      }
    }
    _cjkLengthList = _cjkLengths.toList()..sort();
  }

  /// The lists shipped in the package (see tool/embed_lists.dart).
  factory BundledListDetector.bundled() => BundledListDetector({
        EntityType.company: (jsonDecode(bundledCompanyNamesJson) as List<dynamic>).cast<String>(),
        EntityType.address: (jsonDecode(bundledPlaceNamesJson) as List<dynamic>).cast<String>(),
      });

  final Map<String, EntityType> _latinTerms = {};
  final Map<String, EntityType> _cjkTerms = {};

  /// First words / first code units of the terms: most positions in a text
  /// start no term at all, so this skips the substring lookups there.
  final Set<String> _latinFirst = {};
  final Set<int> _cjkFirst = {};
  final Set<int> _cjkLengths = {};
  List<int> _cjkLengthList = const [];
  var _maxWords = 0;

  int get termCount => _latinTerms.length + _cjkTerms.length;

  static final _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);
  static final _edge = RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true);
  static final _cjk = RegExp(r'[㐀-鿿]');

  @override
  String get name => 'list';

  @override
  Future<List<Detection>> detect(String text) async => detectSync(text);

  List<Detection> detectSync(String text) {
    final out = <Detection>[];
    if (_latinTerms.isNotEmpty) {
      final words = _word.allMatches(text).toList();
      for (var i = 0; i < words.length; i++) {
        if (!_latinFirst.contains(words[i].group(0)!)) continue;
        final start = words[i].start;
        for (var n = 1; n <= _maxWords && i + n - 1 < words.length; n++) {
          final end = words[i + n - 1].end;
          final type = _latinTerms[text.substring(start, end)];
          if (type != null) out.add(_hit(type, text, start, end));
        }
      }
    }
    if (_cjkTerms.isNotEmpty) {
      for (var i = 0; i < text.length; i++) {
        if (!_cjkFirst.contains(text.codeUnitAt(i))) continue;
        for (final length in _cjkLengthList) {
          final end = i + length;
          if (end > text.length) break;
          final type = _cjkTerms[text.substring(i, end)];
          if (type != null) out.add(_hit(type, text, i, end));
        }
      }
    }
    return out;
  }

  Detection _hit(EntityType type, String text, int start, int end) => Detection(
        type: type,
        value: text.substring(start, end),
        start: start,
        end: end,
        confidence: 0.9,
        detector: 'list:${type.placeholderName.toLowerCase()}',
        source: DetectionSource.bundledList,
      );
}
