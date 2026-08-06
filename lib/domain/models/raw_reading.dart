import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/measured_value.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Immutable canonical representation of one raw-reading attempt.
final class RawReading {
  RawReading._({
    required this.id,
    required this.scanId,
    required this.source,
    required this.metricKey,
    required this.pidKey,
    required this.quality,
    required this.value,
    required this.validationCode,
    required DateTime measuredAtUtc,
    required String? sourceNumericText,
  }) : measuredAtUtc = requireUtc(measuredAtUtc, 'measuredAtUtc'),
       sourceNumericText = requireOptionalText(
         sourceNumericText,
         'sourceNumericText',
       ) {
    _validateSource(source, value.provenance);
  }

  /// Creates a valid parsed reading.
  factory RawReading.available({
    required RawReadingId id,
    required ScanId scanId,
    required DataSource source,
    required MetricKey metricKey,
    required PidKey pidKey,
    required MeasuredValue value,
    required DateTime measuredAtUtc,
    String? sourceNumericText,
  }) => RawReading._(
    id: id,
    scanId: scanId,
    source: source,
    metricKey: metricKey,
    pidKey: pidKey,
    quality: ReadingQuality.valid,
    value: source == DataSource.demo
        ? ProvenancedValue.demoDerived(value)
        : ProvenancedValue.measured(value),
    validationCode: null,
    measuredAtUtc: measuredAtUtc,
    sourceNumericText: sourceNumericText,
  );

  /// Creates an unavailable or invalid reading attempt.
  factory RawReading.unavailable({
    required RawReadingId id,
    required ScanId scanId,
    required DataSource source,
    required MetricKey metricKey,
    required PidKey pidKey,
    required ReadingQuality quality,
    required UnavailableReason reason,
    required DateTime measuredAtUtc,
    ValidationCode? validationCode,
    String? sourceNumericText,
  }) {
    if (quality == ReadingQuality.valid) {
      throw ArgumentError.value(
        quality,
        'quality',
        'must not be valid for an unavailable reading',
      );
    }
    if (quality == ReadingQuality.invalid && validationCode == null) {
      throw ArgumentError('validationCode is required for an invalid reading');
    }
    return RawReading._(
      id: id,
      scanId: scanId,
      source: source,
      metricKey: metricKey,
      pidKey: pidKey,
      quality: quality,
      value: ProvenancedValue.unavailable(reason),
      validationCode: validationCode,
      measuredAtUtc: measuredAtUtc,
      sourceNumericText: sourceNumericText,
    );
  }

  /// App-generated identifier.
  final RawReadingId id;

  /// Owning scan identifier.
  final ScanId scanId;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Vehicle-neutral metric key.
  final MetricKey metricKey;

  /// Vehicle-profile mapping key, not a raw command.
  final PidKey pidKey;

  /// Reading quality.
  final ReadingQuality quality;

  /// Parsed measurement or typed unavailability.
  final ProvenancedValue<MeasuredValue> value;

  /// Optional redacted numeric source text, without transport headers.
  final String? sourceNumericText;

  /// Typed validation code, required when [quality] is invalid.
  final ValidationCode? validationCode;

  /// UTC measurement time.
  final DateTime measuredAtUtc;

  static void _validateSource(DataSource source, ValueProvenance provenance) {
    if (source == DataSource.real &&
        provenance == ValueProvenance.demoDerived) {
      throw ArgumentError('Real readings cannot contain demo-derived values');
    }
    if (source == DataSource.demo &&
        provenance != ValueProvenance.demoDerived &&
        provenance != ValueProvenance.unavailable) {
      throw ArgumentError('Available demo readings must be demo-derived');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawReading &&
          other.id == id &&
          other.scanId == scanId &&
          other.source == source &&
          other.metricKey == metricKey &&
          other.pidKey == pidKey &&
          other.quality == quality &&
          other.value == value &&
          other.sourceNumericText == sourceNumericText &&
          other.validationCode == validationCode &&
          other.measuredAtUtc == measuredAtUtc;

  @override
  int get hashCode => Object.hash(
    id,
    scanId,
    source,
    metricKey,
    pidKey,
    quality,
    value,
    sourceNumericText,
    validationCode,
    measuredAtUtc,
  );
}
