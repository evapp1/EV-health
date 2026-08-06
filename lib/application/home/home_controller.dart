import 'dart:async';

import 'package:ev_health/domain/models/app_settings.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/scan_bundle.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable application-level placeholder for starting the demo scan flow.
typedef DemoScanAction = FutureOr<void> Function();

/// Vehicle repository selected by the app composition root.
final homeVehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  throw StateError('Home VehicleRepository has not been configured.');
});

/// History repository selected by the app composition root.
final homeHistoryRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw StateError('Home HistoryRepository has not been configured.');
});

/// Settings repository selected by the app composition root.
final homeSettingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw StateError('Home SettingsRepository has not been configured.');
});

/// Application-level demo scan intent selected by the app composition root.
final demoScanActionProvider = Provider<DemoScanAction>((ref) {
  return () {};
});

/// Loads and coordinates the state displayed by Home.
final homeControllerProvider = AsyncNotifierProvider<HomeController, HomeData>(
  HomeController.new,
);

/// Repository-backed immutable state required by Home.
final class HomeData {
  /// Creates a loaded Home state.
  HomeData({
    required this.settings,
    required this.vehicle,
    required Iterable<ScanBundle> history,
  }) : history = List.unmodifiable(history);

  /// Current settings snapshot.
  final AppSettings settings;

  /// Current supported vehicle.
  final Vehicle vehicle;

  /// Finalized history for the current vehicle, newest first.
  final List<ScanBundle> history;

  /// Whether Home is operating inside the explicitly disclosed demo flow.
  bool get isDemoMode => settings.demoModeEnabled;

  /// Latest finalized scan, or `null` for the approved no-scan state.
  ScanBundle? get latestScan => history.firstOrNull;
}

/// Application controller for repository-backed Home state and user intents.
final class HomeController extends AsyncNotifier<HomeData> {
  bool _isStartingDemoScan = false;

  @override
  Future<HomeData> build() => _load();

  /// Reloads Home after a recoverable repository failure.
  Future<void> reload() async {
    state = const AsyncLoading<HomeData>();
    state = await AsyncValue.guard(_load);
  }

  /// Dispatches the primary demo scan intent without implementing scan flow.
  Future<void> startDemoScan() async {
    final home = state.value;
    if (home == null || !home.isDemoMode) {
      throw StateError('The demo scan action requires loaded demo Home data.');
    }
    if (_isStartingDemoScan) {
      return;
    }

    _isStartingDemoScan = true;
    try {
      await ref.read(demoScanActionProvider)();
    } finally {
      _isStartingDemoScan = false;
    }
  }

  Future<HomeData> _load() async {
    final settings = await ref.read(homeSettingsRepositoryProvider).load();
    final vehicleRepository = ref.read(homeVehicleRepositoryProvider);
    final configuredVehicleId = settings.lastVehicleId;
    final configuredVehicle = configuredVehicleId == null
        ? null
        : await vehicleRepository.getVehicle(configuredVehicleId);
    final vehicle =
        configuredVehicle ??
        (await vehicleRepository.listVehicles()).firstOrNull;

    if (vehicle == null) {
      throw StateError('No supported vehicle is available for Home.');
    }

    final history = await ref.read(homeHistoryRepositoryProvider).listHistory();
    final vehicleHistory =
        history
            .where((bundle) => bundle.scan.vehicleId == vehicle.id)
            .toList(growable: false)
          ..sort(
            (left, right) =>
                right.scan.scannedAtUtc.compareTo(left.scan.scannedAtUtc),
          );

    if (!settings.demoModeEnabled) {
      throw StateError('This Home implementation requires demo mode.');
    }
    _requireDemoData(settings, vehicle, vehicleHistory);

    return HomeData(
      settings: settings,
      vehicle: vehicle,
      history: vehicleHistory,
    );
  }

  static void _requireDemoData(
    AppSettings settings,
    Vehicle vehicle,
    Iterable<ScanBundle> history,
  ) {
    final allDemo =
        settings.source == DataSource.demo &&
        vehicle.source == DataSource.demo &&
        history.every((bundle) => bundle.source == DataSource.demo);
    if (!allDemo) {
      throw StateError('Demo Home received data that is not classified demo.');
    }
  }
}
