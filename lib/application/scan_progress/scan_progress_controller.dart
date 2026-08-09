import 'dart:async';

import 'package:ev_health/application/scan_progress/scan_progress_coordinator.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Confirmed demo vehicle supplied by the progress route.
final scanProgressVehicleProvider = Provider<Vehicle>((ref) {
  throw StateError('Scan progress requires a confirmed vehicle.');
}, dependencies: const []);

/// Coordinator selected only at the application composition root.
final scanProgressCoordinatorProvider = Provider<ScanProgressCoordinator>((
  ref,
) {
  throw StateError('A scan-progress coordinator has not been configured.');
});

/// Typed state controller for the scan-progress route.
final scanProgressControllerProvider =
    NotifierProvider<ScanProgressController, ScanProgressState>(
      ScanProgressController.new,
      dependencies: [
        scanProgressVehicleProvider,
        scanProgressCoordinatorProvider,
      ],
    );

/// Coordinates one injected scan session and pure state transitions.
final class ScanProgressController extends Notifier<ScanProgressState> {
  final ScanProgressStateMachine _machine = ScanProgressStateMachine();
  StreamSubscription<ScanProgressEvent>? _subscription;
  bool _started = false;
  bool _cancelRequested = false;
  bool _released = false;
  late Vehicle _vehicle;
  late ScanProgressCoordinator _coordinator;

  @override
  ScanProgressState build() {
    _vehicle = ref.watch(scanProgressVehicleProvider);
    _coordinator = ref.watch(scanProgressCoordinatorProvider);
    ref.onDispose(() {
      unawaited(_disposeResources());
    });
    return ScanProgressState.initial();
  }

  /// Starts only the injected coordinator after the route opens.
  Future<void> start() async {
    if (_started) {
      return;
    }
    if (_vehicle.source != DataSource.demo) {
      throw StateError(
        'TASK-016 allows only a source-classified demo coordinator.',
      );
    }

    _started = true;
    _subscription = _coordinator.events.listen(
      _apply,
      onError: (Object _) => _apply(
        const ScanFailed(
          'The simulated scan stopped unexpectedly. No vehicle data or '
          'report was created.',
        ),
      ),
    );
    try {
      await _coordinator.start(_vehicle);
    } on Object catch (_) {
      _apply(
        const ScanFailed(
          'The simulated scan could not start. No vehicle data or report '
          'was created.',
        ),
      );
    }
  }

  /// Requests cancellation once and leaves repeated calls safe.
  Future<void> cancel() async {
    if (!_started || _cancelRequested || !state.isInProgress) {
      return;
    }
    _cancelRequested = true;
    await _coordinator.cancel();
  }

  /// Records the explicit choice to keep waiting in typed state.
  void keepWaiting() {
    _apply(const ScanKeepWaitingSelected());
  }

  void _apply(ScanProgressEvent event) {
    if (_released || _isTerminal(state)) {
      return;
    }
    try {
      state = _machine.transition(state, event);
    } on IllegalScanProgressTransition {
      state = ScanProgressFailed(
        state.stages,
        'The simulated scan entered an unexpected state. No vehicle data '
        'or report was created.',
      );
    }
    if (_isTerminal(state)) {
      unawaited(_release());
    }
  }

  Future<void> _release() async {
    if (_released) {
      return;
    }
    _released = true;
    await _subscription?.cancel();
    _subscription = null;
    await _coordinator.release();
  }

  Future<void> _disposeResources() async {
    if (_released) {
      return;
    }
    _released = true;
    final cancelFuture = _started && !_cancelRequested
        ? _coordinator.cancel()
        : Future<void>.value();
    _cancelRequested = _cancelRequested || _started;
    await _subscription?.cancel();
    _subscription = null;
    await cancelFuture;
    await _coordinator.release();
  }

  static bool _isTerminal(ScanProgressState value) =>
      value is ScanProgressComplete ||
      value is ScanProgressPartial ||
      value is ScanProgressFailed ||
      value is ScanProgressCancelled;
}
