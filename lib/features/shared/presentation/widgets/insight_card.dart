import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// A reusable card for controlled, pre-written insight content.
class InsightCard extends StatelessWidget {
  /// Creates an insight card without generating or selecting its content.
  const InsightCard({
    required this.title,
    required this.body,
    required this.tone,
    this.supportingMeasurements,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must either both be supplied or both omitted.',
       );

  /// Controlled insight title.
  final String title;

  /// Controlled plain-English explanation.
  final String body;

  /// Semantic visual emphasis for the insight.
  final EvHealthSemanticTone tone;

  /// Optional text naming the measurements supporting the insight.
  final String? supportingMeasurements;

  /// Optional accessible action label.
  final String? actionLabel;

  /// Optional action intent, such as opening limitations.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    final toneColor = tone.color(colors);

    return Semantics(
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tone.icon, color: toneColor, size: 24),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.small),
                    Text(body, style: Theme.of(context).textTheme.bodyLarge),
                    if (supportingMeasurements != null &&
                        supportingMeasurements!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.mediumSmall),
                      Text(
                        'Based on: ${supportingMeasurements!.trim()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    if (onAction != null) ...[
                      const SizedBox(height: AppSpacing.mediumSmall),
                      TextButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
