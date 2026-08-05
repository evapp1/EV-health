import 'package:ev_health/app/app.dart';
import 'package:ev_health/infrastructure/persistence/in_memory_onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('first launch opens Welcome onboarding', (tester) async {
    await tester.pumpWidget(
      EvHealthApp(onboardingRepository: InMemoryOnboardingRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Understand your EV battery'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      _router(tester).routeInformationProvider.value.uri.path,
      '/onboarding',
    );
  });

  testWidgets('next and back navigate through every onboarding screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      EvHealthApp(onboardingRepository: InMemoryOnboardingRepository()),
    );
    await tester.pumpAndSettle();

    await _tapAction(tester, 'Get started');
    expect(find.text('How it works'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Understand your EV battery'), findsOneWidget);

    await _tapAction(tester, 'Get started');
    await _tapAction(tester, 'Continue');
    expect(find.text('Your data stays local'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('How it works'), findsOneWidget);

    await _tapAction(tester, 'Continue');
    await _tapAction(tester, 'Continue');
    expect(find.text('Bluetooth comes next'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your data stays local'), findsOneWidget);
  });

  testWidgets('Android back returns to the previous onboarding screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      EvHealthApp(onboardingRepository: InMemoryOnboardingRepository()),
    );
    await tester.pumpAndSettle();

    await _tapAction(tester, 'Get started');
    expect(find.text('How it works'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Understand your EV battery'), findsOneWidget);
  });

  testWidgets('completion invokes Bluetooth placeholder and routes to Home', (
    tester,
  ) async {
    final repository = InMemoryOnboardingRepository();
    var bluetoothActionCount = 0;
    await tester.pumpWidget(
      EvHealthApp(
        onboardingRepository: repository,
        bluetoothOnboardingAction: () async {
          bluetoothActionCount += 1;
        },
      ),
    );
    await tester.pumpAndSettle();

    await _advanceToBluetooth(tester);
    await _tapAction(tester, 'Continue to EV Health');

    expect(bluetoothActionCount, 1);
    expect(await repository.isOnboardingComplete(), isTrue);
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(_router(tester).routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets('returning user skips onboarding', (tester) async {
    await tester.pumpWidget(
      EvHealthApp(
        onboardingRepository: InMemoryOnboardingRepository(
          initiallyComplete: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Battery health reports'), findsOneWidget);
    expect(find.text('Understand your EV battery'), findsNothing);
    expect(_router(tester).routeInformationProvider.value.uri.path, '/home');
  });

  for (final brightness in Brightness.values) {
    testWidgets('onboarding renders with the ${brightness.name} system theme', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(
        EvHealthApp(onboardingRepository: InMemoryOnboardingRepository()),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Understand your EV battery'));
      expect(Theme.of(context).brightness, brightness);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('all onboarding screens support 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: EvHealthApp(
          onboardingRepository: InMemoryOnboardingRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final action in <String>[
      'Get started',
      'Continue',
      'Continue',
      'Continue to EV Health',
    ]) {
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text(action));
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }

    expect(find.text('Battery health reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _advanceToBluetooth(WidgetTester tester) async {
  await _tapAction(tester, 'Get started');
  await _tapAction(tester, 'Continue');
  await _tapAction(tester, 'Continue');
}

Future<void> _tapAction(WidgetTester tester, String label) async {
  final action = find.text(label);
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pumpAndSettle();
}

GoRouter _router(WidgetTester tester) {
  final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  return materialApp.routerConfig! as GoRouter;
}
