import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/features/home/presentation/screens/app_launch_screen.dart';
import 'package:flutter/material.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatelessWidget {
  /// Creates the EV Health application.
  const EvHealthApp({super.key, this.themeMode = ThemeMode.system});

  /// Selects light, dark, or the device system theme.
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const AppLaunchScreen(),
    );
  }
}
