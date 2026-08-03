import 'package:ev_health/app/navigation/app_router.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The root widget for EV Health.
class EvHealthApp extends StatefulWidget {
  /// Creates the EV Health application.
  const EvHealthApp({super.key});

  @override
  State<EvHealthApp> createState() => _EvHealthAppState();
}

class _EvHealthAppState extends State<EvHealthApp> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EV Health',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Keep the approved follow-system policy explicit at the app root.
      // ignore: avoid_redundant_argument_values
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
