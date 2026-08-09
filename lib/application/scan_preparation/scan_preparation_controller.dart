import 'dart:async';

import 'package:ev_health/application/scan_preparation/scan_preparation_configuration.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable hand-off invoked only after the user explicitly starts a scan.
typedef StartScanAction = FutureOr<void> Function(Vehicle vehicle);

/// Confirmed vehicle supplied by the setup route.
final scanPreparationVehicleProvider = Provider<Vehicle>((ref) {
  throw StateError('Scan preparation requires a confirmed vehicle.');
}, dependencies: const []);

/// Profile preparation catalogue selected by the composition root.
final scanPreparationConfigurationProvider =
    Provider<ScanPreparationConfiguration>((ref) {
      throw StateError('Scan preparation configuration is not available.');
    });

/// Application-level scan hand-off selected by the composition root.
final startScanActionProvider = Provider<StartScanAction>((ref) {
  return (vehicle) {};
});

/// Typed state coordinator for the preparation screen.
final scanPreparationControllerProvider =
    NotifierProvider<ScanPreparationController, ScanPreparationState>(
      ScanPreparationController.new,
      dependencies: [scanPreparationVehicleProvider],
    );

/// Resolves profile configuration and coordinates explicit Start Scan intent.
final class ScanPreparationController extends Notifier<ScanPreparationState> {
  bool _isStarting = false;

  @override
  ScanPreparationState build() {
    final vehicle = ref.watch(scanPreparationVehicleProvider);
    final instructions = ref
        .watch(scanPreparationConfigurationProvider)
        .forProfile(vehicle.profile, vehicle.source);
    if (instructions == null) {
      return ScanPreparationUnavailable(vehicle);
    }
    return ScanPreparationReady(vehicle, instructions);
  }

  /// Hands off to the injected application action after an explicit tap.
  Future<void> startScan() async {
    final current = state;
    if (current is! ScanPreparationReady || _isStarting) {
      return;
    }

    _isStarting = true;
    state = ScanPreparationStarting(current.vehicle, current.instructions);
    try {
      await ref.read(startScanActionProvider)(current.vehicle);
      state = ScanPreparationStartRequested(
        current.vehicle,
        current.instructions,
      );
    } on Object catch (_) {
      state = ScanPreparationStartFailed(current.vehicle, current.instructions);
    } finally {
      _isStarting = false;
    }
  }

  /// Restores the ready state after an application hand-off failure.
  void retry() {
    final current = state;
    if (current is ScanPreparationStartFailed) {
      state = ScanPreparationReady(current.vehicle, current.instructions);
    }
  }
}

/// Base typed state for scan preparation.
sealed class ScanPreparationState {
  const ScanPreparationState(this.vehicle);

  /// Confirmed vehicle retained for summary and safe failure presentation.
  final Vehicle vehicle;
}

/// Preparation configuration is present and Start Scan is available.
final class ScanPreparationReady extends ScanPreparationState {
  /// Creates a ready state.
  const ScanPreparationReady(super.vehicle, this.instructions);

  /// Profile-specific preparation instructions.
  final VehiclePreparationInstructions instructions;
}

/// The explicit start hand-off is currently running.
final class ScanPreparationStarting extends ScanPreparationState {
  /// Creates a starting state.
  const ScanPreparationStarting(super.vehicle, this.instructions);

  /// Profile-specific preparation instructions.
  final VehiclePreparationInstructions instructions;
}

/// The explicit start hand-off completed; no scan engine is implied.
final class ScanPreparationStartRequested extends ScanPreparationState {
  /// Creates a handed-off state.
  const ScanPreparationStartRequested(super.vehicle, this.instructions);

  /// Profile-specific preparation instructions.
  final VehiclePreparationInstructions instructions;
}

/// The application-level placeholder failed and may be retried explicitly.
final class ScanPreparationStartFailed extends ScanPreparationState {
  /// Creates a recoverable hand-off failure state.
  const ScanPreparationStartFailed(super.vehicle, this.instructions);

  /// Profile-specific preparation instructions.
  final VehiclePreparationInstructions instructions;
}

/// No exact profile/source preparation configuration was available.
final class ScanPreparationUnavailable extends ScanPreparationState {
  /// Creates a fail-closed configuration state.
  const ScanPreparationUnavailable(super.vehicle);
}
