import 'package:ev_health/domain/models/scan_bundle.dart';
import 'package:ev_health/domain/repositories/history_repository.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';

/// Read-only history repository isolated from production scan history.
final class DemoHistoryRepository implements HistoryRepository {
  /// Creates deterministic demo scan/report history.
  DemoHistoryRepository()
    : _history = List.unmodifiable([DemoFixture.completeScanBundle]);

  /// Creates an empty repository for deterministic empty-state tests.
  DemoHistoryRepository.empty() : _history = const [];

  final List<ScanBundle> _history;

  @override
  Future<List<ScanBundle>> listHistory() async => List.unmodifiable(_history);
}
