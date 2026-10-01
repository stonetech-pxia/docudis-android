import 'dart:convert';
import 'dart:isolate';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:docudis_ner_ffi/docudis_ner_ffi.dart';

import 'model_locator.dart';

/// NER through the Rust docudis-ner library and ONNX Runtime.
///
/// Same windows, merge and decoding as the Dart [NerDetector], so the same
/// detections, faster. The model is loaded once into native memory and
/// identified by its address; loading and inference run on background
/// isolates so the UI keeps drawing.
class RustNerDetector implements Detector {
  RustNerDetector._(this.name, this._address);

  /// Shipped in the APK by onnxruntime-android; the loader finds it by name.
  static const onnxRuntimeLibrary = 'libonnxruntime.so';

  static Future<RustNerDetector> load(LocatedModel located) async {
    final specJson = located.specJson;
    final modelPath = located.modelPath;
    final tokenizerPath = located.tokenizerPath;
    final address = await Isolate.run(
      () => DocudisNerNative.open()
          .load(
            onnxRuntimeLibrary: onnxRuntimeLibrary,
            spec: (jsonDecode(specJson) as Map).cast<String, Object?>(),
            modelPath: modelPath,
            tokenizerPath: tokenizerPath,
          )
          .address,
    );
    return RustNerDetector._('ner:${located.spec.name}', address);
  }

  @override
  final String name;

  final int _address;

  @override
  Future<List<Detection>> detect(String text) async {
    final address = _address;
    final found = await Isolate.run(
      () => DocudisNerNative.open().model(address).detect(text),
    );
    return [for (final json in found) Detection.fromJson(json)];
  }
}
