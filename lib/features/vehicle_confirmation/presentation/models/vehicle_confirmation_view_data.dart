import 'package:ev_health/domain/models/vehicle.dart';

/// Presentation-only mapping for the supported demo vehicle profile.
final class VehicleConfirmationViewData {
  /// Maps the typed vehicle without exposing repository implementations.
  factory VehicleConfirmationViewData.from(Vehicle vehicle) {
    return VehicleConfirmationViewData._(
      displayName:
          '${vehicle.manufacturer} ${vehicle.model} ${vehicle.variant}',
      details: List.unmodifiable([
        if (vehicle.modelYear != null)
          VehicleProfileDetail(
            label: 'Model year',
            value: '${vehicle.modelYear}',
          ),
        const VehicleProfileDetail(
          label: 'Profile type',
          value: 'Demo/mock profile',
        ),
        VehicleProfileDetail(
          label: 'Profile version',
          value: vehicle.profile.version.value,
        ),
      ]),
    );
  }

  const VehicleConfirmationViewData._({
    required this.displayName,
    required this.details,
  });

  /// Approved make, model, and variant display name.
  final String displayName;

  /// Approved, non-identifying profile details.
  final List<VehicleProfileDetail> details;
}

/// One display-only vehicle profile detail.
final class VehicleProfileDetail {
  /// Creates a labelled profile detail.
  const VehicleProfileDetail({required this.label, required this.value});

  /// Consumer-facing detail label.
  final String label;

  /// Consumer-facing detail value.
  final String value;
}
