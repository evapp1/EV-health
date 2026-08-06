import 'dart:async';

import 'package:ev_health/app/navigation/app_router.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/application/adapter_discovery/adapter_discovery_controller.dart';
import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/application/onboarding/onboarding_flow_controller.dart';
import 'package:ev_health/domain/onboarding/onboarding_repository.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_history_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_settings_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_vehicle_repository.dart';
import 'package:ev_health/infrastructure/persistence/in_memory_onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatefulWidget {
  /// Creates the EV Health application.
  const EvHealthApp({
    this.onboardingRepository,
    this.bluetoothOnboardingAction,
    this.homeVehicleRepository,
    this.homeHistoryRepository,
    this.homeSettingsRepository,
    this.demoScanAction,
    this.adapterDiscoveryInitialState,
    this.adapterDiscoveryRetryAction,
    this.mockAdapterSelectionAction,
    super.key,
  });

  /// Overrides process-local onboarding state, primarily for tests.
  final OnboardingRepository? onboardingRepository;

  /// Overrides the no-op Bluetooth placeholder action.
  final BluetoothOnboardingAction? bluetoothOnboardingAction;

  /// Overrides the Home vehicle port, primarily for tests.
  final VehicleRepository? homeVehicleRepository;

  /// Overrides the Home history port, primarily for tests.
  final HistoryRepository? homeHistoryRepository;

  /// Overrides the Home settings port, primarily for tests.
  final SettingsRepository? homeSettingsRepository;

  /// Injects the application-level placeholder that starts demo scanning.
  final DemoScanAction? demoScanAction;

  /// Overrides the initial simulated adapter discovery state.
  final AdapterDiscoveryState? adapterDiscoveryInitialState;

  /// Overrides simulated discovery retry behaviour.
  final AdapterDiscoveryRetryAction? adapterDiscoveryRetryAction;

  /// Overrides fictional adapter selection behaviour.
  final MockAdapterSelectionAction? mockAdapterSelectionAction;

  @override
  State<EvHealthApp> createState() => _EvHealthAppState();
}

class _EvHealthAppState extends State<EvHealthApp> {
  GoRouter? _router;
  late final VehicleRepository _homeVehicleRepository;
  late final HistoryRepository _homeHistoryRepository;
  late final SettingsRepository _homeSettingsRepository;

  @override
  void initState() {
    super.initState();
    _homeVehicleRepository =
        widget.homeVehicleRepository ?? DemoVehicleRepository();
    _homeHistoryRepository =
        widget.homeHistoryRepository ?? DemoHistoryRepository();
    _homeSettingsRepository =
        widget.homeSettingsRepository ?? const DemoSettingsRepository();
    unawaited(_initializeRouter());
  }

  Future<void> _initializeRouter() async {
    final onboarding = OnboardingFlowController(
      widget.onboardingRepository ?? InMemoryOnboardingRepository(),
      widget.bluetoothOnboardingAction ?? _defaultBluetoothAction,
    );
    final router = await createAppRouter(
      onboarding,
      homeDemoScanAction: widget.demoScanAction,
    );

    if (!mounted) {
      router.dispose();
      return;
    }

    setState(() => _router = router);
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      return ProviderScope(
        overrides: [
          homeVehicleRepositoryProvider.overrideWithValue(
            _homeVehicleRepository,
          ),
          homeHistoryRepositoryProvider.overrideWithValue(
            _homeHistoryRepository,
          ),
          homeSettingsRepositoryProvider.overrideWithValue(
            _homeSettingsRepository,
          ),
          adapterDiscoveryInitialStateProvider.overrideWithValue(
            widget.adapterDiscoveryInitialState ??
                const AdapterDiscoverySearching(),
          ),
          if (widget.adapterDiscoveryRetryAction != null)
            adapterDiscoveryRetryActionProvider.overrideWithValue(
              widget.adapterDiscoveryRetryAction!,
            ),
          if (widget.mockAdapterSelectionAction != null)
            mockAdapterSelectionActionProvider.overrideWithValue(
              widget.mockAdapterSelectionAction!,
            ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EV Health',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      );
    }

    return ProviderScope(
      overrides: [
        homeVehicleRepositoryProvider.overrideWithValue(_homeVehicleRepository),
        homeHistoryRepositoryProvider.overrideWithValue(_homeHistoryRepository),
        homeSettingsRepositoryProvider.overrideWithValue(
          _homeSettingsRepository,
        ),
        adapterDiscoveryInitialStateProvider.overrideWithValue(
          widget.adapterDiscoveryInitialState ??
              const AdapterDiscoverySearching(),
        ),
        if (widget.adapterDiscoveryRetryAction != null)
          adapterDiscoveryRetryActionProvider.overrideWithValue(
            widget.adapterDiscoveryRetryAction!,
          ),
        if (widget.mockAdapterSelectionAction != null)
          mockAdapterSelectionActionProvider.overrideWithValue(
            widget.mockAdapterSelectionAction!,
          ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'EV Health',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Keep the approved follow-system policy explicit at the app root.
        // ignore: avoid_redundant_argument_values
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }

  static Future<void> _defaultBluetoothAction() async {}
}
