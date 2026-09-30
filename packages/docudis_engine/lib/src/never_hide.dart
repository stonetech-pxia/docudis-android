import 'detection.dart';
import 'detectors/dictionary_detector.dart';

/// Text the user never wants hidden: public names the detectors take for
/// private ones ("Leeds City Council" as an address, a boiler brand as a
/// company). Wherever a term stands in the text, found the way dictionary
/// terms are (any case, Latin accents, a line break for a space), a
/// detection that lies inside it is dropped, whichever detector found it:
/// a letterhead's "Leeds" / "CITY COUNCIL" goes as well as the whole name.
/// The user's own choices stay: dictionary terms and text hidden by hand.
/// A span that reaches beyond the term stays whole: hiding a little too
/// much is the safe side.
class NeverHide {
  NeverHide(Iterable<String> terms) : _finder = DictionaryDetector(terms);

  final DictionaryDetector _finder;

  bool get isEmpty => _finder.terms.isEmpty;

  /// Where the terms stand in [text].
  NeverHideSpans within(String text) => NeverHideSpans._([
        if (!isEmpty)
          for (final d in _finder.detectSync(text)) (d.start, d.end),
      ]);
}

/// The places in one text that stay readable.
class NeverHideSpans {
  const NeverHideSpans._(this._spans);

  final List<(int, int)> _spans;

  /// Whether [d] lies inside one of the places, spaces and punctuation at
  /// its edges aside ("Leeds City Council," is inside "Leeds City Council").
  bool covers(Detection d) {
    if (_spans.isEmpty || d.source == DetectionSource.dictionary || d.source == DetectionSource.manual) {
      return false;
    }
    final lead = _leading.firstMatch(d.value)!.end;
    final trail = d.value.length - _trailing.firstMatch(d.value)!.start;
    final start = d.start + lead;
    final end = d.end - trail;
    if (start >= end) return false;
    return _spans.any((s) => s.$1 <= start && end <= s.$2);
  }
}

final _leading = RegExp(r'^[\s\p{P}]*', unicode: true);
final _trailing = RegExp(r'[\s\p{P}]*$', unicode: true);
