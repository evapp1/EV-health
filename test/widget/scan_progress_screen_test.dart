import 'dart:async';

import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/application/scan_progress/scan_progress_controller.dart';
import 'package:ev_health/application/scan_progress/scan_progress_coordinator.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/features/scan_progress/presentation/screens/scan_progress_screen.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'opening starts injected coordinator with no completed progress',
    (tester) async {
      final fake = _FakeCoordinator();
      await tester.pumpWidget(_screenApp(fake));
      await tester.pump();

      expect(fake.startCalls, 1);
      expect(find.text('DEMO MODE — SIMULATED SCAN'), findsOneWidget);
      expect(find.text('Connected to vehicle'), findsOneWidget);
      expect(find.text('Waiting'), findsNWidgets(6));
      expect(find.text('Complete'), findsNothing);
    },
  );

  testWidgets('named stages reflect typed events without a percentage', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final fake = _FakeCoordinator();
    try {
      await tester.pumpWidget(_screenApp(fake));
      await tester.pump();
      fake.emit(const ScanStarted());
      fake.emit(const ScanStageCompleted(ScanStage.connectedToVehicle));
      await tester.pump();

      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Reading battery capacity. In progress'),
        findsOneWidget,
      );
      final activeStage = tester.getSemantics(
        find.byKey(const Key('scan-stage-readingBatteryCapacity')),
      );
      final pendingStage = tester.getSemantics(
        find.byKey(const Key('scan-stage-readingTemperatures')),
      );
      expect(activeStage.flagsCollection.isLiveRegion, isTrue);
      expect(pendingStage.flagsCollection.isLiveRegion, isFalse);
      expect(find.textContaining('%'), findsNothing);
      final explicitSemanticLabels = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .map((widget) => widget.properties.label)
          .whereType<String>();
      expect(explicitSemanticLabels, everyElement(isNot(contains('%'))));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('recoverable interruption preserves completed stages', (
    tester,
  ) async {
    final fake = _FakeCoordinator();
    await tester.pumpWidget(_screenApp(fake));
    await tester.pump();
    fake.emit(const ScanStarted());
    fake.emit(const ScanStageCompleted(ScanStage.connectedToVehicle));
    fake.emit(const ScanInterrupted('Completed stages remain preserved.'));
    await tester.pump();

    expect(find.byKey(const Key('recoverable-interruption')), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('Android back confirms and Keep scanning preserves progress', (
    tester,
  ) async {
    final fake = _FakeCoordinator(cancelEmitsEvent: true);
    await tester.pumpWidget(_screenApp(fake));
    await tester.pump();
    fake.emit(const ScanStarted());
    fake.emit(const ScanStageCompleted(ScanStage.connectedToVehicle));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Stop this scan?'), findsOneWidget);
    expect(find.text('Keep scanning'), findsOneWidget);
    expect(find.text('Stop scan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('keep-scanning-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(fake.cancelCalls, 0);
    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('Stop Scan invokes idempotent cancellation and shows cancelled', (
    tester,
  ) async {
    final fake = _FakeCoordinator(cancelEmitsEvent: true);
    await tester.pumpWidget(_screenApp(fake));
    await tester.pump();
    fake.emit(const ScanStarted());
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('stop-scan-action')),
      250,
    );

    await tester.tap(find.byKey(const Key('stop-scan-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('confirm-stop-scan-action')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(fake.cancelCalls, 1);
    expect(find.text('Simulation cancelled'), findsWidgets);
    expect(find.textContaining('resources were released'), findsOneWidget);
  });

  testWidgets('long-running state offers only supported actions', (
    tester,
  ) async {
    final fake = _FakeCoordinator(cancelEmitsEvent: true);
    await tester.pumpWidget(_screenApp(fake));
    await tester.pump();
    fake.emit(const ScanStarted());
    fake.emit(const ScanTakingLonger());
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('long-running-notice')),
      250,
    );

    expect(find.text('Keep waiting'), findsOneWidget);
    expect(find.text('Stop and review'), findsNothing);
    expect(
      find.textContaining('has no collected vehicle readings'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('keep-waiting-action')));
    await tester.pump();
    expect(find.byKey(const Key('long-running-notice')), findsNothing);
    expect(find.byKey(const Key('long-running-acknowledged')), findsOneWidget);
  });

  for (final terminal in <ScanProgressEvent, String>{
    const ScanPartiallyCompleted(
      'No battery readings, health result, or report was created.',
    ): 'Partial simulation',
    const ScanFailed(
      'No battery readings, health result, or report was created.',
    ): 'Simulation could not finish',
    const ScanCancelled(): 'Simulation cancelled',
  }.entries) {
    testWidgets('${terminal.value} exposes calm recovery actions', (
      tester,
    ) async {
      final fake = _FakeCoordinator();
      await tester.pumpWidget(_screenApp(fake));
      await tester.pump();
      fake.emit(const ScanStarted());
      fake.emit(terminal.key);
      await tester.pump();

      expect(find.text(terminal.value), findsWidgets);
      expect(
        find.textContaining(RegExp('Prepare|preparation|Return|Try')),
        findsWidgets,
      );
      expect(find.text('Back to vehicle'), findsOneWidget);
    });
  }

  testWidgets('complete terminal state invents no readings or report result', (
    tester,
  ) async {
    final fake = _FakeCoordinator();
    await tester.pumpWidget(_screenApp(fake));
    await tester.pump();
    fake.emit(const ScanStarted());
    for (final stage in ScanStage.values) {
      fake.emit(ScanStageCompleted(stage));
    }
    fake.emit(const ScanCompleted());
    await tester.pump();

    expect(find.text('Simulation complete'), findsWidgets);
    expect(find.textContaining('No battery readings'), findsOneWidget);
    expect(find.textContaining('health score'), findsOneWidget);
  });

  testWidgets('supports narrow dark layout, long copy, and 200 percent text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fake = _FakeCoordinator();
    await tester.pumpWidget(
      _screenApp(
        fake,
        theme: AppTheme.dark,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pump();
    fake.emit(const ScanStarted());
    fake.emit(
      const ScanFailed(
        'This deliberately long simulated failure explanation verifies that '
        'calm recovery copy wraps without horizontal clipping and without '
        'inventing any battery result.',
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Back to vehicle'), 300);

    expect(tester.takeException(), isNull);
    final context = tester.element(find.text('Back to vehicle'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}

Widget _screenApp(
  _FakeCoordinator coordinator, {
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  overrides: [
    scanProgressVehicleProvider.overrideWithValue(DemoFixture.vehicle),
    scanProgressCoordinatorProvider.overrideWithValue(coordinator),
  ],
  child: MaterialApp(
    theme: theme ?? AppTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: ScanProgressScreen(onPrepareAgain: () {}, onExit: () {}),
  ),
);

final class _FakeCoordinator implements ScanProgressCoordinator {
  _FakeCoordinator({this.cancelEmitsEvent = false});

  final bool cancelEmitsEvent;
  final StreamController<ScanProgressEvent> _events =
      StreamController<ScanProgressEvent>.broadcast(sync: true);
  int startCalls = 0;
  int cancelCalls = 0;
  int releaseCalls = 0;

  @override
  Stream<ScanProgressEvent> get events => _events.stream;

  @override
  Future<void> start(Vehicle vehicle) async {
    startCalls += 1;
  }

  @override
  Future<void> cancel() async {
    cancelCalls += 1;
    if (cancelEmitsEvent) {
      emit(const ScanCancelled());
    }
  }

  @override
  Future<void> release() async {
    releaseCalls += 1;
  }

  void emit(ScanProgressEvent event) => _events.add(event);
}
