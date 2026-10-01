import 'dart:convert';
import 'dart:io';

import 'package:docudis/anonymize/model/model_locator.dart';
import 'package:docudis/anonymize/model/onnx_token_classifier.dart';
import 'package:docudis/anonymize/model/rust_ner_detector.dart';
import 'package:docudis_engine/docudis_engine.dart';
import 'package:docudis_ner_ffi/docudis_ner_ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The shipped model, or null where the APK has none (CI: the model comes
/// from a private Hugging Face repo).
Future<LocatedModel?> _locate() async {
  try {
    return await ModelLocator().locate();
  } on PlatformException catch (e) {
    // ignore: avoid_print
    print('no NER model in this build (${e.message}); parity test skipped');
    return null;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android loads the NER library and finds ONNX Runtime by name', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    final native = DocudisNerNative.open();
    expect(native.abiVersion, 1);
    final located = await _locate();
    if (located != null) return; // the parity test loads the real model
    // ONNX Runtime must load from the APK; only the tokenizer is missing.
    expect(
      () => native.load(
        onnxRuntimeLibrary: RustNerDetector.onnxRuntimeLibrary,
        spec: _probeSpec,
        modelPath: '/missing/model.onnx',
        tokenizerPath: '/missing/tokenizer.json',
      ),
      throwsA(
        isA<DocudisNerException>()
            .having((e) => e.status, 'status', DocudisNerStatus.nerError)
            .having(
              (e) => e.message,
              'message',
              contains('/missing/tokenizer.json'),
            ),
      ),
    );
  });

  testWidgets('Rust NER finds exactly what the Dart NER finds', (tester) async {
    final located = await _locate();
    if (located == null) return;
    final rust = await RustNerDetector.load(located);
    final dart = NerDetector(
      spec: located.spec,
      tokenizer: NerTokenizer.fromSpec(
        located.spec.tokenizerKind,
        await File(located.tokenizerPath).readAsBytes(),
      ),
      classifier: await OnnxTokenClassifier.load(
        located.modelPath,
        located.spec,
      ),
    );
    expect(rust.name, dart.name);

    final cases =
        (jsonDecode(await rootBundle.loadString('benchmark/ner_cases.json'))
                as Map)['cases']
            as List<Object?>;
    var spans = 0;
    for (final raw in cases) {
      final c = raw! as Map;
      final text = c['text']! as String;
      final fromRust = [for (final d in await rust.detect(text)) d.toJson()];
      final fromDart = [for (final d in await dart.detect(text)) d.toJson()];
      expect(fromRust, fromDart, reason: c['id'] as String);
      for (final d in fromRust) {
        expect(
          text.substring(d['start']! as int, d['end']! as int),
          d['value'],
          reason: c['id'] as String,
        );
      }
      spans += fromRust.length;
    }
    // ignore: avoid_print
    print('Rust and Dart NER agree on ${cases.length} cases, $spans spans');
    expect(spans, greaterThan(0));
  });
}

/// A valid model.json for the load-failure check; its files do not exist.
const _probeSpec = <String, Object?>{
  'name': 'probe',
  'model': 'model.onnx',
  'tokenizer': {'kind': 'wordpiece', 'file': 'tokenizer.json'},
  'labels': ['O', 'B-PER', 'I-PER'],
  'labelMap': {'PER': 'PERSON'},
  'maxTokens': 128,
  'stride': 16,
  'threshold': 0.5,
  'inputs': {'ids': 'input_ids', 'mask': 'attention_mask'},
  'output': 'logits',
};
