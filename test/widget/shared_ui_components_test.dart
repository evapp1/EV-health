import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/features/shared/presentation/widgets/confidence_label.dart';
import 'package:ev_health/features/shared/presentation/widgets/data_value_type.dart';
import 'package:ev_health/features/shared/presentation/widgets/empty_state.dart';
import 'package:ev_health/features/shared/presentation/widgets/error_panel.dart';
import 'package:ev_health/features/shared/presentation/widgets/hero_health_indicator.dart';
import 'package:ev_health/features/shared/presentation/widgets/insight_card.dart';
import 'package:ev_health/features/shared/presentation/widgets/metric_card.dart';
import 'package:ev_health/features/shared/presentation/widgets/scan_step_row.dart';
import 'package:ev_health/features/shared/presentation/widgets/semantic_tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeroHealthIndicator', () {
    testWidgets('presents supplied health, provenance, and confidence', (
      tester,
    ) async {
      await _pump(
        tester,
        const HeroHealthIndicator(
          title: 'Battery health',
          value: '98%',
          semanticValue: '98 percent battery state of health',
          statusLabel: 'Excellent',
          valueType: DataValueType.calculated,
          tone: EvHealthSemanticTone.positive,
          scanTimeLabel: 'Scanned 29 July 2026 at 8:42 pm',
          completenessLabel: '12 of 12 supported readings available',
          supportingMetrics: [
            HeroHealthMetric(label: 'Battery score', value: '96 / 100'),
            HeroHealthMetric(label: 'Battery grade', value: 'A'),
          ],
          confidence: ConfidenceLevel.high,
        ),
      );

      expect(find.text('98%'), findsOneWidget);
      expect(find.text('Battery score'), findsOneWidget);
      expect(find.text('Calculated by EV Health'), findsOneWidget);
      expect(find.text('High confidence'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final semantics = tester.getSemantics(find.byType(HeroHealthIndicator));
      expect(semantics.label, contains('98 percent battery state of health'));
      expect(semantics.label, contains('12 of 12 supported readings'));
    });

    testWidgets('renders unavailable and demo states explicitly', (
      tester,
    ) async {
      await _pump(
        tester,
        const Column(
          children: [
            HeroHealthIndicator(
              title: 'Battery health',
              statusLabel: 'Not calculated',
              valueType: DataValueType.unavailable,
              tone: EvHealthSemanticTone.unavailable,
              scanTimeLabel: 'Scanned today',
              completenessLabel: 'Required capacity reading unavailable',
            ),
            SizedBox(height: AppSpacing.medium),
            HeroHealthIndicator(
              title: 'Battery health',
              value: '98%',
              statusLabel: 'Excellent — demo placeholder',
              valueType: DataValueType.demo,
              tone: EvHealthSemanticTone.demo,
              scanTimeLabel: 'Demo scan time',
              completenessLabel: '12 of 12 demo readings',
              isDemo: true,
            ),
          ],
        ),
        scrollable: true,
      );

      expect(find.text('Unavailable'), findsNWidgets(2));
      expect(find.text('Demo data — not a vehicle report'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MetricCard', () {
    testWidgets('shows required fields and dispatches its details intent', (
      tester,
    ) async {
      var tapped = false;

      await _pump(
        tester,
        MetricCard(
          title: 'Cell balance',
          statusLabel: 'Within expected range',
          value: '3 mV',
          semanticValue: '3 millivolts cell voltage difference',
          interpretation: 'The reported cell-voltage difference was small.',
          valueType: DataValueType.calculated,
          tone: EvHealthSemanticTone.positive,
          confidence: ConfidenceLevel.moderate,
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('Calculated by EV Health'), findsOneWidget);
      expect(find.text('Moderate confidence'), findsOneWidget);
      expect(
        tester.getSize(find.byType(MetricCard)).height,
        greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
      );

      final semantics = tester.getSemantics(find.byType(MetricCard));
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(semantics.label, contains('3 millivolts cell voltage difference'));

      await tester.tap(find.byType(MetricCard));
      expect(tapped, isTrue);
    });

    testWidgets('never turns a missing value into zero', (tester) async {
      await _pump(
        tester,
        const MetricCard(
          title: 'Remaining capacity',
          statusLabel: 'Unavailable',
          interpretation: 'This value was not available during the scan.',
          valueType: DataValueType.unavailable,
          tone: EvHealthSemanticTone.unavailable,
        ),
      );

      expect(find.text('Unavailable'), findsNWidgets(3));
      expect(find.text('0'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('presents every supported value classification in text', (
      tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: DataValueType.values
              .map(
                (type) => MetricCard(
                  title: 'Metric ${type.name}',
                  statusLabel: type == DataValueType.unavailable
                      ? 'Unavailable'
                      : 'Available',
                  value: type == DataValueType.unavailable ? null : '12 units',
                  interpretation: 'Caller-supplied interpretation.',
                  valueType: type,
                  tone: type == DataValueType.demo
                      ? EvHealthSemanticTone.demo
                      : type == DataValueType.unavailable
                      ? EvHealthSemanticTone.unavailable
                      : EvHealthSemanticTone.information,
                ),
              )
              .toList(),
        ),
        scrollable: true,
      );

      for (final type in DataValueType.values) {
        expect(find.text(type.label), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('ScanStepRow', () {
    testWidgets('distinguishes every supported scan-step state', (
      tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: ScanStepState.values
              .map(
                (state) => ScanStepRow(
                  title: 'Step ${state.name}',
                  state: state,
                  detail: state == ScanStepState.retrying
                      ? 'One automatic retry is underway.'
                      : null,
                ),
              )
              .toList(),
        ),
        scrollable: true,
      );

      for (final state in ScanStepState.values) {
        expect(find.text(state.label), findsOneWidget);
      }
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'announces meaningful active progress to assistive technology',
      (tester) async {
        await _pump(
          tester,
          const ScanStepRow(
            title: 'Reading battery capacity',
            state: ScanStepState.active,
          ),
        );

        final semantics = tester.getSemantics(find.byType(ScanStepRow));
        expect(semantics.label, contains('Reading battery capacity'));
        expect(semantics.label, contains('In progress'));
        expect(semantics.flagsCollection.isLiveRegion, isTrue);
      },
    );
  });

  group('InsightCard', () {
    testWidgets('shows controlled content, evidence, and action', (
      tester,
    ) async {
      var openedLimitations = false;

      await _pump(
        tester,
        InsightCard(
          title: 'Compare scans over time',
          body: 'More scans under similar conditions can provide context.',
          tone: EvHealthSemanticTone.information,
          supportingMeasurements: 'battery state of health and scan time',
          actionLabel: 'View limitations',
          onAction: () => openedLimitations = true,
        ),
      );

      expect(
        find.text('Based on: battery state of health and scan time'),
        findsOneWidget,
      );
      await tester.tap(find.text('View limitations'));
      expect(openedLimitations, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('EmptyState', () {
    testWidgets('provides labelled primary and secondary actions', (
      tester,
    ) async {
      var primaryTapped = false;
      var secondaryTapped = false;

      await _pump(
        tester,
        EmptyState(
          icon: Icons.history,
          title: 'No scans yet',
          body: 'Connect your adapter to create your first report.',
          primaryActionLabel: 'Start a scan',
          onPrimaryAction: () => primaryTapped = true,
          secondaryActionLabel: 'Learn how scans work',
          onSecondaryAction: () => secondaryTapped = true,
        ),
      );

      expect(
        tester
            .getSize(find.widgetWithText(FilledButton, 'Start a scan'))
            .height,
        greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
      );
      await tester.tap(find.text('Start a scan'));
      await tester.tap(find.text('Learn how scans work'));
      expect(primaryTapped, isTrue);
      expect(secondaryTapped, isTrue);

      final primarySemantics = tester.getSemantics(
        find.widgetWithText(FilledButton, 'Start a scan'),
      );
      expect(primarySemantics.label, 'Start a scan');
      expect(primarySemantics.flagsCollection.isButton, isTrue);
    });
  });

  group('ErrorPanel', () {
    testWidgets('explains recovery, data preservation, and actions', (
      tester,
    ) async {
      var retried = false;
      var reviewed = false;

      await _pump(
        tester,
        ErrorPanel(
          severity: ErrorPanelSeverity.error,
          title: 'Connection was lost',
          body: 'Stay near the vehicle and reconnect to continue.',
          dataStatus: 'Completed readings are still available.',
          primaryActionLabel: 'Reconnect',
          onPrimaryAction: () => retried = true,
          secondaryActionLabel: 'Stop and review',
          onSecondaryAction: () => reviewed = true,
        ),
      );

      expect(find.text('Completed readings are still available.'), findsOne);
      final semantics = tester.getSemantics(find.byType(ErrorPanel));
      expect(semantics.flagsCollection.isLiveRegion, isTrue);

      await tester.tap(find.text('Reconnect'));
      await tester.tap(find.text('Stop and review'));
      expect(retried, isTrue);
      expect(reviewed, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('can render a warning with no action', (tester) async {
      await _pump(
        tester,
        const ErrorPanel(
          severity: ErrorPanelSeverity.warning,
          title: 'Some readings were unavailable',
          body: 'Available measurements can still be reviewed.',
          announce: false,
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('ConfidenceLabel', () {
    testWidgets('presents every confidence classification in text', (
      tester,
    ) async {
      await _pump(
        tester,
        const Wrap(
          children: [
            ConfidenceLabel(level: ConfidenceLevel.high),
            ConfidenceLabel(level: ConfidenceLevel.moderate),
            ConfidenceLabel(level: ConfidenceLevel.limited),
            ConfidenceLabel(level: ConfidenceLevel.unavailable),
          ],
        ),
      );

      for (final level in ConfidenceLevel.values) {
        expect(find.text(level.label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('includes qualification in its combined semantic label', (
      tester,
    ) async {
      await _pump(
        tester,
        const ConfidenceLabel(
          level: ConfidenceLevel.limited,
          detail: 'Scan conditions were uncertain.',
        ),
      );

      final semantics = tester.getSemantics(find.byType(ConfidenceLabel));
      expect(semantics.label, contains('Limited confidence'));
      expect(semantics.label, contains('Scan conditions were uncertain'));
    });
  });

  for (final themeMode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    testWidgets('all components render in ${themeMode.name} theme', (
      tester,
    ) async {
      await _pump(
        tester,
        const _AllComponentsHarness(),
        themeMode: themeMode,
        scrollable: true,
      );

      expect(find.byType(HeroHealthIndicator), findsOneWidget);
      expect(find.byType(MetricCard), findsOneWidget);
      expect(find.byType(ScanStepRow), findsOneWidget);
      expect(find.byType(InsightCard), findsOneWidget);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.byType(ErrorPanel), findsOneWidget);
      expect(find.byType(ConfidenceLabel), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'all components handle long text at 200 percent on narrow width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pump(
        tester,
        const _AllComponentsHarness(longText: true),
        textScaler: const TextScaler.linear(2),
        scrollable: true,
      );

      expect(find.textContaining('unusually long'), findsWidgets);
      expect(find.byType(FilledButton), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool scrollable = false,
}) async {
  final content = Padding(
    padding: const EdgeInsets.all(AppSpacing.screenCompact),
    child: child,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Scaffold(
          body: SafeArea(
            child: scrollable ? SingleChildScrollView(child: content) : content,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _AllComponentsHarness extends StatelessWidget {
  const _AllComponentsHarness({this.longText = false});

  final bool longText;

  @override
  Widget build(BuildContext context) {
    final suffix = longText
        ? ' with unusually long explanatory text that must wrap on a narrow phone without hiding information'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroHealthIndicator(
          title: 'Battery health$suffix',
          value: '98%',
          statusLabel: 'Within expected range$suffix',
          valueType: DataValueType.calculated,
          tone: EvHealthSemanticTone.positive,
          scanTimeLabel: 'Scanned 29 July 2026 at 8:42 pm$suffix',
          completenessLabel: '12 of 12 supported readings available$suffix',
          supportingMetrics: const [
            HeroHealthMetric(label: 'Battery score', value: '96 / 100'),
            HeroHealthMetric(label: 'Battery grade', value: 'A'),
          ],
          confidence: ConfidenceLevel.high,
          confidenceDetail: 'Based on all supported reading groups$suffix',
        ),
        const SizedBox(height: AppSpacing.medium),
        MetricCard(
          title: 'Cell balance$suffix',
          statusLabel: 'Within expected range$suffix',
          value: '3 mV',
          interpretation:
              'The supplied interpretation remains readable$suffix.',
          valueType: DataValueType.calculated,
          tone: EvHealthSemanticTone.positive,
          confidence: ConfidenceLevel.moderate,
          confidenceDetail: 'One supporting group was unavailable$suffix',
          onTap: _doNothing,
        ),
        const SizedBox(height: AppSpacing.medium),
        ScanStepRow(
          title: 'Reading battery capacity$suffix',
          state: ScanStepState.retrying,
          detail: 'The adapter is responding slowly$suffix.',
        ),
        const SizedBox(height: AppSpacing.medium),
        InsightCard(
          title: 'Compare scans over time$suffix',
          body: 'This controlled insight stays understandable$suffix.',
          tone: EvHealthSemanticTone.information,
          supportingMeasurements: 'battery health and scan conditions$suffix',
          actionLabel: 'View limitations$suffix',
          onAction: _doNothing,
        ),
        const SizedBox(height: AppSpacing.medium),
        EmptyState(
          icon: Icons.history,
          title: 'No scans yet$suffix',
          body: 'Create your first local battery report$suffix.',
          primaryActionLabel: 'Start a scan$suffix',
          onPrimaryAction: _doNothing,
        ),
        const SizedBox(height: AppSpacing.medium),
        ErrorPanel(
          severity: ErrorPanelSeverity.error,
          title: 'Connection was lost$suffix',
          body: 'Stay near the vehicle and reconnect$suffix.',
          dataStatus: 'Completed readings are still available$suffix.',
          primaryActionLabel: 'Reconnect$suffix',
          onPrimaryAction: _doNothing,
          secondaryActionLabel: 'Stop and review$suffix',
          onSecondaryAction: _doNothing,
        ),
        const SizedBox(height: AppSpacing.medium),
        ConfidenceLabel(
          level: ConfidenceLevel.limited,
          detail: 'Only the minimum inputs were available$suffix.',
        ),
      ],
    );
  }

  static void _doNothing() {}
}
