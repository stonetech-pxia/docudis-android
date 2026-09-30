/// What may stand between a birth label and its date: at most 20 non-digit
/// characters on the same line ("born on ", "Date of birth (DD/MM/YYYY): "),
/// or a line break when the label ends its line, as forms and OCR output
/// put it.
const _gap = r'(?:[^\n\d]{0,20}|[ \t:]*\r?\n[ \t]*)$';

/// Labels that make the date after them a date of birth, in the languages
/// the app targets. Only the label decides: an old year alone says nothing
/// (a degree, a company's founding, an old contract).
final RegExp _birthLabel = RegExp(
  r'(?:\bborn|\bdate\s+of\s+birth|\bbirth\s?date|\bbirthday|\bd\.?o\.?b\.?'
  r'|\bné(?:\(e\)|e)?\s+le|\bnaissance'
  r'|\bnacid[oa]|\bnacimiento|\bf\.\s?nac\.?)'
  '$_gap',
  caseSensitive: false,
  unicode: true,
);

/// French forms write the label in capitals without the accent. Lower-case
/// "ne le" is ordinary prose ("je ne le ferai pas avant le 12/03/2026"), so
/// this one is case-sensitive.
final RegExp _birthLabelCapitals = RegExp(r'\bNE(?:\(E\)|E)?\s+LE' '$_gap');

/// Whether the span starting at [start] in [text] follows a birth label.
bool followsBirthLabel(String text, int start) {
  final before = text.substring(start > 80 ? start - 80 : 0, start);
  return _birthLabel.hasMatch(before) || _birthLabelCapitals.hasMatch(before);
}
