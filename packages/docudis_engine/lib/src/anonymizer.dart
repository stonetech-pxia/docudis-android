import 'dart:math';

import 'detection.dart';
import 'entity_type.dart';
import 'placeholder_map.dart';

/// Output of applying detections to a text.
class AnonymizedText {
  const AnonymizedText({
    required this.text,
    required this.map,
    this.replacements = const [],
  });

  /// The text with every enabled detection replaced by a placeholder.
  final String text;

  /// Placeholder <-> original mapping needed to restore replies.
  final PlaceholderMap map;

  /// Which characters of the original went where, in reading order:
  /// `original[start, end)` became `placeholder`. The same edits applied to
  /// a document file give the same result as [text].
  final List<({int start, int end, String placeholder})> replacements;
}

/// Replaces the enabled, non-overlapping [detections] in [original] with
/// typed placeholders. Placeholders are numbered in reading order, so the
/// first person mentioned is always `[PERSON_1]`.
///
/// Deterministic: same text + same detections -> same output and map, which
/// is what lets a stored record be regenerated after the user toggles spans.
///
/// With [previous] (the map of an earlier run on the same text), values keep
/// the placeholder they had and un-hidden values stay restorable, so an AI
/// reply to the earlier output still restores correctly; new values are
/// numbered after the existing ones.
AnonymizedText anonymize(
  String original,
  List<Detection> detections, {
  PlaceholderMap? previous,
}) {
  final active = detections.where((d) => d.enabled).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  final map = PlaceholderMap();
  if (previous != null) map.import(previous.entries);
  final out = StringBuffer();
  final replacements = <({int start, int end, String placeholder})>[];
  var cursor = 0;
  for (final d in active) {
    if (d.start < cursor) continue; // overlapping span; first one wins
    // A space or comma at the edge of a span stays in the text: it parts two
    // placeholders ("[ADDRESS_1], [ADDRESS_2]", not "[ADDRESS_1][ADDRESS_2]"),
    // and "12 rue des Tanneurs, " gets the placeholder of "12 rue des Tanneurs".
    final raw = original.substring(d.start, d.end);
    final lead = _leadingSeparators.firstMatch(raw)!.group(0)!;
    final value = raw.substring(lead.length).replaceFirst(_trailingSeparators, '');
    if (value.isEmpty) continue;
    final placeholder = map.placeholderFor(value, d.type,
        gender: d.type == EntityType.person ? genderBefore(original, d.start) : null);
    out
      ..write(original.substring(cursor, d.start))
      ..write(lead)
      ..write(placeholder)
      ..write(raw.substring(lead.length + value.length));
    final start = d.start + lead.length;
    replacements.add((start: start, end: start + value.length, placeholder: placeholder));
    cursor = d.end;
  }
  out.write(original.substring(cursor));
  return AnonymizedText(text: out.toString(), map: map, replacements: replacements);
}

final _leadingSeparators = RegExp(r'^[\s,;]*');
final _trailingSeparators = RegExp(r'[\s,;]+$');

/// The gender an honorific right before [start] gives the name there:
/// "Mme Garnier" and "M. Julien Garnier" are two people, whatever their
/// shared surname says. Null when there is none or it says nothing ("Dr").
PersonGender? genderBefore(String text, int start) {
  final before = text.substring(max(0, start - 16), start);
  if (_female.hasMatch(before)) return PersonGender.female;
  if (_male.hasMatch(before)) return PersonGender.male;
  return null;
}

final _female = RegExp(
    r'(?<![\p{L}.])(?:Mme|Madame|Mlle|Mademoiselle|Mrs|Ms|Miss|Sra|Señora|Srta|Señorita|Doña|Dña)\.?[  ]+$',
    unicode: true);
final _male = RegExp(r'(?<![\p{L}.])(?:M\.|Monsieur|Mr|Sr|Señor|Don|D\.)\.?[  ]+$', unicode: true);
