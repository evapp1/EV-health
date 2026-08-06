import 'dart:async';

import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable application action invoked after explicit demo confirmation.
typedef ConfirmVehicleAction = FutureOr<void> Function(Vehicle vehicle);

/// Injectable application action invoked when an unsupported path exits.
typedef ExitUnsupportedVehicleAction = FutureOr<void> Function();

/// Vehicle repository selected by the app composition root.
final vehicleConfirmationRepositoryProvider = Provider<VehicleRepository>((
  ref,
) {
  throw StateError(
    'Vehicle confirmation VehicleRepository has not been configured.',
  );
});

/// Application action selected by the composition root for confirmation.
final confirmVehicleActionProvider = Provider<ConfirmVehicleAction>(
  (ref) => (vehicle) {},
);

/// Application action selected by the composition root for safe exit.
final exitUnsupportedVehicleActionProvider =
    Provider<ExitUnsupportedVehicleAction>((ref) => () {});

/// Loads and coordinates the typed state displayed by vehicle confirmation.
final vehicleConfirmationControllerProvider =
    AsyncNotifierProvider<
      VehicleConfirmationController,
      VehicleConfirmationState
    >(VehicleConfirmationController.new);

/// Coordinates demo profile loading and explicit user intent.
final class VehicleConfirmationController
    extends AsyncNotifier<VehicleConfirmationState> {
  bool _isConfirming = false;
  bool _isExiting = false;

  @override
  Future<VehicleConfirmationState> build() => _loadSupportedVehicle();

  /// Confirms the currently displayed supported demo profile.
  Future<void> confirm() async {
    final current = state.value;
    if (current is! SupportedVehicleConfirmation) {
      throw StateError('Only a supported vehicle can be confirmed.');
    }
    if (_isConfirming) {
      return;
    }

    _isConfirming = true;
    try {
      await ref.read(confirmVehicleActionProvider)(current.vehicle);
      state = AsyncData<VehicleConfirmationState>(
        ConfirmedVehicleConfirmation(current.vehicle),
      );
    } finally {
      _isConfirming = false;
    }
  }

  /// Rejects the displayed profile and prevents further scan-flow progress.
  void reject() {
    final current = state.value;
    if (current is! SupportedVehicleConfirmation) {
      return;
    }
    state = AsyncData<VehicleConfirmationState>(
      UnsupportedVehicleConfirmation(current.vehicle),
    );
  }

  /// Exits the unsupported path through the injected safe action.
  Future<void> exitUnsupported() async {
    if (state.value is! UnsupportedVehicleConfirmation) {
      throw StateError('Safe exit requires an unsupported vehicle state.');
    }
    if (_isExiting) {
      return;
    }

    _isExiting = true;
    try {
      await ref.read(exitUnsupportedVehicleActionProvider)();
    } finally {
      _isExiting = false;
    }
  }

  Future<VehicleConfirmationState> _loadSupportedVehicle() async {
    final vehicles = await ref
        .read(vehicleConfirmationRepositoryProvider)
        .listVehicles();
    final vehicle = vehicles.firstOrNull;
    if (vehicle == null) {
      throw StateError('No demo vehicle profile is available.');
    }
    if (vehicle.source != DataSource.demo) {
      throw StateError(
        'Mock vehicle confirmation requires demo-classified data.',
      );
    }
    return SupportedVehicleConfirmation(vehicle);
  }
}

/// Base state for vehicle confirmation before scan preparation exists.
sealed class VehicleConfirmationState {
  const VehicleConfirmationState();
}

/// A typed, supported demo vehicle awaiting explicit confirmation.
final class SupportedVehicleConfirmation extends VehicleConfirmationState {
  /// Creates a supported state from the immutable domain model.
  const SupportedVehicleConfirmation(this.vehicle);

  /// Demo-classified supported vehicle profile.
  final Vehicle vehicle;
}

/// The supported demo profile was explicitly confirmed by the user.
final class ConfirmedVehicleConfirmation extends VehicleConfirmationState {
  /// Creates a confirmed state without starting scan preparation.
  const ConfirmedVehicleConfirmation(this.vehicle);

  /// Confirmed demo-classified vehicle profile.
  final Vehicle vehicle;
}

/// The user rejected the displayed profile; scanning must not continue.
final class UnsupportedVehicleConfirmation extends VehicleConfirmationState {
  /// Creates an unsupported state while retaining safe display context.
  const UnsupportedVehicleConfirmation(this.rejectedVehicle);

  /// Profile the user said was not the currently connected vehicle.
  final Vehicle rejectedVehicle;
}
