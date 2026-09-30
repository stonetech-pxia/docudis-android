import 'dart:math';

import 'entity_type.dart';
import 'placeholder_map.dart';
import 'restore_tokens.dart';

/// One document an AI reply may answer: the anonymized text that was sent
/// and the key that restores it. Its words and label contexts are indexed
/// once.
class ReplyCandidate {
  ReplyCandidate({required String output, required PlaceholderMap map})
      : _labels = {
          for (final key in map.reverse.keys) ?_label(key),
        } {
    final indexed = _Indexed(output);
    _words = indexed.words;
    _contexts = indexed.contexts;
  }

  final Set<String> _labels;
  late final Set<String> _words;
  late final Map<String, Set<String>> _contexts;

  /// Highest number this document gave a label type ("person" -> 3).
  int _highest(String type) {
    var n = 0;
    for (final label in _labels) {
      final (t, i) = _split(label);
      if (t == type && i > n) n = i;
    }
    return n;
  }
}

/// What a pasted reply says about the document it is restored with.
class ReplyCheck {
  const ReplyCheck({
    this.unknown = const [],
    this.invented = const [],
    this.betterMatch,
  });

  /// Labels in the reply the document never issued, as `[PERSON_4]`, in
  /// reading order, except the [invented] ones.
  final List<String> unknown;

  /// Labels an AI plausibly made up: a higher number of a type the
  /// document has (`[PERSON_4]` next to `[PERSON_1]`..`[PERSON_3]`), or a
  /// type no document ever has (`[EXPEDIENTE_1]`).
  final List<String> invented;

  /// Id of another document the reply fits clearly better.
  final String? betterMatch;
}

/// Tells which document an AI reply answers, so a reply is not restored
/// with another document's key: every document numbers its labels from 1,
/// so `[PERSON_1]` and `[IBAN_1]` exist in most of them and the labels alone
/// cannot tell.
///
/// Evidence, per document: the words around each label in the reply that
/// also stand around that label in the document ("DNI [ID_1]" against
/// "Nº de referencia: [ID_1]"), plus the reply's words the document shares,
/// weighted by how few documents share them. A document fits clearly better
/// when it misses fewer of the reply's labels and has no less evidence, or
/// misses no more and has at least twice the evidence. A short reply with
/// no words of its own gives no evidence either way.
class ReplyMatcher {
  ReplyMatcher(this.candidates);

  /// Record id -> document.
  final Map<String, ReplyCandidate> candidates;

  ReplyCheck check(String reply, String id) {
    final current = candidates[id];
    if (current == null) return const ReplyCheck();
    final indexed = _Indexed(reply);
    final labels = indexed.labels;
    if (labels.isEmpty) return const ReplyCheck();

    final n = candidates.length;
    final idf = <String, double>{
      for (final w in indexed.words)
        w: log((n + 1) / (candidates.values.where((c) => c._words.contains(w)).length + 1)),
    };
    double evidence(ReplyCandidate c) {
      var score = 0.0;
      for (final MapEntry(key: label, value: around) in indexed.contexts.entries) {
        final there = c._contexts[label];
        if (there != null) score += around.where(there.contains).length;
      }
      for (final w in indexed.words) {
        if (c._words.contains(w)) score += idf[w]!;
      }
      return score;
    }

    int missing(ReplyCandidate c) => labels.where((l) => !c._labels.contains(l)).length;

    final ownScore = evidence(current);
    final ownMissing = missing(current);
    String? better;
    var betterScore = 0.0;
    for (final MapEntry(key: otherId, value: other) in candidates.entries) {
      if (otherId == id) continue;
      final score = evidence(other);
      final misses = missing(other);
      final fits = (misses < ownMissing && score >= ownScore) ||
          (misses <= ownMissing && score >= 2 * ownScore && score - ownScore >= 3);
      if (fits && (better == null || score > betterScore)) {
        better = otherId;
        betterScore = score;
      }
    }

    final unknown = <String>[];
    final invented = <String>[];
    for (final label in labels.where((l) => !current._labels.contains(l))) {
      final (type, number) = _split(label);
      final highest = current._highest(type);
      final issued = EntityType.fromName(type.toUpperCase()) != null;
      (!issued || (highest > 0 && number > highest) ? invented : unknown).add('[${label.toUpperCase()}]');
    }
    return ReplyCheck(unknown: unknown, invented: invented, betterMatch: better);
  }
}

/// A text's labels (canonical, "person_1"), its words outside labels, and
/// the words around each label.
class _Indexed {
  _Indexed(String text) {
    final masked = StringBuffer();
    final spans = <(String, int, int)>[];
    var cursor = 0;
    for (final m in mangledCandidate.allMatches(text)) {
      final label = _label(m.group(0)!);
      if (label == null) continue;
      masked
        ..write(text.substring(cursor, m.start))
        ..write(' ' * (m.end - m.start));
      spans.add((label, m.start, m.end));
      cursor = m.end;
    }
    masked.write(text.substring(cursor));
    final plain = masked.toString();
    words = _wordsOf(plain).toSet();
    for (final (label, start, end) in spans) {
      labels.add(label);
      final before = _wordsOf(plain.substring(max(0, start - 40), start));
      final after = _wordsOf(plain.substring(end, min(plain.length, end + 25)));
      (contexts[label] ??= {})
        ..addAll(before.skip(max(0, before.length - 3)))
        ..addAll(after.take(2));
    }
  }

  final labels = <String>{};
  late final Set<String> words;
  final contexts = <String, Set<String>>{};
}

final _word = RegExp(r'[\p{L}\p{N}]{3,}', unicode: true);
final _labelForm = RegExp(r'^[a-z]+(?:_[a-z]+)*_\d+$');

List<String> _wordsOf(String text) =>
    [for (final m in _word.allMatches(text)) m.group(0)!.toLowerCase()];

/// "[PERSON_1]", "[person 1]" or a bare "PERSON_1" as "person_1"; null for
/// anything that is not a typed, numbered label ("[12/9/26, 9:14]").
String? _label(String candidate) {
  final canonical = canonicalPlaceholderForm(candidate);
  return canonical != null && _labelForm.hasMatch(canonical) ? canonical : null;
}

(String, int) _split(String label) {
  final i = label.lastIndexOf('_');
  return (label.substring(0, i), int.parse(label.substring(i + 1)));
}
