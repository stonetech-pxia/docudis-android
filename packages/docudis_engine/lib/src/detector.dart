import 'detection.dart';

/// A pluggable source of detections. The pipeline runs every registered
/// detector on the same text and merges the results.
abstract class Detector {
  /// Stable id used in [Detection.detector] prefixes and logs.
  String get name;

  Future<List<Detection>> detect(String text);
}
