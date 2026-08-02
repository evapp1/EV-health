import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The placeholder screen shown when EV Health launches.
class AppLaunchScreen extends StatelessWidget {
  /// Creates the application launch screen.
  const AppLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('EV Health')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Battery health reports', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.small),
              const Text(
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
