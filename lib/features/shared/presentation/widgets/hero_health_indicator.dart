import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/confidence_label.dart';
import 'package:ev_health/features/shared/presentation/widgets/data_value_type.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';

/// One supporting value displayed by [HeroHealthIndicator].
@immutable
class HeroHealthMetric {
  /// Creates a pre-formatted supporting hero metric.
  const HeroHealthMetric({
    required this.label,
    required this.value,
    this.semanticValue,
  });

  /// Short metric label, such as Battery score or Grade.
  final String label;

  /// Pre-formatted value.
  final String value;

  /// Optional expanded pronunciation for [value].
  final String? semanticValue;
}

/// A prominent, non-certifying summary of supplied battery-health data.
class HeroHealthIndicator extends StatelessWidget {
  /// Creates a hero indicator from pre-formatted display inputs.
  const HeroHealthIndicator({
    required this.title,
    required this.statusLabel,
    required this.valueType,
    required this.tone,
    required this.scanTimeLabel,
    required this.completenessLabel,
    this.value,
    this.semanticValue,
    this.supportingMetrics = const <HeroHealthMetric>[],
    this.confidence,
    this.confidenceDetail,
    this.isDemo = false,
    super.key,
  }) : assert(
         !isDemo || valueType == DataValueType.demo,
         'Demo hero content must use DataValueType.demo.',
       );

  /// Plain-English hero title.
  final String title;

  /// Controlled result status supplied by the caller.
  final String statusLabel;

  /// Classification of how the hero value was obtained.
  final DataValueType valueType;

  /// Semantic visual emphasis for the supplied status.
  final EvHealthSemanticTone tone;

  /// Unambiguous, already formatted scan time.
  final String scanTimeLabel;

  /// Already formatted data-completeness description.
  final String completenessLabel;

  /// Pre-formatted primary value, or null when unavailable.
  final String? value;

  /// Optional expanded pronunciation for [value].
  final String? semanticValue;

  /// Optional supporting values, such as score, grade, and SOH.
  final List<HeroHealthMetric> supportingMetrics;

  /// Optional pre-classified confidence.
  final ConfidenceLevel? confidence;

  /// Optional qualification for [confidence].
  final String? confidenceDetail;

  /// Whether the entire summary represents fictional demo data.
  final bool isDemo;

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
      if (isDemo) 'Demo data',
      title,
      spokenValue,
      statusLabel,
      ...supportingMetrics.expand(
        (metric) => <String>[
          metric.label,
          metric.semanticValue ?? metric.value,
        ],
      ),
      scanTimeLabel,
      completenessLabel,
      valueType.label,
      if (confidence != null) confidence!.label,
      if (confidenceDetail != null && confidenceDetail!.trim().isNotEmpty)
        confidenceDetail!.trim(),
    ].join('. ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDemo) ...[
                  _DemoBanner(color: colors.info),
                  const SizedBox(height: AppSpacing.medium),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.mediumSmall),
                Text(
                  displayValue,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tone.icon, color: statusColor, size: 20),
                    const SizedBox(width: AppSpacing.small),
                    Flexible(
                      child: Text(
                        statusLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
                if (supportingMetrics.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.large),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.large,
                    runSpacing: AppSpacing.medium,
                    children: supportingMetrics
                        .map((metric) => _SupportingMetric(metric: metric))
                        .toList(growable: false),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                _MetadataRow(
                  icon: Icons.schedule_outlined,
                  label: scanTimeLabel,
                ),
                const SizedBox(height: AppSpacing.small),
                _MetadataRow(
                  icon: Icons.fact_check_outlined,
                  label: completenessLabel,
                ),
                const SizedBox(height: AppSpacing.small),
                _MetadataRow(icon: valueType.icon, label: valueType.label),
                if (confidence != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConfidenceLabel(
                      level: confidence!,
                      detail: confidenceDetail,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppSpacing.buttonRadius,
        border: Border.all(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mediumSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, color: color, size: 20),
            const SizedBox(width: AppSpacing.small),
            Flexible(
              child: Text(
                'Demo data — not a vehicle report',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportingMetric extends StatelessWidget {
  const _SupportingMetric({required this.metric});

  final HeroHealthMetric metric;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.extraSmall),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.textSecondary, size: 20),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
