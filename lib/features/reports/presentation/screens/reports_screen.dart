import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal Reports destination for the EV Health shell.
class ReportsScreen extends StatelessWidget {
  /// Creates the Reports placeholder.
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Text(
          'Reports generated from saved scans will appear here.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
