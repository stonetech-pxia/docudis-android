/// Runs one window of token ids through a token-classification model.
///
/// Implemented by the app with ONNX Runtime; the engine only sees logits.
abstract class TokenClassifier {
  /// [inputIds] and [attentionMask] have the same length (one window,
  /// special tokens included). Returns one row of raw logits per token,
  /// each row `labels.length` wide, in the same order as the input.
  Future<List<List<double>>> classify(
    List<int> inputIds,
    List<int> attentionMask,
  );

  Future<void> close();
}
