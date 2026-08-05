import 'dart:async';

import 'package:ev_health/app/navigation/app_router.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/application/onboarding/onboarding_flow_controller.dart';
import 'package:ev_health/domain/onboarding/onboarding_repository.dart';
import 'package:ev_health/infrastructure/persistence/in_memory_onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatefulWidget {
  /// Creates the EV Health application.
  const EvHealthApp({
    this.onboardingRepository,
    this.bluetoothOnboardingAction,
    super.key,
  });

  /// Overrides process-local onboarding state, primarily for tests.
  final OnboardingRepository? onboardingRepository;

  /// Overrides the no-op Bluetooth placeholder action.
  final BluetoothOnboardingAction? bluetoothOnboardingAction;

  @override
  State<EvHealthApp> createState() => _EvHealthAppState();
}

class _EvHealthAppState extends State<EvHealthApp> {
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeRouter());
  }

  Future<void> _initializeRouter() async {
    final onboarding = OnboardingFlowController(
      widget.onboardingRepository ?? InMemoryOnboardingRepository(),
      widget.bluetoothOnboardingAction ?? _defaultBluetoothAction,
    );
    final router = await createAppRouter(onboarding);

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
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EV Health',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(body: SizedBox.shrink()),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Keep the approved follow-system policy explicit at the app root.
      // ignore: avoid_redundant_argument_values
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }

  static Future<void> _defaultBluetoothAction() async {}
}
