import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/measured_value.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Validated score in the inclusive 0–100 range.
final class BatteryScore {
  /// Creates a battery score.
  BatteryScore(this.value) {
    if (value < 0 || value > 100) {
      throw RangeError.range(value, 0, 100, 'batteryScore');
    }
  }

  /// Integer score.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BatteryScore && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Validated component weight in basis points.
final class WeightBasisPoints {
  /// Creates a component weight.
  WeightBasisPoints(this.value) {
    if (value < 0 || value > 10000) {
      throw RangeError.range(value, 0, 10000, 'weightBasisPoints');
    }
  }

  /// Weight where 10,000 basis points equals 100 percent.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightBasisPoints && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Immutable component score and rule metadata.
final class AnalysisComponentScore {
  /// Creates a validated component score.
  AnalysisComponentScore({
    required this.component,
    required this.score,
    required this.weight,
    required String ruleId,
    required Iterable<MetricKey> inputKeys,
  }) : ruleId = requireText(ruleId, 'ruleId'),
       inputKeys = requireUnique(inputKeys, 'inputKeys') {
    if (this.inputKeys.isEmpty) {
      throw ArgumentError.value(inputKeys, 'inputKeys', 'must not be empty');
    }
    _requireCalculatedValue(score, 'score');
  }

  /// Component represented by this score.
  final AnalysisComponentKind component;

  /// Calculated, demo-derived, or unavailable component score.
  final ProvenancedValue<BatteryScore> score;

  /// Configured weight.
  final WeightBasisPoints weight;

  /// Stable governed rule identifier.
  final String ruleId;

  /// Canonical input metrics.
  final List<MetricKey> inputKeys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisComponentScore &&
          other.component == component &&
          other.score == score &&
          other.weight == weight &&
          other.ruleId == ruleId &&
          domainListEquals(other.inputKeys, inputKeys);

  @override
  int get hashCode =>
      Object.hash(component, score, weight, ruleId, Object.hashAll(inputKeys));
}

/// Immutable result produced for one scan.
final class AnalysisResult {
  /// Creates a validated analysis result.
  AnalysisResult({
    required this.id,
    required this.scanId,
    required this.source,
    required this.engineVersion,
    required this.scoringConfigVersion,
    required this.thresholdConfigVersion,
    required this.sohPercent,
    required this.cellDelta,
    required this.temperatureSpread,
    required this.equivalentFullCycles,
    required this.batteryScore,
    required this.overallGrade,
    required this.capacityGrade,
    required this.cellBalanceGrade,
    required this.temperatureGrade,
    required this.confidence,
    required Iterable<AnalysisComponentScore> componentScores,
    required Iterable<AnalysisWarningCode> warnings,
    required DateTime createdAtUtc,
  }) : componentScores = requireUnique(componentScores, 'componentScores'),
       warnings = requireUnique(warnings, 'warnings'),
       createdAtUtc = requireUtc(createdAtUtc, 'createdAtUtc') {
    _requireCalculatedValue(batteryScore, 'batteryScore');
    _requireCalculatedValue(overallGrade, 'overallGrade');
    _requireCalculatedValue(capacityGrade, 'capacityGrade');
    _requireCalculatedValue(cellBalanceGrade, 'cellBalanceGrade');
    _requireCalculatedValue(temperatureGrade, 'temperatureGrade');
    final componentKinds = this.componentScores.map((item) => item.component);
    if (componentKinds.toSet().length != componentKinds.length) {
      throw ArgumentError('componentScores must have unique component kinds');
    }
    final provenances = <ValueProvenance>[
      sohPercent.value.provenance,
      cellDelta.value.provenance,
      temperatureSpread.value.provenance,
      equivalentFullCycles.value.provenance,
      batteryScore.provenance,
      overallGrade.provenance,
      capacityGrade.provenance,
      cellBalanceGrade.provenance,
      temperatureGrade.provenance,
      ...this.componentScores.map((item) => item.score.provenance),
    ];
    _validateSourceProvenance(source, provenances);
  }

  /// App-generated identifier.
  final AnalysisResultId id;

  /// Owning scan identifier.
  final ScanId scanId;

  /// Real, demo, or test classification.
  final DataSource source;

  /// Battery Engine version.
  final VersionId engineVersion;

  /// Scoring configuration version.
  final VersionId scoringConfigVersion;

  /// Threshold configuration version.
  final VersionId thresholdConfigVersion;

  /// Calculated state of health or typed unavailability.
  final MetricResult sohPercent;

  /// Calculated cell voltage delta or typed unavailability.
  final MetricResult cellDelta;

  /// Calculated temperature spread or typed unavailability.
  final MetricResult temperatureSpread;

  /// Estimated equivalent full cycles or typed unavailability.
  final MetricResult equivalentFullCycles;

  /// Calculated overall score or typed unavailability.
  final ProvenancedValue<BatteryScore> batteryScore;

  /// Calculated overall grade or typed unavailability.
  final ProvenancedValue<AssessmentGrade> overallGrade;

  /// Calculated capacity grade or typed unavailability.
  final ProvenancedValue<AssessmentGrade> capacityGrade;

  /// Calculated cell-balance grade or typed unavailability.
  final ProvenancedValue<AssessmentGrade> cellBalanceGrade;

  /// Calculated temperature grade or typed unavailability.
  final ProvenancedValue<AssessmentGrade> temperatureGrade;

  /// Scan completeness and data-quality confidence.
  final AnalysisConfidence confidence;

  /// Immutable component score snapshot.
  final List<AnalysisComponentScore> componentScores;

  /// Immutable typed warning codes.
  final List<AnalysisWarningCode> warnings;

  /// UTC creation time.
  final DateTime createdAtUtc;

  static void _validateSourceProvenance(
    DataSource source,
    Iterable<ValueProvenance> provenances,
  ) {
    final available = provenances.where(
      (item) => item != ValueProvenance.unavailable,
    );
    if (source == DataSource.real &&
        available.contains(ValueProvenance.demoDerived)) {
      throw ArgumentError('Real analysis cannot contain demo-derived values');
    }
    if (source == DataSource.demo &&
        available.any((item) => item != ValueProvenance.demoDerived)) {
      throw ArgumentError(
        'Available demo analysis values must be demo-derived',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisResult &&
          other.id == id &&
          other.scanId == scanId &&
          other.source == source &&
          other.engineVersion == engineVersion &&
          other.scoringConfigVersion == scoringConfigVersion &&
          other.thresholdConfigVersion == thresholdConfigVersion &&
          other.sohPercent == sohPercent &&
          other.cellDelta == cellDelta &&
          other.temperatureSpread == temperatureSpread &&
          other.equivalentFullCycles == equivalentFullCycles &&
          other.batteryScore == batteryScore &&
          other.overallGrade == overallGrade &&
          other.capacityGrade == capacityGrade &&
          other.cellBalanceGrade == cellBalanceGrade &&
          other.temperatureGrade == temperatureGrade &&
          other.confidence == confidence &&
          domainListEquals(other.componentScores, componentScores) &&
          domainListEquals(other.warnings, warnings) &&
          other.createdAtUtc == createdAtUtc;

  @override
  int get hashCode => Object.hashAll([
    id,
    scanId,
    source,
    engineVersion,
    scoringConfigVersion,
    thresholdConfigVersion,
    sohPercent,
    cellDelta,
    temperatureSpread,
    equivalentFullCycles,
    batteryScore,
    overallGrade,
    capacityGrade,
    cellBalanceGrade,
    temperatureGrade,
    confidence,
    Object.hashAll(componentScores),
    Object.hashAll(warnings),
    createdAtUtc,
  ]);
}

void _requireCalculatedValue<T>(ProvenancedValue<T> value, String name) {
  const allowed = <ValueProvenance>{
    ValueProvenance.calculated,
    ValueProvenance.unavailable,
    ValueProvenance.demoDerived,
  };
  if (!allowed.contains(value.provenance)) {
    throw ArgumentError.value(value.provenance, name, 'must be calculated');
  }
}
