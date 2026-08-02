import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/features/home/presentation/screens/app_launch_screen.dart';
import 'package:flutter/material.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatelessWidget {
  /// Creates the EV Health application.
  const EvHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Keep the approved follow-system policy explicit at the app root.
      // ignore: avoid_redundant_argument_values
      themeMode: ThemeMode.system,
      home: const AppLaunchScreen(),
    );
  }
}
