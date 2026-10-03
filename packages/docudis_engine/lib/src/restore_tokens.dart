// Tolerant placeholder matching for restore, after DocCloak.Core
// src/restore-tokens.ts (Apache-2.0), modified by stonetech.
//
// LLM replies mangle placeholders: "[person_1]", "[PERSON 1]", "**[PERSON_1]**",
// "PERSON_1", "[PERSON_1.]". Every candidate and every map key is reduced to
// one canonical form; a candidate is restored only when exactly one key owns
// that form. A wrong restore silently corrupts the document, a missed one is
// visible and recoverable.

final RegExp _tokenShapedKey = RegExp(r'^(?:\[[^\[\]\n]+\]|<<[^<>\n]+>>)$');
final RegExp _markdownEmphasis = RegExp(r'[*`~]');
final RegExp _edgeJunk =
    RegExp(r'^[^\p{L}\p{N}]+|[^\p{L}\p{N}]+$', unicode: true);
final RegExp _separatorRun = RegExp(r'[\s_-]+');

/// Candidates for the tolerant pass: bracketed tokens, legacy angle tokens,
/// or bare uppercase typed tokens like `PERSON_1`.
final RegExp mangledCandidate = RegExp(
  r'\[[^\[\]\n]+\]|<<[^<>\n]+>>|(?<![\p{L}\p{N}_\[<])[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)*_\d+(?![\p{L}\p{N}_])',
  unicode: true,
);

/// "[PERSON_1]", "[person 1]", "**[PERSON-1]**" and "PERSON_1" all yield
/// "person_1". Returns null when nothing substantive remains.
String? canonicalPlaceholderForm(String candidate) {
  final stripped = candidate
      .replaceAll(_markdownEmphasis, '')
      .replaceAll(_edgeJunk, '')
      .toLowerCase();
  if (stripped.isEmpty) return null;
  final parts = stripped.split(_separatorRun).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return null;
  return parts.join('_');
}

/// Canonical form -> the one exact key it identifies. Ambiguous forms are
/// absent by construction.
Map<String, String> buildTolerantIndex(Iterable<String> keys) {
  final byCanonical = <String, String>{};
  final ambiguous = <String>{};
  for (final key in keys) {
    if (!_tokenShapedKey.hasMatch(key)) continue;
    final canonical = canonicalPlaceholderForm(key);
    if (canonical == null || ambiguous.contains(canonical)) continue;
    final existing = byCanonical[canonical];
    if (existing != null && existing != key) {
      byCanonical.remove(canonical);
      ambiguous.add(canonical);
      continue;
    }
    byCanonical[canonical] = key;
  }
  return byCanonical;
}
