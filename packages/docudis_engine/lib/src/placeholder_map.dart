import 'dart:convert';

import 'entity_type.dart';
import 'restore_tokens.dart';

/// What an honorific in front of a name says about the person.
enum PersonGender { female, male }

/// One reversible mapping: an original value and the placeholder it became.
class MappingEntry {
  const MappingEntry({
    required this.original,
    required this.placeholder,
    required this.type,
  });

  final String original;
  final String placeholder;
  final EntityType type;

  Map<String, Object?> toJson() => {
        'original': original,
        'placeholder': placeholder,
        'type': type.placeholderName,
      };

  factory MappingEntry.fromJson(Map<String, Object?> json) => MappingEntry(
        original: json['original'] as String,
        placeholder: json['placeholder'] as String,
        type: EntityType.fromName(json['type'] as String) ?? EntityType.other,
      );
}

/// Issues typed placeholders (`[PERSON_1]`, `[PHONE_2]`), keeps the
/// reverse map, and restores placeholders in text an LLM may have mangled.
///
/// Same original value -> same placeholder. PERSON values that are variants
/// of one another ("张三" / "张三先生", "John" / "John Smith") share one
/// placeholder; restore yields the longest form. Variants whose honorifics
/// disagree ("Mme Garnier" / "M. Julien Garnier") do not, and neither does a
/// value that fits two people equally well ("García" after "Ana García" and
/// "Luis García"): it gets a placeholder of its own.
class PlaceholderMap {
  PlaceholderMap();

  final Map<String, String> _forward = {};
  final Map<String, String> _reverse = {};
  final Map<String, EntityType> _types = {};
  final Map<String, PersonGender> _genders = {};
  final Map<EntityType, int> _counters = {};

  bool get isEmpty => _forward.isEmpty;
  int get length => _reverse.length;

  String placeholderFor(String original, EntityType type, {PersonGender? gender}) {
    final existing = _forward[original];
    if (existing != null) return existing;
    if (type == EntityType.person) {
      if (gender != null) _genders[original] = gender;
      final variant = _findPersonVariant(original, gender);
      if (variant != null) {
        final placeholder = _forward[variant]!;
        _forward[original] = placeholder;
        _types[original] = type;
        final canonical = _reverse[placeholder];
        if (canonical == null || original.length > canonical.length) {
          _reverse[placeholder] = original;
        }
        return placeholder;
      }
    }
    final placeholder = _next(type);
    _forward[original] = placeholder;
    _reverse[placeholder] = original;
    _types[original] = type;
    return placeholder;
  }

  String _next(EntityType type) {
    var n = _counters[type] ?? 0;
    String p;
    do {
      n++;
      p = '[${type.placeholderName}_$n]';
    } while (_reverse.containsKey(p));
    _counters[type] = n;
    return p;
  }

  String? _findPersonVariant(String value, PersonGender? gender) {
    final tokens = _personTokens(value);
    if (tokens.isEmpty) return null;
    String? best;
    var bestShared = 0;
    var tie = false;
    for (final original in _forward.keys) {
      if (_types[original] != EntityType.person) continue;
      if (!_isPersonVariant(value, original)) continue;
      final other = _genders[original];
      if (gender != null && other != null && other != gender) continue;
      final shared =
          _personTokens(original).where(tokens.contains).length;
      if (shared > bestShared) {
        bestShared = shared;
        best = original;
        tie = false;
      } else if (shared == bestShared && _forward[original] != _forward[best]) {
        tie = true;
      }
    }
    return tie ? null : best;
  }

  static final _cjk = RegExp(r'[぀-ヿ㐀-鿿가-힯]');
  static final _honorific = RegExp(r'(先生|女士|小姐|同学|老师|经理|总|医生|律师|さん|様|씨)$');

  static List<String> _personTokens(String value) {
    if (_cjk.hasMatch(value)) {
      // CJK names have no spaces; strip a trailing honorific and treat the
      // rest as one token so 张三 / 张三先生 unify but 张三 / 张四 do not.
      final core = value.replaceFirst(_honorific, '').trim();
      return core.isEmpty ? const [] : [core];
    }
    return value
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp('^[.,;:!?()"\']+|[.,;:!?()"\']+\$'), ''))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  static bool _isPersonVariant(String a, String b) {
    final ta = _personTokens(a);
    final tb = _personTokens(b);
    if (ta.isEmpty || tb.isEmpty) return false;
    final (small, big) = ta.length <= tb.length ? (ta, tb) : (tb, ta);
    return small.every(big.contains) && small.any((t) => t.length >= 2);
  }

  /// Replaces every placeholder in [text] with its original value. Exact
  /// matches first (longest placeholder first), then one tolerant pass for
  /// mangled tokens that unambiguously identify a single placeholder.
  String restore(String text) {
    var result = text;
    final entries = _reverse.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final e in entries) {
      result = result.replaceAll(e.key, e.value);
    }
    return _restoreMangled(result);
  }

  String _restoreMangled(String text) {
    final index = buildTolerantIndex(_reverse.keys);
    if (index.isEmpty) return text;
    final out = StringBuffer();
    var last = 0;
    for (final m in mangledCandidate.allMatches(text)) {
      final canonical = canonicalPlaceholderForm(m.group(0)!);
      if (canonical == null) continue;
      final key = index[canonical];
      if (key == null) continue;
      final original = _reverse[key];
      if (original == null) continue;
      out
        ..write(text.substring(last, m.start))
        ..write(original);
      last = m.end;
    }
    if (last == 0) return text;
    out.write(text.substring(last));
    return out.toString();
  }

  List<MappingEntry> get entries => [
        for (final e in _forward.entries)
          MappingEntry(
            original: e.key,
            placeholder: e.value,
            type: _types[e.key] ?? EntityType.other,
          ),
      ];

  /// Placeholder -> canonical (longest) original, one row per placeholder.
  Map<String, String> get reverse => Map.unmodifiable(_reverse);

  String toJson() => jsonEncode([for (final e in entries) e.toJson()]);

  factory PlaceholderMap.fromJson(String json) {
    final map = PlaceholderMap();
    final list = jsonDecode(json) as List<dynamic>;
    map.import(
      list.map((e) => MappingEntry.fromJson((e as Map).cast<String, Object?>())),
    );
    return map;
  }

  static final _typed = RegExp(r'^\[([A-Z_]+)_(\d+)\]$');

  void import(Iterable<MappingEntry> entries) {
    for (final e in entries) {
      _forward[e.original] = e.placeholder;
      final canonical = _reverse[e.placeholder];
      if (canonical == null || e.original.length > canonical.length) {
        _reverse[e.placeholder] = e.original;
      }
      _types[e.original] = e.type;
      final m = _typed.firstMatch(e.placeholder);
      if (m != null) {
        final type = EntityType.fromName(m.group(1)!);
        if (type != null) {
          final n = int.parse(m.group(2)!);
          if (n > (_counters[type] ?? 0)) _counters[type] = n;
        }
      }
    }
  }
}
