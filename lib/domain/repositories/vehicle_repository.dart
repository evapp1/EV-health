import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/vehicle.dart';

/// Persistence-agnostic access to supported local vehicles.
abstract interface class VehicleRepository {
  /// Returns all vehicles available in this repository.
  Future<List<Vehicle>> listVehicles();

  /// Returns the vehicle with [id], or `null` when it is absent.
  Future<Vehicle?> getVehicle(VehicleId id);

  /// Saves [vehicle] when the implementation supports mutation.
  Future<void> saveVehicle(Vehicle vehicle);
}
