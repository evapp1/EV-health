import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/report_snapshot.dart';

/// Persistence-agnostic access to immutable report snapshots.
abstract interface class ReportRepository {
  /// Returns all reports, newest first.
  Future<List<ReportSnapshot>> listReports();

  /// Returns [reportId], or `null` when it is absent.
  Future<ReportSnapshot?> getReport(ReportSnapshotId reportId);

  /// Saves [report] when the implementation supports mutation.
  Future<void> saveReport(ReportSnapshot report);

  /// Deletes [reportId] when the implementation supports mutation.
  Future<void> deleteReport(ReportSnapshotId reportId);
}
