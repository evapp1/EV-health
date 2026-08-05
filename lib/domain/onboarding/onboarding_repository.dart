/// Stores whether the user has completed the first-use onboarding flow.
abstract interface class OnboardingRepository {
  /// Returns whether onboarding has been completed.
  Future<bool> isOnboardingComplete();

  /// Records that onboarding has been completed.
  Future<void> markOnboardingComplete();
}
