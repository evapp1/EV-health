import 'package:flutter/material.dart';

/// The placeholder screen shown when EV Health launches.
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
