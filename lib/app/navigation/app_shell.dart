import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hosts the stateful root navigators and approved primary destinations.
class AppShell extends StatelessWidget {
  /// Creates the EV Health navigation shell.
  const AppShell({
    required this.navigationShell,
    required this.isAtBranchRoot,
    super.key,
  });

  /// The stateful shell supplied by go_router.
  final StatefulNavigationShell navigationShell;

  /// Whether the visible route is the root of its current branch.
  final bool isAtBranchRoot;

  @override
  Widget build(BuildContext context) {
    final isHomeRoot =
        isAtBranchRoot && navigationShell.currentIndex == _homeIndex;

    return PopScope<Object?>(
      canPop: !isAtBranchRoot || isHomeRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isAtBranchRoot) {
          navigationShell.goBranch(_homeIndex);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _selectDestination,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
              tooltip: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description),
              label: 'Reports',
              tooltip: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _selectDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _homeIndex = 0;
}
