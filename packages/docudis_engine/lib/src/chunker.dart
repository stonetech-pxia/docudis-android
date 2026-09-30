import 'detection.dart';

/// A range of the text the user can redact with a single tap.
///
/// Offsets are UTF-16 code-unit indices, like [Detection].
class TextChunk {
  const TextChunk(this.start, this.end);

  final int start;
  final int end;

  int get length => end - start;

  bool contains(int offset) => offset >= start && offset < end;

  @override
  String toString() => 'TextChunk($start:$end)';
}

/// Cuts [text] into one-tap chunks. Whatever [taken] covers — the spans the
/// detectors found — is left out, and is a hard boundary: no chunk crosses a
/// placeholder.
///
/// Three cuts and one merge:
///
/// 1. lines (`\n`), which for photos are the OCR lines as ML Kit joined them;
/// 2. cells inside a line (tab, two or more spaces, `|`), which is what
///    splits `Label : value` and invoice columns;
/// 3. clauses inside a cell (`,` `;` `:` `。` `、` …), keeping the punctuation
///    that belongs to a value (`1,250.00`, `pierre.martin@exemple.fr`);
/// 4. atoms that read as one value — a run of capitalised words, a group of
///    digits, an e-mail, a CJK run — merge back into one chunk, so a full
///    name or a spaced-out phone number takes one tap.
///
/// Lower-case prose words stay one chunk each; lone punctuation is not a
/// chunk at all. CJK has no word boundaries to go by, so a CJK run is only
/// cut at punctuation: one tap there covers a clause.
List<TextChunk> chunkText(String text, {Iterable<Detection> taken = const []}) {
  final chunks = <TextChunk>[];
  for (final (from, to) in _outside(text, taken)) {
    for (final (start, end) in _segments(text, from, to)) {
      _mergeAtoms(text, start, end, chunks);
    }
  }
  return chunks;
}

/// The stretches of [text] that [taken] does not cover.
List<(int, int)> _outside(String text, Iterable<Detection> taken) {
  final ranges = [for (final d in taken) (d.start, d.end)]
    ..sort((a, b) => a.$1.compareTo(b.$1));
  final out = <(int, int)>[];
  var cursor = 0;
  for (final (start, end) in ranges) {
    if (end <= cursor) continue;
    if (start > cursor) out.add((cursor, start));
    cursor = end;
  }
  if (cursor < text.length) out.add((cursor, text.length));
  return out;
}

/// Cuts 1-3: the ranges between hard breaks inside `text[from:to]`.
List<(int, int)> _segments(String text, int from, int to) {
  final out = <(int, int)>[];
  var start = from;
  for (var i = from; i < to; i++) {
    final width = _breakAt(text, i);
    if (width == 0) continue;
    if (i > start) out.add((start, i));
    i += width - 1;
    start = i + 1;
  }
  if (start < to) out.add((start, to));
  return out;
}

/// How many characters the hard break at [i] spans, or 0 if there is none.
int _breakAt(String text, int i) {
  final c = text[i];
  if (c == '\n' || c == '\t' || c == '|' || c == ' ') return 1;
  if (c == ' ') {
    var n = 0;
    while (i + n < text.length && text[i + n] == ' ') {
      n++;
    }
    // A single space joins atoms; a run of them is a column gap.
    return n >= 2 ? n : 0;
  }
  if (_clausePunct.contains(c)) return 1;
  if (c == ':') return i + 1 == text.length || text[i + 1] == ' ' ? 1 : 0;
  if (c == ',' || c == '.') {
    // Not a break inside a number (1,250.00) or a host name.
    if (_digit(text, i - 1) && _digit(text, i + 1)) return 0;
    if (c == '.') {
      if (_letter(text, i + 1)) return 0; // exemple.fr
      if (_abbreviationBefore(text, i)) return 0; // Ms. Dr. No.
    }
    return 1;
  }
  return 0;
}

const _clausePunct = {
  ';', '?', '!', '，', '；', '：', '、', '。', //
  '！', '？', '(', ')', '（', '）', '[', ']', //
  '【', '】', '《', '》', '"', '“', '”', //
  '「', '」', '『', '』', '<', '>', '{', '}',
};

/// True for `Ms.`, `Dr.`, `No.`: up to three letters, starting upper case.
bool _abbreviationBefore(String text, int dot) {
  var i = dot - 1;
  var letters = 0;
  while (_letter(text, i)) {
    i--;
    letters++;
    if (letters > 3) return false;
  }
  if (letters == 0) return false;
  final first = text[i + 1];
  return first.toUpperCase() == first && first.toLowerCase() != first;
}

bool _digit(String text, int i) {
  if (i < 0 || i >= text.length) return false;
  final c = text.codeUnitAt(i);
  return c >= 0x30 && c <= 0x39;
}

bool _letter(String text, int i) =>
    i >= 0 && i < text.length && _latinLetter.hasMatch(text[i]);

/// Cut 4: the atoms inside one segment, salient neighbours merged.
void _mergeAtoms(String text, int start, int end, List<TextChunk> out) {
  final atoms = _atom
      .allMatches(text.substring(start, end))
      .map((m) => (start + m.start, start + m.end))
      .toList();
  var i = 0;
  while (i < atoms.length) {
    final (from, to) = atoms[i];
    if (!_salient(text, from, to)) {
      // A lower-case prose word is a chunk of its own; punctuation is not.
      if (_letter(text, from)) out.add(TextChunk(from, to));
      i++;
      continue;
    }
    var last = i; // the last salient atom taken so far
    var bridged = 0; // short lower-case words waiting for another salient
    var j = i;
    while (j + 1 < atoms.length) {
      final (nextFrom, nextTo) = atoms[j + 1];
      final gap = text.substring(atoms[j].$2, nextFrom);
      if (gap != '' && gap != ' ') break;
      if (nextTo - from > _maxChunk) break;
      if (_salient(text, nextFrom, nextTo)) {
        last = j + 1;
        bridged = 0;
      } else if (bridged < _maxBridge &&
          nextTo - nextFrom <= _maxBridgeWord &&
          _letter(text, nextFrom)) {
        bridged++; // e.g. "14 rue de la Paix"
      } else {
        break;
      }
      j++;
    }
    out.add(TextChunk(from, atoms[last].$2));
    // Words bridged past the last salient atom are chunks of their own.
    i = last + 1;
  }
}

/// The longest chunk one tap may cover, in characters.
const _maxChunk = 60;

/// How many short lower-case words may sit between two salient atoms, and
/// how short they have to be.
///
/// Three characters at most: enough for the particles that hold a name or an
/// address together ("14 rue de la Paix", "Ludwig van Beethoven"), short
/// enough to leave ordinary verbs out ("Please call Sarah Meyer" is three
/// chunks, not one).
const _maxBridge = 3;
const _maxBridgeWord = 3;

/// Whether the atom reads as a value on its own, and so merges with its
/// neighbours: e-mails and URLs, abbreviations, capitalised words, digit
/// groups, CJK runs, currency signs.
bool _salient(String text, int start, int end) {
  final atom = text.substring(start, end);
  if (atom.contains('@') || atom.contains('://')) return true;
  if (_cjk.hasMatch(atom)) return true;
  if (_digit(text, start)) return true;
  if (_currency.contains(atom)) return true;
  if (!_latinLetter.hasMatch(atom[0])) return false;
  return atom[0].toUpperCase() == atom[0] && atom[0].toLowerCase() != atom[0];
}

const _currency = {
  '€', '£', '\$', '¥', '%', '₽', '₹', '¢',
};

final _latinLetter = RegExp(r'[A-Za-zÀ-ɏ]');
final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯豈-﫿]');

final _atom = RegExp(
  r'[^\s]+@[^\s]+' // e-mail
  r'|[A-Za-z][A-Za-z0-9+.\-]*://[^\s]+|www\.[^\s]+' // URL
  r'|[぀-ヿ㐀-鿿가-힯豈-﫿]+' // CJK run
  r'|[A-Za-zÀ-ɏ]{1,3}\.' // Ms. Dr. No.
  r"|[0-9](?:[0-9.,/\-+'’]*[0-9])?" // digit group
  r"|[A-Za-zÀ-ɏ][A-Za-zÀ-ɏ'’\-]*" // word
  r'|[^\s]', // anything else, one character
);
