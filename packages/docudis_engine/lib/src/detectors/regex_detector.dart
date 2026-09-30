import '../detection.dart';
import '../detector.dart';
import '../entity_type.dart';
import '../rules/rule.dart';
import '../rules/rule_metadata.dart';
import '../rules/rules_data.dart';

/// Runs every rule of the loaded packs over the text.
///
/// Rules with a checksum validator produce [DetectionSource.validatedRule]
/// spans, confident rules (>= [strongConfidence]) [DetectionSource.strongRule],
/// the rest [DetectionSource.rule]; the pipeline uses that to let validated
/// and confident matches beat the model and loose matches lose to it.
class RegexDetector implements Detector {
  RegexDetector(this.rules);

  static const strongConfidence = 0.8;

  static DetectionSource sourceFor(RegexRule rule) {
    if (rule.isValidated) return DetectionSource.validatedRule;
    if (rule.confidence >= strongConfidence) return DetectionSource.strongRule;
    return DetectionSource.rule;
  }

  /// The type a match of [rule] is reported as. A loose identifier or phone
  /// rule ("any 9 digits is a passport number") that matched bare digits
  /// only knows it found a number: [EntityType.number] rather than a guessed
  /// kind. Validated and confident rules, and matches with letters or a `+`
  /// in them (a label, a letter-prefixed format, an international prefix),
  /// keep the rule's type.
  static EntityType typeFor(RegexRule rule, String value) {
    if (sourceFor(rule) == DetectionSource.rule &&
        _numericTypes.contains(rule.type) &&
        _bareDigits.hasMatch(value)) {
      return EntityType.number;
    }
    return rule.type;
  }

  static const _numericTypes = {
    EntityType.id,
    EntityType.card,
    EntityType.other,
    EntityType.phone,
  };

  static final _bareDigits = RegExp(r'^[\d\s./-]+$');

  /// The universal pack plus the given region packs (every region when
  /// [regions] is null). Use [regionsForLanguages] to pick regions from the
  /// text's detected languages: a Portuguese street rule or an Austrian
  /// postal-code rule produces junk on English prose.
  factory RegexDetector.bundled({
    Set<String>? regions,
    RuleSelection? selection,
  }) {
    if (regions != null && selection?.jurisdictions != null) {
      throw ArgumentError('Pass regions or selection.jurisdictions, not both');
    }
    final selectedRegions =
        selection?.jurisdictions
            ?.map((jurisdiction) => jurisdiction.toLowerCase())
            .toSet() ??
        regions;
    final rules = <RegexRule>[];
    for (final entry in bundledRulePackSources.entries) {
      if (selectedRegions != null &&
          entry.key != 'universal' &&
          !selectedRegions.contains(entry.key)) {
        continue;
      }
      final parsed = parseRulePack(entry.value);
      rules.addAll(
        selection == null
            ? parsed
            : parsed.where(
                (rule) => selection.includes(rule.id, rule.classification),
              ),
      );
    }
    return RegexDetector(rules);
  }

  /// Regions whose packs apply to [text] in these BCP-47 language tags; with
  /// no recognisable language the MVP's guaranteed languages are used.
  /// The Chinese packs also turn on whenever [text] contains Han characters
  /// outside Japanese text, because language id tends to report only the main
  /// language of a mixed document. They are never on by default: their
  /// "6 digits = postal code" and "15–19 digits = bank card" rules turn
  /// invoice numbers and amounts in English or French text into ADDRESS.
  static Set<String> regionsForLanguages(
    Iterable<String> languageTags,
    String text,
  ) {
    final regions = <String>{};
    final langs = {
      for (final tag in languageTags)
        tag.split(RegExp('[-_]')).first.toLowerCase(),
    };
    for (final lang in langs) {
      regions.addAll(_regionsByLanguage[lang] ?? const {});
    }
    if (!langs.any(_regionsByLanguage.containsKey)) {
      regions.addAll(defaultRegions);
    }
    if (!langs.contains('ja') && _han.hasMatch(text)) regions.add('cn');
    return regions;
  }

  static const defaultRegions = {'us', 'gb', 'fr', 'es'};

  static final _han = RegExp(r'\p{Script=Han}', unicode: true);

  static const _regionsByLanguage = <String, Set<String>>{
    'zh': {'cn'},
    'en': {'us', 'gb', 'ie'},
    'fr': {'fr', 'be', 'ch'},
    'es': {'es'},
    'de': {'de', 'at', 'ch'},
    'it': {'it', 'ch'},
    'pt': {'pt'},
    'nl': {'nl', 'be'},
    'pl': {'pl'},
    'sv': {'se'},
    'no': {'no'},
    'nb': {'no'},
    'nn': {'no'},
    'da': {'dk'},
    'fi': {'fi'},
    'ja': {'jp'},
    'hi': <String>{},
  };

  final List<RegexRule> rules;

  @override
  String get name => 'regex';

  @override
  Future<List<Detection>> detect(String text) async => detectSync(text);

  /// A match never spans a tab: a tab parts two cells (a photo's columns, a
  /// spreadsheet or docx row). A label may still sit a cell before its value,
  /// as it is outside the match. Text with tabs is matched a second time with
  /// each tab turned into a character no rule takes for a space, which finds
  /// what the first pass had run over the tab ("27 rue des Tanneurs").
  List<Detection> detectSync(String text) {
    final view = _zerosForOs(text);
    final cells = view.contains('\t') ? view.replaceAll('\t', '\u0001') : null;
    final seen = <(String, int, int)>{};
    final out = <Detection>[];
    for (final rule in rules) {
      final matches = [
        ...rule.pattern.allMatches(view),
        if (cells != null) ...rule.pattern.allMatches(cells),
      ];
      for (final m in matches) {
        final value = m.group(0)!;
        if (value.isEmpty || value.contains(RegExp('[\t\u0001]'))) continue;
        if (!seen.add((rule.id, m.start, m.end))) continue;
        final validate = rule.validate;
        if (validate != null && !validate(value)) continue;
        out.add(
          Detection(
            type: typeFor(rule, value),
            value: text.substring(m.start, m.end),
            start: m.start,
            end: m.end,
            confidence: rule.confidence,
            detector: rule.id,
            source: sourceFor(rule),
          ),
        );
      }
    }
    return out;
  }
}

/// A token of digits and letters o/O with at least one digit in it.
final _digitsWithOs = RegExp(
  r'(?<![\p{L}\p{N}])[\doO]*\d[\doO]*(?![\p{L}\p{N}])',
  unicode: true,
);

/// [text] with the o / O of [_digitsWithOs] tokens turned into 0: OCR reads a
/// zero as the letter in some fonts ("o113 496 o721"). The rules match this
/// copy; it has the same length, so a match's offsets hold in [text] and the
/// detection keeps the text as written. A word ("Good", "No") is untouched.
String _zerosForOs(String text) => text.replaceAllMapped(
  _digitsWithOs,
  (m) => m[0]!.replaceAll(RegExp('[oO]'), '0'),
);
