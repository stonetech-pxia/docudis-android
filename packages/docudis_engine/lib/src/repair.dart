import 'dart:math';

import 'detection.dart';
import 'entity_type.dart';
import 'rules/title_stoplist.dart';

/// Closes the holes a fresh run leaves right next to what it hides: most of
/// what the leak reports show is half of a name, an address or a number
/// (see docs/anonymization-design.md).
///
/// [kept] is the non-overlapping result of the overlap resolution,
/// [candidates] everything the detectors reported. In this order:
/// 1. a candidate that lost its overlap to a span of the same kind never
///    leaves its text showing: the winner grows over it;
/// 2. after a PERSON or COMPANY written in capitals the words in capitals
///    that follow, and the name particle in front of it; next to a number
///    its digit groups; in front of an ADDRESS the unit and house number;
/// 3. two spans of one kind with only a name particle (PERSON, COMPANY) or
///    address filler (ADDRESS) between them become one;
/// 4. a line of an address block that nothing hides, between two lines that
///    are hidden as an address, becomes a span of its own (see
///    [_addressBlockLines]).
///
/// A span only grows within its own line and never into another span,
/// switched off or not; rule 4 is the one thing that crosses a line, and it
/// adds a separate span instead of growing one. Runs on a fresh detection
/// only, never on what the user has toggled.
///
/// Growing a span costs something further down: rule 4 propagates a kept
/// *value* to its other occurrences, and a value that has grown is no longer
/// the short one it was. "Sheffield" absorbed into the address line around it
/// stops propagating to the "Sheffield" elsewhere in the document. Measured on
/// the consumer set that trade is 20 entities gained against 2 lost, so it
/// stands; address and company parts are deliberately not propagated on their
/// own (see [Pipeline.propagate]) and widening that is the wrong fix.
List<Detection> repairSpans(String text, List<Detection> kept, List<Detection> candidates) {
  final spans = [for (final d in kept) _Span(d)]..sort((a, b) => a.start.compareTo(b.start));

  for (var i = 0; i < spans.length; i++) {
    final s = spans[i];
    final kind = _kindOf(s.type);
    if (!s.d.enabled || kind == null) continue;
    final lineStart = text.lastIndexOf('\n', max(0, s.start - 1)) + 1;
    final lineEnd = text.indexOf('\n', s.end);
    final lo = max(lineStart, i == 0 ? 0 : spans[i - 1].end);
    final hi = min(lineEnd == -1 ? text.length : lineEnd, i + 1 == spans.length ? text.length : spans[i + 1].start);
    if (lo > s.start || hi < s.end) continue;

    // A loser that reaches on into the next span of the same kind ("12 rue des
    // Tanneurs, 69007 Lyon" from ML Kit over the street and the postcode rules)
    // leaves the text between the two to the join below, which knows when
    // "street, town" is one placeholder and when it is two. Otherwise the
    // winner stops on the separator in front of its neighbour, the join sees an
    // empty gap, and the output reads "[ADDRESS_1][ADDRESS_2]".
    final prev = i == 0 ? null : spans[i - 1];
    final next = i + 1 == spans.length ? null : spans[i + 1];
    bool joinsWith(_Span? a, _Span? b) =>
        a != null &&
        b != null &&
        a.d.enabled &&
        b.d.enabled &&
        _kindOf(a.type) == _kindOf(b.type) &&
        _joins(kind, text.substring(a.end, b.start), text.substring(a.start, b.end));
    for (final c in candidates) {
      if (!c.enabled || _kindOf(c.type) != kind || c.start >= s.end || c.end <= s.start) continue;
      var start = max(lo, min(s.start, c.start));
      var end = min(hi, max(s.end, c.end));
      if (c.end > hi && next != null && hi == next.start && joinsWith(s, next)) end = s.end;
      if (c.start < lo && prev != null && lo == prev.end && joinsWith(prev, s)) start = s.start;
      while (end > s.end && _separator.hasMatch(text[end - 1])) {
        end--;
      }
      while (start < s.start && _separator.hasMatch(text[start])) {
        start++;
      }
      final grown = text.substring(start, s.start) + text.substring(s.end, end);
      if (grown.isEmpty || !_lostText[kind]!.hasMatch(grown)) continue;
      if (c.length > s.d.length) s.retype(c.type);
      s.grow(start, end);
    }

    final before = text.substring(lo, s.start);
    final after = text.substring(s.end, hi);
    switch (kind) {
      case _Kind.person || _Kind.company:
        final own = text.substring(s.start, s.end);
        if (own == own.toUpperCase() && own.contains(_letter)) {
          s.grow(s.start - (_particleBefore.firstMatch(before)?.group(0) ?? '').length, s.end + _capitalsLength(after));
        }
        // The model keeps cutting a firm's name short and leaving the end of it
        // showing: "JTS" of JTS Haulage, "Logan Square" of Logan Square Internal
        // Medicine, "Tetuán" of Tetuán Gestión Inmobiliaria. Take in the words
        // in capitals that finish the name, and a particle that only leads to
        // the next span ("IUT de" in front of a Bordeaux already hidden).
        if (kind == _Kind.company) {
          final rest = text.substring(s.end, hi); // the capitals rule above may already have moved s.end
          final tail = _companyTail.firstMatch(rest)?.group(0) ??
              (rest.isNotEmpty && _nameParticle.hasMatch(rest) ? rest : '');
          s.grow(s.start, s.end + _companyTailLength(tail));
        }
      case _Kind.number:
        final left = _digit.hasMatch(text[s.start]) ? _digitsBefore.firstMatch(before)?.group(1) ?? '' : '';
        var right = _digit.hasMatch(text[s.end - 1]) ? _digitsAfter.firstMatch(after)?.group(0) ?? '' : '';
        if (_moreNumber.hasMatch(after.substring(right.length))) right = '';
        if (left.isNotEmpty || right.isNotEmpty) s.retype(EntityType.number);
        s.grow(s.start - left.length, s.end + right.length);
      case _Kind.address:
        s.grow(s.start - (_unitBefore.firstMatch(before)?.group(0) ?? '').length, s.end);
    }
  }

  for (var i = 0; i + 1 < spans.length;) {
    final a = spans[i], b = spans[i + 1];
    final kind = _kindOf(a.type);
    final gap = text.substring(a.end, b.start);
    if (a.d.enabled && b.d.enabled && kind == _kindOf(b.type) && _joins(kind, gap, text.substring(a.start, b.end))) {
      a.grow(a.start, b.end);
      spans.removeAt(i + 1);
    } else {
      i++;
    }
  }

  // Last, and only once the merges above have had the text between two address
  // parts to work with: a printed address is one line, and the model regularly
  // hides part of one and leaves the rest of that same line showing — only the
  // Eircode of "Apartment 12, Millrace Court, Old Kilmainham, Dublin 8, D08 XK72",
  // only the street of "…, Meanwood Road, Leeds LS7 2BB". Take in what is still
  // address on that line and stop at the first word of prose, which is where the
  // sentence around the address starts.
  for (var i = 0; i < spans.length; i++) {
    final s = spans[i];
    if (!s.d.enabled || _kindOf(s.type) != _Kind.address) continue;
    final lineStart = text.lastIndexOf('\n', max(0, s.start - 1)) + 1;
    final lineEnd = text.indexOf('\n', s.end);
    final lo = max(lineStart, i == 0 ? 0 : spans[i - 1].end);
    final hi = min(lineEnd == -1 ? text.length : lineEnd, i + 1 == spans.length ? text.length : spans[i + 1].start);
    if (lo > s.start || hi < s.end) continue;
    // A run never ends on a small word: "from St Luke's on 9 September" would
    // lose its "on" to the hospital.
    final left = (_addressRunBefore.firstMatch(text.substring(lo, s.start))?.group(0) ?? '')
        .replaceFirst(_leadingParticles, '');
    final right = (_addressRunAfter.firstMatch(text.substring(s.end, hi))?.group(0) ?? '')
        .replaceFirst(_trailingParticles, '');
    s.grow(s.start - left.length, s.end + right.length);
  }

  final kept2 = [for (final s in spans) s.build(text)];
  return [...kept2, ..._addressBlockLines(text, kept2)];
}

/// The town of a postal address written over several lines: the one line of
/// the block that nothing hides. "PO Box 4402 / Leicester / LE87 9AB" comes
/// back with "Leicester" showing — alone on its line it carries no house
/// number and no postcode, so no rule keys on it, and the model, after the
/// fine-tune, reads it as an ordinary capitalised word.
///
/// The line above and the line below must both be a line of address — hidden
/// as an address over most of what they print, not merely carrying a place
/// somewhere. That is what separates the town inside a block from what else
/// gets printed above a line that holds an address: a trading name under the
/// company's name ("Personal Lending Services" beneath the bank) has a
/// COMPANY above it, and a job title in a CV sits between a line that ends
/// in a place and a sentence that names three more ("Severnside Logistics
/// Ltd, Avonmouth" / "Transport Supervisor" / "…covering Bristol, Bath and
/// Weston-super-Mare"). Both stay showing.
///
/// At most two lines are taken at a time, enough for the town and the tail of
/// a street that wrapped ("…, Nether Parkfield / Road / Sheffield"), and each
/// line becomes its own span so the block keeps its shape.
List<Detection> _addressBlockLines(String text, List<Detection> kept) {
  final lines = _lineRanges(text);
  final address = List<bool>.filled(text.length, false);
  final touched = List<bool>.filled(text.length, false);
  for (final d in kept) {
    for (var i = max(0, d.start); i < min(text.length, d.end); i++) {
      touched[i] = true;
      if (d.enabled && d.type == EntityType.address) address[i] = true;
    }
  }
  // A line of an address block: three fifths of what it prints is already
  // hidden as an address. A sentence with a place name in it is not.
  bool addressLine(int i) {
    if (i < 0 || i >= lines.length) return false;
    var ink = 0, hidden = 0;
    for (var p = lines[i].start; p < lines[i].end; p++) {
      if (text[p] == ' ' || text[p] == '\t') continue;
      ink++;
      if (address[p]) hidden++;
    }
    return ink > 0 && hidden * 5 >= ink * 3;
  }

  // Anything already detected on the line, switched off or not: a date or an
  // amount between two address lines is not part of the address.
  bool untouched(int i) {
    for (var p = lines[i].start; p < lines[i].end; p++) {
      if (touched[p]) return false;
    }
    return true;
  }

  final out = <Detection>[];
  for (var i = 1; i < lines.length; i++) {
    if (!addressLine(i - 1) || !untouched(i)) continue;
    var j = i;
    while (j < lines.length && j - i < 2 && untouched(j) && _isAddressLine(_lineOf(text, lines[j]))) {
      j++;
    }
    if (j == i || !addressLine(j)) continue;
    for (var k = i; k < j; k++) {
      final line = _lineOf(text, lines[k]);
      final start = lines[k].start + (line.length - line.trimLeft().length);
      final end = lines[k].end - (line.length - line.trimRight().length);
      out.add(Detection(
        type: EntityType.address,
        value: text.substring(start, end),
        start: start,
        end: end,
        confidence: 0.7,
        detector: 'repair:address_line',
        source: DetectionSource.rule,
      ));
    }
    i = j;
  }
  return out;
}

List<({int start, int end})> _lineRanges(String text) {
  final out = <({int start, int end})>[];
  var start = 0;
  while (true) {
    final nl = text.indexOf('\n', start);
    out.add((start: start, end: nl == -1 ? text.length : nl));
    if (nl == -1) return out;
    start = nl + 1;
  }
}

String _lineOf(String text, ({int start, int end}) line) => text.substring(line.start, line.end);

/// A line that is nothing but address: the words an address may contain and
/// no more. Short, because a town line is short and a sentence is not, and
/// never a job title or a department, which is what else is printed inside a
/// letterhead.
bool _isAddressLine(String line) {
  final v = line.trim();
  if (v.length < 2 || v.length > 40 || !_letter.hasMatch(v)) return false;
  if (!_addressOnlyLine.hasMatch(v)) return false;
  for (final word in v.split(_wordGap)) {
    if (isTitleOrDepartment(word)) return false;
  }
  return true;
}

final _addressOnlyLine = RegExp('^$_addressWord(?:[ ,]{1,2}$_addressWord)*\$', unicode: true);
final _wordGap = RegExp(r'[ ,]+');

enum _Kind { person, company, address, number }

_Kind? _kindOf(EntityType t) => switch (t) {
      EntityType.person => _Kind.person,
      EntityType.company => _Kind.company,
      EntityType.address => _Kind.address,
      EntityType.phone || EntityType.id || EntityType.number || EntityType.card || EntityType.other => _Kind.number,
      _ => null,
    };

/// What a winner may grow over when it takes in the rest of a loser. No
/// digits or sentence punctuation for a name: the model now and then reports
/// a span across half a sentence.
final _lostText = {
  _Kind.person: RegExp(r"^[\p{L} .'’&()-]{1,40}$", unicode: true),
  _Kind.company: RegExp(r"^[\p{L} .'’&()-]{1,40}$", unicode: true),
  _Kind.address: RegExp(r"^[\p{L}\p{N} .,'’ºª°/()-]{1,40}$", unicode: true),
  _Kind.number: RegExp(r'^[\d ./-]+$'),
};

/// What a grown span must not end on: it hides nothing and parts the span
/// from its neighbour.
final _separator = RegExp(r'[\s,;]');

final _letter = RegExp(r'\p{L}', unicode: true);
final _alphanumeric = RegExp(r'[\p{L}\p{N}]', unicode: true);
final _digit = RegExp(r'\d');

/// Up to three words in capitals, each a space away: the rest of the name.
final _capitalsAfter = RegExp(r"^(?: \p{Lu}[\p{Lu}'’-]+(?![\p{L}\p{N}])){1,3}", unicode: true);

/// In front of a name only its particle: what stands there in a line of
/// capitals is a label or the sentence ("SIENDO SOCIO UNICO MARIA PEÑA").
final _particleBefore = RegExp(r'(?<![\p{L}\p{N}])(?:DE LAS|DE LOS|DE LA|DEL|DE|DU|DES|VAN DER|VAN DEN|VAN|VON|DA|DOS|DO|DI) $');

/// Length of the run of capitals at the start of [after], cut at the first
/// job title ("ANA LLANO DIRECTORA").
int _capitalsLength(String after) {
  var n = 0;
  for (final w in (_capitalsAfter.firstMatch(after)?.group(0) ?? '').trim().split(' ')) {
    if (w.isEmpty || isTitleOrDepartment(w)) break;
    n += w.length + 1;
  }
  return n;
}

/// The end of a firm's name: up to three more words in capitals, with the
/// small words a name may carry between them ("College of Nursing",
/// "SEGUROS Y REASEGUROS"). Stops at anything that starts a sentence instead.
final _companyTail = RegExp(
  r"^(?:[ ](?:of|de|del|da|du|des|la|las|los|le|les|y|e|et|and|the|für|van)(?![\p{L}\p{N}]))?"
  r"(?:[ ]\p{Lu}[\p{L}\p{N}'’&.-]*){1,3}(?![\p{L}\p{N}])",
  unicode: true,
);

/// Length of [tail], which always begins with a space, cut at the first job
/// title or department: "Acme Ltd" does not reach on into "Credit Control".
int _companyTailLength(String tail) {
  var n = 0;
  for (final w in tail.substring(min(1, tail.length)).split(' ')) {
    if (w.isEmpty || isTitleOrDepartment(w)) break;
    n += w.length + 1;
  }
  return n;
}

final _digitsAfter = RegExp(r'^(?:[ .-]\d{2,})+');
final _digitsBefore = RegExp(r'(?<![\d/:.,-])((?:\d{2,}[ .-])+)$');

/// The number goes on after the groups taken in (another group, a decimal
/// part, a date or a time): not the tail of this number after all.
final _moreNumber = RegExp(r'^(?:\d|[ .,/:-]\d)');

final _unitBefore = RegExp(
  r'(?<![\p{L}\p{N}])(?:(?:Appartement|Appt?\.?|Apt\.?|Bâtiment|Bât\.?|Étage|Unit|Suite|Flat|Floor|Room|Piso|Planta|Puerta|Local)'
  r' [\p{L}\p{N}.º-]{1,6},? )*(?:\d{1,4}[A-Za-z]?(?: bis| ter)?,? )?$',
  unicode: true,
  caseSensitive: false,
);

/// The rest of an address on the same line: words in capitals, numbers, and
/// the small words an address is allowed to contain. Anything else — a verb, a
/// noun in lower case — ends it, because that is the sentence, not the address.
const _addressParticle = r'de|del|de la|la|las|los|el|du|des|le|les|na|an|of|the|upon|on';
const _addressWord = r"(?:\p{Lu}[\p{L}'’.-]*|\d[\p{L}\p{N}º°ª.-]*"
    '|(?:$_addressParticle|cedex|bis|ter|c/|s/n)(?![\\p{L}\\p{N}]))';
final _addressRunAfter = RegExp('^(?:[ ,]{1,2}$_addressWord){1,8}', unicode: true);
final _addressRunBefore = RegExp('(?:$_addressWord[ ,]{1,2}){1,8}\$', unicode: true);
final _trailingParticles = RegExp('(?:[ ,]{1,2}(?:$_addressParticle))+\$');
final _leadingParticles = RegExp('^(?:(?:$_addressParticle)[ ,]{1,2})+');

/// One space, or one particle: two spans the model cut one name into.
final _nameParticle = RegExp(r'^ (?:(?:de|del|de la|de los|de las|du|des|van|van der|van den|von|da|do|dos|di) )?$',
    caseSensitive: false);

/// A word that starts in lower case and is not part of an address: the two
/// places sit in a sentence ("from Bristol to Bath").
final _proseWord = RegExp(
  r"(?<![\p{L}\p{N}'’])(?!(?:de|del|la|las|los|el|du|des|le|les|bis|ter|sur|sous|en|of|the|upon|on|cedex)(?![\p{L}\p{N}]))\p{Ll}{2,}",
  unicode: true,
);

bool _joins(_Kind? kind, String gap, String whole) => switch (kind) {
      _Kind.person || _Kind.company => _nameParticle.hasMatch(gap),
      // Something to hide in between ("BP 633", "3ºA"): "street, town" with
      // only a comma stays two placeholders. A digit somewhere: a street
      // number or a postcode, not "Paris (France), Lyon".
      _Kind.address => gap.length <= 30 &&
          !gap.contains('\n') &&
          gap.contains(_alphanumeric) &&
          !_proseWord.hasMatch(gap) &&
          _digit.hasMatch(whole),
      _ => false,
    };

class _Span {
  _Span(this.d)
      : start = d.start,
        end = d.end,
        type = d.type;

  final Detection d;
  int start;
  int end;
  EntityType type;

  void grow(int newStart, int newEnd) {
    start = newStart;
    end = newEnd;
  }

  /// A checksum vouches for the winner's type whatever it grew over.
  void retype(EntityType t) {
    if (d.source != DetectionSource.validatedRule) type = t;
  }

  Detection build(String text) => start == d.start && end == d.end && type == d.type
      ? d
      : Detection(
          type: type,
          value: text.substring(start, end),
          start: start,
          end: end,
          confidence: d.confidence,
          detector: d.detector,
          source: d.source,
          enabled: d.enabled,
        );
}
