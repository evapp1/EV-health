import 'package:ev_health/application/scan_preparation/scan_preparation_configuration.dart';
import 'package:ev_health/application/scan_preparation/scan_preparation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BYD Dolphin Premium demo profile resolves to a ready state', () {
    final container = _container(configuration: _configuration());
    addTearDown(container.dispose);

    final state = container.read(scanPreparationControllerProvider);

    expect(state, isA<ScanPreparationReady>());
    final ready = state as ScanPreparationReady;
    expect(ready.vehicle, same(DemoFixture.vehicle));
    expect(
      ready.instructions.powerStateInstruction,
      'Keep the vehicle switched on and ready.',
    );
    expect(
      ready.instructions.basis,
      PreparationInstructionBasis.demoAssumption,
    );
  });

  test('opening preparation does not invoke Start Scan', () {
    var calls = 0;
    final container = _container(
      configuration: _configuration(),
      onStart: (vehicle) => calls += 1,
    );
    addTearDown(container.dispose);

    container.read(scanPreparationControllerProvider);

    expect(calls, 0);
  });

  test('callback runs only after explicit start intent', () async {
    var calls = 0;
    final container = _container(
      configuration: _configuration(),
      onStart: (vehicle) {
        expect(vehicle, same(DemoFixture.vehicle));
        calls += 1;
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(
      scanPreparationControllerProvider.notifier,
    );
    expect(calls, 0);

    await controller.startScan();

    expect(calls, 1);
    expect(
      container.read(scanPreparationControllerProvider),
      isA<ScanPreparationStartRequested>(),
    );
    await controller.startScan();
    expect(calls, 1);
  });

  test('missing exact profile configuration fails closed', () async {
    var calls = 0;
    final container = _container(
      configuration: ScanPreparationConfiguration(const []),
      onStart: (vehicle) => calls += 1,
    );
    addTearDown(container.dispose);

    expect(
      container.read(scanPreparationControllerProvider),
      isA<ScanPreparationUnavailable>(),
    );

    await container
        .read(scanPreparationControllerProvider.notifier)
        .startScan();
    expect(calls, 0);
  });

  test('configuration selects by exact profile version and source', () {
    final otherProfile = VehicleProfileIdentity(
      id: DemoFixture.profile.id,
      version: VersionId('different_profile_version'),
    );
    final configuration = _configuration(
      powerStateInstruction: 'Use the configured replacement instruction.',
    );

    expect(
      configuration
          .forProfile(DemoFixture.profile, DataSource.demo)!
          .powerStateInstruction,
      'Use the configured replacement instruction.',
    );
    expect(configuration.forProfile(otherProfile, DataSource.demo), isNull);
    expect(
      configuration.forProfile(DemoFixture.profile, DataSource.real),
      isNull,
    );
  });

  test('demo instructions require a demo-only evidence basis', () {
    expect(
      () => VehiclePreparationInstructions(
        profile: DemoFixture.profile,
        source: DataSource.demo,
        powerStateInstruction: 'Configured instruction.',
        basis: PreparationInstructionBasis.referenceVehicleValidated,
      ),
      throwsArgumentError,
    );
  });
}

ProviderContainer _container({
  required ScanPreparationConfiguration configuration,
  StartScanAction? onStart,
}) {
  return ProviderContainer(
    overrides: [
      scanPreparationVehicleProvider.overrideWithValue(DemoFixture.vehicle),
      scanPreparationConfigurationProvider.overrideWithValue(configuration),
      if (onStart != null) startScanActionProvider.overrideWithValue(onStart),
    ],
  );
}

ScanPreparationConfiguration _configuration({
  String powerStateInstruction = 'Keep the vehicle switched on and ready.',
}) {
  return ScanPreparationConfiguration([
    VehiclePreparationInstructions(
      profile: DemoFixture.profile,
      source: DataSource.demo,
      powerStateInstruction: powerStateInstruction,
      basis: PreparationInstructionBasis.demoAssumption,
    ),
  ]);
}
