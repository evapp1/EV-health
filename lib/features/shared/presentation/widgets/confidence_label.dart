import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// Confidence classifications supplied by a validated result view model.
enum ConfidenceLevel {
  /// Required and supporting inputs are available and valid.
  high,

  /// A usable result has one or more supporting groups unavailable.
  moderate,

  /// Only the minimum inputs are available or conditions are uncertain.
  limited,

  /// Confidence cannot be presented because the result is unavailable.
  unavailable,
}

/// Controlled labels and semantic tones for [ConfidenceLevel].
extension ConfidenceLevelPresentation on ConfidenceLevel {
  /// Human-readable confidence label.
  String get label {
    return switch (this) {
      ConfidenceLevel.high => 'High confidence',
      ConfidenceLevel.moderate => 'Moderate confidence',
      ConfidenceLevel.limited => 'Limited confidence',
      ConfidenceLevel.unavailable => 'Confidence unavailable',
    };
  }

  EvHealthSemanticTone get _tone {
    return switch (this) {
      ConfidenceLevel.high => EvHealthSemanticTone.positive,
      ConfidenceLevel.moderate => EvHealthSemanticTone.information,
      ConfidenceLevel.limited => EvHealthSemanticTone.caution,
      ConfidenceLevel.unavailable => EvHealthSemanticTone.unavailable,
    };
  }
}

/// Displays a confidence classification without deriving it.
class ConfidenceLabel extends StatelessWidget {
  /// Creates a confidence label from a pre-classified [level].
  const ConfidenceLabel({required this.level, this.detail, super.key});

  /// Confidence classification produced outside the presentation layer.
  final ConfidenceLevel level;

  /// Optional plain-language qualification or limitation.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    final toneColor = level._tone.color(colors);
    final semanticsLabel = [
      level.label,
      if (detail != null && detail!.trim().isNotEmpty) detail!.trim(),
    ].join('. ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: toneColor.withValues(alpha: 0.10),
            borderRadius: AppSpacing.buttonRadius,
            border: Border.all(color: toneColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.mediumSmall,
              vertical: AppSpacing.small,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(level._tone.icon, color: toneColor, size: 20),
                const SizedBox(width: AppSpacing.small),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: toneColor),
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
