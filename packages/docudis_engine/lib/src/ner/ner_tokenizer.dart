import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:typed_data';

import 'package:dart_bert_tokenizer/dart_bert_tokenizer.dart' as bert;
import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart'
    as sp;

/// Tokens of a whole text, without special tokens, with UTF-16 offsets
/// back into the source string.
class NerEncoding {
  const NerEncoding({
    required this.ids,
    required this.starts,
    required this.ends,
    required this.wordIds,
  });

  final List<int> ids;

  /// UTF-16 start/end offsets of each token in the source text.
  final List<int> starts;
  final List<int> ends;

  /// Word index of each token; subword continuations share the id.
  final List<int?> wordIds;

  int get length => ids.length;
}

/// Tokenizer facade so the NER detector does not care which family the
/// current model uses.
abstract class NerTokenizer {
  NerEncoding encode(String text);

  /// Ids of the sequence-start and sequence-end special tokens
  /// (`[CLS]`/`[SEP]` for BERT, `<s>`/`</s>` for XLM-R).
  int get startId;
  int get endId;

  /// Builds the tokenizer named in a model spec from the file's contents:
  /// `tokenizer.json` for `wordpiece`, the `.model` protobuf for
  /// `sentencepiece`.
  static NerTokenizer fromSpec(String kind, Uint8List tokenizerFile) {
    switch (kind) {
      case 'wordpiece':
        return WordPieceNerTokenizer(
          bert.WordPieceTokenizer.fromTokenizerJsonString(
            utf8.decode(tokenizerFile),
          ),
        );
      case 'sentencepiece':
        // A HuggingFace `tokenizer.json` (carries the model's own token ids,
        // e.g. XLM-R's fairseq offsets) or a raw SentencePiece `.model`.
        final looksLikeJson = tokenizerFile.isNotEmpty &&
            tokenizerFile.first == 0x7B; // '{'
        return SentencePieceNerTokenizer(
          looksLikeJson
              ? sp.TokenizerJsonLoader.fromJsonString(
                  _withoutStripNormalizer(utf8.decode(tokenizerFile)),
                )
              : sp.SentencePieceTokenizer.fromBytes(tokenizerFile),
        );
      default:
        throw ArgumentError.value(kind, 'kind', 'unknown tokenizer kind');
    }
  }
}

/// XLM-R's `tokenizer.json` ends its normalizer sequence with a `Strip`
/// (trailing whitespace) step that dart_sentencepiece_tokenizer rejects.
/// Dropping it only changes how trailing spaces tokenize, which never
/// affects entity spans, so it is removed before loading.
String _withoutStripNormalizer(String json) {
  final data = jsonDecode(json) as Map<String, dynamic>;
  final normalizer = data['normalizer'];
  if (normalizer is Map<String, dynamic>) {
    if (normalizer['type'] == 'Strip') {
      data['normalizer'] = null;
    } else if (normalizer['type'] == 'Sequence') {
      final steps = (normalizer['normalizers'] as List<dynamic>)
          .where((n) => (n as Map<String, dynamic>)['type'] != 'Strip')
          .toList();
      normalizer['normalizers'] = steps;
    } else {
      return json;
    }
    return jsonEncode(data);
  }
  return json;
}

/// Maps code-point offsets (what the tokenizer packages report) to UTF-16
/// offsets (what Dart strings index by).
List<int> _codePointToUnitIndex(String text) {
  final table = <int>[];
  var unit = 0;
  for (final r in text.runes) {
    table.add(unit);
    unit += r > 0xFFFF ? 2 : 1;
  }
  table.add(unit);
  return table;
}

class WordPieceNerTokenizer implements NerTokenizer {
  WordPieceNerTokenizer(this._tokenizer) {
    final withSpecial = _tokenizer.encode('a', addSpecialTokens: true).ids;
    startId = withSpecial.first;
    endId = withSpecial.last;
  }

  final bert.WordPieceTokenizer _tokenizer;

  @override
  late final int startId;
  @override
  late final int endId;

  @override
  NerEncoding encode(String text) {
    final enc = _tokenizer.encode(text, addSpecialTokens: false);
    final table = _codePointToUnitIndex(text);
    return NerEncoding(
      ids: enc.ids,
      starts: [for (final (s, _) in enc.offsets) table[s]],
      ends: [for (final (_, e) in enc.offsets) table[e]],
      wordIds: enc.wordIds,
    );
  }
}

class SentencePieceNerTokenizer implements NerTokenizer {
  SentencePieceNerTokenizer(this._tokenizer) {
    final withSpecial = _tokenizer.encode('a', addSpecialTokens: true).ids;
    startId = withSpecial.first;
    endId = withSpecial.last;
  }

  final sp.SentencePieceTokenizer _tokenizer;

  @override
  late final int startId;
  @override
  late final int endId;

  @override
  NerEncoding encode(String text) {
    final enc = _tokenizer.encode(text, addSpecialTokens: false);
    final (starts, ends) = realign(text, enc.tokens);
    return NerEncoding(
      ids: enc.ids,
      starts: starts,
      ends: ends,
      wordIds: _wordIds(text, starts, ends),
    );
  }

  static final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]');
  static final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);
  static final _space = RegExp(r'\s');

  /// UTF-16 offsets of [tokens] (SentencePiece pieces, `▁` = a space) in
  /// [text], placed again from the pieces themselves.
  ///
  /// dart_sentencepiece_tokenizer 1.4.1 maps its normalized text back one
  /// character at a time and never recovers from a character the normalizer
  /// changed ("º" → "o", "½" → "1⁄2", "\r\n" → a space): every later offset
  /// drifts, and model labels land on the wrong words. Here each piece is
  /// found in the source after the one before it; a piece that cannot be
  /// found as written (the normalizer changed it) is laid over the text
  /// between its found neighbours. As in the package, a piece that starts
  /// with `▁` owns the whitespace in front of it.
  static (List<int>, List<int>) realign(String text, List<String> tokens) {
    final starts = List<int>.filled(tokens.length, 0);
    final ends = List<int>.filled(tokens.length, 0);
    bool space(int i) => _space.hasMatch(text[i]);
    final pending = <int>[];
    var pendingChars = 0;
    var cursor = 0;

    // Lays the pending pieces over text[from, to) in order.
    void place(int from, int to) {
      var at = from;
      for (var k = 0; k < pending.length; k++) {
        final i = pending[k];
        var content = at;
        while (content < to && space(content)) {
          content++;
        }
        final start = tokens[i].startsWith('▁') ? at : content;
        var end = content + tokens[i].replaceAll('▁', '').length;
        if (k == pending.length - 1 || end > to) end = to;
        while (end > content && space(end - 1)) {
          end--;
        }
        starts[i] = start;
        ends[i] = end < start ? start : end;
        at = ends[i];
      }
      pending.clear();
      pendingChars = 0;
    }

    for (var i = 0; i < tokens.length; i++) {
      final piece = tokens[i].replaceAll('▁', '');
      final found = piece.isEmpty ? -1 : _find(text, piece, cursor, pendingChars);
      if (found == -1) {
        pending.add(i);
        pendingChars += piece.length;
        continue;
      }
      var start = found;
      if (tokens[i].startsWith('▁')) {
        while (start > cursor && space(start - 1)) {
          start--;
        }
      }
      place(cursor, start);
      starts[i] = start;
      ends[i] = found + piece.length;
      cursor = ends[i];
    }
    place(cursor, text.length);
    return (starts, ends);
  }

  /// Where [piece] is in [text] from [cursor] on, when what it skips is
  /// whitespace plus about the [pendingChars] of the pieces not found yet;
  /// -1 otherwise.
  static int _find(String text, String piece, int cursor, int pendingChars) {
    var skipped = 0;
    for (var at = cursor; at + piece.length <= text.length; at++) {
      if (text.startsWith(piece, at)) return at;
      if (!_space.hasMatch(text[at]) && ++skipped > pendingChars + 2) return -1;
    }
    return -1;
  }

  /// SentencePiece has no word concept (a whole Chinese sentence is one
  /// "word"), so words are derived here: a piece that starts with
  /// whitespace (the `▁` marker) begins a word, every piece containing CJK
  /// characters is a word of its own, and so is a punctuation-only piece
  /// (otherwise "Chen." would inherit the PERSON label of "Chen"). Latin
  /// subword continuations ("Ye" "ster" "day") stay in one word, which the
  /// BIO decoder needs.
  static List<int?> _wordIds(String text, List<int> starts, List<int> ends) {
    final out = <int?>[];
    var word = -1;
    var prevStandalone = false;
    var prevEnd = -1;
    for (var i = 0; i < starts.length; i++) {
      final piece = text.substring(starts[i], ends[i]);
      final standalone = _cjk.hasMatch(piece) || !_wordChar.hasMatch(piece);
      final startsWithSpace =
          piece.isNotEmpty && piece.trimLeft().length < piece.length;
      final gap = starts[i] > prevEnd;
      if (word == -1 || startsWithSpace || standalone || prevStandalone || gap) {
        word++;
      }
      out.add(word);
      prevStandalone = standalone;
      prevEnd = ends[i];
    }
    return out;
  }
}
