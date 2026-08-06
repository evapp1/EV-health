import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// Actual states that a scan step row can present.
enum ScanStepState {
  /// The step has not started.
  waiting,

  /// Work for the step is currently active.
  active,

  /// Work for the step completed.
  complete,

  /// The step is being retried after a transient failure.
  retrying,

  /// The step was intentionally not run.
  skipped,

  /// The step failed.
  failed,
}

/// Controlled presentation metadata for [ScanStepState].
extension ScanStepStatePresentation on ScanStepState {
  /// Human-readable state label.
  String get label {
    return switch (this) {
      ScanStepState.waiting => 'Waiting',
      ScanStepState.active => 'In progress',
      ScanStepState.complete => 'Complete',
      ScanStepState.retrying => 'Retrying',
      ScanStepState.skipped => 'Skipped',
      ScanStepState.failed => 'Failed',
    };
  }

  EvHealthSemanticTone get _tone {
    return switch (this) {
      ScanStepState.waiting => EvHealthSemanticTone.unavailable,
      ScanStepState.active => EvHealthSemanticTone.information,
      ScanStepState.complete => EvHealthSemanticTone.positive,
      ScanStepState.retrying => EvHealthSemanticTone.caution,
      ScanStepState.skipped => EvHealthSemanticTone.unavailable,
      ScanStepState.failed => EvHealthSemanticTone.critical,
    };
  }
}

/// Displays one real scan stage without calculating progress.
class ScanStepRow extends StatelessWidget {
  /// Creates a scan step row from an externally supplied [state].
  const ScanStepRow({
    required this.title,
    required this.state,
    this.detail,
    super.key,
  });

  /// Plain-language name of the actual scan stage.
  final String title;

  /// Current stage state supplied by the scan view model.
  final ScanStepState state;

  /// Optional supporting or recovery detail.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    final stateColor = state._tone.color(colors);
    final semanticsLabel = [
      title,
      state.label,
      if (detail != null && detail!.trim().isNotEmpty) detail!.trim(),
    ].join('. ');

    return Semantics(
      container: true,
      liveRegion:
          state == ScanStepState.active || state == ScanStepState.retrying,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minimumTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.extraSmall),
                  child: _StepIcon(state: state, color: stateColor),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        state.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: stateColor),
                      ),
                      if (detail != null && detail!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.extraSmall),
                        Text(
                          detail!.trim(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.state, required this.color});

  final ScanStepState state;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (state == ScanStepState.active || state == ScanStepState.retrying) {
      return SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }

    final icon = switch (state) {
      ScanStepState.waiting => Icons.radio_button_unchecked,
      ScanStepState.complete => Icons.check_circle_outline,
      ScanStepState.skipped => Icons.remove_circle_outline,
      ScanStepState.failed => Icons.error_outline,
      ScanStepState.active || ScanStepState.retrying => throw StateError(
        'Active scan steps use a progress indicator.',
      ),
    };

    return Icon(icon, color: color, size: 24);
  }
}
