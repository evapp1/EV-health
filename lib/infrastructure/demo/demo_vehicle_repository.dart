import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/domain/repositories/vehicle_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_repository_write_exception.dart';

/// Read-only vehicle repository for the labelled fictional demo experience.
final class DemoVehicleRepository implements VehicleRepository {
  /// Creates the repository with the approved demo vehicle.
  DemoVehicleRepository()
    : _vehicles = List.unmodifiable([DemoFixture.vehicle]);

  /// Creates an empty repository for deterministic empty-state tests.
  DemoVehicleRepository.empty() : _vehicles = const [];

  final List<Vehicle> _vehicles;

  @override
  Future<Vehicle?> getVehicle(VehicleId id) async {
    for (final vehicle in _vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }

  @override
  Future<List<Vehicle>> listVehicles() async => List.unmodifiable(_vehicles);

  @override
  Future<void> saveVehicle(Vehicle vehicle) =>
      Future<void>.error(const DemoRepositoryWriteException('saveVehicle'));
}
