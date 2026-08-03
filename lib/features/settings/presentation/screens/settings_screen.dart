import 'package:ev_health/app/navigation/route_names.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Minimal Settings destination for the EV Health shell.
class SettingsScreen extends StatelessWidget {
  /// Creates the Settings placeholder.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'App preferences will appear here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton.icon(
              key: const Key('settings-about-route'),
              onPressed: () => context.goNamed(AppRouteNames.settingsAbout),
              icon: const Icon(Icons.info_outline),
              label: const Text('About and legal'),
            ),
          ],
        ),
      ),
    );
  }
}
