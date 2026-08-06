import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/confidence_label.dart';
import 'package:ev_health/features/shared/presentation/widgets/data_value_type.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// A reusable summary card for one pre-formatted battery metric.
class MetricCard extends StatelessWidget {
  /// Creates a metric card that displays supplied presentation data only.
  const MetricCard({
    required this.title,
    required this.statusLabel,
    required this.interpretation,
    required this.valueType,
    required this.tone,
    this.value,
    this.confidence,
    this.confidenceDetail,
    this.onTap,
    this.semanticValue,
    super.key,
  });

  /// Plain-English metric name.
  final String title;

  /// Controlled status text supplied by the caller.
  final String statusLabel;

  /// One-sentence interpretation supplied by the caller.
  final String interpretation;

  /// Classification of how the value was obtained.
  final DataValueType valueType;

  /// Semantic visual emphasis for the supplied status.
  final EvHealthSemanticTone tone;

  /// Pre-formatted value and unit, or null when unavailable.
  final String? value;

  /// Optional pre-classified confidence.
  final ConfidenceLevel? confidence;

  /// Optional qualification for [confidence].
  final String? confidenceDetail;

  /// Opens metric details when supplied.
  final VoidCallback? onTap;

  /// Optional expanded pronunciation for the formatted [value].
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;
    final statusColor = tone.color(colors);
    final displayValue = value?.trim().isNotEmpty == true
        ? value!.trim()
        : 'Unavailable';
    final spokenValue = semanticValue?.trim().isNotEmpty == true
        ? semanticValue!.trim()
        : displayValue;
    final semanticsLabel = [
      title,
      statusLabel,
      spokenValue,
      interpretation,
      valueType.label,
      if (confidence != null) confidence!.label,
      if (confidenceDetail != null && confidenceDetail!.trim().isNotEmpty)
        confidenceDetail!.trim(),
    ].join('. ');

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.mediumSmall),
          _StatusLabel(label: statusLabel, color: statusColor, icon: tone.icon),
          const SizedBox(height: AppSpacing.small),
          Text(displayValue, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.mediumSmall),
          Text(interpretation, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.mediumSmall),
          _ProvenanceLabel(valueType: valueType),
          if (confidence != null) ...[
            const SizedBox(height: AppSpacing.mediumSmall),
            ConfidenceLabel(level: confidence!, detail: confidenceDetail),
          ],
          if (onTap != null) ...[
            const SizedBox(height: AppSpacing.mediumSmall),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.chevron_right, color: colors.primary),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      onTap: onTap,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minimumTouchTarget,
            ),
            child: onTap == null
                ? content
                : InkWell(onTap: onTap, child: content),
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ProvenanceLabel extends StatelessWidget {
  const _ProvenanceLabel({required this.valueType});

  final DataValueType valueType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(valueType.icon, color: colors.textSecondary, size: 20),
        const SizedBox(width: AppSpacing.small),
        Flexible(
          child: Text(
            valueType.label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
