import 'dart:math' as math;

import '../detection.dart';
import '../detector.dart';
import 'ner_model_spec.dart';
import 'ner_tokenizer.dart';
import 'token_classifier.dart';

/// Named-entity detector over any BIO token-classification model.
///
/// Tokenizes the whole text once, slides overlapping windows through the
/// classifier, keeps for each token the prediction from the window where it
/// sits farthest from an edge, then decodes BIO tags into spans.
class NerDetector implements Detector {
  NerDetector({
    required this.spec,
    required this.tokenizer,
    required this.classifier,
  });

  final NerModelSpec spec;
  final NerTokenizer tokenizer;
  final TokenClassifier classifier;

  @override
  String get name => 'ner:${spec.name}';

  @override
  Future<List<Detection>> detect(String text) async {
    final enc = tokenizer.encode(titleCased(text));
    if (enc.length == 0) return const [];
    final predictions = await _predict(enc);
    return _decode(text, enc, predictions);
  }

  /// What the model reads instead of [text]: words of four or more capital
  /// letters become title case ("LOPEZ CORCOLES" -> "Lopez Corcoles"). The
  /// model was trained on ordinary prose and misses or mistypes names
  /// written in capitals, which registries and French forms do all the time.
  /// Every word keeps its length, so token offsets still index [text] and
  /// detections carry the original spelling. Shorter words stay as they
  /// are: they are mostly acronyms (SA, SL, RCS, NHS).
  static String titleCased(String text) => text.replaceAllMapped(_capitalsWord, (m) {
        final word = m[0]!;
        final lowered = word.substring(1).toLowerCase();
        return lowered.length == word.length - 1 ? word[0] + lowered : word;
      });

  static final _capitalsWord = RegExp(r'(?<!\p{L})\p{Lu}{4,}(?!\p{L})', unicode: true);

  Future<List<_TokenPrediction?>> _predict(NerEncoding enc) async {
    final n = enc.length;
    final window = spec.maxTokens - 2;
    final step = math.max(1, window - spec.stride);
    final best = List<_TokenPrediction?>.filled(n, null);
    final bestDistance = List<int>.filled(n, -1);
    var start = 0;
    while (true) {
      final end = math.min(start + window, n);
      final ids = <int>[
        tokenizer.startId,
        ...enc.ids.sublist(start, end),
        tokenizer.endId,
      ];
      final mask = List<int>.filled(ids.length, 1);
      final logits = await classifier.classify(ids, mask);
      for (var t = start; t < end; t++) {
        final distance = math.min(t - start, end - 1 - t);
        if (distance <= bestDistance[t]) continue;
        bestDistance[t] = distance;
        best[t] = _argmax(logits[t - start + 1]);
      }
      if (end >= n) break;
      start += step;
    }
    return best;
  }

  _TokenPrediction _argmax(List<double> logits) {
    var maxLogit = double.negativeInfinity;
    var maxIdx = 0;
    for (var i = 0; i < logits.length; i++) {
      if (logits[i] > maxLogit) {
        maxLogit = logits[i];
        maxIdx = i;
      }
    }
    var sum = 0.0;
    for (final l in logits) {
      sum += math.exp(l - maxLogit);
    }
    return _TokenPrediction(maxIdx, 1 / sum);
  }

  List<Detection> _decode(
    String text,
    NerEncoding enc,
    List<_TokenPrediction?> predictions,
  ) {
    final out = <Detection>[];
    String? currentEntity;
    var spanStart = -1;
    var spanEnd = -1;
    var probSum = 0.0;
    var probCount = 0;

    void close() {
      if (currentEntity == null || spanStart < 0 || spanEnd <= spanStart) {
        currentEntity = null;
        return;
      }
      final type = spec.labelMap[currentEntity];
      final confidence = probCount == 0 ? 0.0 : probSum / probCount;
      if (type != null && confidence >= spec.threshold) {
        var s = spanStart;
        var e = spanEnd;
        // Trim whitespace the tokenizer may have kept inside the span.
        while (s < e && _isSpace(text.codeUnitAt(s))) {
          s++;
        }
        while (e > s && _isSpace(text.codeUnitAt(e - 1))) {
          e--;
        }
        if (e > s) {
          out.add(Detection(
            type: type,
            value: text.substring(s, e),
            start: s,
            end: e,
            confidence: confidence,
            detector: name,
            source: DetectionSource.model,
          ));
        }
      }
      currentEntity = null;
    }

    int? lastWord;
    String? wordLabel;
    for (var t = 0; t < enc.length; t++) {
      final p = predictions[t];
      final word = enc.wordIds[t];
      final isContinuation = word != null && word == lastWord;
      lastWord = word;
      // Word-first strategy: continuation subwords inherit the label of the
      // word's first subword, which is what the model was trained to tag.
      final label = isContinuation
          ? (wordLabel ?? 'O')
          : (p == null ? 'O' : spec.labels[p.label]);
      if (!isContinuation) wordLabel = label;

      if (label == 'O') {
        close();
        continue;
      }
      final dash = label.indexOf('-');
      final prefix = dash == -1 ? 'B' : label.substring(0, dash);
      final entity = dash == -1 ? label : label.substring(dash + 1);

      final continues = currentEntity == entity &&
          (prefix == 'I' || prefix == 'E' || isContinuation);
      if (!continues) {
        close();
        currentEntity = entity;
        spanStart = enc.starts[t];
        spanEnd = enc.ends[t];
        probSum = 0;
        probCount = 0;
      } else {
        spanEnd = enc.ends[t];
      }
      if (p != null && !isContinuation) {
        probSum += p.probability;
        probCount++;
      }
    }
    close();
    return out;
  }

  static bool _isSpace(int unit) =>
      unit == 0x20 || unit == 0x09 || unit == 0x0A || unit == 0x0D || unit == 0x3000;
}

class _TokenPrediction {
  const _TokenPrediction(this.label, this.probability);

  final int label;
  final double probability;
}
