import 'package:ev_health/domain/models/analysis_result.dart';
import 'package:ev_health/domain/models/battery_scan.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/model_support.dart';
import 'package:ev_health/domain/models/raw_reading.dart';
import 'package:ev_health/domain/models/report_snapshot.dart';

/// Immutable aggregate for a finalized scan and its exact report snapshot.
final class ScanBundle {
  /// Creates a validated finalized scan aggregate.
  ScanBundle({
    required this.scan,
    required Iterable<RawReading> readings,
    required this.analysis,
    required this.report,
  }) : readings = immutableList(readings) {
    if (analysis.scanId != scan.id || report.scanId != scan.id) {
      throw ArgumentError('Bundle records must belong to the same scan');
    }
    if (analysis.source != scan.source || report.source != scan.source) {
      throw ArgumentError('Bundle records must use the same source');
    }
    if (report.scanStatus != scan.status) {
      throw ArgumentError('Report status must match the scan status');
    }
    if (this.readings.any(
      (reading) => reading.scanId != scan.id || reading.source != scan.source,
    )) {
      throw ArgumentError('Every reading must belong to the bundle scan');
    }
    final readingIds = this.readings.map((reading) => reading.id);
    if (readingIds.toSet().length != readingIds.length) {
      throw ArgumentError('Bundle readings must have unique IDs');
    }
  }

  /// Immutable completed or partial scan metadata.
  final BatteryScan scan;

  /// Immutable readings captured for the scan.
  final List<RawReading> readings;

  /// Immutable analysis result for the scan.
  final AnalysisResult analysis;

  /// Immutable report snapshot generated for the scan.
  final ReportSnapshot report;

  /// Shared source classification for every record in this bundle.
  DataSource get source => scan.source;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanBundle &&
          other.scan == scan &&
          domainListEquals(other.readings, readings) &&
          other.analysis == analysis &&
          other.report == report;

  @override
  int get hashCode =>
      Object.hash(scan, Object.hashAll(readings), analysis, report);
}
