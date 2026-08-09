import 'dart:async';

import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/domain/models/vehicle.dart';

/// Application port for a source-classified scan-progress session.
abstract interface class ScanProgressCoordinator {
  /// Typed events for the single opened session.
  Stream<ScanProgressEvent> get events;

  /// Starts the session for the already-confirmed [vehicle].
  Future<void> start(Vehicle vehicle);

  /// Requests idempotent cancellation.
  Future<void> cancel();

  /// Releases session resources idempotently.
  Future<void> release();
}

/// Injectable time boundary used by deterministic demo coordinators.
abstract interface class ScanProgressClock {
  /// Completes after [duration] according to the injected clock.
  Future<void> delay(Duration duration);

  /// Cancels and completes any pending delay idempotently.
  Future<void> cancelPendingDelay();
}
