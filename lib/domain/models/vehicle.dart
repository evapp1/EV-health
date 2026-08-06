import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Immutable locally selected supported vehicle without identifying data.
final class Vehicle {
  /// Creates a validated vehicle.
  Vehicle({
    required this.id,
    required this.source,
    required String manufacturer,
    required String model,
    required String variant,
    required this.profile,
    required DateTime lastConfirmedAtUtc,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    int? modelYear,
    String? nickname,
  }) : manufacturer = requireText(manufacturer, 'manufacturer'),
       model = requireText(model, 'model'),
       variant = requireText(variant, 'variant'),
       modelYear = _validateModelYear(modelYear),
       nickname = requireOptionalText(nickname, 'nickname'),
       lastConfirmedAtUtc = requireUtc(
         lastConfirmedAtUtc,
         'lastConfirmedAtUtc',
       ),
       createdAtUtc = requireUtc(createdAtUtc, 'createdAtUtc'),
       updatedAtUtc = requireUtc(updatedAtUtc, 'updatedAtUtc') {
    requireOrdered(
      this.createdAtUtc,
      'createdAtUtc',
      this.lastConfirmedAtUtc,
      'lastConfirmedAtUtc',
    );
    requireOrdered(
      this.lastConfirmedAtUtc,
      'lastConfirmedAtUtc',
      this.updatedAtUtc,
      'updatedAtUtc',
    );
  }

  /// App-generated identifier.
  final VehicleId id;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Manufacturer display name.
  final String manufacturer;

  /// Model display name.
  final String model;

  /// Supported variant display name.
  final String variant;

  /// Optional model year when known.
  final int? modelYear;

  /// Optional user-controlled nickname.
  final String? nickname;

  /// Exact vehicle profile identity.
  final VehicleProfileIdentity profile;

  /// Last UTC time the vehicle selection was confirmed.
  final DateTime lastConfirmedAtUtc;

  /// UTC creation time.
  final DateTime createdAtUtc;

  /// UTC update time.
  final DateTime updatedAtUtc;

  static int? _validateModelYear(int? value) {
    if (value != null && (value < 1886 || value > 9999)) {
      throw RangeError.range(value, 1886, 9999, 'modelYear');
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          other.id == id &&
          other.source == source &&
          other.manufacturer == manufacturer &&
          other.model == model &&
          other.variant == variant &&
          other.modelYear == modelYear &&
          other.nickname == nickname &&
          other.profile == profile &&
          other.lastConfirmedAtUtc == lastConfirmedAtUtc &&
          other.createdAtUtc == createdAtUtc &&
          other.updatedAtUtc == updatedAtUtc;

  @override
  int get hashCode => Object.hash(
    id,
    source,
    manufacturer,
    model,
    variant,
    modelYear,
    nickname,
    profile,
    lastConfirmedAtUtc,
    createdAtUtc,
    updatedAtUtc,
  );
}
