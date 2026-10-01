import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Goldens are rendered on macOS. Linux CI rasterises the same text 1–6 % of
/// pixels differently, so off macOS the screen tests still run every other
/// expectation but do not compare pixels, and refuse to rewrite the goldens.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (!Platform.isMacOS) goldenFileComparator = _MacOsGoldens();
  await testMain();
}

class _MacOsGoldens extends GoldenFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async => true;

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) =>
      throw UnsupportedError('Goldens are rendered on macOS; update them there.');
}
