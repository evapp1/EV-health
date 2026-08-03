import 'package:ev_health/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';

/// First onboarding screen explaining the EV Health purpose and scope.
class WelcomeOnboardingScreen extends StatelessWidget {
  /// Creates the welcome screen.
  const WelcomeOnboardingScreen({required this.onNext, super.key});

  /// Advances to How It Works.
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      step: 1,
      title: 'Understand your EV battery',
      body:
          'EV Health turns supported battery readings into a clear, '
          'informational report for BYD Dolphin Premium owners.',
      icon: Icons.electric_car_outlined,
      items: const [
        OnboardingItem(
          icon: Icons.chat_bubble_outline,
          title: 'Plain-English insights',
          description:
              'See conclusions first, with measurements available for context.',
        ),
        OnboardingItem(
          icon: Icons.android,
          title: 'Android and adapter required',
          description:
              'Real scans will use a compatible ELM327 Bluetooth OBD adapter.',
        ),
        OnboardingItem(
          icon: Icons.visibility_outlined,
          title: 'Informational only',
          description:
              'EV Health is not a diagnosis, safety inspection, or warranty assessment.',
        ),
      ],
      primaryLabel: 'Get started',
      onPrimary: onNext,
    );
  }
}
