import 'package:ev_health/domain/models/model_support.dart';

/// Base equality implementation for strongly typed string value objects.
abstract base class DomainStringValue {
  /// Creates a validated string value object.
  DomainStringValue(String value, String name)
    : value = requireText(value, name);

  /// The validated domain value.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is DomainStringValue &&
          other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => value;
}

/// App-generated vehicle identifier.
final class VehicleId extends DomainStringValue {
  /// Creates a vehicle identifier.
  VehicleId(String value) : super(value, 'vehicleId');
}

/// App-generated adapter identifier.
final class AdapterId extends DomainStringValue {
  /// Creates an adapter identifier.
  AdapterId(String value) : super(value, 'adapterId');
}

/// App-generated scan identifier.
final class ScanId extends DomainStringValue {
  /// Creates a scan identifier.
  ScanId(String value) : super(value, 'scanId');
}

/// App-generated raw-reading identifier.
final class RawReadingId extends DomainStringValue {
  /// Creates a raw-reading identifier.
  RawReadingId(String value) : super(value, 'rawReadingId');
}

/// App-generated analysis-result identifier.
final class AnalysisResultId extends DomainStringValue {
  /// Creates an analysis-result identifier.
  AnalysisResultId(String value) : super(value, 'analysisResultId');
}

/// App-generated report-snapshot identifier.
final class ReportSnapshotId extends DomainStringValue {
  /// Creates a report-snapshot identifier.
  ReportSnapshotId(String value) : super(value, 'reportSnapshotId');
}

/// Stable vehicle-profile key.
final class VehicleProfileId extends DomainStringValue {
  /// Creates a vehicle-profile identifier.
  VehicleProfileId(String value) : super(value, 'vehicleProfileId');
}

/// Stable version identifier for governed assets and algorithms.
final class VersionId extends DomainStringValue {
  /// Creates a version identifier.
  VersionId(String value) : super(value, 'versionId');
}

/// Stable vehicle-profile PID mapping key.
final class PidKey extends DomainStringValue {
  /// Creates a PID mapping key.
  PidKey(String value) : super(value, 'pidKey');
}

/// Typed validation failure code.
final class ValidationCode extends DomainStringValue {
  /// Creates a validation code.
  ValidationCode(String value) : super(value, 'validationCode');
}

/// Typed analysis warning code.
final class AnalysisWarningCode extends DomainStringValue {
  /// Creates an analysis warning code.
  AnalysisWarningCode(String value) : super(value, 'analysisWarningCode');
}

/// Typed deterministic report item identifier.
final class ReportItemId extends DomainStringValue {
  /// Creates a report item identifier.
  ReportItemId(String value) : super(value, 'reportItemId');
}

/// Random local report share identifier that is not derived from a VIN.
final class ShareIdentifier extends DomainStringValue {
  /// Creates a share identifier.
  ShareIdentifier(String value) : super(value, 'shareIdentifier');
}

/// Canonical, vehicle-neutral metric key.
final class MetricKey extends DomainStringValue {
  /// Creates and validates a canonical metric key.
  MetricKey(String value) : super(_validate(value), 'metricKey');

  static String _validate(String value) {
    requireText(value, 'metricKey');
    final pattern = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
    if (!pattern.hasMatch(value)) {
      throw ArgumentError.value(value, 'metricKey', 'must be a canonical key');
    }
    return value;
  }
}

/// Positive local schema version.
final class SchemaVersion {
  /// Creates a schema version.
  SchemaVersion(this.value) {
    if (value < 1) {
      throw RangeError.range(value, 1, null, 'schemaVersion');
    }
  }

  /// Numeric schema version.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SchemaVersion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Vehicle profile identity captured with a scan.
final class VehicleProfileIdentity {
  /// Creates a profile identity.
  const VehicleProfileIdentity({required this.id, required this.version});

  /// Stable profile key.
  final VehicleProfileId id;

  /// Exact profile version.
  final VersionId version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleProfileIdentity &&
          other.id == id &&
          other.version == version;

  @override
  int get hashCode => Object.hash(id, version);
}
