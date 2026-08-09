import 'dart:async';

import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/application/scan_progress/scan_progress_controller.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/features/shared/presentation/widgets/scan_step_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays typed demo scan progress without fabricating vehicle readings.
class ScanProgressScreen extends ConsumerStatefulWidget {
  /// Creates the focused scan-progress route.
  const ScanProgressScreen({
    required this.onPrepareAgain,
    required this.onExit,
    super.key,
  });

  /// Returns to scan preparation for an explicit new attempt.
  final VoidCallback onPrepareAgain;

  /// Exits the scan flow to vehicle confirmation.
  final VoidCallback onExit;

  @override
  ConsumerState<ScanProgressScreen> createState() => _ScanProgressScreenState();
}

class _ScanProgressScreenState extends ConsumerState<ScanProgressScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(
      () => ref.read(scanProgressControllerProvider.notifier).start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(scanProgressControllerProvider);
    final controller = ref.read(scanProgressControllerProvider.notifier);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 840
        ? AppSpacing.screenExpanded
        : screenWidth >= 600
        ? AppSpacing.screenMedium
        : AppSpacing.screenCompact;

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('scan-progress-back'),
          onPressed: () {
            unawaited(_handleExitRequest(progress, controller));
          },
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Checking your battery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.medium,
            horizontalPadding,
            AppSpacing.extraLarge,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DemoDisclosure(),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    _headline(progress),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    _supportingCopy(progress),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  ...progress.stages.map(
                    (stage) => ScanStepRow(
                      key: Key('scan-stage-${stage.stage.name}'),
                      title: _stageLabel(stage.stage),
                      state: _presentationStatus(stage.status),
                      detail: stage.status is ScanStageFailed
                          ? (stage.status as ScanStageFailed).reason
                          : null,
                    ),
                  ),
                  if (progress is ScanProgressInterrupted) ...[
                    const SizedBox(height: AppSpacing.medium),
                    _LiveNotice(
                      key: const Key('recoverable-interruption'),
                      icon: Icons.sync,
                      title: 'The simulation paused briefly',
                      body: progress.message,
                    ),
                  ],
                  if (progress case ScanProgressRunning(
                    isTakingLonger: true,
                    longWaitAcknowledged: false,
                  )) ...[
                    const SizedBox(height: AppSpacing.medium),
                    _LongRunningNotice(
                      onKeepWaiting: controller.keepWaiting,
                      onStop: () => _confirmStop(controller),
                    ),
                  ],
                  if (progress case ScanProgressRunning(
                    isTakingLonger: true,
                    longWaitAcknowledged: true,
                  )) ...[
                    const SizedBox(height: AppSpacing.medium),
                    const _LiveNotice(
                      key: Key('long-running-acknowledged'),
                      icon: Icons.schedule,
                      title: 'Still waiting',
                      body:
                          'The simulated session is still active. Completed '
                          'stages remain preserved.',
                    ),
                  ],
                  const SizedBox(height: AppSpacing.large),
                  if (progress.isInProgress)
                    OutlinedButton.icon(
                      key: const Key('stop-scan-action'),
                      onPressed: () => _confirmStop(controller),
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Stop Scan'),
                    )
                  else
                    _TerminalActions(
                      state: progress,
                      onPrepareAgain: widget.onPrepareAgain,
                      onExit: widget.onExit,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_handleExitRequest(progress, controller));
        }
      },
      child: scaffold,
    );
  }

  Future<void> _handleExitRequest(
    ScanProgressState progress,
    ScanProgressController controller,
  ) async {
    if (progress.isInProgress) {
      await _confirmStop(controller);
      return;
    }
    widget.onExit();
  }

  Future<void> _confirmStop(ScanProgressController controller) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Stop this scan?'),
        content: const Text(
          'The current scan will end. Any complete readings already '
          'collected may be saved as a partial scan. In this simulated flow, '
          'no vehicle readings or report are created.',
        ),
        actions: [
          TextButton(
            key: const Key('keep-scanning-action'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep scanning'),
          ),
          FilledButton(
            key: const Key('confirm-stop-scan-action'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Stop scan'),
          ),
        ],
      ),
    );
    if (shouldStop ?? false) {
      await controller.cancel();
    }
  }

  static String _headline(ScanProgressState state) => switch (state) {
    ScanProgressReady() => 'Starting simulated scan',
    ScanProgressRunning() => 'Simulated scan in progress',
    ScanProgressInterrupted() => 'Preserving completed stages',
    ScanProgressComplete() => 'Simulation complete',
    ScanProgressPartial() => 'Partial simulation',
    ScanProgressFailed() => 'Simulation could not finish',
    ScanProgressCancelled() => 'Simulation cancelled',
  };

  static String _supportingCopy(ScanProgressState state) => switch (state) {
    ScanProgressReady() =>
      'No stage is complete until the injected demo coordinator emits an '
          'event.',
    ScanProgressRunning() =>
      'Keep the app open. Named stages below reflect deterministic demo '
          'events, not vehicle activity.',
    ScanProgressInterrupted() =>
      'Completed simulated stages are kept while the one allowed recovery '
          'attempt continues.',
    ScanProgressComplete() =>
      'All simulated stages completed. No battery readings, health score, '
          'diagnostic finding, or report was created.',
    ScanProgressPartial(:final message) => message,
    ScanProgressFailed(:final message) => message,
    ScanProgressCancelled() =>
      'The simulated session was stopped and its resources were released. '
          'No battery readings or report was created.',
  };

  static String _stageLabel(ScanStage stage) => switch (stage) {
    ScanStage.connectedToVehicle => 'Connected to vehicle',
    ScanStage.readingBatteryCapacity => 'Reading battery capacity',
    ScanStage.checkingCellBalance => 'Checking cell balance',
    ScanStage.readingTemperatures => 'Reading temperatures',
    ScanStage.calculatingResult => 'Calculating result',
    ScanStage.savingScan => 'Saving scan',
  };

  static ScanStepState _presentationStatus(ScanStageStatus status) =>
      switch (status) {
        ScanStagePending() => ScanStepState.waiting,
        ScanStageActive() => ScanStepState.active,
        ScanStageComplete() => ScanStepState.complete,
        ScanStageSkipped() => ScanStepState.skipped,
        ScanStageFailed() => ScanStepState.failed,
      };
}

class _DemoDisclosure extends StatelessWidget {
  const _DemoDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      label:
          'Demo Mode. Simulated scan progress. No Bluetooth, vehicle, OBD, '
          'diagnostic, or telemetry operation is running.',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.info.withValues(alpha: 0.10),
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: colors.info),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science_outlined, color: colors.info),
                const SizedBox(width: AppSpacing.mediumSmall),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DEMO MODE — SIMULATED SCAN'),
                      SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        'Fictional progress only. EV Health is not connected '
                        'to or reading a vehicle.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveNotice extends StatelessWidget {
  const _LiveNotice({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $body',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.info.withValues(alpha: 0.08),
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: colors.info),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: colors.info),
                const SizedBox(width: AppSpacing.mediumSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LongRunningNotice extends StatelessWidget {
  const _LongRunningNotice({required this.onKeepWaiting, required this.onStop});

  final VoidCallback onKeepWaiting;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('long-running-notice'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              header: true,
              child: Text(
                'This is taking longer than the reference scan target.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            const Text(
              'The deterministic demo is responding slowly. You can keep '
              'waiting or stop the simulation. Stop and review is not offered '
              'because this flow has no collected vehicle readings.',
            ),
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                FilledButton(
                  key: const Key('keep-waiting-action'),
                  onPressed: onKeepWaiting,
                  child: const Text('Keep waiting'),
                ),
                OutlinedButton(
                  key: const Key('long-running-stop-action'),
                  onPressed: onStop,
                  child: const Text('Stop scan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalActions extends StatelessWidget {
  const _TerminalActions({
    required this.state,
    required this.onPrepareAgain,
    required this.onExit,
  });

  final ScanProgressState state;
  final VoidCallback onPrepareAgain;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    if (state is ScanProgressReady) {
      return const SizedBox.shrink();
    }
    final actionLabel = switch (state) {
      ScanProgressComplete() => 'Run another simulation',
      ScanProgressPartial() => 'Prepare another simulation',
      ScanProgressFailed() => 'Try from preparation',
      ScanProgressCancelled() => 'Return to preparation',
      _ => 'Return to preparation',
    };
    return Semantics(
      container: true,
      liveRegion: true,
      label: _ScanProgressScreenState._headline(state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(onPressed: onPrepareAgain, child: Text(actionLabel)),
          const SizedBox(height: AppSpacing.small),
          OutlinedButton(
            onPressed: onExit,
            child: const Text('Back to vehicle'),
          ),
        ],
      ),
    );
  }
}
