import 'package:ev_health/domain/onboarding/onboarding_repository.dart';

/// Process-local onboarding storage used until settings persistence is added.
final class InMemoryOnboardingRepository implements OnboardingRepository {
  /// Creates an in-memory repository with an optional initial completion state.
  InMemoryOnboardingRepository({bool initiallyComplete = false})
    : _isComplete = initiallyComplete;

  bool _isComplete;

  @override
  Future<bool> isOnboardingComplete() async => _isComplete;

  @override
  Future<void> markOnboardingComplete() async {
    _isComplete = true;
  }
}
