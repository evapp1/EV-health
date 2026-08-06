import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/measured_value.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Immutable deterministic insight captured in a report snapshot.
final class ReportInsightItem {
  /// Creates a report insight item.
  ReportInsightItem({
    required this.id,
    required String title,
    required String body,
    required Iterable<MetricKey> supportingMetricKeys,
  }) : title = requireText(title, 'title'),
       body = requireText(body, 'body'),
       supportingMetricKeys = requireUnique(
         supportingMetricKeys,
         'supportingMetricKeys',
       );

  /// Stable deterministic item identifier.
  final ReportItemId id;

  /// User-visible title.
  final String title;

  /// Deterministic user-visible body.
  final String body;

  /// Canonical metrics supporting the insight.
  final List<MetricKey> supportingMetricKeys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportInsightItem &&
          other.id == id &&
          other.title == title &&
          other.body == body &&
          domainListEquals(other.supportingMetricKeys, supportingMetricKeys);

  @override
  int get hashCode =>
      Object.hash(id, title, body, Object.hashAll(supportingMetricKeys));
}

/// Immutable typed technical row captured in a report snapshot.
final class ReportTechnicalItem {
  /// Creates a technical report item.
  ReportTechnicalItem({
    required this.metricKey,
    required String label,
    required this.result,
  }) : label = requireText(label, 'label');

  /// Canonical metric key.
  final MetricKey metricKey;

  /// User-visible governed label.
  final String label;

  /// Exact value, provenance, and calculation metadata.
  final MetricResult result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTechnicalItem &&
          other.metricKey == metricKey &&
          other.label == label &&
          other.result == result;

  @override
  int get hashCode => Object.hash(metricKey, label, result);
}

/// Immutable presentation-neutral snapshot of exactly what a report showed.
final class ReportSnapshot {
  /// Creates a validated report snapshot.
  ReportSnapshot({
    required this.id,
    required this.scanId,
    required this.source,
    required this.scanStatus,
    required this.reportVersion,
    required String title,
    required String summaryText,
    required Iterable<ReportInsightItem> insightItems,
    required Iterable<ReportTechnicalItem> technicalItems,
    required this.disclaimerVersion,
    required DateTime generatedAtUtc,
    required this.shareIdentifier,
  }) : title = requireText(title, 'title'),
       summaryText = requireText(summaryText, 'summaryText'),
       insightItems = immutableList(insightItems),
       technicalItems = immutableList(technicalItems),
       generatedAtUtc = requireUtc(generatedAtUtc, 'generatedAtUtc') {
    final insightIds = this.insightItems.map((item) => item.id);
    if (insightIds.toSet().length != insightIds.length) {
      throw ArgumentError('insightItems must have unique IDs');
    }
    final technicalKeys = this.technicalItems.map((item) => item.metricKey);
    if (technicalKeys.toSet().length != technicalKeys.length) {
      throw ArgumentError('technicalItems must have unique metric keys');
    }
    _validateSource(source, this.technicalItems);
  }

  /// App-generated identifier.
  final ReportSnapshotId id;

  /// Owning scan identifier.
  final ScanId scanId;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Completeness status inherited from the immutable scan.
  final ScanStatus scanStatus;

  /// Presentation schema/template version.
  final VersionId reportVersion;

  /// User-visible report title.
  final String title;

  /// Deterministic summary text.
  final String summaryText;

  /// Ordered immutable insight cards.
  final List<ReportInsightItem> insightItems;

  /// Ordered immutable technical rows.
  final List<ReportTechnicalItem> technicalItems;

  /// Exact disclaimer version shown.
  final VersionId disclaimerVersion;

  /// UTC generation time.
  final DateTime generatedAtUtc;

  /// Random local share identifier not derived from identifying data.
  final ShareIdentifier shareIdentifier;

  static void _validateSource(
    DataSource source,
    Iterable<ReportTechnicalItem> items,
  ) {
    final provenances = items
        .map((item) => item.result.value.provenance)
        .where((item) => item != ValueProvenance.unavailable);
    if (source == DataSource.real &&
        provenances.contains(ValueProvenance.demoDerived)) {
      throw ArgumentError('Real reports cannot contain demo-derived values');
    }
    if (source == DataSource.demo &&
        provenances.any((item) => item != ValueProvenance.demoDerived)) {
      throw ArgumentError('Available demo report values must be demo-derived');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSnapshot &&
          other.id == id &&
          other.scanId == scanId &&
          other.source == source &&
          other.scanStatus == scanStatus &&
          other.reportVersion == reportVersion &&
          other.title == title &&
          other.summaryText == summaryText &&
          domainListEquals(other.insightItems, insightItems) &&
          domainListEquals(other.technicalItems, technicalItems) &&
          other.disclaimerVersion == disclaimerVersion &&
          other.generatedAtUtc == generatedAtUtc &&
          other.shareIdentifier == shareIdentifier;

  @override
  int get hashCode => Object.hashAll([
    id,
    scanId,
    source,
    scanStatus,
    reportVersion,
    title,
    summaryText,
    Object.hashAll(insightItems),
    Object.hashAll(technicalItems),
    disclaimerVersion,
    generatedAtUtc,
    shareIdentifier,
  ]);
}
