import 'package:ev_health/infrastructure/persistence/in_memory_onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completion remains available for the repository lifetime', () async {
    final repository = InMemoryOnboardingRepository();

    expect(await repository.isOnboardingComplete(), isFalse);

    await repository.markOnboardingComplete();

    expect(await repository.isOnboardingComplete(), isTrue);
  });
}
