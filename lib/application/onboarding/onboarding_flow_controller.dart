import 'package:ev_health/domain/onboarding/onboarding_repository.dart';

/// Injectable action that stands in for the future Bluetooth permission flow.
typedef BluetoothOnboardingAction = Future<void> Function();

/// Ordered steps in the first-use onboarding flow.
enum OnboardingStep {
  /// Product introduction.
  welcome,

  /// Connection, scan, and report explanation.
  howItWorks,

  /// Local-first privacy explanation.
  privacy,

  /// Contextual Bluetooth access explanation.
  bluetooth,
}

/// Application-level destinations produced by onboarding user intents.
enum OnboardingDestination {
  /// Welcome destination.
  welcome,

  /// How It Works destination.
  howItWorks,

  /// Privacy destination.
  privacy,

  /// Bluetooth explanation destination.
  bluetooth,

  /// Main navigation shell Home destination.
  home,
}

/// Resolves startup and coordinates onboarding without depending on widgets.
final class OnboardingFlowController {
  /// Creates the controller from its repository and placeholder Bluetooth action.
  OnboardingFlowController(this._repository, this._bluetoothAction);

  final OnboardingRepository _repository;
  final BluetoothOnboardingAction _bluetoothAction;
  bool _isCompleting = false;

  /// Chooses the initial application destination from stored completion state.
  Future<OnboardingDestination> resolveStartupDestination() async {
    return await _repository.isOnboardingComplete()
        ? OnboardingDestination.home
        : OnboardingDestination.welcome;
  }

  /// Returns the next destination for a non-final onboarding step.
  OnboardingDestination nextFrom(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => OnboardingDestination.howItWorks,
      OnboardingStep.howItWorks => OnboardingDestination.privacy,
      OnboardingStep.privacy => OnboardingDestination.bluetooth,
      OnboardingStep.bluetooth => throw StateError(
        'Complete the Bluetooth step with completeOnboarding().',
      ),
    };
  }

  /// Returns the previous destination, or null when already at the first step.
  OnboardingDestination? backFrom(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => null,
      OnboardingStep.howItWorks => OnboardingDestination.welcome,
      OnboardingStep.privacy => OnboardingDestination.howItWorks,
      OnboardingStep.bluetooth => OnboardingDestination.privacy,
    };
  }

  /// Runs the injected Bluetooth placeholder before recording completion.
  Future<OnboardingDestination?> completeOnboarding() async {
    if (_isCompleting) {
      return null;
    }

    _isCompleting = true;
    try {
      await _bluetoothAction();
      await _repository.markOnboardingComplete();
      return OnboardingDestination.home;
    } finally {
      _isCompleting = false;
    }
  }
}
