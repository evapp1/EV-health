import 'dart:async';

import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/domain/models/app_settings.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/scan_bundle.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads Home through repository ports and exposes latest history',
    () async {
      final vehicles = _VehicleRepository([DemoFixture.vehicle]);
      final history = _HistoryRepository([DemoFixture.completeScanBundle]);
      final settings = _SettingsRepository(DemoFixture.settings);
      final container = _container(
        vehicles: vehicles,
        history: history,
        settings: settings,
      );
      addTearDown(container.dispose);

      final home = await container.read(homeControllerProvider.future);

      expect(home.vehicle, DemoFixture.vehicle);
      expect(home.latestScan, DemoFixture.completeScanBundle);
      expect(home.isDemoMode, isTrue);
      expect(vehicles.getCalls, 1);
      expect(vehicles.listCalls, 0);
      expect(history.calls, 1);
      expect(settings.calls, 1);
    },
  );

  test('loads the approved no-scan state from empty history', () async {
    final container = _container(
      vehicles: _VehicleRepository([DemoFixture.vehicle]),
      history: _HistoryRepository(const []),
      settings: _SettingsRepository(DemoFixture.settings),
    );
    addTearDown(container.dispose);

    final home = await container.read(homeControllerProvider.future);

    expect(home.history, isEmpty);
    expect(home.latestScan, isNull);
  });

  test('dispatches the injected demo scan application action', () async {
    var actionCalls = 0;
    final container = _container(
      vehicles: _VehicleRepository([DemoFixture.vehicle]),
      history: _HistoryRepository(const []),
      settings: _SettingsRepository(DemoFixture.settings),
      demoScanAction: () => actionCalls += 1,
    );
    addTearDown(container.dispose);
    await container.read(homeControllerProvider.future);

    await container.read(homeControllerProvider.notifier).startDemoScan();

    expect(actionCalls, 1);
  });

  test('ignores duplicate demo scan actions while one is active', () async {
    var actionCalls = 0;
    final actionCompleter = Completer<void>();
    final container = _container(
      vehicles: _VehicleRepository([DemoFixture.vehicle]),
      history: _HistoryRepository(const []),
      settings: _SettingsRepository(DemoFixture.settings),
      demoScanAction: () {
        actionCalls += 1;
        return actionCompleter.future;
      },
    );
    addTearDown(container.dispose);
    await container.read(homeControllerProvider.future);
    final controller = container.read(homeControllerProvider.notifier);

    final firstAction = controller.startDemoScan();
    await controller.startDemoScan();

    expect(actionCalls, 1);
    actionCompleter.complete();
    await firstAction;
  });

  test('surfaces repository loading failures as AsyncError', () async {
    final container = _container(
      vehicles: _VehicleRepository([DemoFixture.vehicle]),
      history: _HistoryRepository(const [], error: StateError('offline')),
      settings: _SettingsRepository(DemoFixture.settings),
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(homeControllerProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(container.read(homeControllerProvider), isA<AsyncError<HomeData>>());
  });

  test('rejects non-demo records when demo mode is enabled', () async {
    final testVehicle = Vehicle(
      id: DemoFixture.vehicle.id,
      source: DataSource.test,
      manufacturer: DemoFixture.vehicle.manufacturer,
      model: DemoFixture.vehicle.model,
      variant: DemoFixture.vehicle.variant,
      profile: DemoFixture.vehicle.profile,
      lastConfirmedAtUtc: DemoFixture.vehicle.lastConfirmedAtUtc,
      createdAtUtc: DemoFixture.vehicle.createdAtUtc,
      updatedAtUtc: DemoFixture.vehicle.updatedAtUtc,
      modelYear: DemoFixture.vehicle.modelYear,
    );
    final container = _container(
      vehicles: _VehicleRepository([testVehicle]),
      history: _HistoryRepository([DemoFixture.completeScanBundle]),
      settings: _SettingsRepository(DemoFixture.settings),
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(homeControllerProvider.future),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('not classified demo'),
        ),
      ),
    );
  });
}

ProviderContainer _container({
  required VehicleRepository vehicles,
  required HistoryRepository history,
  required SettingsRepository settings,
  DemoScanAction? demoScanAction,
}) {
  return ProviderContainer(
    overrides: [
      homeVehicleRepositoryProvider.overrideWithValue(vehicles),
      homeHistoryRepositoryProvider.overrideWithValue(history),
      homeSettingsRepositoryProvider.overrideWithValue(settings),
      if (demoScanAction != null)
        demoScanActionProvider.overrideWithValue(demoScanAction),
    ],
  );
}

final class _VehicleRepository implements VehicleRepository {
  _VehicleRepository(this.vehicles);

  final List<Vehicle> vehicles;
  int listCalls = 0;
  int getCalls = 0;

  @override
  Future<Vehicle?> getVehicle(VehicleId id) async {
    getCalls += 1;
    return vehicles.where((vehicle) => vehicle.id == id).firstOrNull;
  }

  @override
  Future<List<Vehicle>> listVehicles() async {
    listCalls += 1;
    return List.unmodifiable(vehicles);
  }

  @override
  Future<void> saveVehicle(Vehicle vehicle) => throw UnimplementedError();
}

final class _HistoryRepository implements HistoryRepository {
  _HistoryRepository(this.history, {this.error});

  final List<ScanBundle> history;
  final Object? error;
  int calls = 0;

  @override
  Future<List<ScanBundle>> listHistory() async {
    calls += 1;
    if (error != null) {
      throw StateError(error.toString());
    }
    return List.unmodifiable(history);
  }
}

final class _SettingsRepository implements SettingsRepository {
  _SettingsRepository(this.settings);

  final AppSettings settings;
  int calls = 0;

  @override
  Future<AppSettings> load() async {
    calls += 1;
    return settings;
  }

  @override
  Future<void> save(AppSettings settings) => throw UnimplementedError();
}
