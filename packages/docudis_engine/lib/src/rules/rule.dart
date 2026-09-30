import 'dart:convert';

import '../entity_type.dart';
import 'rule_metadata.dart';
import 'validators.dart';

/// One compiled regex rule from a rule pack.
class RegexRule {
  RegexRule({
    required this.id,
    required this.region,
    required this.type,
    required this.pattern,
    required this.confidence,
    required this.description,
    required this.scope,
    required this.classification,
    this.examples = const [],
    this.validate,
  });

  final String id;
  final String region;
  final EntityType type;
  final RegExp pattern;
  final double confidence;
  final String description;
  final RulePackScope scope;
  final RuleClassification classification;
  final List<String> examples;
  final RuleValidator? validate;

  bool get isValidated => validate != null;
}

/// Compiles one `rules/<region>.json` document (DocCloak.Core fields plus
/// Docudis scope and classification metadata).
///
/// Throws [FormatException] on an unknown entity type, validator or a
/// pattern Dart's RegExp cannot compile, so problems surface at load time.
List<RegexRule> parseRulePack(String jsonSource) {
  final doc = jsonDecode(jsonSource) as Map<String, dynamic>;
  final schemaVersion = doc['schemaVersion'];
  if (schemaVersion != 2) {
    throw FormatException('Unsupported rule schema version $schemaVersion');
  }
  final region = doc['region'] as String;
  final rawScope = doc['scope'] as Map<String, dynamic>;
  final scope = RulePackScope(
    jurisdictions: (rawScope['jurisdictions'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    languages: (rawScope['languages'] as List<dynamic>).cast<String>().toSet(),
  );
  final rules = <RegexRule>[];
  for (final raw in doc['rules'] as List<dynamic>) {
    final r = raw as Map<String, dynamic>;
    final id = r['id'] as String;
    final type = EntityType.fromName(r['entityType'] as String);
    if (type == null) {
      throw FormatException('Rule $id: unknown entityType ${r['entityType']}');
    }
    final rawClassification = r['classification'] as Map<String, dynamic>;
    final classification = RuleClassification(
      category: _enumValue(
        RuleCategory.values,
        rawClassification['category'] as String,
        id,
        'category',
      ),
      subtype: rawClassification['subtype'] as String,
      applicability: _enumValue(
        RuleApplicability.values,
        rawClassification['applicability'] as String,
        id,
        'applicability',
      ),
      verticals: (rawClassification['verticals'] as List<dynamic>)
          .cast<String>()
          .map((name) => _enumValue(RuleVertical.values, name, id, 'vertical'))
          .toSet(),
      protectionLevel: _enumValue(
        RuleProtectionLevel.values,
        rawClassification['protectionLevel'] as String,
        id,
        'protectionLevel',
      ),
      defaultAction: _enumValue(
        RuleDefaultAction.values,
        rawClassification['defaultAction'] as String,
        id,
        'defaultAction',
      ),
      provenance: _enumValue(
        RuleProvenance.values,
        rawClassification['provenance'] as String,
        id,
        'provenance',
      ),
      status: _enumValue(
        RuleStatus.values,
        rawClassification['status'] as String,
        id,
        'status',
      ),
    );
    final flags = (r['flags'] as String?) ?? 'g';
    final RegExp pattern;
    try {
      pattern = RegExp(
        r['pattern'] as String,
        caseSensitive: !flags.contains('i'),
        multiLine: flags.contains('m'),
        dotAll: flags.contains('s'),
        unicode: flags.contains('u'),
      );
    } on FormatException catch (e) {
      throw FormatException('Rule $id: pattern does not compile: ${e.message}');
    }
    RuleValidator? validate;
    final validateName = r['validate'] as String?;
    if (validateName != null) {
      validate = validators[validateName];
      if (validate == null) {
        throw FormatException('Rule $id: unknown validator "$validateName"');
      }
    }
    rules.add(
      RegexRule(
        id: id,
        region: region,
        type: type,
        pattern: pattern,
        confidence: (r['confidence'] as num).toDouble(),
        description: r['description'] as String,
        scope: scope,
        classification: classification,
        examples: (r['examples'] as List<dynamic>?)?.cast<String>() ?? const [],
        validate: validate,
      ),
    );
  }
  return rules;
}

T _enumValue<T extends Enum>(
  List<T> values,
  String name,
  String ruleId,
  String field,
) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Rule $ruleId: unknown $field "$name"');
}
