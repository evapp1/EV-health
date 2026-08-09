import 'dart:async';

import 'package:ev_health/application/scan_progress/scan_progress_coordinator.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/vehicle.dart';

/// Deterministic fictional outcomes supported by the demo scan driver.
enum DemoScanScenario {
  /// Every named simulated stage completes.
  complete,

  /// Some simulated stages cannot complete.
  partial,

  /// The simulated session ends in failure.
  failed,

  /// The simulated session ends in explicit cancellation.
  cancelled,

  /// Test/QA fixture that crosses the reference-duration threshold.
  longRunningComplete,
}

/// Real elapsed-time clock used only by the fictional demo driver.
final class DemoScanSystemClock implements ScanProgressClock {
  /// Creates the demo clock.
  DemoScanSystemClock();

  Timer? _timer;
  Completer<void>? _pending;

  @override
  Future<void> delay(Duration duration) {
    final pending = Completer<void>();
    _pending = pending;
    _timer = Timer(duration, () {
      _timer = null;
      _pending = null;
      pending.complete();
    });
    return pending.future;
  }

  @override
  Future<void> cancelPendingDelay() async {
    _timer?.cancel();
    _timer = null;
    final pending = _pending;
    _pending = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }
}

/// Demo-only coordinator that emits typed events and never reads a vehicle.
final class DemoScanProgressCoordinator implements ScanProgressCoordinator {
  /// Creates a deterministic coordinator for [scenario].
  DemoScanProgressCoordinator({
    required this.scenario,
    ScanProgressClock? clock,
  }) : clock = clock ?? DemoScanSystemClock();

  /// Selected fictional outcome.
  final DemoScanScenario scenario;

  /// Injected clock used only to schedule deterministic demo events.
  final ScanProgressClock clock;
  final StreamController<ScanProgressEvent> _events =
      StreamController<ScanProgressEvent>(sync: true);
  bool _started = false;
  bool _cancelled = false;
  bool _released = false;

  @override
  Stream<ScanProgressEvent> get events => _events.stream;

  @override
  Future<void> start(Vehicle vehicle) async {
    if (_started || _released) {
      return;
    }
    if (vehicle.source != DataSource.demo) {
      throw StateError('The demo coordinator accepts demo vehicles only.');
    }
    _started = true;
    await _run(_scriptFor(scenario));
  }

  @override
  Future<void> cancel() async {
    if (_cancelled || _released) {
      return;
    }
    _cancelled = true;
    await clock.cancelPendingDelay();
    _emit(const ScanCancelled());
  }

  @override
  Future<void> release() async {
    if (_released) {
      return;
    }
    _released = true;
    await clock.cancelPendingDelay();
    await _events.close();
  }

  Future<void> _run(List<_DemoStep> script) async {
    for (final step in script) {
      if (_cancelled || _released) {
        return;
      }
      if (step.delay != Duration.zero) {
        await clock.delay(step.delay);
      }
      if (_cancelled || _released) {
        return;
      }
      _emit(step.event);
    }
  }

  void _emit(ScanProgressEvent event) {
    if (!_released && !_events.isClosed) {
      _events.add(event);
    }
  }

  static List<_DemoStep> _scriptFor(DemoScanScenario scenario) {
    const short = Duration(milliseconds: 350);
    const immediate = Duration.zero;
    final completeTail = <_DemoStep>[
      const _DemoStep(short, ScanStageCompleted(ScanStage.checkingCellBalance)),
      const _DemoStep(short, ScanStageCompleted(ScanStage.readingTemperatures)),
      const _DemoStep(short, ScanStageCompleted(ScanStage.calculatingResult)),
      const _DemoStep(short, ScanStageCompleted(ScanStage.savingScan)),
      const _DemoStep(immediate, ScanCompleted()),
    ];

    return switch (scenario) {
      DemoScanScenario.complete => <_DemoStep>[
        const _DemoStep(immediate, ScanStarted()),
        const _DemoStep(
          short,
          ScanStageCompleted(ScanStage.connectedToVehicle),
        ),
        const _DemoStep(
          short,
          ScanStageCompleted(ScanStage.readingBatteryCapacity),
        ),
        const _DemoStep(
          short,
          ScanInterrupted(
            'The simulated connection paused. Completed stages are preserved '
            'while the demo resumes once.',
          ),
        ),
        const _DemoStep(short, ScanResumed()),
        ...completeTail,
      ],
      DemoScanScenario.partial => const <_DemoStep>[
        _DemoStep(immediate, ScanStarted()),
        _DemoStep(short, ScanStageCompleted(ScanStage.connectedToVehicle)),
        _DemoStep(short, ScanStageCompleted(ScanStage.readingBatteryCapacity)),
        _DemoStep(
          short,
          ScanStageFailureOccurred(
            ScanStage.checkingCellBalance,
            'This fictional stage did not complete.',
          ),
        ),
        _DemoStep(short, ScanStageWasSkipped(ScanStage.readingTemperatures)),
        _DemoStep(short, ScanStageWasSkipped(ScanStage.calculatingResult)),
        _DemoStep(short, ScanStageWasSkipped(ScanStage.savingScan)),
        _DemoStep(
          immediate,
          ScanPartiallyCompleted(
            'The simulated scan ended with incomplete stages. No battery '
            'readings, health result, or report was created.',
          ),
        ),
      ],
      DemoScanScenario.failed => const <_DemoStep>[
        _DemoStep(immediate, ScanStarted()),
        _DemoStep(short, ScanStageCompleted(ScanStage.connectedToVehicle)),
        _DemoStep(
          short,
          ScanStageFailureOccurred(
            ScanStage.readingBatteryCapacity,
            'The fictional demo stage did not respond.',
          ),
        ),
        _DemoStep(
          immediate,
          ScanFailed(
            'The simulated scan stopped. No battery readings, health result, '
            'or report was created.',
          ),
        ),
      ],
      DemoScanScenario.cancelled => const <_DemoStep>[
        _DemoStep(immediate, ScanStarted()),
        _DemoStep(short, ScanStageCompleted(ScanStage.connectedToVehicle)),
        _DemoStep(short, ScanCancelled()),
      ],
      DemoScanScenario.longRunningComplete => <_DemoStep>[
        const _DemoStep(immediate, ScanStarted()),
        const _DemoStep(Duration(seconds: 10), ScanTakingLonger()),
        const _DemoStep(
          short,
          ScanStageCompleted(ScanStage.connectedToVehicle),
        ),
        const _DemoStep(
          short,
          ScanStageCompleted(ScanStage.readingBatteryCapacity),
        ),
        ...completeTail,
      ],
    };
  }
}

final class _DemoStep {
  const _DemoStep(this.delay, this.event);

  final Duration delay;
  final ScanProgressEvent event;
}
