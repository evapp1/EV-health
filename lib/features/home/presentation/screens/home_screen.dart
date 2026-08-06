import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/features/home/presentation/models/home_view_data.dart';
import 'package:ev_health/features/shared/presentation/widgets/confidence_label.dart';
import 'package:ev_health/features/shared/presentation/widgets/data_value_type.dart';
import 'package:ev_health/features/shared/presentation/widgets/empty_state.dart';
import 'package:ev_health/features/shared/presentation/widgets/error_panel.dart';
import 'package:ev_health/features/shared/presentation/widgets/hero_health_indicator.dart';
import 'package:ev_health/features/shared/presentation/widgets/metric_card.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository-backed Home destination for the labelled demo experience.
class HomeScreen extends ConsumerWidget {
  /// Creates Home.
  const HomeScreen({this.onDemoScan, super.key});

  /// Optional navigation-level override for the Home demo scan action.
  final DemoScanAction? onDemoScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('EV Health')),
      body: home.when(
        loading: () => const _HomeLoading(),
        error: (error, stackTrace) => _HomeError(
          onRetry: () => ref.read(homeControllerProvider.notifier).reload(),
        ),
        data: (data) => _HomeContent(
          viewData: HomeViewData.from(data),
          onDemoScan: () => ref
              .read(homeControllerProvider.notifier)
              .startDemoScan(onDemoScan),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.viewData, required this.onDemoScan});

  final HomeViewData viewData;
  final Future<void> Function() onDemoScan;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 840
        ? AppSpacing.screenExpanded
        : screenWidth >= 600
        ? AppSpacing.screenMedium
        : AppSpacing.screenCompact;

    return SingleChildScrollView(
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
              const SizedBox(height: AppSpacing.medium),
              _VehicleSummary(viewData: viewData),
              const SizedBox(height: AppSpacing.large),
              if (viewData.recentScan == null)
                EmptyState(
                  icon: Icons.battery_charging_full_outlined,
                  title: 'No demo scans yet',
                  body:
                      'Start the demo scan flow to create a fictional battery '
                      'health report. No vehicle or Bluetooth adapter is used.',
                  primaryActionLabel: 'Start demo scan',
                  onPrimaryAction: onDemoScan,
                )
              else
                _RecentScan(scan: viewData.recentScan!, onDemoScan: onDemoScan),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoDisclosure extends StatelessWidget {
  const _DemoDisclosure();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Semantics(
      container: true,
      label:
          'Demo data. Fictional sample values. Not measured from or read from '
          'a real vehicle.',
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DEMO DATA',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: colors.info),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        'Fictional sample values. They were not measured from '
                        'or read from a real vehicle.',
                        style: Theme.of(context).textTheme.bodyLarge,
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

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.viewData});

  final HomeViewData viewData;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<EvHealthColors>()!;

    return Semantics(
      container: true,
      label:
          'Current demo vehicle. ${viewData.vehicleName}. '
          '${viewData.vehicleDetail}. Profile ${viewData.profileVersion}.',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  color: colors.primary,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current demo vehicle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        viewData.vehicleName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.extraSmall),
                      Text(
                        viewData.vehicleDetail,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Profile ${viewData.profileVersion}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
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

class _RecentScan extends StatelessWidget {
  const _RecentScan({required this.scan, required this.onDemoScan});

  final RecentHomeScanViewData scan;
  final Future<void> Function() onDemoScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Latest demo battery report',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        HeroHealthIndicator(
          title: 'Battery health — demo',
          value: scan.healthValue,
          semanticValue:
              '${scan.healthValue.replaceAll('%', '')} percent '
              'demo state of health',
          statusLabel: scan.healthStatus,
          valueType: DataValueType.demo,
          tone: EvHealthSemanticTone.demo,
          scanTimeLabel: scan.scanTimeLabel,
          completenessLabel: scan.completenessLabel,
          supportingMetrics: [
            HeroHealthMetric(label: 'Demo score', value: scan.scoreValue),
            HeroHealthMetric(label: 'Demo grade', value: scan.gradeValue),
          ],
          confidence: _confidence(scan.confidence),
          confidenceDetail:
              'Based only on the complete fictional demo fixture.',
          isDemo: true,
        ),
        const SizedBox(height: AppSpacing.large),
        Semantics(
          header: true,
          child: Text(
            'Key demo metrics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 600
                ? (constraints.maxWidth - AppSpacing.medium) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.medium,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    title: 'Remaining capacity',
                    statusLabel: 'Fictional sample',
                    value: scan.remainingCapacity,
                    semanticValue: '147 point 39 amp hours, demo data',
                    interpretation:
                        'A fictional capacity value from the approved demo '
                        'snapshot.',
                    valueType: DataValueType.demo,
                    tone: EvHealthSemanticTone.demo,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    title: 'Cell balance',
                    statusLabel: 'Excellent — demo placeholder',
                    value: scan.cellDelta,
                    semanticValue:
                        '3 millivolts cell voltage difference, demo data',
                    interpretation:
                        'The fictional highest and lowest cell values differ '
                        'by 3 millivolts.',
                    valueType: DataValueType.demo,
                    tone: EvHealthSemanticTone.demo,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    title: 'Temperature spread',
                    statusLabel: 'Excellent — demo placeholder',
                    value: scan.temperatureSpread,
                    semanticValue:
                        '2 degrees Celsius temperature spread, demo data',
                    interpretation:
                        'The fictional highest and lowest battery '
                        'temperatures differ by 2 degrees.',
                    valueType: DataValueType.demo,
                    tone: EvHealthSemanticTone.demo,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.large),
        Semantics(
          button: true,
          label:
              'Run demo scan again. Starts a fictional demo flow and does not '
              'connect to a vehicle.',
          child: ExcludeSemantics(
            child: FilledButton.icon(
              key: const Key('home-demo-scan-action'),
              onPressed: onDemoScan,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run demo scan again'),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Loading demo Home data',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Loading demo battery summary…',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenCompact),
      child: ErrorPanel(
        severity: ErrorPanelSeverity.error,
        title: 'Demo Home could not be loaded',
        body:
            'The local demo repositories did not return a usable Home state. '
            'Try loading the sample data again.',
        dataStatus: 'No vehicle data was read or changed.',
        primaryActionLabel: 'Try again',
        onPrimaryAction: onRetry,
      ),
    );
  }
}

ConfidenceLevel _confidence(AnalysisConfidence confidence) {
  return switch (confidence) {
    AnalysisConfidence.high => ConfidenceLevel.high,
    AnalysisConfidence.moderate => ConfidenceLevel.moderate,
    AnalysisConfidence.limited => ConfidenceLevel.limited,
    AnalysisConfidence.unavailable => ConfidenceLevel.unavailable,
  };
}
