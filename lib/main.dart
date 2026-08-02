import 'package:flutter/material.dart';

/// Starts the EV Health application.
void main() {
  runApp(const EvHealthApp());
}

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

/// The initial screen shown when EV Health launches.
class AppLaunchScreen extends StatelessWidget {
  /// Creates the application launch screen.
  const AppLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EV Health')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Battery health reports'),
              SizedBox(height: 8),
              Text(
                'Clear battery insights, stored locally on your device.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
