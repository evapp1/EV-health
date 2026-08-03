import 'dart:async';

import 'package:ev_health/application/onboarding/onboarding_flow_controller.dart';
import 'package:ev_health/infrastructure/persistence/in_memory_onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first launch resolves to Welcome', () async {
    final controller = _controller(InMemoryOnboardingRepository());

    expect(
      await controller.resolveStartupDestination(),
      OnboardingDestination.welcome,
    );
  });

  test('completed onboarding resolves to Home', () async {
    final controller = _controller(
      InMemoryOnboardingRepository(initiallyComplete: true),
    );

    expect(
      await controller.resolveStartupDestination(),
      OnboardingDestination.home,
    );
  });

  test('next and back follow the four approved steps', () {
    final controller = _controller(InMemoryOnboardingRepository());

    expect(controller.backFrom(OnboardingStep.welcome), isNull);
    expect(
      controller.nextFrom(OnboardingStep.welcome),
      OnboardingDestination.howItWorks,
    );
    expect(
      controller.backFrom(OnboardingStep.howItWorks),
      OnboardingDestination.welcome,
    );
    expect(
      controller.nextFrom(OnboardingStep.howItWorks),
      OnboardingDestination.privacy,
    );
    expect(
      controller.backFrom(OnboardingStep.privacy),
      OnboardingDestination.howItWorks,
    );
    expect(
      controller.nextFrom(OnboardingStep.privacy),
      OnboardingDestination.bluetooth,
    );
    expect(
      controller.backFrom(OnboardingStep.bluetooth),
      OnboardingDestination.privacy,
    );
  });

  test('Bluetooth placeholder runs before completion is stored', () async {
    final calls = <String>[];
    final repository = InMemoryOnboardingRepository();
    final controller = OnboardingFlowController(repository, () async {
      calls.add('bluetooth');
      expect(await repository.isOnboardingComplete(), isFalse);
    });

    final destination = await controller.completeOnboarding();

    expect(destination, OnboardingDestination.home);
    expect(calls, ['bluetooth']);
    expect(await repository.isOnboardingComplete(), isTrue);
  });

  test('a failed placeholder action does not record completion', () async {
    final repository = InMemoryOnboardingRepository();
    final controller = OnboardingFlowController(
      repository,
      () async => throw StateError('placeholder failed'),
    );

    await expectLater(controller.completeOnboarding(), throwsStateError);

    expect(await repository.isOnboardingComplete(), isFalse);
  });

  test('duplicate completion is ignored while the action is running', () async {
    final actionCompleter = Completer<void>();
    var callCount = 0;
    final controller = OnboardingFlowController(
      InMemoryOnboardingRepository(),
      () {
        callCount += 1;
        return actionCompleter.future;
      },
    );

    final firstCompletion = controller.completeOnboarding();
    final duplicateDestination = await controller.completeOnboarding();
    actionCompleter.complete();

    expect(duplicateDestination, isNull);
    expect(await firstCompletion, OnboardingDestination.home);
    expect(callCount, 1);
  });
}

OnboardingFlowController _controller(InMemoryOnboardingRepository repository) {
  return OnboardingFlowController(repository, () async {});
}
