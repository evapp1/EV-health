/// Named work performed by the scan-progress experience.
enum ScanStage {
  /// The session is connected to the selected vehicle path.
  connectedToVehicle,

  /// Battery-capacity inputs are being requested.
  readingBatteryCapacity,

  /// Cell-balance inputs are being requested.
  checkingCellBalance,

  /// Battery-temperature inputs are being requested.
  readingTemperatures,

  /// Available inputs are being prepared for a result.
  calculatingResult,

  /// The finalized scan is being saved.
  savingScan,
}

/// Typed status for one named [ScanStage].
sealed class ScanStageStatus {
  const ScanStageStatus();
}

/// The stage has not started.
final class ScanStagePending extends ScanStageStatus {
  /// Creates a pending status.
  const ScanStagePending();
}

/// The stage is the current work item.
final class ScanStageActive extends ScanStageStatus {
  /// Creates an active status.
  const ScanStageActive();
}

/// The stage completed successfully.
final class ScanStageComplete extends ScanStageStatus {
  /// Creates a complete status.
  const ScanStageComplete();
}

/// The stage was intentionally not run because earlier demo work was partial.
final class ScanStageSkipped extends ScanStageStatus {
  /// Creates a skipped status.
  const ScanStageSkipped();
}

/// The stage did not complete.
final class ScanStageFailed extends ScanStageStatus {
  /// Creates a failed status with a controlled reason.
  const ScanStageFailed(this.reason);

  /// Plain-language, non-diagnostic reason supplied by the coordinator.
  final String reason;
}

/// Immutable progress for one stage.
final class ScanStageProgress {
  /// Creates stage progress.
  const ScanStageProgress({required this.stage, required this.status});

  /// Named stage.
  final ScanStage stage;

  /// Current typed status.
  final ScanStageStatus status;

  /// Returns a copy with a new typed status.
  ScanStageProgress withStatus(ScanStageStatus nextStatus) =>
      ScanStageProgress(stage: stage, status: nextStatus);
}

/// Events accepted by [ScanProgressStateMachine].
sealed class ScanProgressEvent {
  const ScanProgressEvent();
}

/// Starts the first stage without fabricating any completed work.
final class ScanStarted extends ScanProgressEvent {
  /// Creates the start event.
  const ScanStarted();
}

/// Marks the active stage complete and starts the next stage.
final class ScanStageCompleted extends ScanProgressEvent {
  /// Creates a completion event for [stage].
  const ScanStageCompleted(this.stage);

  /// Stage that actually completed.
  final ScanStage stage;
}

/// Marks the active stage failed while preserving prior completed stages.
final class ScanStageFailureOccurred extends ScanProgressEvent {
  /// Creates a controlled stage-failure event.
  const ScanStageFailureOccurred(this.stage, this.reason);

  /// Stage that failed.
  final ScanStage stage;

  /// Safe, plain-language reason.
  final String reason;
}

/// Skips a pending stage when a partial demo script cannot perform it.
final class ScanStageWasSkipped extends ScanProgressEvent {
  /// Creates a skipped-stage event.
  const ScanStageWasSkipped(this.stage);

  /// Stage that was skipped.
  final ScanStage stage;
}

/// Represents a recoverable interruption during the active stage.
final class ScanInterrupted extends ScanProgressEvent {
  /// Creates an interruption event.
  const ScanInterrupted(this.message);

  /// Controlled recovery message.
  final String message;
}

/// Resumes the stage that was active before an interruption.
final class ScanResumed extends ScanProgressEvent {
  /// Creates a resume event.
  const ScanResumed();
}

/// Indicates that the scan exceeded its reference target.
final class ScanTakingLonger extends ScanProgressEvent {
  /// Creates a long-running event.
  const ScanTakingLonger();
}

/// Records the user's choice to keep waiting without hiding slow state.
final class ScanKeepWaitingSelected extends ScanProgressEvent {
  /// Creates a keep-waiting event.
  const ScanKeepWaitingSelected();
}

/// Completes a scan with every required demo stage complete.
final class ScanCompleted extends ScanProgressEvent {
  /// Creates a complete terminal event.
  const ScanCompleted();
}

/// Completes a scan without claiming that readings or a report exist.
final class ScanPartiallyCompleted extends ScanProgressEvent {
  /// Creates a partial terminal event.
  const ScanPartiallyCompleted(this.message);

  /// Honest explanation of the partial simulation.
  final String message;
}

/// Ends the scan in a controlled failure state.
final class ScanFailed extends ScanProgressEvent {
  /// Creates a failed terminal event.
  const ScanFailed(this.message);

  /// Safe recovery message.
  final String message;
}

/// Ends the scan in an explicit cancelled state.
final class ScanCancelled extends ScanProgressEvent {
  /// Creates a cancellation event.
  const ScanCancelled();
}

/// Base immutable state rendered by the progress screen.
sealed class ScanProgressState {
  const ScanProgressState(this.stages);

  /// Ordered immutable stage state.
  final List<ScanStageProgress> stages;

  /// Whether cancelling this state requires user confirmation.
  bool get isInProgress => false;

  /// Creates a state with no fabricated completed progress.
  static ScanProgressReady initial() => ScanProgressReady(
    List.unmodifiable(
      ScanStage.values.map(
        (stage) =>
            ScanStageProgress(stage: stage, status: const ScanStagePending()),
      ),
    ),
  );
}

/// The screen is open but the coordinator has not emitted start.
final class ScanProgressReady extends ScanProgressState {
  /// Creates the ready state.
  const ScanProgressReady(super.stages);
}

/// A demo scan stage is active.
final class ScanProgressRunning extends ScanProgressState {
  /// Creates a running state.
  const ScanProgressRunning(
    super.stages, {
    this.isTakingLonger = false,
    this.longWaitAcknowledged = false,
  });

  /// Whether the reference-duration threshold was crossed.
  final bool isTakingLonger;

  /// Whether the user explicitly chose to keep waiting.
  final bool longWaitAcknowledged;

  @override
  bool get isInProgress => true;
}

/// A recoverable interruption is visible while completed stages remain intact.
final class ScanProgressInterrupted extends ScanProgressState {
  /// Creates an interrupted state.
  const ScanProgressInterrupted(super.stages, this.message);

  /// Controlled interruption message.
  final String message;

  @override
  bool get isInProgress => true;
}

/// The demo scan completed all stages.
final class ScanProgressComplete extends ScanProgressState {
  /// Creates a complete terminal state.
  const ScanProgressComplete(super.stages);
}

/// The demo scan ended with incomplete stages and no fabricated result data.
final class ScanProgressPartial extends ScanProgressState {
  /// Creates a partial terminal state.
  const ScanProgressPartial(super.stages, this.message);

  /// Honest explanation of what is and is not available.
  final String message;
}

/// The demo scan failed without producing a report.
final class ScanProgressFailed extends ScanProgressState {
  /// Creates a failed terminal state.
  const ScanProgressFailed(super.stages, this.message);

  /// Controlled recovery message.
  final String message;
}

/// The user or deterministic demo driver cancelled the scan.
final class ScanProgressCancelled extends ScanProgressState {
  /// Creates a cancelled terminal state.
  const ScanProgressCancelled(super.stages);
}

/// Deterministic error for an illegal or repeated transition.
final class IllegalScanProgressTransition implements Exception {
  /// Creates an illegal-transition error.
  const IllegalScanProgressTransition(this.message);

  /// Explanation suitable for tests and local diagnostics.
  final String message;

  @override
  String toString() => 'IllegalScanProgressTransition: $message';
}

/// Pure transition rules for scan-progress application state.
final class ScanProgressStateMachine {
  /// Applies [event] or throws [IllegalScanProgressTransition].
  ScanProgressState transition(
    ScanProgressState current,
    ScanProgressEvent event,
  ) {
    if (current is ScanProgressReady && event is ScanStarted) {
      return ScanProgressRunning(
        _replace(
          current.stages,
          ScanStage.connectedToVehicle,
          const ScanStageActive(),
        ),
      );
    }

    if (current is ScanProgressRunning) {
      return _fromRunning(current, event);
    }

    if (current is ScanProgressInterrupted && event is ScanResumed) {
      return ScanProgressRunning(current.stages);
    }

    if (current.isInProgress && event is ScanCancelled) {
      return ScanProgressCancelled(_stopActiveStages(current.stages));
    }

    throw IllegalScanProgressTransition(
      '${current.runtimeType} cannot accept ${event.runtimeType}.',
    );
  }

  ScanProgressState _fromRunning(
    ScanProgressRunning current,
    ScanProgressEvent event,
  ) {
    if (event is ScanStageCompleted) {
      _requireActive(current.stages, event.stage);
      var stages = _replace(
        current.stages,
        event.stage,
        const ScanStageComplete(),
      );
      final nextIndex = event.stage.index + 1;
      if (nextIndex < ScanStage.values.length) {
        final nextStage = ScanStage.values[nextIndex];
        final nextStatus = stages[nextIndex].status;
        if (nextStatus is! ScanStagePending) {
          throw IllegalScanProgressTransition(
            'The stage after ${event.stage.name} is not pending.',
          );
        }
        stages = _replace(stages, nextStage, const ScanStageActive());
      }
      return ScanProgressRunning(
        stages,
        isTakingLonger: current.isTakingLonger,
        longWaitAcknowledged: current.longWaitAcknowledged,
      );
    }

    if (event is ScanStageFailureOccurred) {
      _requireActive(current.stages, event.stage);
      return ScanProgressRunning(
        _replace(current.stages, event.stage, ScanStageFailed(event.reason)),
        isTakingLonger: current.isTakingLonger,
        longWaitAcknowledged: current.longWaitAcknowledged,
      );
    }

    if (event is ScanStageWasSkipped) {
      final status = current.stages[event.stage.index].status;
      if (status is! ScanStagePending) {
        throw IllegalScanProgressTransition(
          '${event.stage.name} can be skipped only while pending.',
        );
      }
      return ScanProgressRunning(
        _replace(current.stages, event.stage, const ScanStageSkipped()),
        isTakingLonger: current.isTakingLonger,
        longWaitAcknowledged: current.longWaitAcknowledged,
      );
    }

    if (event is ScanInterrupted) {
      if (!_hasActiveStage(current.stages)) {
        throw const IllegalScanProgressTransition(
          'An interruption requires an active stage.',
        );
      }
      return ScanProgressInterrupted(current.stages, event.message);
    }

    if (event is ScanTakingLonger) {
      if (current.isTakingLonger) {
        throw const IllegalScanProgressTransition(
          'Taking-longer state was already recorded.',
        );
      }
      return ScanProgressRunning(current.stages, isTakingLonger: true);
    }

    if (event is ScanKeepWaitingSelected) {
      if (!current.isTakingLonger || current.longWaitAcknowledged) {
        throw const IllegalScanProgressTransition(
          'Keep waiting requires an unacknowledged long-running state.',
        );
      }
      return ScanProgressRunning(
        current.stages,
        isTakingLonger: true,
        longWaitAcknowledged: true,
      );
    }

    if (event is ScanCompleted) {
      if (current.stages.any((stage) => stage.status is! ScanStageComplete)) {
        throw const IllegalScanProgressTransition(
          'A complete outcome requires every stage to be complete.',
        );
      }
      return ScanProgressComplete(current.stages);
    }

    if (event is ScanPartiallyCompleted) {
      if (current.stages.every((stage) => stage.status is ScanStageComplete)) {
        throw const IllegalScanProgressTransition(
          'A partial outcome requires an incomplete stage.',
        );
      }
      return ScanProgressPartial(
        _stopActiveStages(current.stages),
        event.message,
      );
    }

    if (event is ScanFailed) {
      return ScanProgressFailed(
        _stopActiveStages(current.stages),
        event.message,
      );
    }

    if (event is ScanCancelled) {
      return ScanProgressCancelled(_stopActiveStages(current.stages));
    }

    throw IllegalScanProgressTransition(
      '${current.runtimeType} cannot accept ${event.runtimeType}.',
    );
  }

  static void _requireActive(List<ScanStageProgress> stages, ScanStage stage) {
    if (stages[stage.index].status is! ScanStageActive) {
      throw IllegalScanProgressTransition('${stage.name} is not active.');
    }
  }

  static bool _hasActiveStage(List<ScanStageProgress> stages) =>
      stages.any((stage) => stage.status is ScanStageActive);

  static List<ScanStageProgress> _replace(
    List<ScanStageProgress> stages,
    ScanStage stage,
    ScanStageStatus status,
  ) {
    final next = List<ScanStageProgress>.of(stages);
    next[stage.index] = next[stage.index].withStatus(status);
    return List.unmodifiable(next);
  }

  static List<ScanStageProgress> _stopActiveStages(
    List<ScanStageProgress> stages,
  ) => List.unmodifiable(
    stages.map(
      (stage) => stage.status is ScanStageActive
          ? stage.withStatus(const ScanStageSkipped())
          : stage,
    ),
  );
}
