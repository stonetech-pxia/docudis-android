/// Docudis on-device anonymization engine: detect sensitive spans, replace
/// them with typed placeholders, restore placeholders in replies.
///
/// Pure Dart. Model inference is injected through [TokenClassifier] so the
/// Flutter app supplies the ONNX runtime while this package stays testable.
library;

export 'src/anonymizer.dart';
export 'src/chunker.dart';
export 'src/detection.dart';
export 'src/detector.dart';
export 'src/detectors/bundled_list_detector.dart';
export 'src/detectors/dictionary_detector.dart';
export 'src/detectors/regex_detector.dart';
export 'src/entity_type.dart';
export 'src/ner/ner_detector.dart';
export 'src/ner/ner_model_spec.dart';
export 'src/ner/ner_tokenizer.dart';
export 'src/ner/token_classifier.dart';
export 'src/never_hide.dart';
export 'src/pipeline.dart';
export 'src/placeholder_map.dart';
export 'src/repair.dart';
export 'src/reply_match.dart';
export 'src/rules/rule.dart';
export 'src/rules/rule_metadata.dart';
export 'src/rules/rules_data.dart' show bundledRulePackSources;
export 'src/rules/title_stoplist.dart';
