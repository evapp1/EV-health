import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal Home destination for the EV Health shell.
class HomeScreen extends StatelessWidget {
  /// Creates the Home placeholder.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EV Health')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Battery health reports',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Clear battery insights, stored locally on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
