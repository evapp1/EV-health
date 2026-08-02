import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final themeMode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'representative Material components render in ${themeMode.name}',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const _ThemeComponentHarness(),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(
          tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
        );
        expect(
          tester.getSize(find.byType(OutlinedButton)).height,
          greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('representative components support 200 percent text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: _ThemeComponentHarness(),
        ),
      ),
    );

    expect(find.text('Battery health summary'), findsOneWidget);
    expect(find.text('Review battery health'), findsOneWidget);
    expect(find.text('View supporting details'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
    );
    expect(
      tester.getSize(find.byType(OutlinedButton)).height,
      greaterThanOrEqualTo(AppSpacing.minimumTouchTarget),
    );
    expect(tester.takeException(), isNull);
  });
}

class _ThemeComponentHarness extends StatelessWidget {
  const _ThemeComponentHarness();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenCompact),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Text(
                    'Battery health summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              FilledButton(
                onPressed: _doNothing,
                child: const Text('Review battery health'),
              ),
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton(
                onPressed: _doNothing,
                child: const Text('View supporting details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _doNothing() {}
}
