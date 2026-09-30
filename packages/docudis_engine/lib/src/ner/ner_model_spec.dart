import 'dart:convert';

import '../entity_type.dart';

/// Describes one token-classification NER model so it can be swapped by
/// editing a `model.json` next to the model files, without code changes.
///
/// ```json
/// {
///   "name": "distilbert-base-multilingual-cased-ner-hrl",
///   "model": "model_int8.onnx",
///   "tokenizer": {"kind": "wordpiece", "file": "tokenizer.json"},
///   "labels": ["O", "B-DATE", "I-DATE", "B-PER", "I-PER", ...],
///   "labelMap": {"PER": "PERSON", "ORG": "COMPANY", "LOC": "ADDRESS"},
///   "maxTokens": 256,
///   "stride": 32,
///   "threshold": 0.5,
///   "padId": 0,
///   "inputs": {"ids": "input_ids", "mask": "attention_mask"},
///   "output": "logits"
/// }
/// ```
class NerModelSpec {
  const NerModelSpec({
    required this.name,
    required this.modelFile,
    required this.tokenizerKind,
    required this.tokenizerFile,
    required this.labels,
    required this.labelMap,
    this.maxTokens = 256,
    this.stride = 32,
    this.threshold = 0.5,
    this.padId = 0,
    this.inputIdsName = 'input_ids',
    this.attentionMaskName = 'attention_mask',
    this.outputName = 'logits',
  });

  final String name;
  final String modelFile;

  /// `wordpiece` (BERT family) or `sentencepiece` (XLM-R / mDeBERTa).
  final String tokenizerKind;
  final String tokenizerFile;

  /// BIO labels in output-index order, e.g. `O, B-PER, I-PER, ...`.
  final List<String> labels;

  /// Model entity name (`PER`) -> engine [EntityType]. Unmapped labels are
  /// ignored.
  final Map<String, EntityType> labelMap;

  /// Window length including the two special tokens.
  final int maxTokens;

  /// Overlap between consecutive windows, in tokens.
  final int stride;

  /// Minimum mean token probability for a span to be reported.
  final double threshold;
  final int padId;
  final String inputIdsName;
  final String attentionMaskName;
  final String outputName;

  factory NerModelSpec.fromJson(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    final tok = j['tokenizer'] as Map<String, dynamic>;
    final inputs = (j['inputs'] as Map<String, dynamic>?) ?? const {};
    final labelMap = <String, EntityType>{};
    for (final e in (j['labelMap'] as Map<String, dynamic>).entries) {
      final t = EntityType.fromName(e.value as String);
      if (t == null) {
        throw FormatException('labelMap: unknown entity type ${e.value}');
      }
      labelMap[e.key] = t;
    }
    return NerModelSpec(
      name: j['name'] as String,
      modelFile: j['model'] as String,
      tokenizerKind: tok['kind'] as String,
      tokenizerFile: tok['file'] as String,
      labels: (j['labels'] as List<dynamic>).cast<String>(),
      labelMap: labelMap,
      maxTokens: (j['maxTokens'] as int?) ?? 256,
      stride: (j['stride'] as int?) ?? 32,
      threshold: ((j['threshold'] as num?) ?? 0.5).toDouble(),
      padId: (j['padId'] as int?) ?? 0,
      inputIdsName: (inputs['ids'] as String?) ?? 'input_ids',
      attentionMaskName: (inputs['mask'] as String?) ?? 'attention_mask',
      outputName: (j['output'] as String?) ?? 'logits',
    );
  }
}
