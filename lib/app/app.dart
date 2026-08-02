import 'package:ev_health/features/home/presentation/screens/app_launch_screen.dart';
import 'package:flutter/material.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatelessWidget {
  /// Creates the EV Health application.
  const EvHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      home: AppLaunchScreen(),
    );
  }
}
