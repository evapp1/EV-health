import 'package:ev_health/domain/models/scan_bundle.dart';

/// Read boundary for scan and report history aggregates.
abstract interface class HistoryRepository {
  /// Returns finalized scan/report aggregates, newest first.
  Future<List<ScanBundle>> listHistory();
}
