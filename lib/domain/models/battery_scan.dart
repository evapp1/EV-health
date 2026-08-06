import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Immutable typed conditions captured with a scan.
final class ScanConditions {
  /// Creates scan conditions.
  ScanConditions({required this.powerState, String? notes})
    : notes = requireOptionalText(notes, 'notes');

  /// Observed vehicle power state.
  final VehiclePowerState powerState;

  /// Optional non-identifying contextual note.
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanConditions &&
          other.powerState == powerState &&
          other.notes == notes;

  @override
  int get hashCode => Object.hash(powerState, notes);
}

/// Immutable completed, partial, or unassessable battery scan snapshot.
final class BatteryScan {
  /// Creates a validated scan snapshot.
  BatteryScan({
    required this.id,
    required this.vehicleId,
    required this.adapterId,
    required this.source,
    required this.status,
    required DateTime startedAtUtc,
    required DateTime scannedAtUtc,
    required this.timezoneOffsetMinutes,
    required this.profile,
    required this.pidMapVersion,
    required this.parserVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.conditions,
    required Iterable<MetricKey> unavailableMetricKeys,
    required Iterable<MetricKey> invalidMetricKeys,
    required DateTime createdAtUtc,
  }) : startedAtUtc = requireUtc(startedAtUtc, 'startedAtUtc'),
       scannedAtUtc = requireUtc(scannedAtUtc, 'scannedAtUtc'),
       unavailableMetricKeys = requireUnique(
         unavailableMetricKeys,
         'unavailableMetricKeys',
       ),
       invalidMetricKeys = requireUnique(
         invalidMetricKeys,
         'invalidMetricKeys',
       ),
       createdAtUtc = requireUtc(createdAtUtc, 'createdAtUtc') {
    if (timezoneOffsetMinutes < -840 || timezoneOffsetMinutes > 840) {
      throw RangeError.range(
        timezoneOffsetMinutes,
        -840,
        840,
        'timezoneOffsetMinutes',
      );
    }
    requireOrdered(
      this.startedAtUtc,
      'startedAtUtc',
      this.scannedAtUtc,
      'scannedAtUtc',
    );
    requireOrdered(
      this.scannedAtUtc,
      'scannedAtUtc',
      this.createdAtUtc,
      'createdAtUtc',
    );
    if (source == DataSource.real && adapterId == null) {
      throw ArgumentError('adapterId is required for a real scan');
    }
    if (source == DataSource.demo && adapterId != null) {
      throw ArgumentError('adapterId must be absent for a demo scan');
    }
    final overlap = this.unavailableMetricKeys.toSet().intersection(
      this.invalidMetricKeys.toSet(),
    );
    if (overlap.isNotEmpty) {
      throw ArgumentError('A metric cannot be both unavailable and invalid');
    }
  }

  /// App-generated identifier.
  final ScanId id;

  /// Vehicle associated with the scan.
  final VehicleId vehicleId;

  /// Adapter used for the scan, absent for demo data.
  final AdapterId? adapterId;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Final completeness classification.
  final ScanStatus status;

  /// UTC scan start time.
  final DateTime startedAtUtc;

  /// UTC finalization time of the scan.
  final DateTime scannedAtUtc;

  /// Local offset at scan time, in minutes.
  final int timezoneOffsetMinutes;

  /// Exact vehicle profile identity used.
  final VehicleProfileIdentity profile;

  /// Exact PID map version used.
  final VersionId pidMapVersion;

  /// Exact parser version used.
  final VersionId parserVersion;

  /// Application version that created the scan.
  final VersionId appVersion;

  /// Snapshot schema version.
  final SchemaVersion schemaVersion;

  /// Typed scan conditions.
  final ScanConditions conditions;

  /// Canonical keys that were unavailable.
  final List<MetricKey> unavailableMetricKeys;

  /// Canonical keys that failed validation.
  final List<MetricKey> invalidMetricKeys;

  /// UTC record creation time.
  final DateTime createdAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatteryScan &&
          other.id == id &&
          other.vehicleId == vehicleId &&
          other.adapterId == adapterId &&
          other.source == source &&
          other.status == status &&
          other.startedAtUtc == startedAtUtc &&
          other.scannedAtUtc == scannedAtUtc &&
          other.timezoneOffsetMinutes == timezoneOffsetMinutes &&
          other.profile == profile &&
          other.pidMapVersion == pidMapVersion &&
          other.parserVersion == parserVersion &&
          other.appVersion == appVersion &&
          other.schemaVersion == schemaVersion &&
          other.conditions == conditions &&
          domainListEquals(
            other.unavailableMetricKeys,
            unavailableMetricKeys,
          ) &&
          domainListEquals(other.invalidMetricKeys, invalidMetricKeys) &&
          other.createdAtUtc == createdAtUtc;

  @override
  int get hashCode => Object.hashAll([
    id,
    vehicleId,
    adapterId,
    source,
    status,
    startedAtUtc,
    scannedAtUtc,
    timezoneOffsetMinutes,
    profile,
    pidMapVersion,
    parserVersion,
    appVersion,
    schemaVersion,
    conditions,
    Object.hashAll(unavailableMetricKeys),
    Object.hashAll(invalidMetricKeys),
    createdAtUtc,
  ]);
}
