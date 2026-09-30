import 'package:docudis_engine/docudis_engine.dart' as engine;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

/// Google ML Kit Entity Extraction as a second model detector: addresses,
/// natural-language dates, money, cards, IBANs. On-device; the per-language
/// model is fetched once by Google Play services, the text never leaves the
/// phone. When the model is not ready yet the detector triggers the download
/// and returns nothing for this run.
class MlKitEntityDetector implements engine.Detector {
  MlKitEntityDetector({required this.languageTags});

  /// Detected languages of the text (BCP-47), most likely first.
  final List<String> languageTags;

  final _modelManager = EntityExtractorModelManager();

  @override
  String get name => 'mlkit-entity';

  @override
  Future<List<engine.Detection>> detect(String text) async {
    final language = _languageFor(languageTags);
    if (language == null) return const [];
    try {
      if (!await _modelManager.isModelDownloaded(language.name)) {
        // Fire and forget; the next run benefits.
        _modelManager.downloadModel(language.name, isWifiRequired: false).ignore();
        return const [];
      }
      final extractor = EntityExtractor(language: language);
      try {
        final annotations = await extractor.annotateText(text);
        // ML Kit reads the text as one flat string: an "address" over several
        // lines is as often a code, a body's name and the next heading
        // ("4941A / URSSAF Midi-Pyrénées / Salarié" on a payslip) as a real
        // one, and the rules already take a real address block line by line.
        // It also takes a statute for an address ("Housing Act 1988, Section
        // 19A"); hiding one takes the legal meaning out of the text.
        return [
          for (final a in annotations)
            for (final t in _typesOf(a).take(1))
              if (a.end > a.start &&
                  a.end <= text.length &&
                  !text.substring(a.start, a.end).contains('\n') &&
                  !(t == engine.EntityType.address && isLegalCitation(text.substring(a.start, a.end))))
                engine.Detection(
                  type: numberUnlessDialable(t, text.substring(a.start, a.end)),
                  value: text.substring(a.start, a.end),
                  start: a.start,
                  end: a.end,
                  confidence: 0.7,
                  detector: name,
                  source: engine.DetectionSource.model,
                ),
        ];
      } finally {
        await extractor.close();
      }
    } catch (e) {
      debugPrint('MlKitEntityDetector skipped: $e');
      return const [];
    }
  }

  /// ML Kit calls nearly any run of digits a phone: a staff number, a patient
  /// number, a SIRET, even a DNI with its letter ("30567812W"). A real phone in
  /// a known format is taken by a phone rule, which outranks this detector;
  /// what is left is only known to be a number, the same downgrade
  /// `RegexDetector.typeFor` gives a loose rule. A `+` or brackets still say
  /// phone.
  @visibleForTesting
  static engine.EntityType numberUnlessDialable(engine.EntityType type, String value) =>
      type == engine.EntityType.phone && !_dialMark.hasMatch(value) ? engine.EntityType.number : type;

  static final _dialMark = RegExp(r'[+()]');

  /// A reference to a law or an article of one: "Housing Act 1988",
  /// "Section 21", "article L. 1232-2", "loi n° 89-462", "Ley 29/1994".
  /// A street named after a law ("Rue de la Loi 16") has no law number.
  @visibleForTesting
  static bool isLegalCitation(String value) => _citation.hasMatch(value);

  static final _citation = RegExp(
    r'\bAct\s+\d{4}\b'
    r'|\b(?:Section|Sec\.)\s*\d+[A-Z]?\b'
    r'|\b(?:Article|Art\.|Artículo)\s*(?:[LRD]\.?\s*)?\d'
    r'|\b[LRD]\.\s?\d{3,4}-\d'
    r'|\b(?:Loi|Ley|Décret|Decreto|Real Decreto|Ordonnance)\s+(?:(?:org[aá]nica\s+)?n[°ºo]\.?\s*)?\d+[-/]\d',
    caseSensitive: false,
  );

  Iterable<engine.EntityType> _typesOf(EntityAnnotation a) sync* {
    for (final e in a.entities) {
      final t = switch (e.type) {
        EntityType.address => engine.EntityType.address,
        EntityType.dateTime => engine.EntityType.date,
        EntityType.email => engine.EntityType.email,
        EntityType.iban => engine.EntityType.iban,
        EntityType.paymentCard => engine.EntityType.card,
        EntityType.phone => engine.EntityType.phone,
        EntityType.url => engine.EntityType.url,
        EntityType.money => engine.EntityType.amount,
        _ => null,
      };
      if (t != null) yield t;
    }
  }

  static EntityExtractorLanguage? _languageFor(List<String> tags) {
    for (final tag in tags) {
      final l = _languages[tag.split('-').first];
      if (l != null) return l;
    }
    return null;
  }

  static const _languages = {
    'ar': EntityExtractorLanguage.arabic,
    'zh': EntityExtractorLanguage.chinese,
    'nl': EntityExtractorLanguage.dutch,
    'en': EntityExtractorLanguage.english,
    'fr': EntityExtractorLanguage.french,
    'de': EntityExtractorLanguage.german,
    'it': EntityExtractorLanguage.italian,
    'ja': EntityExtractorLanguage.japanese,
    'ko': EntityExtractorLanguage.korean,
    'pl': EntityExtractorLanguage.polish,
    'pt': EntityExtractorLanguage.portuguese,
    'ru': EntityExtractorLanguage.russian,
    'es': EntityExtractorLanguage.spanish,
    'th': EntityExtractorLanguage.thai,
    'tr': EntityExtractorLanguage.turkish,
  };
}
