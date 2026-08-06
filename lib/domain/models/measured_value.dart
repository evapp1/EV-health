import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Exact scaled-integer measurement in a canonical unit.
final class MeasuredValue {
  /// Creates a measured value with explicit decimal scale.
  MeasuredValue({
    required this.scaledValue,
    required this.decimalScale,
    required this.unit,
  }) {
    const minSigned64 = -9223372036854775808;
    const maxSigned64 = 9223372036854775807;
    if (scaledValue < minSigned64 || scaledValue > maxSigned64) {
      throw RangeError.range(
        scaledValue,
        minSigned64,
        maxSigned64,
        'scaledValue',
      );
    }
    if (decimalScale < 0 || decimalScale > 18) {
      throw RangeError.range(decimalScale, 0, 18, 'decimalScale');
    }
  }

  /// Signed 64-bit scaled value.
  final int scaledValue;

  /// Number of decimal places represented by [scaledValue].
  final int decimalScale;

  /// Canonical unit.
  final CanonicalUnit unit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasuredValue &&
          other.scaledValue == scaledValue &&
          other.decimalScale == decimalScale &&
          other.unit == unit;

  @override
  int get hashCode => Object.hash(scaledValue, decimalScale, unit);
}

/// A typed value paired with its provenance or unavailability reason.
final class ProvenancedValue<T> {
  ProvenancedValue._({
    required this.provenance,
    required this.value,
    required this.unavailableReason,
  });

  /// Creates a measured, vehicle-reported value.
  factory ProvenancedValue.measured(T value) => ProvenancedValue._(
    provenance: ValueProvenance.measured,
    value: value,
    unavailableReason: null,
  );

  /// Creates a calculated value.
  factory ProvenancedValue.calculated(T value) => ProvenancedValue._(
    provenance: ValueProvenance.calculated,
    value: value,
    unavailableReason: null,
  );

  /// Creates an estimated value.
  factory ProvenancedValue.estimated(T value) => ProvenancedValue._(
    provenance: ValueProvenance.estimated,
    value: value,
    unavailableReason: null,
  );

  /// Creates a value derived exclusively for demo mode.
  factory ProvenancedValue.demoDerived(T value) => ProvenancedValue._(
    provenance: ValueProvenance.demoDerived,
    value: value,
    unavailableReason: null,
  );

  /// Creates an unavailable value with a typed reason.
  factory ProvenancedValue.unavailable(UnavailableReason reason) =>
      ProvenancedValue._(
        provenance: ValueProvenance.unavailable,
        value: null,
        unavailableReason: reason,
      );

  /// How the value was obtained.
  final ValueProvenance provenance;

  /// Available value, or `null` only when [provenance] is unavailable.
  final T? value;

  /// Reason for unavailability, or `null` for available values.
  final UnavailableReason? unavailableReason;

  /// Whether this instance carries an available value.
  bool get isAvailable => provenance != ValueProvenance.unavailable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProvenancedValue<T> &&
          other.provenance == provenance &&
          other.value == value &&
          other.unavailableReason == unavailableReason;

  @override
  int get hashCode => Object.hash(provenance, value, unavailableReason);
}

/// A measured or derived metric with reproducibility metadata.
final class MetricResult {
  MetricResult._({
    required this.value,
    required Iterable<MetricKey> inputKeys,
    required this.formulaId,
    required this.algorithmVersion,
  }) : inputKeys = requireUnique(inputKeys, 'inputKeys');

  /// Creates a measured metric.
  factory MetricResult.measured(MeasuredValue value) => MetricResult._(
    value: ProvenancedValue.measured(value),
    inputKeys: const [],
    formulaId: null,
    algorithmVersion: null,
  );

  /// Creates a calculated metric with its inputs and governed formula.
  factory MetricResult.calculated({
    required MeasuredValue value,
    required Iterable<MetricKey> inputKeys,
    required String formulaId,
    required VersionId algorithmVersion,
  }) {
    final inputs = requireUnique(inputKeys, 'inputKeys');
    if (inputs.isEmpty) {
      throw ArgumentError.value(inputKeys, 'inputKeys', 'must not be empty');
    }
    return MetricResult._(
      value: ProvenancedValue.calculated(value),
      inputKeys: inputs,
      formulaId: requireText(formulaId, 'formulaId'),
      algorithmVersion: algorithmVersion,
    );
  }

  /// Creates an estimated metric with its inputs and governed formula.
  factory MetricResult.estimated({
    required MeasuredValue value,
    required Iterable<MetricKey> inputKeys,
    required String formulaId,
    required VersionId algorithmVersion,
  }) {
    final inputs = requireUnique(inputKeys, 'inputKeys');
    if (inputs.isEmpty) {
      throw ArgumentError.value(inputKeys, 'inputKeys', 'must not be empty');
    }
    return MetricResult._(
      value: ProvenancedValue.estimated(value),
      inputKeys: inputs,
      formulaId: requireText(formulaId, 'formulaId'),
      algorithmVersion: algorithmVersion,
    );
  }

  /// Creates an unavailable metric.
  factory MetricResult.unavailable(UnavailableReason reason) => MetricResult._(
    value: ProvenancedValue.unavailable(reason),
    inputKeys: const [],
    formulaId: null,
    algorithmVersion: null,
  );

  /// Creates a metric derived exclusively for demo mode.
  factory MetricResult.demoDerived(MeasuredValue value) => MetricResult._(
    value: ProvenancedValue.demoDerived(value),
    inputKeys: const [],
    formulaId: null,
    algorithmVersion: null,
  );

  /// Value and provenance.
  final ProvenancedValue<MeasuredValue> value;

  /// Canonical input metrics for a calculation or estimate.
  final List<MetricKey> inputKeys;

  /// Stable formula identifier for a calculation or estimate.
  final String? formulaId;

  /// Exact algorithm version for a calculation or estimate.
  final VersionId? algorithmVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricResult &&
          other.value == value &&
          domainListEquals(other.inputKeys, inputKeys) &&
          other.formulaId == formulaId &&
          other.algorithmVersion == algorithmVersion;

  @override
  int get hashCode => Object.hash(
    value,
    Object.hashAll(inputKeys),
    formulaId,
    algorithmVersion,
  );
}
