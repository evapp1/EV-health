import 'dart:async';

import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/domain/models/app_settings.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/features/home/presentation/screens/home_screen.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_history_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_settings_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_vehicle_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the approved no-scan demo Home state', (tester) async {
    await tester.pumpWidget(_homeApp(history: DemoHistoryRepository.empty()));
    await tester.pumpAndSettle();

    expect(find.text('DEMO DATA'), findsOneWidget);
    expect(find.text('BYD Dolphin Premium'), findsOneWidget);
    expect(find.text('2024 • Demo vehicle profile'), findsOneWidget);
    expect(find.text('No demo scans yet'), findsOneWidget);
    expect(find.text('Start demo scan'), findsOneWidget);
    expect(find.textContaining('not measured from'), findsOneWidget);
    expect(find.text('Latest demo battery report'), findsNothing);
  });

  testWidgets('renders the recent completed demo scan and health summary', (
    tester,
  ) async {
    await tester.pumpWidget(_homeApp());
    await tester.pumpAndSettle();

    expect(find.text('Latest demo battery report'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('96/100'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('147.39 Ah'), findsOneWidget);
    expect(find.text('3 mV'), findsOneWidget);
    expect(find.text('2 °C'), findsOneWidget);
    expect(find.text('High confidence'), findsOneWidget);
    expect(find.textContaining('Scanned 29 Jul 2026'), findsOneWidget);
    expect(find.text('Demo data'), findsNWidgets(4));
  });

  testWidgets('keeps demo classification and disclaimer visible', (
    tester,
  ) async {
    await tester.pumpWidget(_homeApp());
    await tester.pumpAndSettle();

    expect(find.text('DEMO DATA'), findsOneWidget);
    expect(
      find.text(
        'Fictional sample values. They were not measured from or read from a '
        'real vehicle.',
      ),
      findsOneWidget,
    );
    expect(find.text('Demo data — not a vehicle report'), findsOneWidget);
    expect(find.textContaining('Fictional sample'), findsWidgets);
  });

  testWidgets('dispatches the injected primary demo scan callback', (
    tester,
  ) async {
    var actionCalls = 0;
    await tester.pumpWidget(_homeApp(demoScanAction: () => actionCalls += 1));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('home-demo-scan-action')));
    await tester.tap(find.byKey(const Key('home-demo-scan-action')));
    await tester.pump();

    expect(actionCalls, 1);
  });

  testWidgets('shows labelled loading and recoverable error states', (
    tester,
  ) async {
    final pendingSettings = Completer<AppSettings>();
    await tester.pumpWidget(
      _homeApp(settings: _PendingSettingsRepository(pendingSettings.future)),
    );
    await tester.pump();

    expect(find.text('Loading demo battery summary…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pendingSettings.completeError(StateError('local demo unavailable'));
    await tester.pumpAndSettle();

    expect(find.text('Demo Home could not be loaded'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('No vehicle data was read or changed.'), findsOneWidget);
  });

  for (final testCase in <(ThemeData, Brightness)>[
    (AppTheme.light, Brightness.light),
    (AppTheme.dark, Brightness.dark),
  ]) {
    testWidgets('renders in ${testCase.$2.name} theme', (tester) async {
      await tester.pumpWidget(_homeApp(theme: testCase.$1));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Latest demo battery report'));
      final colors = Theme.of(context).extension<EvHealthColors>()!;
      expect(Theme.of(context).brightness, testCase.$2);
      expect(colors.brightness, testCase.$2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports narrow width and 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_homeApp(textScaler: const TextScaler.linear(2)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-demo-scan-action')),
      300,
    );

    expect(find.byKey(const Key('home-demo-scan-action')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps long repository-supplied vehicle copy without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final longVehicle = Vehicle(
      id: DemoFixture.vehicle.id,
      source: DemoFixture.vehicle.source,
      manufacturer: 'BYD demonstration manufacturer name',
      model: 'Dolphin Premium extended presentation model name',
      variant: 'Long fictional sample variant label',
      modelYear: 2024,
      profile: DemoFixture.vehicle.profile,
      lastConfirmedAtUtc: DemoFixture.vehicle.lastConfirmedAtUtc,
      createdAtUtc: DemoFixture.vehicle.createdAtUtc,
      updatedAtUtc: DemoFixture.vehicle.updatedAtUtc,
    );

    await tester.pumpWidget(
      _homeApp(
        vehicles: _VehicleRepository([longVehicle]),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('extended presentation model'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes main health summary and primary action semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_homeApp());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp(r'Battery health — demo\. 98 percent demo state of health'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Run demo scan again. Starts a fictional demo flow and does not '
          'connect to a vehicle.',
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}

Widget _homeApp({
  VehicleRepository? vehicles,
  HistoryRepository? history,
  SettingsRepository? settings,
  DemoScanAction? demoScanAction,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      homeVehicleRepositoryProvider.overrideWithValue(
        vehicles ?? DemoVehicleRepository(),
      ),
      homeHistoryRepositoryProvider.overrideWithValue(
        history ?? DemoHistoryRepository(),
      ),
      homeSettingsRepositoryProvider.overrideWithValue(
        settings ?? const DemoSettingsRepository(),
      ),
      if (demoScanAction != null)
        demoScanActionProvider.overrideWithValue(demoScanAction),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const HomeScreen(),
    ),
  );
}

final class _PendingSettingsRepository implements SettingsRepository {
  const _PendingSettingsRepository(this.result);

  final Future<AppSettings> result;

  @override
  Future<AppSettings> load() => result;

  @override
  Future<void> save(AppSettings settings) => throw UnimplementedError();
}

final class _VehicleRepository implements VehicleRepository {
  const _VehicleRepository(this.vehicles);

  final List<Vehicle> vehicles;

  @override
  Future<Vehicle?> getVehicle(VehicleId id) async =>
      vehicles.where((vehicle) => vehicle.id == id).firstOrNull;

  @override
  Future<List<Vehicle>> listVehicles() async => List.unmodifiable(vehicles);

  @override
  Future<void> saveVehicle(Vehicle vehicle) => throw UnimplementedError();
}
