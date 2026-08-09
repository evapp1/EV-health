import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/application/vehicle_confirmation/vehicle_confirmation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/features/vehicle_confirmation/presentation/screens/vehicle_confirmation_screen.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the supported BYD Dolphin Premium demo profile', (
    tester,
  ) async {
    await tester.pumpWidget(_screenApp());
    await tester.pumpAndSettle();

    expect(find.text('DEMO / MOCK PROFILE'), findsOneWidget);
    expect(find.text('BYD Dolphin Premium'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('Demo/mock profile'), findsOneWidget);
    expect(find.text('byd_dolphin_premium_demo_1.0'), findsOneWidget);
    expect(find.textContaining('No live vehicle detection'), findsOneWidget);
    expect(find.textContaining('No VIN'), findsOneWidget);
  });

  testWidgets('confirmation dispatches the callback without starting a scan', (
    tester,
  ) async {
    Vehicle? confirmed;
    Vehicle? routedVehicle;
    await tester.pumpWidget(
      _screenApp(
        onConfirm: (vehicle) => confirmed = vehicle,
        onConfirmationComplete: (vehicle) async => routedVehicle = vehicle,
      ),
    );
    await tester.pumpAndSettle();

    final confirm = find.byKey(const Key('confirm-supported-vehicle'));
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pump();

    expect(confirmed, same(DemoFixture.vehicle));
    expect(routedVehicle, same(DemoFixture.vehicle));
    expect(find.text('Confirm the vehicle'), findsOneWidget);
    expect(find.text('Demo vehicle confirmed'), findsOneWidget);
    expect(find.textContaining('No scan has started'), findsOneWidget);
    expect(find.textContaining('Start scan'), findsNothing);
  });

  testWidgets('unsupported state blocks progress and safely exits', (
    tester,
  ) async {
    var applicationExitCalls = 0;
    var navigationExitCalls = 0;
    await tester.pumpWidget(
      _screenApp(
        onExit: () => applicationExitCalls += 1,
        onSafeExitComplete: () => navigationExitCalls += 1,
      ),
    );
    await tester.pumpAndSettle();

    final reject = find.byKey(const Key('reject-supported-vehicle'));
    await tester.ensureVisible(reject);
    await tester.tap(reject);
    await tester.pump();

    expect(find.text('Vehicle not supported'), findsOneWidget);
    expect(find.textContaining('will not continue'), findsOneWidget);
    expect(find.textContaining('generic scanning'), findsOneWidget);
    expect(find.byKey(const Key('confirm-supported-vehicle')), findsNothing);

    await tester.tap(find.text('Back to adapter discovery'));
    await tester.pump();

    expect(applicationExitCalls, 1);
    expect(navigationExitCalls, 1);
  });

  for (final testCase in <(ThemeData, Brightness)>[
    (AppTheme.light, Brightness.light),
    (AppTheme.dark, Brightness.dark),
  ]) {
    testWidgets('renders in ${testCase.$2.name} theme', (tester) async {
      await tester.pumpWidget(_screenApp(theme: testCase.$1));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('BYD Dolphin Premium'));
      final colors = Theme.of(context).extension<EvHealthColors>()!;
      expect(Theme.of(context).brightness, testCase.$2);
      expect(colors.brightness, testCase.$2);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports narrow width, long details, and 200 percent scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final longVehicle = Vehicle(
      id: VehicleId('long-demo-vehicle'),
      source: DataSource.demo,
      manufacturer: 'BYD with a deliberately long manufacturer label',
      model: 'Dolphin with long presentation-only model text',
      variant: 'Premium demonstration variant',
      modelYear: 2024,
      profile: VehicleProfileIdentity(
        id: VehicleProfileId('long_demo_profile'),
        version: VersionId(
          'byd_dolphin_premium_demo_with_a_very_long_version_1.0',
        ),
      ),
      lastConfirmedAtUtc: DateTime.utc(2026),
      createdAtUtc: DateTime.utc(2026),
      updatedAtUtc: DateTime.utc(2026),
    );

    await tester.pumpWidget(
      _screenApp(
        repository: _VehicleRepository([longVehicle]),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('confirm-supported-vehicle')),
      250,
    );

    expect(find.textContaining('deliberately long'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes vehicle details and actions through semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(_screenApp());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Supported demo profile\. BYD Dolphin Premium\..*Model year: 2024',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'Yes, confirm BYD Dolphin Premium demo profile'),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'No live vehicle detection.*vehicle identifier'),
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}

Widget _screenApp({
  VehicleRepository? repository,
  ConfirmVehicleAction? onConfirm,
  ExitUnsupportedVehicleAction? onExit,
  VoidCallback? onSafeExitComplete,
  Future<void> Function(Vehicle vehicle)? onConfirmationComplete,
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return ProviderScope(
    overrides: [
      vehicleConfirmationRepositoryProvider.overrideWithValue(
        repository ?? _VehicleRepository([DemoFixture.vehicle]),
      ),
      if (onConfirm != null)
        confirmVehicleActionProvider.overrideWithValue(onConfirm),
      if (onExit != null)
        exitUnsupportedVehicleActionProvider.overrideWithValue(onExit),
    ],
    child: MaterialApp(
      theme: theme ?? AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: VehicleConfirmationScreen(
        onSafeExitComplete: onSafeExitComplete,
        onConfirmationComplete: onConfirmationComplete,
      ),
    ),
  );
}

final class _VehicleRepository implements VehicleRepository {
  _VehicleRepository(this.vehicles);

  final List<Vehicle> vehicles;

  @override
  Future<Vehicle?> getVehicle(VehicleId id) async {
    for (final vehicle in vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }

  @override
  Future<List<Vehicle>> listVehicles() async => List.unmodifiable(vehicles);

  @override
  Future<void> saveVehicle(Vehicle vehicle) {
    throw UnsupportedError('Test repository is read-only.');
  }
}
