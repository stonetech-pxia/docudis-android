import '../detection.dart';
import '../detector.dart';
import '../entity_type.dart';

/// User-supplied terms that must always be replaced.
///
/// Matching ignores case and Latin accents ("Émilie" also finds the "EMILIE"
/// of a scan) and is whole-word for terms made of letters and digits; CJK
/// terms match anywhere since CJK text has no word boundaries. A space in a
/// term stands for any run of whitespace, so a term still matches where the
/// document breaks the line.
class DictionaryDetector implements Detector {
  DictionaryDetector(Iterable<String> terms)
      : terms = terms.map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();

  final Set<String> terms;

  @override
  String get name => 'dictionary';

  @override
  Future<List<Detection>> detect(String text) async => detectSync(text);

  List<Detection> detectSync(String text) {
    final out = <Detection>[];
    for (final term in terms) {
      final escaped = _loosePattern(term);
      final wordBounded = _isWordy(term);
      final pattern = RegExp(
        wordBounded ? '(?<![\\p{L}\\p{N}])$escaped(?![\\p{L}\\p{N}])' : escaped,
        caseSensitive: false,
        unicode: true,
      );
      for (final m in pattern.allMatches(text)) {
        out.add(Detection(
          type: EntityType.custom,
          value: m.group(0)!,
          start: m.start,
          end: m.end,
          confidence: 1.0,
          detector: 'dictionary',
          source: DetectionSource.dictionary,
        ));
      }
    }
    return out;
  }

  /// A base letter and the accented forms it stands for. One character
  /// each, so a match keeps the offsets of the text it was found in.
  static const _accents = ['aàáâãäå', 'cç', 'eèéêë', 'iìíîï', 'nñ', 'oòóôõö', 'uùúûü', 'yýÿ'];

  static final _space = RegExp(r'\s+');

  static String _loosePattern(String term) {
    final out = StringBuffer();
    for (final word in term.split(_space)) {
      if (out.isNotEmpty) out.write(r'\s+');
      for (final rune in word.runes) {
        final char = String.fromCharCode(rune);
        final lower = char.toLowerCase();
        final family = _accents.where((f) => f.contains(lower)).firstOrNull;
        out.write(family == null ? RegExp.escape(char) : '[$family]');
      }
    }
    return out.toString();
  }

  static final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]');

  static bool _isWordy(String term) => !_cjk.hasMatch(term);
}
