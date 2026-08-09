import 'dart:async';

import 'package:ev_health/application/scan_progress/scan_progress_coordinator.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_scan_progress_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scenario in <DemoScanScenario>[
    DemoScanScenario.complete,
    DemoScanScenario.partial,
    DemoScanScenario.failed,
    DemoScanScenario.cancelled,
  ]) {
    test(
      'demo driver emits a typed ${scenario.name} terminal outcome',
      () async {
        final coordinator = DemoScanProgressCoordinator(
          scenario: scenario,
          clock: const _ImmediateClock(),
        );
        addTearDown(coordinator.release);
        final events = <ScanProgressEvent>[];
        final subscription = coordinator.events.listen(events.add);
        addTearDown(subscription.cancel);

        await coordinator.start(DemoFixture.vehicle);

        expect(events.first, isA<ScanStarted>());
        final terminal = events.last;
        switch (scenario) {
          case DemoScanScenario.complete:
            expect(terminal, isA<ScanCompleted>());
          case DemoScanScenario.partial:
            expect(terminal, isA<ScanPartiallyCompleted>());
          case DemoScanScenario.failed:
            expect(terminal, isA<ScanFailed>());
          case DemoScanScenario.cancelled:
            expect(terminal, isA<ScanCancelled>());
          case DemoScanScenario.longRunningComplete:
            fail('Not part of this scenario table.');
        }
      },
    );
  }

  test('long-running fixture is driven by the injected clock', () async {
    final clock = _ControlledClock();
    final coordinator = DemoScanProgressCoordinator(
      scenario: DemoScanScenario.longRunningComplete,
      clock: clock,
    );
    addTearDown(coordinator.release);
    final events = <ScanProgressEvent>[];
    final subscription = coordinator.events.listen(events.add);
    addTearDown(subscription.cancel);

    final run = coordinator.start(DemoFixture.vehicle);
    await Future<void>.delayed(Duration.zero);
    expect(events, [isA<ScanStarted>()]);

    clock.advanceNext();
    await Future<void>.delayed(Duration.zero);
    expect(events.last, isA<ScanTakingLonger>());

    while (clock.hasPendingDelay) {
      clock.advanceNext();
      await Future<void>.delayed(Duration.zero);
    }
    await run;
    expect(events.last, isA<ScanCompleted>());
  });
}

final class _ImmediateClock implements ScanProgressClock {
  const _ImmediateClock();

  @override
  Future<void> delay(Duration duration) async {}

  @override
  Future<void> cancelPendingDelay() async {}
}

final class _ControlledClock implements ScanProgressClock {
  final List<_PendingDelay> _pending = <_PendingDelay>[];

  bool get hasPendingDelay => _pending.isNotEmpty;

  @override
  Future<void> delay(Duration duration) {
    final pending = _PendingDelay();
    _pending.add(pending);
    return pending.future;
  }

  void advanceNext() {
    _pending.removeAt(0).complete();
  }

  @override
  Future<void> cancelPendingDelay() async {
    while (_pending.isNotEmpty) {
      advanceNext();
    }
  }
}

final class _PendingDelay {
  final _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void complete() => _completer.complete();
}
