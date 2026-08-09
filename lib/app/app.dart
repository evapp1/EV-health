import 'dart:async';

import 'package:ev_health/app/navigation/app_router.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/application/adapter_discovery/adapter_discovery_controller.dart';
import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/application/onboarding/onboarding_flow_controller.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_configuration.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_controller.dart';
import 'package:ev_health/application/vehicle_confirmation/vehicle_confirmation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/onboarding/onboarding_repository.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/domain/repositories/settings_repository.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_history_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_scan_progress_coordinator.dart';
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
    this.vehicleConfirmationRepository,
    this.confirmVehicleAction,
    this.exitUnsupportedVehicleAction,
    this.scanPreparationConfiguration,
    this.startScanAction,
    this.demoScanScenario = DemoScanScenario.complete,
    this.initialLocation,
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

  /// Overrides the typed vehicle source for confirmation, primarily in tests.
  final VehicleRepository? vehicleConfirmationRepository;

  /// Overrides the application callback for supported confirmation.
  final ConfirmVehicleAction? confirmVehicleAction;

  /// Overrides the application callback for the unsupported safe exit.
  final ExitUnsupportedVehicleAction? exitUnsupportedVehicleAction;

  /// Overrides profile preparation configuration, primarily for tests.
  final ScanPreparationConfiguration? scanPreparationConfiguration;

  /// Overrides the explicit Start Scan application hand-off.
  final StartScanAction? startScanAction;

  /// Deterministic fictional outcome selected by development/QA or tests.
  final DemoScanScenario demoScanScenario;

  /// Optional development/QA initial route; production entry points omit it.
  final String? initialLocation;

  @override
  State<EvHealthApp> createState() => _EvHealthAppState();
}

class _EvHealthAppState extends State<EvHealthApp> {
  GoRouter? _router;
  late final VehicleRepository _homeVehicleRepository;
  late final HistoryRepository _homeHistoryRepository;
  late final SettingsRepository _homeSettingsRepository;
  late final VehicleRepository _vehicleConfirmationRepository;

  @override
  void initState() {
    super.initState();
    _homeVehicleRepository =
        widget.homeVehicleRepository ?? DemoVehicleRepository();
    _homeHistoryRepository =
        widget.homeHistoryRepository ?? DemoHistoryRepository();
    _homeSettingsRepository =
        widget.homeSettingsRepository ?? const DemoSettingsRepository();
    _vehicleConfirmationRepository =
        widget.vehicleConfirmationRepository ?? _homeVehicleRepository;
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
      scanProgressCoordinatorFactory: () =>
          DemoScanProgressCoordinator(scenario: widget.demoScanScenario),
      startScanAction: widget.startScanAction,
      initialLocationOverride: widget.initialLocation,
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
          vehicleConfirmationRepositoryProvider.overrideWithValue(
            _vehicleConfirmationRepository,
          ),
          if (widget.confirmVehicleAction != null)
            confirmVehicleActionProvider.overrideWithValue(
              widget.confirmVehicleAction!,
            ),
          if (widget.exitUnsupportedVehicleAction != null)
            exitUnsupportedVehicleActionProvider.overrideWithValue(
              widget.exitUnsupportedVehicleAction!,
            ),
          scanPreparationConfigurationProvider.overrideWithValue(
            widget.scanPreparationConfiguration ??
                _defaultScanPreparationConfiguration,
          ),
          if (widget.startScanAction != null)
            startScanActionProvider.overrideWithValue(widget.startScanAction!),
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
        vehicleConfirmationRepositoryProvider.overrideWithValue(
          _vehicleConfirmationRepository,
        ),
        if (widget.confirmVehicleAction != null)
          confirmVehicleActionProvider.overrideWithValue(
            widget.confirmVehicleAction!,
          ),
        if (widget.exitUnsupportedVehicleAction != null)
          exitUnsupportedVehicleActionProvider.overrideWithValue(
            widget.exitUnsupportedVehicleAction!,
          ),
        scanPreparationConfigurationProvider.overrideWithValue(
          widget.scanPreparationConfiguration ??
              _defaultScanPreparationConfiguration,
        ),
        if (widget.startScanAction != null)
          startScanActionProvider.overrideWithValue(widget.startScanAction!),
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

  static final _defaultScanPreparationConfiguration =
      ScanPreparationConfiguration([
        VehiclePreparationInstructions(
          profile: DemoFixture.profile,
          source: DataSource.demo,
          powerStateInstruction: 'Keep the vehicle switched on and ready.',
          basis: PreparationInstructionBasis.demoAssumption,
        ),
      ]);
}
