import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// User-selectable temperature display unit.
enum TemperatureUnit {
  /// Degrees Celsius.
  celsius,

  /// Degrees Fahrenheit.
  fahrenheit,
}

/// User-selectable distance display unit.
enum DistanceUnit {
  /// Kilometres.
  kilometres,

  /// Miles.
  miles,
}

/// Immutable local application settings.
final class AppSettings {
  /// Creates validated application settings.
  AppSettings({
    required String id,
    required this.source,
    required this.schemaVersion,
    required this.onboardingComplete,
    required this.temperatureUnit,
    required this.distanceUnit,
    required this.demoModeEnabled,
    required this.lastVehicleId,
    required this.lastAdapterId,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
  }) : id = requireText(id, 'id'),
       createdAtUtc = requireUtc(createdAtUtc, 'createdAtUtc'),
       updatedAtUtc = requireUtc(updatedAtUtc, 'updatedAtUtc') {
    requireOrdered(
      this.createdAtUtc,
      'createdAtUtc',
      this.updatedAtUtc,
      'updatedAtUtc',
    );
    if (source == DataSource.demo && !demoModeEnabled) {
      throw ArgumentError('Demo settings must keep demo mode enabled');
    }
    if (source == DataSource.demo && lastAdapterId != null) {
      throw ArgumentError('Demo settings cannot select a real adapter');
    }
  }

  /// Singleton settings key.
  final String id;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Local settings schema version.
  final SchemaVersion schemaVersion;

  /// Whether first-use onboarding is complete.
  final bool onboardingComplete;

  /// Preferred temperature display unit.
  final TemperatureUnit temperatureUnit;

  /// Preferred distance display unit.
  final DistanceUnit distanceUnit;

  /// Whether the explicitly disclosed demo experience is active.
  final bool demoModeEnabled;

  /// Last selected vehicle, when one exists.
  final VehicleId? lastVehicleId;

  /// Last selected adapter, absent in demo mode.
  final AdapterId? lastAdapterId;

  /// UTC creation time.
  final DateTime createdAtUtc;

  /// UTC update time.
  final DateTime updatedAtUtc;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.id == id &&
          other.source == source &&
          other.schemaVersion == schemaVersion &&
          other.onboardingComplete == onboardingComplete &&
          other.temperatureUnit == temperatureUnit &&
          other.distanceUnit == distanceUnit &&
          other.demoModeEnabled == demoModeEnabled &&
          other.lastVehicleId == lastVehicleId &&
          other.lastAdapterId == lastAdapterId &&
          other.createdAtUtc == createdAtUtc &&
          other.updatedAtUtc == updatedAtUtc;

  @override
  int get hashCode => Object.hash(
    id,
    source,
    schemaVersion,
    onboardingComplete,
    temperatureUnit,
    distanceUnit,
    demoModeEnabled,
    lastVehicleId,
    lastAdapterId,
    createdAtUtc,
    updatedAtUtc,
  );
}
