import 'package:ev_health/app/app.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('initial route opens Home', (tester) async {
    await tester.pumpWidget(const EvHealthApp());
    await tester.pumpAndSettle();

    expect(find.text('EV Health'), findsOneWidget);
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
    expect(_router(tester).routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets('bottom navigation opens every approved root destination', (
    tester,
  ) async {
    await tester.pumpWidget(const EvHealthApp());
    await tester.pumpAndSettle();

    const destinations = <(String, String, int)>[
      ('History', 'Scan history', 1),
      ('Reports', 'Saved reports', 2),
      ('Settings', 'App preferences will appear here.', 3),
      ('Home', 'Battery health reports', 0),
    ];

    for (final destination in destinations) {
      await tester.tap(find.text(destination.$1));
      await tester.pumpAndSettle();

      expect(find.text(destination.$2), findsOneWidget);
      expect(_navigationBar(tester).selectedIndex, destination.$3);
    }
  });

  testWidgets('a branch restores its nested navigation state', (tester) async {
    await tester.pumpWidget(const EvHealthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-about-route')));
    await tester.pumpAndSettle();
    expect(
      find.text('App information and legal documents will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(
      find.text('App information and legal documents will appear here.'),
      findsOneWidget,
    );
    expect(_navigationBar(tester).selectedIndex, 3);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('App preferences will appear here.'), findsOneWidget);
  });

  testWidgets('Android back returns nested routes to their parent', (
    tester,
  ) async {
    await tester.pumpWidget(const EvHealthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-about-route')));
    await tester.pumpAndSettle();
    expect(_router(tester).canPop(), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('App preferences will appear here.'), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 3);
  });

  testWidgets('Android back returns a non-Home root to Home before exit', (
    tester,
  ) async {
    await tester.pumpWidget(const EvHealthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(_router(tester).canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Battery health reports'), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
    expect(_router(tester).canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(_router(tester).canPop(), isFalse);
  });

  for (final testCase in <(Brightness, EvHealthColors)>[
    (Brightness.light, EvHealthColors.light),
    (Brightness.dark, EvHealthColors.dark),
  ]) {
    testWidgets('navigation shell uses the ${testCase.$1.name} system theme', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = testCase.$1;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const EvHealthApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);
      expect(materialApp.theme, same(AppTheme.light));
      expect(materialApp.darkTheme, same(AppTheme.dark));
      _expectHomeTheme(tester, testCase.$2);
    });
  }

  testWidgets('all root destinations render at 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: EvHealthApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['History', 'Reports', 'Settings', 'Home']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$label must not overflow',
      );
    }
  });
}

NavigationBar _navigationBar(WidgetTester tester) {
  return tester.widget<NavigationBar>(find.byType(NavigationBar));
}

GoRouter _router(WidgetTester tester) {
  final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
  return materialApp.routerConfig! as GoRouter;
}

void _expectHomeTheme(WidgetTester tester, EvHealthColors colors) {
  final homeContext = tester.element(find.text('Battery health reports'));
  final theme = Theme.of(homeContext);
  final title = tester.widget<Text>(find.text('Battery health reports'));
  final body = tester.widget<Text>(
    find.text('Clear battery insights, stored locally on your device.'),
  );

  expect(theme.brightness, colors.brightness);
  expect(theme.scaffoldBackgroundColor, colors.surface);
  expect(theme.appBarTheme.backgroundColor, colors.surface);
  expect(theme.appBarTheme.foregroundColor, colors.textPrimary);
  expect(title.style!.color, colors.textPrimary);
  expect(body.style!.color, colors.textPrimary);
}
