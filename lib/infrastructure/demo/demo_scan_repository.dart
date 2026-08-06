import 'package:ev_health/domain/models/battery_scan.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/scan_bundle.dart';
import 'package:ev_health/domain/repositories/scan_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_repository_write_exception.dart';

/// Read-only scan repository for the labelled fictional demo experience.
final class DemoScanRepository implements ScanRepository {
  /// Creates the repository with the approved completed demo scan.
  DemoScanRepository()
    : _bundles = List.unmodifiable([DemoFixture.completeScanBundle]);

  /// Creates an empty repository for deterministic empty-state tests.
  DemoScanRepository.empty() : _bundles = const [];

  final List<ScanBundle> _bundles;

  @override
  Future<void> deleteScan(ScanId scanId) =>
      Future<void>.error(const DemoRepositoryWriteException('deleteScan'));

  @override
  Future<ScanBundle?> getScan(ScanId scanId) async {
    for (final bundle in _bundles) {
      if (bundle.scan.id == scanId) {
        return bundle;
      }
    }
    return null;
  }

  @override
  Future<List<BatteryScan>> listScans(VehicleId vehicleId) async =>
      List.unmodifiable(
        _bundles
            .map((bundle) => bundle.scan)
            .where((scan) => scan.vehicleId == vehicleId),
      );

  @override
  Future<void> saveCompletedScan(ScanBundle bundle) => Future<void>.error(
    const DemoRepositoryWriteException('saveCompletedScan'),
  );
}
