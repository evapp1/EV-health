import 'package:ev_health/app/app.dart';
import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the EV Health application launch experience.
void main() {
  testWidgets('EV Health app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const EvHealthApp());

    expect(find.text('EV Health'), findsOneWidget);
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(
      find.text('Clear battery insights, stored locally on your device.'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  for (final testCase in <(Brightness, EvHealthColors)>[
    (Brightness.light, EvHealthColors.light),
    (Brightness.dark, EvHealthColors.dark),
  ]) {
    testWidgets('EV Health uses the ${testCase.$1.name} system theme', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = testCase.$1;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const EvHealthApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(materialApp.themeMode, ThemeMode.system);
      expect(materialApp.theme, same(AppTheme.light));
      expect(materialApp.darkTheme, same(AppTheme.dark));
      _expectLaunchTheme(tester, testCase.$2);
    });
  }

  testWidgets('launch content remains available at 200 percent text scaling', (
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

    expect(find.text('EV Health'), findsOneWidget);
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(
      find.text('Clear battery insights, stored locally on your device.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

void _expectLaunchTheme(WidgetTester tester, EvHealthColors colors) {
  final launchContext = tester.element(find.text('Battery health reports'));
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  final appBar = tester.widget<AppBar>(find.byType(AppBar));
  final title = tester.widget<Text>(find.text('Battery health reports'));
  final body = tester.widget<Text>(
    find.text('Clear battery insights, stored locally on your device.'),
  );

  expect(Theme.of(launchContext).brightness, colors.brightness);
  expect(scaffold.backgroundColor, colors.surface);
  expect(appBar.backgroundColor, colors.surface);
  expect(appBar.foregroundColor, colors.textPrimary);
  expect(title.style!.color, colors.textPrimary);
  expect(body.style!.color, colors.textPrimary);
}
