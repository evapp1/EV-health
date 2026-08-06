import 'package:ev_health/domain/models/battery_scan.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/scan_bundle.dart';

/// Persistence-agnostic access to finalized scan snapshots.
abstract interface class ScanRepository {
  /// Returns finalized scans for [vehicleId], newest first.
  Future<List<BatteryScan>> listScans(VehicleId vehicleId);

  /// Returns the complete aggregate for [scanId], or `null` when absent.
  Future<ScanBundle?> getScan(ScanId scanId);

  /// Saves an immutable finalized aggregate when mutation is supported.
  Future<void> saveCompletedScan(ScanBundle bundle);

  /// Deletes [scanId] when mutation is supported.
  Future<void> deleteScan(ScanId scanId);
}
