import 'package:ev_health/app/app.dart';
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

  testWidgets('EV Health follows the system theme by default', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const EvHealthApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final launchContext = tester.element(find.text('Battery health reports'));

    expect(materialApp.themeMode, ThemeMode.system);
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
    expect(Theme.of(launchContext).brightness, Brightness.dark);
  });

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
