import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_configuration.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/features/scan_preparation/presentation/screens/scan_preparation_screen.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows supported vehicle, persistent demo, and safety guidance', (
    tester,
  ) async {
    await tester.pumpWidget(_screenApp());

    expect(find.text('Prepare for battery scan'), findsOneWidget);
    expect(find.text('DEMO MODE'), findsOneWidget);
    expect(find.text('BYD Dolphin Premium'), findsOneWidget);
    expect(find.text('Before you start'), findsOneWidget);
    expect(find.textContaining('Park safely'), findsOneWidget);
    expect(
      find.textContaining('Do not use the app while driving'),
      findsOneWidget,
    );
    expect(find.textContaining('apply the parking brake'), findsOneWidget);
    expect(
      find.text('Keep the vehicle switched on and ready.'),
      findsOneWidget,
    );
    expect(find.textContaining('read-only'), findsOneWidget);
    expect(
      find.textContaining('will not change vehicle settings'),
      findsOneWidget,
    );
    expect(
      find.textContaining('has not been validated on a real vehicle'),
      findsOneWidget,
    );
    expect(find.text('Start Scan'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.textContaining('adapter summary'), findsNothing);
  });

  testWidgets(
    'opening does not start and explicit Start Scan invokes callback',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(_screenApp(onStart: (vehicle) => calls += 1));

      expect(calls, 0);
      await tester.scrollUntilVisible(
        find.byKey(const Key('start-scan-action')),
        250,
      );
      expect(calls, 0);

      await tester.tap(find.byKey(const Key('start-scan-action')));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(find.text('DEMO MODE'), findsOneWidget);
      expect(find.textContaining('Start Scan was requested'), findsOneWidget);
      expect(
        find.textContaining('does not implement scan progress'),
        findsOneWidget,
      );
    },
  );

  testWidgets('renders power-state instruction supplied by configuration', (
    tester,
  ) async {
    const replacement =
        'Use a deliberately different configured power-state instruction '
        'for this future profile.';
    await tester.pumpWidget(_screenApp(powerStateInstruction: replacement));

    expect(find.text(replacement), findsOneWidget);
    expect(find.text('Keep the vehicle switched on and ready.'), findsNothing);
  });

  testWidgets('missing configuration blocks Start Scan and fails safely', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _screenApp(
        configuration: ScanPreparationConfiguration(const []),
        onStart: (vehicle) => calls += 1,
      ),
    );

    expect(find.text('Preparation instructions unavailable'), findsOneWidget);
    expect(
      find.textContaining('exact vehicle profile and version'),
      findsOneWidget,
    );
    expect(find.textContaining('Start Scan is disabled'), findsOneWidget);
    expect(find.byKey(const Key('start-scan-action')), findsNothing);
    expect(calls, 0);
  });

  testWidgets(
    'Cancel and Android back both return through the route callback',
    (tester) async {
      var backCalls = 0;
      await tester.pumpWidget(_screenApp(onBack: () => backCalls += 1));

      await tester.scrollUntilVisible(find.text('Cancel'), 250);
      await tester.tap(find.text('Cancel'));
      expect(backCalls, 1);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(backCalls, 2);
    },
  );

  for (final testCase in <(ThemeData, Brightness)>[
    (AppTheme.light, Brightness.light),
    (AppTheme.dark, Brightness.dark),
  ]) {
    testWidgets('renders in ${testCase.$2.name} theme', (tester) async {
      await tester.pumpWidget(_screenApp(theme: testCase.$1));

      final context = tester.element(find.text('BYD Dolphin Premium'));
      final colors = Theme.of(context).extension<EvHealthColors>()!;
      expect(Theme.of(context).brightness, testCase.$2);
      expect(colors.brightness, testCase.$2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports narrow width, long configuration, and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const longInstruction =
        'Keep this fictional future vehicle in the configuration-defined '
        'power state while stationary, with enough deliberately long text to '
        'verify wrapping without horizontal overflow.';

    await tester.pumpWidget(
      _screenApp(
        powerStateInstruction: longInstruction,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('start-scan-action')),
      300,
    );

    expect(find.text(longInstruction), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes safety guidance and Start Scan semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_screenApp());
      await tester.scrollUntilVisible(
        find.byKey(const Key('start-scan-action')),
        250,
      );

      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Safety and preparation guidance\..*do not use.*driving',
            caseSensitive: false,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'Start Scan\. Explicitly continue from preparation'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Demo Mode\. Fictional preparation')),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}

Widget _screenApp({
  ScanPreparationConfiguration? configuration,
  StartScanAction? onStart,
  VoidCallback? onBack,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
  String powerStateInstruction = 'Keep the vehicle switched on and ready.',
}) {
  final selectedConfiguration =
      configuration ??
      ScanPreparationConfiguration([
        VehiclePreparationInstructions(
          profile: DemoFixture.profile,
          source: DataSource.demo,
          powerStateInstruction: powerStateInstruction,
          basis: PreparationInstructionBasis.demoAssumption,
        ),
      ]);
  return ProviderScope(
    overrides: [
      scanPreparationVehicleProvider.overrideWithValue(DemoFixture.vehicle),
      scanPreparationConfigurationProvider.overrideWithValue(
        selectedConfiguration,
      ),
      if (onStart != null) startScanActionProvider.overrideWithValue(onStart),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: ScanPreparationScreen(onBack: onBack ?? () {}),
    ),
  );
}
