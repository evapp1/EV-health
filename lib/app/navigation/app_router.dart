import 'package:ev_health/app/navigation/app_shell.dart';
import 'package:ev_health/app/navigation/route_names.dart';
import 'package:ev_health/features/history/presentation/screens/history_screen.dart';
import 'package:ev_health/features/home/presentation/screens/home_screen.dart';
import 'package:ev_health/features/reports/presentation/screens/reports_screen.dart';
import 'package:ev_health/features/settings/presentation/screens/settings_about_screen.dart';
import 'package:ev_health/features/settings/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

/// Creates the application router and its state-preserving root branches.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutePaths.home,
    routes: <RouteBase>[
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
                builder: (context, state) => const HomeScreen(),
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
