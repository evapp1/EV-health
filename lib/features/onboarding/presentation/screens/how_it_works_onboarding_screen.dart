import 'package:ev_health/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';

/// Explains the future connection, scan, and report sequence.
class HowItWorksOnboardingScreen extends StatelessWidget {
  /// Creates the How It Works screen.
  const HowItWorksOnboardingScreen({
    required this.onBack,
    required this.onNext,
    super.key,
  });

  /// Returns to Welcome.
  final VoidCallback onBack;

  /// Advances to Privacy.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      step: 2,
      title: 'How it works',
      body:
          'A guided, read-only flow keeps the technical work out of your way.',
      icon: Icons.route_outlined,
      items: const [
        OnboardingItem(
          icon: Icons.bluetooth_searching,
          title: '1. Connect',
          description:
              'Choose a compatible Bluetooth OBD adapter while parked.',
        ),
        OnboardingItem(
          icon: Icons.battery_charging_full_outlined,
          title: '2. Scan',
          description:
              'EV Health will read supported battery data without changing the vehicle.',
        ),
        OnboardingItem(
          icon: Icons.description_outlined,
          title: '3. Understand',
          description:
              'Review a timestamped report with clear sources and limitations.',
        ),
      ],
      primaryLabel: 'Continue',
      onPrimary: onNext,
      onBack: onBack,
    );
  }
}
