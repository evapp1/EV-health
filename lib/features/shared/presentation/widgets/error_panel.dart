import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// Severity available to a consumer-facing [ErrorPanel].
enum ErrorPanelSeverity {
  /// A recoverable condition or important warning.
  warning,

  /// A failed operation.
  error,
}

/// A reusable, plain-language failure panel with recovery actions.
class ErrorPanel extends StatelessWidget {
  /// Creates an error panel from already mapped consumer-facing content.
  const ErrorPanel({
    required this.severity,
    required this.title,
    required this.body,
    this.dataStatus,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.announce = true,
    super.key,
  }) : assert(
         (primaryActionLabel == null) == (onPrimaryAction == null),
         'Primary action label and callback must be supplied together.',
       ),
       assert(
         (secondaryActionLabel == null) == (onSecondaryAction == null),
         'Secondary action label and callback must be supplied together.',
       );

  /// Whether this is a warning or failed operation.
  final ErrorPanelSeverity severity;

  /// Plain-language description of what happened.
  final String title;

  /// Plain-language recovery guidance.
  final String body;

  /// Optional statement describing whether usable data was preserved.
  final String? dataStatus;

  /// Optional primary recovery action label.
  final String? primaryActionLabel;

  /// Optional primary recovery intent.
  final VoidCallback? onPrimaryAction;

  /// Optional secondary recovery action label.
  final String? secondaryActionLabel;

  /// Optional secondary recovery intent.
  final VoidCallback? onSecondaryAction;

  /// Whether assistive technology should announce this panel when it appears.
  final bool announce;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    final tone = severity == ErrorPanelSeverity.error
        ? EvHealthSemanticTone.critical
        : EvHealthSemanticTone.caution;
    final toneColor = tone.color(colors);

    return Semantics(
      container: true,
      liveRegion: announce,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: toneColor.withValues(alpha: 0.10),
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(color: toneColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Icon(tone.icon, color: toneColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.mediumSmall),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(body, style: Theme.of(context).textTheme.bodyLarge),
              if (dataStatus != null && dataStatus!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.mediumSmall),
                Text(
                  dataStatus!.trim(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
              ],
              if (onPrimaryAction != null) ...[
                const SizedBox(height: AppSpacing.large),
                FilledButton(
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel!),
                ),
              ],
              if (onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.small),
                OutlinedButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
