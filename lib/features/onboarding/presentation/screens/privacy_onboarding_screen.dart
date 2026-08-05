import 'package:ev_health/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';

/// Explains local-first storage and data minimisation.
class PrivacyOnboardingScreen extends StatelessWidget {
  /// Creates the Privacy screen.
  const PrivacyOnboardingScreen({
    required this.onBack,
    required this.onNext,
    super.key,
  });

  /// Returns to How It Works.
  final VoidCallback onBack;

  /// Advances to the Bluetooth explanation.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      step: 3,
      title: 'Your data stays local',
      body:
          'EV Health is designed to work offline. You choose when a report '
          'leaves your device.',
      icon: Icons.privacy_tip_outlined,
      items: const [
        OnboardingItem(
          icon: Icons.phone_android,
          title: 'Stored on this device',
          description:
              'Future scans and reports will be kept in app-controlled local storage.',
        ),
        OnboardingItem(
          icon: Icons.location_off_outlined,
          title: 'No location tracking',
          description:
              'EV Health does not collect precise or background location.',
        ),
        OnboardingItem(
          icon: Icons.badge_outlined,
          title: 'Identifiers minimised',
          description:
              'Raw VIN and Bluetooth hardware addresses are not stored or shown.',
        ),
      ],
      primaryLabel: 'Continue',
      onPrimary: onNext,
      onBack: onBack,
    );
  }
}
