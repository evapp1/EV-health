import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal nested route used to establish Settings back navigation.
class SettingsAboutScreen extends StatelessWidget {
  /// Creates the About and legal placeholder.
  const SettingsAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About and legal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Text(
          'App information and legal documents will appear here.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
