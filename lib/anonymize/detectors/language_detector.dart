import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

/// On-device language identification (ML Kit). Returns BCP-47 tags of the
/// languages plausibly present in the text, most likely first; empty when
/// nothing is recognised.
class LanguageDetector {
  const LanguageDetector();

  Future<List<String>> detect(String text) async {
    final identifier = LanguageIdentifier(confidenceThreshold: 0.3);
    try {
      final found = await identifier.identifyPossibleLanguages(text);
      return [
        for (final l in found)
          if (l.languageTag != 'und') l.languageTag,
      ];
    } catch (_) {
      return const [];
    } finally {
      try {
        await identifier.close();
      } on Object {
        // Unit tests and unsupported hosts have no ML Kit method channel.
        // Detection already falls back to the rule-only path above.
      }
    }
  }
}
