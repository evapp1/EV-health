import 'package:ev_health/application/vehicle_confirmation/vehicle_confirmation_controller.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_vehicle_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'loads supported BYD Dolphin Premium from the typed repository',
    () async {
      final container = _container();
      addTearDown(container.dispose);

      final state = await container.read(
        vehicleConfirmationControllerProvider.future,
      );

      expect(state, isA<SupportedVehicleConfirmation>());
      final vehicle = (state as SupportedVehicleConfirmation).vehicle;
      expect(vehicle.manufacturer, 'BYD');
      expect(vehicle.model, 'Dolphin');
      expect(vehicle.variant, 'Premium');
      expect(vehicle.source, DataSource.demo);
    },
  );

  test('rejecting the profile enters the unsupported state', () async {
    final container = _container();
    addTearDown(container.dispose);
    await container.read(vehicleConfirmationControllerProvider.future);

    container.read(vehicleConfirmationControllerProvider.notifier).reject();

    expect(
      container.read(vehicleConfirmationControllerProvider).value,
      isA<UnsupportedVehicleConfirmation>(),
    );
  });

  test('confirmation dispatches the typed vehicle callback', () async {
    Object? confirmed;
    final container = ProviderContainer(
      overrides: [
        vehicleConfirmationRepositoryProvider.overrideWithValue(
          DemoVehicleRepository(),
        ),
        confirmVehicleActionProvider.overrideWithValue(
          (vehicle) => confirmed = vehicle,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(vehicleConfirmationControllerProvider.future);

    await container
        .read(vehicleConfirmationControllerProvider.notifier)
        .confirm();

    expect(confirmed, same(DemoFixture.vehicle));
    expect(
      container.read(vehicleConfirmationControllerProvider).value,
      isA<ConfirmedVehicleConfirmation>(),
    );
  });

  test('unsupported safe exit dispatches its callback', () async {
    var exitCalls = 0;
    final container = ProviderContainer(
      overrides: [
        vehicleConfirmationRepositoryProvider.overrideWithValue(
          DemoVehicleRepository(),
        ),
        exitUnsupportedVehicleActionProvider.overrideWithValue(
          () => exitCalls += 1,
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(vehicleConfirmationControllerProvider.future);
    final controller = container.read(
      vehicleConfirmationControllerProvider.notifier,
    );
    controller.reject();

    await controller.exitUnsupported();

    expect(exitCalls, 1);
    expect(
      container.read(vehicleConfirmationControllerProvider).value,
      isA<UnsupportedVehicleConfirmation>(),
    );
  });

  test('rejects non-demo data before presentation', () async {
    final realVehicle = DemoFixture.vehicle;
    final repository = _VehicleRepository([
      _copyWithSource(realVehicle, DataSource.real),
    ]);
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await expectLater(
      container.read(vehicleConfirmationControllerProvider.future),
      throwsStateError,
    );
  });
}

ProviderContainer _container({VehicleRepository? repository}) {
  return ProviderContainer(
    overrides: [
      vehicleConfirmationRepositoryProvider.overrideWithValue(
        repository ?? DemoVehicleRepository(),
      ),
    ],
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

Vehicle _copyWithSource(Vehicle vehicle, DataSource source) {
  return Vehicle(
    id: vehicle.id,
    source: source,
    manufacturer: vehicle.manufacturer,
    model: vehicle.model,
    variant: vehicle.variant,
    modelYear: vehicle.modelYear,
    nickname: vehicle.nickname,
    profile: vehicle.profile,
    lastConfirmedAtUtc: vehicle.lastConfirmedAtUtc,
    createdAtUtc: vehicle.createdAtUtc,
    updatedAtUtc: vehicle.updatedAtUtc,
  );
}
