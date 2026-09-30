import 'dart:typed_data';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

/// [TokenClassifier] backed by ONNX Runtime (CPU execution provider).
class OnnxTokenClassifier implements TokenClassifier {
  OnnxTokenClassifier._(this._session, this._spec);

  final OrtSession _session;
  final NerModelSpec _spec;

  static Future<OnnxTokenClassifier> load(String modelPath, NerModelSpec spec) async {
    final session = await OnnxRuntime().createSession(
      modelPath,
      options: OrtSessionOptions(providers: [OrtProvider.CPU]),
    );
    return OnnxTokenClassifier._(session, spec);
  }

  @override
  Future<List<List<double>>> classify(List<int> inputIds, List<int> attentionMask) async {
    final n = inputIds.length;
    final ids = await OrtValue.fromList(Int64List.fromList(inputIds), [1, n]);
    final mask = await OrtValue.fromList(Int64List.fromList(attentionMask), [1, n]);
    Map<String, OrtValue>? outputs;
    try {
      outputs = await _session.run({
        _spec.inputIdsName: ids,
        _spec.attentionMaskName: mask,
      });
      final logits = outputs[_spec.outputName];
      if (logits == null) {
        throw StateError('model has no output named ${_spec.outputName}');
      }
      final flat = await logits.asFlattenedList();
      final width = _spec.labels.length;
      if (flat.length != n * width) {
        throw StateError('logits shape mismatch: ${flat.length} != $n x $width');
      }
      return [
        for (var t = 0; t < n; t++)
          [for (var l = 0; l < width; l++) (flat[t * width + l] as num).toDouble()],
      ];
    } finally {
      await ids.dispose();
      await mask.dispose();
      if (outputs != null) {
        for (final v in outputs.values) {
          await v.dispose();
        }
      }
    }
  }

  @override
  Future<void> close() => _session.close();
}
