import 'detection.dart';
import 'detector.dart';
import 'entity_type.dart';
import 'never_hide.dart';
import 'repair.dart';
import 'rules/birth_date.dart';
import 'rules/public_products.dart';
import 'rules/title_stoplist.dart';

/// Runs all detectors, then merges their spans into one non-overlapping,
/// reading-ordered list.
///
/// Merge rules (see docs/anonymization-design.md):
/// 1. higher [DetectionSource.priority] wins an overlap;
/// 2. among equals, the longer span wins, then the more confident one;
/// 3. a dictionary term gives way to a longer hidden span that contains it;
/// 4. every other whole-word occurrence of a kept value is propagated.
///
/// Model spans that are only a job title, honorific or department name are
/// dropped first (see [titleStoplist]), and so is anything the user put on
/// the never-hide list (see [NeverHide]), before overlaps are settled, so
/// dropping a term never uncovers text another span would have hidden. A
/// fresh run also closes the holes next to what it hides (see [repairSpans])
/// before rule 4.
class DetectionPipeline {
  DetectionPipeline(this.detectors, {Iterable<String> neverHide = const []})
      : neverHide = NeverHide(neverHide);

  final List<Detector> detectors;

  /// What stays visible whatever the detectors say.
  final NeverHide neverHide;

  Future<List<Detection>> run(String text) async {
    if (text.trim().isEmpty) return const [];
    final all = <Detection>[];
    for (final d in detectors) {
      all.addAll(await d.detect(text));
    }
    final readable = neverHide.within(text);
    final fresh = withDefaults(text, all.expand((d) => _withoutTitleLines(text, d)).toList())
        .where((d) => _notNoise(d) && !readable.covers(d) && !_publicProduct(text, d))
        .toList();
    return merge(text, repairSpans(text, resolveOverlaps(fresh), fresh), readable: readable);
  }

  /// What a fresh run hides. A date after a birth label, and any other
  /// mention of that same date, becomes a [EntityType.birthDate]. The other
  /// dates and the amounts stay detected but are switched off: whoever reads
  /// the anonymized text usually needs them, and alone they identify nobody.
  /// So is a bare number a loose rule found in a row of figures (see
  /// [figureRows]): a trading volume between prices and percentages, not an
  /// account or passport number. The user can switch them all back on.
  ///
  /// Not part of [merge], which also runs on detections the user has
  /// already toggled.
  static List<Detection> withDefaults(String text, List<Detection> candidates) {
    final birthDates = {
      for (final d in candidates)
        if (d.type == EntityType.date && followsBirthLabel(text, d.start)) d.value.trim(),
    };
    final figures = figureRows(text);
    bool inFigures(Detection d) => figures.any((r) => r.start <= d.start && d.end <= r.end);
    return [
      for (final d in candidates)
        if (d.type == EntityType.date && birthDates.contains(d.value.trim()))
          d.copyWith(type: EntityType.birthDate)
        else if (d.type == EntityType.date || d.type == EntityType.amount)
          d.copyWith(enabled: false)
        else if (_looseNumber(d) && inFigures(d))
          d.copyWith(enabled: false)
        else
          d,
    ];
  }

  /// A number of no known kind: a bare-digit match of a loose regex rule
  /// ([RegexDetector.typeFor]) or a number a model reported as such (ML Kit
  /// files a phone number without a dial prefix as [EntityType.number]; the
  /// NER model has no number label).
  static bool _looseNumber(Detection d) =>
      d.type == EntityType.number &&
      (d.source == DetectionSource.model ||
          (d.source == DetectionSource.rule && d.detector.startsWith('regex:')));

  /// The lines of [text] that are rows of figures: two or more measures (a
  /// decimal, signed or percentage number) and no word that names an
  /// identifier ("Account", "Tel", "N°"...). Only when the text has three
  /// such rows or more: one line of figures is not a table.
  static List<({int start, int end})> figureRows(String text) {
    final rows = <({int start, int end})>[];
    var start = 0;
    while (start <= text.length) {
      var end = text.indexOf('\n', start);
      if (end == -1) end = text.length;
      final line = text.substring(start, end);
      if (_measure.allMatches(line).length >= 2 && !_identifierWord.hasMatch(line)) {
        rows.add((start: start, end: end));
      }
      start = end + 1;
    }
    return rows.length >= 3 ? rows : const [];
  }

  static final _measure = RegExp(
    r'(?<![\p{L}\p{N}.,])(?:[+\-−][$€£]?\d+(?:[.,]\d+)*|[$€£]?\d+(?:[.,]\d+)+)\s?%?(?![\p{L}\p{N}.,])',
    unicode: true,
  );

  static final _identifierWord = RegExp(
    r'(?<![\p{L}\p{N}])(?:account|acct|a/c|compte|cuenta|iban|bic|swift|sort code|phone|tel|'
    r'téléphone|telephone|teléfono|telefono|mobile|móvil|movil|portable|fax|passport|passeport|pasaporte|'
    r'client|customer|cliente|policy|police|póliza|poliza|member|adhérent|adherent|socio|ref|'
    r'reference|référence|referencia|contract|contrat|contrato|dossier|expediente|number|numéro|'
    r'numero|número|no\.|nº|n°|id)(?![\p{L}\p{N}])',
    caseSensitive: false,
    unicode: true,
  );

  /// Pure merge step, exposed so callers can add manual spans and re-merge.
  /// Nothing inside [readable] is kept or propagated.
  static List<Detection> merge(String text, List<Detection> candidates, {NeverHideSpans? readable}) {
    bool allowed(Detection d) => readable == null || !readable.covers(d);
    final kept = resolveOverlaps(candidates.where((d) => _notNoise(d) && allowed(d)).toList());
    final propagated = propagate(text, kept).where(allowed);
    return resolveOverlaps([...kept, ...propagated]);
  }

  static bool _notNoise(Detection d) {
    final v = d.value.trim();
    if (v.isEmpty) return false;
    if (d.source == DetectionSource.model) {
      // A lone Latin letter or digit pair is never a real entity, but a
      // two-character CJK name is common.
      if (v.length < 2) return false;
      if (v.length < 3 && _asciiOnly.hasMatch(v)) return false;
      if (isTitleOrDepartment(v) || isFunctionWordsOnly(v)) return false;
    }
    return true;
  }

  static final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

  /// A model span that runs over a line break onto a job title or department
  /// ("Priya Raman\nAccounts Manager" as one COMPANY) loses those lines: the
  /// span is cut into its lines and the ones [_notNoise] rejects are dropped.
  /// A span with no such line stays whole, so a name wrapped over two lines is
  /// still one person. In a table (a line of the span holds a tab between the
  /// cells of its row) the span is always cut, since two rows are never one
  /// name, and a piece that is a column value (the same cell three times or
  /// more) is dropped too: "Equity" + the next row's fund name.
  static Iterable<Detection> _withoutTitleLines(String text, Detection d) {
    if (d.source != DetectionSource.model || !d.value.contains('\n')) return [d];
    final pieces = <Detection>[];
    for (final m in _lineContent.allMatches(d.value)) {
      final start = d.start + m.start;
      pieces.add(Detection(
        type: d.type,
        value: m.group(0)!,
        start: start,
        end: start + m.group(0)!.length,
        confidence: d.confidence,
        detector: d.detector,
        source: d.source,
        enabled: d.enabled,
      ));
    }
    final table = pieces.any((p) => _lineHasTab(text, p.start));
    final kept = pieces.where((p) => _notNoise(p) && !(table && _repeatedCell(text, p.value))).toList();
    return kept.length == pieces.length && !table ? [d] : kept;
  }

  /// What a line prints, without the spaces around it.
  static final _lineContent = RegExp(r'[^\s](?:[^\n]*[^\s])?');

  static bool _lineHasTab(String text, int at) {
    final start = at == 0 ? 0 : text.lastIndexOf('\n', at - 1) + 1;
    var end = text.indexOf('\n', at);
    if (end == -1) end = text.length;
    return text.substring(start, end).contains('\t');
  }

  /// [value] fills a whole table cell three times or more.
  static bool _repeatedCell(String text, String value) =>
      RegExp('(?:^|[\\t\\n])${RegExp.escape(value)}(?=\$|[\\t\\n])').allMatches(text).length >= 3;

  /// A company (or, from ML Kit, address) detection that names a public
  /// investment product (see [isPublicProduct]), read to the end of the word
  /// it stops in and with the capitalised words right after it: the model
  /// often stops a fund name before its "ETF", or inside "S&P". What the user
  /// hid by hand or listed as "Always hide" is never let through.
  static bool _publicProduct(String text, Detection d) {
    if (d.type != EntityType.company && d.type != EntityType.address) return false;
    if (d.source == DetectionSource.dictionary || d.source == DetectionSource.manual) return false;
    final rest = _followingNameWords.matchAsPrefix(text, d.end)?.group(0) ?? '';
    return isPublicProduct(d.value + rest);
  }

  static final _followingNameWords =
      RegExp(r"[\p{L}\p{N}&.'’-]*(?:[  ]+[\p{Lu}\p{N}&][\p{L}\p{N}&.-]*){0,4}", unicode: true);

  /// A dictionary term inside a longer span that is hidden anyway gives way
  /// to it: with "Dupont" in the dictionary, "Jean Dupont" stays one PERSON
  /// instead of "Jean [CUSTOM_1]". It only gives way to a span that survives
  /// its own overlaps, so the term is never left showing.
  static List<Detection> resolveOverlaps(List<Detection> entities) {
    bool covered(Detection term, Iterable<Detection> by) => by.any((c) =>
        c.enabled &&
        c.source != DetectionSource.dictionary &&
        c.start <= term.start &&
        c.end >= term.end &&
        c.length > term.length);

    var yielding = {
      for (final e in entities)
        if (e.source == DetectionSource.dictionary && covered(e, entities)) e,
    };
    while (true) {
      final kept = _resolve(entities.where((e) => !yielding.contains(e)));
      final exposed = yielding.where((e) => !covered(e, kept)).toSet();
      if (exposed.isEmpty) return kept;
      yielding = yielding.difference(exposed);
    }
  }

  static List<Detection> _resolve(Iterable<Detection> entities) {
    final sorted = [...entities]..sort((a, b) {
        final p = b.source.priority.compareTo(a.source.priority);
        if (p != 0) return p;
        final len = b.length.compareTo(a.length);
        if (len != 0) return len;
        final c = b.confidence.compareTo(a.confidence);
        if (c != 0) return c;
        return a.start.compareTo(b.start);
      });
    final resolved = <Detection>[];
    for (final e in sorted) {
      if (resolved.any((k) => k.overlaps(e))) continue;
      resolved.add(e);
    }
    resolved.sort((a, b) => a.start.compareTo(b.start));
    return resolved;
  }

  /// Every other whole-word occurrence of a detected value becomes a
  /// propagated detection. For PERSON values the individual name parts
  /// propagate too ("John Smith" -> a later "Smith"); other types do not,
  /// since words of an address or company ("Street", "from") are prose.
  /// A name part must keep its first letter as written: many surnames are
  /// also common words ("Katie Price" -> every "price", "Will Smith" -> every
  /// "will", "Jean Petit" -> every "petit"). And it must be capitalized where
  /// the script has case: a lower-case word inside a person span is prose
  /// the model took in ("desayuno" in a misread span), not a name part.
  static List<Detection> propagate(String text, List<Detection> entities) {
    final seen = <String>{for (final e in entities) '${e.start}:${e.end}'};
    final terms = <(String, EntityType, bool)>[];
    final added = <String>{};
    for (final e in entities) {
      if (!e.enabled) continue;
      final val = e.value.trim();
      if (_termOk(val) && added.add(val.toLowerCase())) {
        terms.add((val, e.type, false));
      }
      if (e.type == EntityType.person && val.contains(RegExp(r'\s'))) {
        for (final word in val.split(RegExp(r'\s+'))) {
          final w = word.replaceFirst(RegExp(r'[.,;:!?()]+$'), '');
          if (w.length >= 4 &&
              !_lowerCase(w) &&
              !isTitleOrDepartment(w) &&
              added.add(w.toLowerCase())) {
            terms.add((w, e.type, true));
          }
        }
      }
    }
    final out = <Detection>[];
    final lower = text.toLowerCase();
    for (final (term, type, namePart) in terms) {
      final lowerTerm = term.toLowerCase();
      var from = 0;
      while (from < text.length) {
        final idx = lower.indexOf(lowerTerm, from);
        if (idx == -1) break;
        final end = idx + term.length;
        final key = '$idx:$end';
        if (!seen.contains(key) &&
            _boundary(text, idx, end) &&
            (!namePart || text[idx] == term[0])) {
          seen.add(key);
          out.add(Detection(
            type: type,
            value: text.substring(idx, end),
            start: idx,
            end: end,
            confidence: 0.95,
            detector: 'propagated',
            source: DetectionSource.propagated,
          ));
        }
        from = idx + 1;
      }
    }
    return out;
  }

  /// Starts with a lower-case letter of a script that has case.
  static bool _lowerCase(String word) {
    final first = String.fromCharCode(word.runes.first);
    return first != first.toUpperCase() && first == first.toLowerCase();
  }

  static bool _termOk(String v) {
    if (v.length >= 3) return true;
    // Two-character CJK values (e.g. 张三) still propagate.
    return v.length == 2 && !_asciiOnly.hasMatch(v);
  }

  static final _wordChar = RegExp(r'[\p{L}\p{N}]', unicode: true);

  static final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]');

  static bool _boundary(String text, int start, int end) {
    // CJK: no word boundaries to respect. Accented Latin has them: "René"
    // is not inside "Renée".
    if (_cjk.hasMatch(text.substring(start, end))) return true;
    final before = start > 0 ? text[start - 1] : ' ';
    final after = end < text.length ? text[end] : ' ';
    return !_wordChar.hasMatch(before) && !_wordChar.hasMatch(after);
  }
}
