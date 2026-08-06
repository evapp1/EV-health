import 'package:ev_health/app/navigation/app_shell.dart';
import 'package:ev_health/app/navigation/route_names.dart';
import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/application/onboarding/onboarding_flow_controller.dart';
import 'package:ev_health/features/adapter_discovery/presentation/screens/adapter_discovery_screen.dart';
import 'package:ev_health/features/history/presentation/screens/history_screen.dart';
import 'package:ev_health/features/home/presentation/screens/home_screen.dart';
import 'package:ev_health/features/onboarding/presentation/screens/bluetooth_onboarding_screen.dart';
import 'package:ev_health/features/onboarding/presentation/screens/how_it_works_onboarding_screen.dart';
import 'package:ev_health/features/onboarding/presentation/screens/privacy_onboarding_screen.dart';
import 'package:ev_health/features/onboarding/presentation/screens/welcome_onboarding_screen.dart';
import 'package:ev_health/features/reports/presentation/screens/reports_screen.dart';
import 'package:ev_health/features/settings/presentation/screens/settings_about_screen.dart';
import 'package:ev_health/features/settings/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

/// Creates the application router and its state-preserving root branches.
Future<GoRouter> createAppRouter(
  OnboardingFlowController onboarding, {
  DemoScanAction? homeDemoScanAction,
}) async {
  final startupDestination = await onboarding.resolveStartupDestination();

  return GoRouter(
    initialLocation: _pathFor(startupDestination),
    routes: <RouteBase>[
      GoRoute(
        name: AppRouteNames.onboardingWelcome,
        path: AppRoutePaths.onboardingWelcome,
        builder: (context, state) => WelcomeOnboardingScreen(
          onNext: () => context.push(
            _pathFor(onboarding.nextFrom(OnboardingStep.welcome)),
          ),
        ),
      ),
      GoRoute(
        name: AppRouteNames.onboardingHowItWorks,
        path: AppRoutePaths.onboardingHowItWorks,
        builder: (context, state) => HowItWorksOnboardingScreen(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                _pathFor(onboarding.backFrom(OnboardingStep.howItWorks)!),
              );
            }
          },
          onNext: () => context.push(
            _pathFor(onboarding.nextFrom(OnboardingStep.howItWorks)),
          ),
        ),
      ),
      GoRoute(
        name: AppRouteNames.onboardingPrivacy,
        path: AppRoutePaths.onboardingPrivacy,
        builder: (context, state) => PrivacyOnboardingScreen(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                _pathFor(onboarding.backFrom(OnboardingStep.privacy)!),
              );
            }
          },
          onNext: () => context.push(
            _pathFor(onboarding.nextFrom(OnboardingStep.privacy)),
          ),
        ),
      ),
      GoRoute(
        name: AppRouteNames.onboardingBluetooth,
        path: AppRoutePaths.onboardingBluetooth,
        builder: (context, state) => BluetoothOnboardingScreen(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(
                _pathFor(onboarding.backFrom(OnboardingStep.bluetooth)!),
              );
            }
          },
          onComplete: () async {
            final destination = await onboarding.completeOnboarding();
            if (context.mounted && destination != null) {
              context.go(_pathFor(destination));
            }
          },
        ),
      ),
      GoRoute(
        name: AppRouteNames.adapterDiscovery,
        path: AppRoutePaths.adapterDiscovery,
        builder: (context, state) => AdapterDiscoveryScreen(
          onBack: () => context.go(AppRoutePaths.home),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            isAtBranchRoot: AppRoutePaths.rootDestinations.contains(
              state.matchedLocation,
            ),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteNames.home,
                path: AppRoutePaths.home,
                builder: (context, state) => HomeScreen(
                  onDemoScan:
                      homeDemoScanAction ??
                      () => context.go(AppRoutePaths.adapterDiscovery),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteNames.history,
                path: AppRoutePaths.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteNames.reports,
                path: AppRoutePaths.reports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteNames.settings,
                path: AppRoutePaths.settings,
                builder: (context, state) => const SettingsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRouteNames.settingsAbout,
                    path: 'about',
                    builder: (context, state) => const SettingsAboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String _pathFor(OnboardingDestination destination) {
  return switch (destination) {
    OnboardingDestination.welcome => AppRoutePaths.onboardingWelcome,
    OnboardingDestination.howItWorks => AppRoutePaths.onboardingHowItWorks,
    OnboardingDestination.privacy => AppRoutePaths.onboardingPrivacy,
    OnboardingDestination.bluetooth => AppRoutePaths.onboardingBluetooth,
    OnboardingDestination.home => AppRoutePaths.home,
  };
}
