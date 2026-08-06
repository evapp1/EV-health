import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/report_snapshot.dart';
import 'package:ev_health/domain/repositories/report_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:ev_health/infrastructure/demo/demo_repository_write_exception.dart';

/// Read-only report repository for the labelled fictional demo experience.
final class DemoReportRepository implements ReportRepository {
  /// Creates the repository with the approved demo report snapshot.
  DemoReportRepository()
    : _reports = List.unmodifiable([DemoFixture.completeScanBundle.report]);

  /// Creates an empty repository for deterministic empty-state tests.
  DemoReportRepository.empty() : _reports = const [];

  final List<ReportSnapshot> _reports;

  @override
  Future<void> deleteReport(ReportSnapshotId reportId) =>
      Future<void>.error(const DemoRepositoryWriteException('deleteReport'));

  @override
  Future<ReportSnapshot?> getReport(ReportSnapshotId reportId) async {
    for (final report in _reports) {
      if (report.id == reportId) {
        return report;
      }
    }
    return null;
  }

  @override
  Future<List<ReportSnapshot>> listReports() async =>
      List.unmodifiable(_reports);

  @override
  Future<void> saveReport(ReportSnapshot report) =>
      Future<void>.error(const DemoRepositoryWriteException('saveReport'));
}
