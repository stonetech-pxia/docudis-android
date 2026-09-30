import 'dart:io';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Finds the NER model files on disk.
///
/// The model ships as an Android asset: in the Play Asset Delivery pack
/// `model_pack` (install-time) for app bundles, or in the app's debug source
/// set for `flutter run`. Either way it is copied once into the app support
/// directory by the native `model_assets` channel, streamed through a small
/// buffer so the 278 MB file never sits in Dart memory. ONNX Runtime then
/// opens the copied file by path.
class ModelLocator {
  ModelLocator({this.assetDir = 'models/xlmr_ner_docudis'});

  /// Android asset directory (relative to the asset root, no `assets/`
  /// prefix) holding `model.json`, the ONNX file and the tokenizer file.
  final String assetDir;

  static const _channel = MethodChannel('com.stonetech.docudis/model_assets');

  /// Materialized model directory containing the ONNX and tokenizer files.
  Future<LocatedModel> locate() async {
    final specJson = await _channel.invokeMethod<String>(
      'readString',
      {'asset': '$assetDir/model.json'},
    );
    final spec = NerModelSpec.fromJson(specJson!);
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'models', spec.name));
    await dir.create(recursive: true);
    final modelPath = await _materialize(spec.modelFile, dir);
    final tokenizerPath = await _materialize(spec.tokenizerFile, dir);
    return LocatedModel(
      spec: spec,
      modelPath: modelPath,
      tokenizerPath: tokenizerPath,
    );
  }

  Future<String> _materialize(String fileName, Directory dir) async {
    final asset = '$assetDir/$fileName';
    final target = File(p.join(dir.path, fileName));
    final expected = await _channel.invokeMethod<int>('length', {'asset': asset}) ?? -1;
    if (await target.exists()) {
      final have = await target.length();
      // Unknown length (compressed asset): trust an existing complete file.
      if (expected < 0 || have == expected) return target.path;
    }
    await _channel.invokeMethod<int>('copy', {'asset': asset, 'dest': target.path});
    return target.path;
  }
}

class LocatedModel {
  const LocatedModel({
    required this.spec,
    required this.modelPath,
    required this.tokenizerPath,
  });

  final NerModelSpec spec;
  final String modelPath;
  final String tokenizerPath;
}
