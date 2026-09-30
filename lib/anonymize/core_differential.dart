import 'dart:convert';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:docudis_ffi/docudis_ffi.dart';
import 'package:flutter/foundation.dart';

class DocudisCoreOutcome {
  const DocudisCoreOutcome({
    required this.detections,
    required this.anonymized,
  });

  final List<Detection> detections;
  final AnonymizedText anonymized;
}

/// Optional, fail-safe Rust candidate path. The Dart result remains the
/// fallback for every load error, ABI mismatch, call failure, or difference.
class DocudisCoreDifferential {
  DocudisCoreDifferential({
    this.enabled = const bool.fromEnvironment(
      'DOCUDIS_RUST_DIFFERENTIAL',
      defaultValue: false,
    ),
    this._native,
  });

  final bool enabled;
  DocudisNative? _native;

  Future<DocudisCoreOutcome> process({
    required String text,
    required List<Detection> dartDetections,
    required AnonymizedText dartResult,
    required Map<String, Object?> rustRequest,
  }) async {
    final reference = _payload(dartDetections, dartResult);
    if (!enabled) return _outcome(reference);

    try {
      final native = _native ??= DocudisNative.open();
      final payload = await DocudisDifferentialRunner(
        native,
        onMismatch: _diagnostic,
      ).process(dartReference: () async => reference, rustRequest: rustRequest);
      return _outcome(payload);
    } on Object catch (error) {
      _diagnostic('Rust library unavailable; using Dart result', {
        'case_id': 'u16-${text.length}-detections-${dartDetections.length}',
        'error_type': error.runtimeType.toString(),
      });
      return _outcome(reference);
    }
  }

  static Map<String, Object?> _payload(
    List<Detection> detections,
    AnonymizedText result,
  ) => {
    'schema_version': 1,
    'text': result.text,
    'detections': [for (final detection in detections) detection.toJson()],
    'mappings': [for (final entry in result.map.entries) entry.toJson()],
    'replacements': [
      for (final replacement in result.replacements)
        {
          'start': replacement.start,
          'end': replacement.end,
          'placeholder': replacement.placeholder,
        },
    ],
  };

  static DocudisCoreOutcome _outcome(Map<String, Object?> payload) {
    final detections = [
      for (final raw in payload['detections']! as List<Object?>)
        Detection.fromJson((raw! as Map).cast<String, Object?>()),
    ];
    final map = PlaceholderMap()
      ..import(
        (payload['mappings']! as List<Object?>).map(
          (raw) => MappingEntry.fromJson((raw! as Map).cast<String, Object?>()),
        ),
      );
    final replacements = [
      for (final raw in payload['replacements']! as List<Object?>)
        _replacement(raw),
    ];
    return DocudisCoreOutcome(
      detections: detections,
      anonymized: AnonymizedText(
        text: payload['text']! as String,
        map: map,
        replacements: replacements,
      ),
    );
  }

  static ({int start, int end, String placeholder}) _replacement(Object? raw) {
    final value = (raw! as Map).cast<String, Object?>();
    return (
      start: value['start']! as int,
      end: value['end']! as int,
      placeholder: value['placeholder']! as String,
    );
  }

  static void _diagnostic(String message, Map<String, Object?> details) {
    // Core diagnostics contain only shape, counts, offsets, status and a
    // non-reversible digest. Never add input text, values or mappings here.
    debugPrint('[docudis-core] $message ${jsonEncode(details)}');
  }
}
