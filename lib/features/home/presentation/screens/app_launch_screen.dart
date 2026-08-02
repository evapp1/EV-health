import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// The placeholder screen shown when EV Health launches.
class AppLaunchScreen extends StatelessWidget {
  /// Creates the application launch screen.
  const AppLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('EV Health')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Battery health reports', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Clear battery insights, stored locally on your device.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
