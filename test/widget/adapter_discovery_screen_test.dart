import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/application/adapter_discovery/adapter_discovery_controller.dart';
import 'package:ev_health/features/adapter_discovery/presentation/screens/adapter_discovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the searching state as an explicit simulation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _screenApp(state: const AdapterDiscoverySearching()),
    );

    expect(find.text('SIMULATED DISCOVERY'), findsOneWidget);
    expect(find.text('Searching nearby…'), findsOneWidget);
    expect(find.text('Mock adapter discovery'), findsOneWidget);
    expect(find.textContaining('no hardware search'), findsOneWidget);
  });

  testWidgets('renders fictional device results without compatibility claims', (
    tester,
  ) async {
    await tester.pumpWidget(
      _screenApp(
        state: AdapterDiscoveryDevicesFound(
          AdapterDiscoveryMockFixtures.devices,
        ),
      ),
    );

    expect(find.text('Representative mock devices'), findsOneWidget);
    expect(find.text('Known mock devices'), findsOneWidget);
    expect(find.text('Other fictional nearby devices'), findsOneWidget);
    expect(find.text('Fictional ELM Aurora'), findsOneWidget);
    expect(find.text('Mock reference: MOCK-AURORA-01'), findsOneWidget);
    expect(find.textContaining('has not verified'), findsOneWidget);
    expect(find.textContaining('compatibility not verified'), findsNWidgets(3));
  });

  testWidgets('renders the no-device state and dispatches retry', (
    tester,
  ) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      _screenApp(
        state: const AdapterDiscoveryNoDevicesFound(),
        onRetry: () => retryCalls += 1,
      ),
    );

    expect(find.text('No mock adapters found'), findsOneWidget);
    await tester.tap(find.text('Search again'));
    await tester.pump();

    expect(retryCalls, 1);
    expect(find.text('Searching nearby…'), findsOneWidget);
  });

  testWidgets('renders the Bluetooth-disabled explanation and retry', (
    tester,
  ) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      _screenApp(
        state: const AdapterDiscoveryBluetoothDisabled(),
        onRetry: () => retryCalls += 1,
      ),
    );

    expect(find.text('Bluetooth is off — simulated state'), findsOneWidget);
    expect(
      find.textContaining('cannot change Android Bluetooth'),
      findsOneWidget,
    );
    expect(
      find.text('No Bluetooth setting was read or changed.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Check again'));
    await tester.pump();
    expect(retryCalls, 1);
  });

  testWidgets('renders the permission-denied explanation and retry', (
    tester,
  ) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      _screenApp(
        state: const AdapterDiscoveryPermissionDenied(),
        onRetry: () => retryCalls += 1,
      ),
    );

    expect(
      find.text('Bluetooth access is off — simulated state'),
      findsOneWidget,
    );
    expect(find.textContaining('does not request permission'), findsOneWidget);
    expect(find.text('No Android permission API was called.'), findsOneWidget);
    await tester.tap(find.text('Check again'));
    await tester.pump();
    expect(retryCalls, 1);
  });

  testWidgets('renders a recoverable mock error and dispatches retry', (
    tester,
  ) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      _screenApp(
        state: const AdapterDiscoveryRecoverableError(
          detail: 'A fictional temporary failure interrupted this mock search.',
        ),
        onRetry: () => retryCalls += 1,
      ),
    );

    expect(find.text('Mock search could not finish'), findsOneWidget);
    expect(find.textContaining('fictional temporary failure'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retryCalls, 1);
  });

  testWidgets('dispatches mock adapter selection without navigating', (
    tester,
  ) async {
    MockAdapterCandidate? selected;
    await tester.pumpWidget(
      _screenApp(
        state: AdapterDiscoveryDevicesFound(
          AdapterDiscoveryMockFixtures.devices,
        ),
        onSelect: (adapter) => selected = adapter,
      ),
    );

    final selectedRow = find.byKey(const Key('mock-adapter-MOCK-CIRCUIT-02'));
    await tester.ensureVisible(selectedRow);
    await tester.tap(selectedRow);
    await tester.pump();

    expect(selected?.mockId, 'MOCK-CIRCUIT-02');
    expect(find.text('Representative mock devices'), findsOneWidget);
  });

  for (final testCase in <(ThemeData, Brightness)>[
    (AppTheme.light, Brightness.light),
    (AppTheme.dark, Brightness.dark),
  ]) {
    testWidgets('renders in ${testCase.$2.name} theme', (tester) async {
      await tester.pumpWidget(
        _screenApp(
          state: AdapterDiscoveryDevicesFound(
            AdapterDiscoveryMockFixtures.devices,
          ),
          theme: testCase.$1,
        ),
      );

      final context = tester.element(find.text('Representative mock devices'));
      final colors = Theme.of(context).extension<EvHealthColors>()!;
      expect(Theme.of(context).brightness, testCase.$2);
      expect(colors.brightness, testCase.$2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports narrow width, long text, and 200 percent scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const longCandidate = MockAdapterCandidate(
      mockId: 'MOCK-VERY-LONG-FICTIONAL-REFERENCE-ONLY-04',
      displayName:
          'Fictional ELM327 compatible presentation adapter with a very long '
          'mock device name',
      description:
          'Nearby mock device with deliberately long explanatory content • '
          'compatibility not verified',
      isKnownDevice: false,
    );

    await tester.pumpWidget(
      _screenApp(
        state: AdapterDiscoveryDevicesFound(const [longCandidate]),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(
        const Key('mock-adapter-MOCK-VERY-LONG-FICTIONAL-REFERENCE-ONLY-04'),
      ),
      250,
    );

    expect(find.textContaining('very long mock device name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes status, retry, and device-row accessibility semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        _screenApp(
          state: AdapterDiscoveryDevicesFound(
            AdapterDiscoveryMockFixtures.devices,
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(
          RegExp(r'Simulated search complete\. 3 fictional mock adapters'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'Fictional ELM Aurora.*MOCK-AURORA-01.*not been verified'),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        _screenApp(state: const AdapterDiscoveryNoDevicesFound()),
      );
      expect(find.bySemanticsLabel('Search again'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp(r'Simulated search complete\. No mock adapters found'),
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}

Widget _screenApp({
  required AdapterDiscoveryState state,
  AdapterDiscoveryRetryAction? onRetry,
  MockAdapterSelectionAction? onSelect,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      adapterDiscoveryInitialStateProvider.overrideWithValue(state),
      if (onRetry != null)
        adapterDiscoveryRetryActionProvider.overrideWithValue(onRetry),
      if (onSelect != null)
        mockAdapterSelectionActionProvider.overrideWithValue(onSelect),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const AdapterDiscoveryScreen(),
    ),
  );
}
