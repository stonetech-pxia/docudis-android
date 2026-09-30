import 'entity_type.dart';

/// Where a detection came from; decides who wins when spans overlap.
///
/// Order matters: higher [priority] wins. Dictionary terms always win
/// (unless a longer hidden span already contains them, see
/// `DetectionPipeline.resolveOverlaps`), checksum-validated rules beat the
/// model, the model beats loose rules.
/// A rule with confidence >= 0.8 but no checksum (e-mail, international
/// phone, ISO date) is a [strongRule]: it also beats the model, because the
/// model sometimes emits a long junk span across digits and prose that
/// would otherwise swallow the e-mail or phone inside it.
/// A [bundledList] hit (well-known company or Chinese place name shipped
/// with the app) ranks with the model, so the longer of the two wins.
enum DetectionSource {
  dictionary(40),
  validatedRule(30),
  strongRule(25),
  model(20),
  bundledList(20),
  rule(10),
  propagated(5),

  /// A span the user selected by hand.
  manual(50);

  const DetectionSource(this.priority);

  final int priority;
}

/// One sensitive span inside a text. Offsets are UTF-16 code-unit indices
/// into the text it was detected in (Dart `String` indices).
class Detection {
  Detection({
    required this.type,
    required this.value,
    required this.start,
    required this.end,
    required this.confidence,
    required this.detector,
    required this.source,
    this.enabled = true,
  }) : assert(end > start);

  final EntityType type;
  final String value;
  final int start;
  final int end;
  final double confidence;

  /// Detector id, e.g. `regex:cn:phone_mobile`, `ner:distilbert`, `dictionary`.
  final String detector;
  final DetectionSource source;

  /// Whether the user wants this span replaced. Toggled on the review page.
  final bool enabled;

  int get length => end - start;

  bool overlaps(Detection other) => start < other.end && end > other.start;

  Detection copyWith({bool? enabled, EntityType? type}) => Detection(
        type: type ?? this.type,
        value: value,
        start: start,
        end: end,
        confidence: confidence,
        detector: detector,
        source: source,
        enabled: enabled ?? this.enabled,
      );

  Map<String, Object?> toJson() => {
        'type': type.placeholderName,
        'value': value,
        'start': start,
        'end': end,
        'confidence': confidence,
        'detector': detector,
        'source': source.name,
        'enabled': enabled,
      };

  factory Detection.fromJson(Map<String, Object?> json) => Detection(
        type: EntityType.fromName(json['type'] as String) ?? EntityType.other,
        value: json['value'] as String,
        start: json['start'] as int,
        end: json['end'] as int,
        confidence: (json['confidence'] as num).toDouble(),
        detector: json['detector'] as String,
        source: DetectionSource.values.byName(json['source'] as String),
        enabled: json['enabled'] as bool? ?? true,
      );

  @override
  String toString() =>
      '${type.placeholderName}[$start:$end]="$value" ${confidence.toStringAsFixed(2)} $detector';
}
