import 'package:ev_health/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';

/// Explains future Bluetooth access without requesting system permission.
class BluetoothOnboardingScreen extends StatelessWidget {
  /// Creates the Bluetooth explanation screen.
  const BluetoothOnboardingScreen({
    required this.onBack,
    required this.onComplete,
    super.key,
  });

  /// Returns to Privacy.
  final VoidCallback onBack;

  /// Dispatches the injectable placeholder and completion intent.
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      step: 4,
      title: 'Bluetooth comes next',
      body:
          'EV Health will need nearby-device access to find and connect to '
          'your OBD adapter.',
      icon: Icons.bluetooth_outlined,
      items: const [
        OnboardingItem(
          icon: Icons.touch_app_outlined,
          title: 'Requested in context',
          description:
              'Android permission will be requested only when you choose to connect.',
        ),
        OnboardingItem(
          icon: Icons.lock_outline,
          title: 'No permission requested now',
          description:
              'This onboarding step only explains the future connection flow.',
        ),
        OnboardingItem(
          icon: Icons.home_outlined,
          title: 'Continue to Home',
          description:
              'Adapter discovery and system permissions are implemented in later tasks.',
        ),
      ],
      primaryLabel: 'Continue to EV Health',
      onPrimary: onComplete,
      onBack: onBack,
    );
  }
}
