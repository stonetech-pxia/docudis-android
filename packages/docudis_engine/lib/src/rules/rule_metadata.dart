/// Geographic and linguistic scope shared by every rule in one pack.
///
/// Empty lists mean that the pack is global. Jurisdictions use upper-case
/// ISO-like country codes (`FR`, `GB`, `CN`); languages use lower-case BCP-47
/// language tags (`fr`, `en`, `zh`). They are deliberately separate: French
/// text is not necessarily governed by French identifiers.
class RulePackScope {
  const RulePackScope({
    this.jurisdictions = const {},
    this.languages = const {},
  });

  final Set<String> jurisdictions;
  final Set<String> languages;
}

/// The kind of information a rule protects, independent of where it applies.
enum RuleCategory {
  identity,
  contact,
  location,
  financialAccount,
  financialValue,
  organization,
  businessRecord,
  medicalRecord,
  legalRecord,
  digital,
  credential,
  temporal,
  genericIdentifier,
}

/// Whether a rule belongs to every profile or only selected verticals.
enum RuleApplicability { baseline, specialized }

/// Product guidance for how prominently a rule should be enabled or exposed.
///
/// This is not overlap priority; confidence and validators still decide that.
enum RuleProtectionLevel { essential, recommended, optional }

/// The default treatment of a detection produced by this rule.
enum RuleDefaultAction {
  /// Replace the match in the anonymized output.
  hide,

  /// Keep the detection for review but leave it visible initially.
  detectOnly,

  /// Decide from context, such as an ordinary date versus a birth date.
  contextual,
}

/// Where the rule definition came from.
enum RuleProvenance { doccloak, doccloakModified, docudis }

enum RuleStatus { active, experimental, deprecated }

/// A vertical is a usage context, not a data type.
enum RuleVertical {
  healthcare,
  legal,
  finance,
  employment,
  insurance,
  technology,
  utilities,
}

/// User-facing and selection metadata carried by every regex rule.
class RuleClassification {
  const RuleClassification({
    required this.category,
    required this.subtype,
    required this.applicability,
    required this.protectionLevel,
    required this.defaultAction,
    required this.provenance,
    required this.status,
    this.verticals = const {},
  });

  final RuleCategory category;

  /// Stable, lower-snake-case detail such as `passport`, `iban`, or
  /// `medical_record_number`. It refines [category] without changing the
  /// placeholder type written to anonymized text.
  final String subtype;
  final RuleApplicability applicability;
  final Set<RuleVertical> verticals;
  final RuleProtectionLevel protectionLevel;
  final RuleDefaultAction defaultAction;
  final RuleProvenance provenance;
  final RuleStatus status;
}

/// Selects a personalized subset without coupling rules to the app UI.
///
/// A null selection keeps the legacy behavior and loads every rule in the
/// chosen region packs. When a selection is supplied, baseline rules remain
/// enabled and specialized rules require a selected vertical. Category and
/// rule-id overrides are then applied explicitly.
class RuleSelection {
  const RuleSelection({
    this.jurisdictions,
    this.verticals = const {},
    this.categories,
    this.enabledRuleIds = const {},
    this.disabledRuleIds = const {},
    this.includeAllSpecialized = false,
  });

  /// Upper-case country/territory codes to load, such as `FR` or `CH`.
  ///
  /// Null preserves the caller's language-derived region selection. An empty
  /// set deliberately loads only the global pack.
  final Set<String>? jurisdictions;
  final Set<RuleVertical> verticals;
  final Set<RuleCategory>? categories;
  final Set<String> enabledRuleIds;
  final Set<String> disabledRuleIds;
  final bool includeAllSpecialized;

  bool includes(String id, RuleClassification classification) {
    if (disabledRuleIds.contains(id)) return false;
    if (enabledRuleIds.contains(id)) return true;
    final allowedCategories = categories;
    if (allowedCategories != null &&
        !allowedCategories.contains(classification.category)) {
      return false;
    }
    if (classification.applicability == RuleApplicability.baseline) return true;
    if (includeAllSpecialized) return true;
    return classification.verticals.any(verticals.contains);
  }
}
