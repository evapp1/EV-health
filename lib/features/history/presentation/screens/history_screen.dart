import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal History destination for the EV Health shell.
class HistoryScreen extends StatelessWidget {
  /// Creates the History placeholder.
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan history')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Text(
          'Your completed and partial scans will appear here.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
