import 'package:flutter/material.dart';

/// Declares how a displayed value was obtained.
enum DataValueType {
  /// A value reported directly by the vehicle.
  measured,

  /// A value calculated by EV Health from reported inputs.
  calculated,

  /// A modelled or formula-based estimate.
  estimated,

  /// A value that was not available for presentation.
  unavailable,

  /// Fictional sample data used only in demo experiences.
  demo,
}

/// Controlled presentation metadata for [DataValueType].
extension DataValueTypePresentation on DataValueType {
  /// Approved plain-language provenance label.
  String get label {
    return switch (this) {
      DataValueType.measured => 'Reported by the vehicle',
      DataValueType.calculated => 'Calculated by EV Health',
      DataValueType.estimated => 'Estimated by EV Health',
      DataValueType.unavailable => 'Unavailable',
      DataValueType.demo => 'Demo data',
    };
  }

  /// Icon that reinforces the provenance label.
  IconData get icon {
    return switch (this) {
      DataValueType.measured => Icons.directions_car_outlined,
      DataValueType.calculated => Icons.calculate_outlined,
      DataValueType.estimated => Icons.query_stats_outlined,
      DataValueType.unavailable => Icons.remove_circle_outline,
      DataValueType.demo => Icons.science_outlined,
    };
  }
}
