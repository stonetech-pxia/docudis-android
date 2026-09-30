import 'dart:io';
import 'dart:isolate';

import 'package:docudis_engine/docudis_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'detectors/language_detector.dart';
import 'detectors/mlkit_entity_detector.dart';
import 'image_redaction.dart';
import 'input/input_source.dart';
import 'input/text_extractor.dart';
import 'model/model_locator.dart';
import 'model/onnx_token_classifier.dart';
import 'output/document_redaction.dart';
import 'core_differential.dart';
import 'storage/anonymization_record.dart';
import 'storage/record_store.dart';

/// Regex rules run in a background isolate; the packs are compiled there.
class _IsolateRegexDetector implements Detector {
  _IsolateRegexDetector(this.regions);

  final Set<String> regions;

  @override
  String get name => 'regex';

  @override
  Future<List<Detection>> detect(String text) {
    final regions = this.regions;
    return Isolate.run(
      () => RegexDetector.bundled(regions: regions).detectSync(text),
    );
  }
}

class _FixedDetector implements Detector {
  const _FixedDetector(this.values);

  final List<Detection> values;

  @override
  String get name => 'external';

  @override
  Future<List<Detection>> detect(String text) async => values;
}

class _DetectionPlan {
  const _DetectionPlan(this.dartDetections, this.rustRequest);

  final List<Detection> dartDetections;
  final Map<String, Object?> rustRequest;
}

/// Orchestrates extract -> detect -> anonymize -> store, and the later
/// edits (toggle spans, restore replies).
class AnonymizeService {
  AnonymizeService({
    required this.store,
    required this.extractor,
    required this.modelLocator,
    required this.dictionaryTerms,
    required this.neverHideTerms,
    required this.listOnly,
  });

  final RecordStore store;
  final TextExtractor extractor;
  final ModelLocator modelLocator;

  /// Current global dictionary; read at each run.
  final Future<List<String>> Function() dictionaryTerms;

  /// Current never-hide list; read at each run.
  final Future<List<String>> Function() neverHideTerms;

  /// "Hide only this list"; read at each run.
  final bool Function() listOnly;

  Future<NerDetector>? _ner;
  final _languages = const LanguageDetector();
  final _core = DocudisCoreDifferential();
  _DetectionPlan? _lastDetectionPlan;

  /// Loads the model once; a failure is logged and the model is skipped.
  Future<NerDetector?> _nerDetector() async {
    try {
      return await (_ner ??= () async {
        final located = await modelLocator.locate();
        final tokenizer = NerTokenizer.fromSpec(
          located.spec.tokenizerKind,
          await _readBytes(located.tokenizerPath),
        );
        final classifier = await OnnxTokenClassifier.load(
          located.modelPath,
          located.spec,
        );
        return NerDetector(
          spec: located.spec,
          tokenizer: tokenizer,
          classifier: classifier,
        );
      }());
    } catch (e, st) {
      debugPrint('NER model unavailable, rules only: $e\n$st');
      _ner = null;
      return null;
    }
  }

  static Future<Uint8List> _readBytes(String path) => File(path).readAsBytes();

  /// Bundled company and Chinese place names; built once, the parse is cheap.
  static final _lists = BundledListDetector.bundled();

  /// Pre-warms the model so the first run is not slower than the rest.
  Future<void> warmUp() => _nerDetector();

  Future<_DetectionPlan> _detectionPlan(
    String text, {
    required List<String> dictionary,
  }) async {
    final sw = Stopwatch()..start();
    final ner = await _nerDetector();
    _log('model ready', sw);
    final languageTags = await _languages.detect(text);
    _log('language id $languageTags', sw);
    final external = (await Future.wait([
      if (ner != null) ner.detect(text),
      MlKitEntityDetector(languageTags: languageTags).detect(text),
    ])).expand((values) => values).toList();
    final regions = RegexDetector.regionsForLanguages(languageTags, text);
    final neverHide = await neverHideTerms();
    final pipeline = DetectionPipeline([
      DictionaryDetector(dictionary),
      _IsolateRegexDetector(regions),
      _lists,
      _FixedDetector(external),
    ], neverHide: neverHide);
    final detections = await pipeline.run(text);
    _log(
      'detection done (${detections.length} spans, ${text.length} chars)',
      sw,
    );
    return _DetectionPlan(detections, {
      'schema_version': 1,
      'text': text,
      'regions': regions.toList()..sort(),
      'dictionary': dictionary,
      'never_hide': neverHide,
      'include_bundled_lists': true,
      'detections': [for (final detection in external) detection.toJson()],
    });
  }

  Future<List<Detection>> detect(String text) async {
    final plan = await _detectionPlan(
      text,
      dictionary: await dictionaryTerms(),
    );
    _lastDetectionPlan = plan;
    return plan.dartDetections;
  }

  static void _log(String stage, Stopwatch sw) =>
      debugPrint('[anonymize] $stage at ${sw.elapsedMilliseconds} ms');

  Future<AnonymizationRecord> process(InputSource source) async {
    final sw = Stopwatch()..start();
    final extraction = await extractor.extract(source);
    final original = extraction.text;
    _log('extracted ${original.length} chars', sw);
    // "Hide only this list": the list alone. An empty list never counts, it
    // would hide nothing.
    final terms = await dictionaryTerms();
    final listOnly = this.listOnly() && terms.isNotEmpty;
    _lastDetectionPlan = null;
    late final _DetectionPlan plan;
    if (listOnly) {
      final detections = await DetectionPipeline([DictionaryDetector(terms)])
          .run(original);
      plan = _DetectionPlan(detections, {
        'schema_version': 1,
        'text': original,
        'regions': <String>[],
        'selection': {'categories': <String>[]},
        'dictionary': terms,
        'never_hide': <String>[],
        'include_bundled_lists': false,
        'detections': <Object?>[],
      });
    } else {
      final detections = await detect(original);
      final prepared = _lastDetectionPlan;
      plan = prepared != null && identical(detections, prepared.dartDetections)
          ? prepared
          : _DetectionPlan(detections, {
              'schema_version': 1,
              'text': original,
              'regions': <String>[],
              'selection': {'categories': <String>[]},
              'dictionary': <String>[],
              'never_hide': <String>[],
              'include_bundled_lists': false,
              'detections': [
                for (final detection in detections) detection.toJson(),
              ],
            });
    }
    final dartResult = anonymize(original, plan.dartDetections);
    final core = await _core.process(
      text: original,
      dartDetections: plan.dartDetections,
      dartResult: dartResult,
      rustRequest: plan.rustRequest,
    );
    final detections = core.detections;
    final result = core.anonymized;
    if (listOnly) _log('list only (${detections.length} spans)', sw);
    final image = extraction.image;
    final redacted = image == null
        ? null
        : await _redact(image.path, image.layout, detections);
    if (image != null) _log('image painted', sw);
    final document = extraction.document;
    final redactedDocument = document == null
        ? null
        : await _redactDocument(
            document.kind,
            document.path,
            document.pdf,
            detections,
            result,
          );
    if (document != null) _log('${document.kind.name} redacted', sw);
    final now = DateTime.now();
    final record = AnonymizationRecord(
      id: '${now.millisecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
      kind: switch (source) {
        TextInput() => InputKind.text,
        FileInput() => InputKind.file,
        CameraInput() => InputKind.image,
      },
      sourceName: switch (source) {
        TextInput() => null,
        FileInput(:final name) || CameraInput(:final name) => name,
      },
      outputFileName: _outputName(source, now),
      detectionCount: detections.where((d) => d.enabled).length,
      preview: _preview(result.text),
      title: source is FileInput ? null : titleFromText(original),
      listOnly: listOnly,
    );
    await store.save(
      record: record,
      original: original,
      output: result.text,
      detections: detections,
      map: result.map,
      image: image == null
          ? null
          : (sourcePath: image.path, layout: image.layout),
      redactedImage: redacted,
      document: document == null
          ? null
          : (sourcePath: document.path, kind: document.kind, pdf: document.pdf),
      redactedDocument: redactedDocument,
    );
    await store.prune(maxRecords);
    return record;
  }

  static Future<Uint8List> _redact(
    String imagePath,
    ImageLayout layout,
    List<Detection> detections,
  ) async => renderRedactedImage(
    await _readBytes(imagePath),
    layout.boxesFor(detections),
  );

  /// The redacted copy of a PDF or Word file, or null when it cannot be
  /// made: the record then shares its text as a `.txt`, as before.
  static Future<Uint8List?> _redactDocument(
    DocumentKind kind,
    String sourcePath,
    PdfLayout? pdf,
    List<Detection> detections,
    AnonymizedText result,
  ) async {
    try {
      return await redactDocument(
        kind: kind,
        sourcePath: sourcePath,
        pdf: pdf,
        detections: detections,
        result: result,
      );
    } catch (e, st) {
      debugPrint('Redacted ${kind.name} unavailable, sharing text: $e\n$st');
      return null;
    }
  }

  /// Records kept on the device; the oldest go first.
  static const maxRecords = 100;

  /// "Clear data on this device": every record, plus the temporary copies of
  /// picked files and photos. The model and dictionary stay.
  Future<void> clearLocalData() async {
    await store.deleteAll();
    final tmp = await getTemporaryDirectory();
    await for (final entry in tmp.list()) {
      try {
        await entry.delete(recursive: true);
      } on FileSystemException {
        // In use by the OS or a plugin; it goes with the next clear.
      }
    }
  }

  /// Re-generates the output after the user enabled/disabled spans or added
  /// a manual one. Updates the record in place.
  Future<RecordDetail> reapply(String id, List<Detection> detections) async {
    final detail = await store.load(id);
    final merged = DetectionPipeline.merge(detail.original, detections);
    final result = anonymize(detail.original, merged, previous: detail.map);
    final image = detail.image;
    final redacted = image == null
        ? null
        : await _redact(image.sourcePath, image.layout, merged);
    final document = detail.document;
    final redactedDocument = document == null
        ? null
        : await _redactDocument(
            document.kind,
            document.sourcePath,
            document.pdf,
            merged,
            result,
          );
    final record = AnonymizationRecord(
      id: detail.record.id,
      createdAt: detail.record.createdAt,
      updatedAt: DateTime.now(),
      kind: detail.record.kind,
      sourceName: detail.record.sourceName,
      outputFileName: detail.record.outputFileName,
      detectionCount: merged.where((d) => d.enabled).length,
      preview: _preview(result.text),
      title: detail.record.title,
      listOnly: detail.record.listOnly,
    );
    await store.save(
      record: record,
      original: detail.original,
      output: result.text,
      detections: merged,
      map: result.map,
      image: image == null
          ? null
          : (sourcePath: image.sourcePath, layout: image.layout),
      redactedImage: redacted,
      document: document == null
          ? null
          : (
              sourcePath: document.sourcePath,
              kind: document.kind,
              pdf: document.pdf,
            ),
      redactedDocument: redactedDocument,
    );
    return store.load(id);
  }

  /// A span the user selected by hand in the original text.
  Detection manualDetection(
    String original,
    int start,
    int end,
    EntityType type,
  ) => Detection(
    type: type,
    value: original.substring(start, end),
    start: start,
    end: end,
    confidence: 1,
    detector: 'manual',
    source: DetectionSource.manual,
  );

  /// Puts real values back into text (an AI reply) that contains this
  /// record's placeholders. Not stored.
  Future<String> restore(String id, String text) async {
    final detail = await store.load(id);
    return detail.map.restore(text);
  }

  static String _outputName(InputSource source, DateTime now) {
    if (source is FileInput) {
      final dot = source.name.lastIndexOf('.');
      final base = dot == -1 ? source.name : source.name.substring(0, dot);
      return '$base-anonymized.txt';
    }
    return 'docudis-${DateFormat('yyyyMMdd-HHmm').format(now)}.txt';
  }

  static String _preview(String text) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return flat.length <= 120 ? flat : '${flat.substring(0, 120)}…';
  }
}
