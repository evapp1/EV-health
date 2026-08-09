import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ScanProgressStateMachine machine;
  late ScanProgressState state;

  setUp(() {
    machine = ScanProgressStateMachine();
    state = ScanProgressState.initial();
  });

  ScanStageStatus status(ScanStage stage) => state.stages[stage.index].status;

  test('initial state has six pending stages and no fabricated progress', () {
    expect(state, isA<ScanProgressReady>());
    expect(state.stages.map((stage) => stage.stage), ScanStage.values);
    expect(
      state.stages.every((stage) => stage.status is ScanStagePending),
      isTrue,
    );
  });

  test('every complete-flow transition is typed and ordered', () {
    state = machine.transition(state, const ScanStarted());
    expect(status(ScanStage.connectedToVehicle), isA<ScanStageActive>());

    for (final stage in ScanStage.values) {
      state = machine.transition(state, ScanStageCompleted(stage));
      expect(status(stage), isA<ScanStageComplete>());
      if (stage != ScanStage.savingScan) {
        expect(
          status(ScanStage.values[stage.index + 1]),
          isA<ScanStageActive>(),
        );
      }
    }

    state = machine.transition(state, const ScanCompleted());
    expect(state, isA<ScanProgressComplete>());
  });

  test('recoverable interruption preserves completed and active stages', () {
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(
      state,
      const ScanStageCompleted(ScanStage.connectedToVehicle),
    );
    state = machine.transition(
      state,
      const ScanInterrupted('Simulated interruption.'),
    );

    expect(state, isA<ScanProgressInterrupted>());
    expect(status(ScanStage.connectedToVehicle), isA<ScanStageComplete>());
    expect(status(ScanStage.readingBatteryCapacity), isA<ScanStageActive>());

    state = machine.transition(state, const ScanResumed());
    expect(state, isA<ScanProgressRunning>());
    expect(status(ScanStage.connectedToVehicle), isA<ScanStageComplete>());
    expect(status(ScanStage.readingBatteryCapacity), isA<ScanStageActive>());
  });

  test('taking longer and Keep waiting are explicit transitions', () {
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(state, const ScanTakingLonger());
    expect(
      state,
      isA<ScanProgressRunning>()
          .having((value) => value.isTakingLonger, 'taking longer', isTrue)
          .having(
            (value) => value.longWaitAcknowledged,
            'acknowledged',
            isFalse,
          ),
    );

    state = machine.transition(state, const ScanKeepWaitingSelected());
    expect((state as ScanProgressRunning).longWaitAcknowledged, isTrue);
  });

  test('failure, skipped stages, and partial outcome stay distinct', () {
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(
      state,
      const ScanStageFailureOccurred(
        ScanStage.connectedToVehicle,
        'Fictional failure.',
      ),
    );
    for (final stage in ScanStage.values.skip(1)) {
      state = machine.transition(state, ScanStageWasSkipped(stage));
    }
    state = machine.transition(
      state,
      const ScanPartiallyCompleted('No result was created.'),
    );

    expect(state, isA<ScanProgressPartial>());
    expect(status(ScanStage.connectedToVehicle), isA<ScanStageFailed>());
    expect(
      state.stages.skip(1).every((stage) => stage.status is ScanStageSkipped),
      isTrue,
    );
  });

  test('terminal failure stops the active stage safely', () {
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(state, const ScanFailed('Stopped.'));

    expect(state, isA<ScanProgressFailed>());
    expect(status(ScanStage.connectedToVehicle), isA<ScanStageSkipped>());
  });

  test('cancellation is explicit from running and interrupted states', () {
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(state, const ScanCancelled());
    expect(state, isA<ScanProgressCancelled>());

    state = ScanProgressState.initial();
    state = machine.transition(state, const ScanStarted());
    state = machine.transition(state, const ScanInterrupted('Paused.'));
    state = machine.transition(state, const ScanCancelled());
    expect(state, isA<ScanProgressCancelled>());
  });

  test('illegal and repeated transitions fail deterministically', () {
    expect(
      () => machine.transition(state, const ScanCompleted()),
      throwsA(isA<IllegalScanProgressTransition>()),
    );

    state = machine.transition(state, const ScanStarted());
    expect(
      () => machine.transition(state, const ScanStarted()),
      throwsA(isA<IllegalScanProgressTransition>()),
    );
    expect(
      () => machine.transition(
        state,
        const ScanStageCompleted(ScanStage.readingBatteryCapacity),
      ),
      throwsA(isA<IllegalScanProgressTransition>()),
    );
    state = machine.transition(state, const ScanTakingLonger());
    expect(
      () => machine.transition(state, const ScanTakingLonger()),
      throwsA(isA<IllegalScanProgressTransition>()),
    );
  });
}
