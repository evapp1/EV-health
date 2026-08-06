import 'package:ev_health/domain/models/domain_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('representative construction and equality', () {
    test(
      'vehicle is immutable, equal by value, and supports optional data',
      () {
        final first = _vehicle();
        final second = _vehicle();

        expect(first, second);
        expect(first.hashCode, second.hashCode);
        expect(first.modelYear, isNull);
        expect(first.nickname, isNull);
        expect(first.source, DataSource.real);
      },
    );

    test('adapter is immutable, equal by value, and omits device IDs', () {
      final first = _adapter();
      final second = _adapter();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.lastConnectedAtUtc, isNull);
      expect(first.source, DataSource.real);
    });

    test('scan is immutable and equal by value', () {
      final first = _scan();
      final second = _scan();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.status, ScanStatus.partial);
      expect(first.unavailableMetricKeys, [MetricKey('temperature.average_c')]);
    });

    test('raw reading represents available and unavailable attempts', () {
      final available = _reading();
      final equalAvailable = _reading();
      final unavailable = RawReading.unavailable(
        id: RawReadingId('reading-2'),
        scanId: ScanId('scan-1'),
        source: DataSource.real,
        metricKey: MetricKey('temperature.average_c'),
        pidKey: PidKey('temperature_average'),
        quality: ReadingQuality.timeout,
        reason: UnavailableReason.commandTimeout,
        measuredAtUtc: _scanTime,
      );

      expect(available, equalAvailable);
      expect(available.hashCode, equalAvailable.hashCode);
      expect(available.value.provenance, ValueProvenance.measured);
      expect(unavailable.value.isAvailable, isFalse);
      expect(
        unavailable.value.unavailableReason,
        UnavailableReason.commandTimeout,
      );
    });

    test('analysis result is immutable and equal by value', () {
      final first = _analysis();
      final second = _analysis();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.sohPercent.value.provenance, ValueProvenance.calculated);
      expect(first.equivalentFullCycles.value.isAvailable, isFalse);
      expect(first.batteryScore.value, BatteryScore(96));
    });

    test('report snapshot is immutable and equal by value', () {
      final first = _report();
      final second = _report();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.source, DataSource.real);
      expect(
        first.technicalItems.last.result.value.provenance,
        ValueProvenance.unavailable,
      );
    });
  });

  group('value objects and boundary validation', () {
    test('string value objects reject empty or untrimmed values', () {
      expect(() => VehicleId(''), throwsArgumentError);
      expect(() => VersionId(' 1.0'), throwsArgumentError);
      expect(() => ShareIdentifier('share-1 '), throwsArgumentError);
    });

    test('metric keys require a canonical vehicle-neutral shape', () {
      expect(MetricKey('battery.soc_percent').value, 'battery.soc_percent');
      expect(() => MetricKey('soc'), throwsArgumentError);
      expect(() => MetricKey('BYD.soc'), throwsArgumentError);
      expect(() => MetricKey('battery.SOC'), throwsArgumentError);
    });

    test('schema versions are positive', () {
      expect(SchemaVersion(1).value, 1);
      expect(() => SchemaVersion(0), throwsRangeError);
    });

    test('scaled measurements enforce signed-64 and scale boundaries', () {
      expect(
        MeasuredValue(
          scaledValue: -9223372036854775808,
          decimalScale: 0,
          unit: CanonicalUnit.ampere,
        ).scaledValue,
        -9223372036854775808,
      );
      expect(
        MeasuredValue(
          scaledValue: 9223372036854775807,
          decimalScale: 18,
          unit: CanonicalUnit.volt,
        ).decimalScale,
        18,
      );
      expect(
        () => MeasuredValue(
          scaledValue: 1,
          decimalScale: -1,
          unit: CanonicalUnit.count,
        ),
        throwsRangeError,
      );
    });

    test('score and weight include both boundaries and reject overflow', () {
      expect(BatteryScore(0).value, 0);
      expect(BatteryScore(100).value, 100);
      expect(() => BatteryScore(-1), throwsRangeError);
      expect(() => BatteryScore(101), throwsRangeError);
      expect(WeightBasisPoints(0).value, 0);
      expect(WeightBasisPoints(10000).value, 10000);
      expect(() => WeightBasisPoints(10001), throwsRangeError);
    });

    test('calculated and estimated metrics require reproducibility data', () {
      expect(
        () => MetricResult.calculated(
          value: _percent(98),
          inputKeys: const [],
          formulaId: 'soh',
          algorithmVersion: VersionId('1.0.0'),
        ),
        throwsArgumentError,
      );
      expect(
        MetricResult.estimated(
          value: _count(200),
          inputKeys: [MetricKey('usage.accumulated_charge_kwh')],
          formulaId: 'equivalent_full_cycles',
          algorithmVersion: VersionId('1.0.0'),
        ).value.provenance,
        ValueProvenance.estimated,
      );
    });
  });

  group('entity validation', () {
    test('vehicle validates optional year, text, UTC, and time order', () {
      expect(() => _vehicle(modelYear: 1885), throwsRangeError);
      expect(() => _vehicle(nickname: ' '), throwsArgumentError);
      expect(
        () => _vehicle(lastConfirmedAtUtc: DateTime(2026)),
        throwsArgumentError,
      );
      expect(
        () => _vehicle(
          lastConfirmedAtUtc: _createdAt.add(const Duration(seconds: 1)),
          updatedAtUtc: _createdAt,
        ),
        throwsArgumentError,
      );
    });

    test('adapter validates UTC and timestamp ordering', () {
      expect(
        () => _adapter(lastConnectedAtUtc: DateTime(2026)),
        throwsArgumentError,
      );
      expect(
        () => _adapter(
          lastConnectedAtUtc: _createdAt.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('scan enforces source, time, offset, and metric-list invariants', () {
      expect(() => _scan(adapterId: null), throwsArgumentError);
      expect(
        () => _scan(source: DataSource.demo, adapterId: AdapterId('adapter-1')),
        throwsArgumentError,
      );
      expect(
        _scan(source: DataSource.demo, adapterId: null).source,
        DataSource.demo,
      );
      expect(() => _scan(timezoneOffsetMinutes: -841), throwsRangeError);
      expect(() => _scan(timezoneOffsetMinutes: 841), throwsRangeError);
      expect(
        () => _scan(
          unavailableMetricKeys: [
            MetricKey('temperature.average_c'),
            MetricKey('temperature.average_c'),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => _scan(
          unavailableMetricKeys: [MetricKey('temperature.average_c')],
          invalidMetricKeys: [MetricKey('temperature.average_c')],
        ),
        throwsArgumentError,
      );
    });

    test('invalid raw readings require validation codes', () {
      expect(
        () => RawReading.unavailable(
          id: RawReadingId('reading-invalid'),
          scanId: ScanId('scan-1'),
          source: DataSource.real,
          metricKey: MetricKey('battery.soc_percent'),
          pidKey: PidKey('soc'),
          quality: ReadingQuality.valid,
          reason: UnavailableReason.outOfRange,
          measuredAtUtc: _scanTime,
        ),
        throwsArgumentError,
      );
      expect(
        () => RawReading.unavailable(
          id: RawReadingId('reading-invalid'),
          scanId: ScanId('scan-1'),
          source: DataSource.real,
          metricKey: MetricKey('battery.soc_percent'),
          pidKey: PidKey('soc'),
          quality: ReadingQuality.invalid,
          reason: UnavailableReason.outOfRange,
          measuredAtUtc: _scanTime,
        ),
        throwsArgumentError,
      );
    });

    test('analysis rejects non-calculated grades and duplicate components', () {
      expect(
        () => _analysis(
          overallGrade: ProvenancedValue.measured(AssessmentGrade.excellent),
        ),
        throwsArgumentError,
      );
      final duplicate = _component();
      expect(
        () => _analysis(componentScores: [duplicate, _component(score: 90)]),
        throwsArgumentError,
      );
    });

    test('report rejects duplicate item IDs and metric keys', () {
      final item = _insight();
      expect(() => _report(insightItems: [item, item]), throwsArgumentError);
      final technical = _technicalMeasured();
      expect(
        () => _report(technicalItems: [technical, technical]),
        throwsArgumentError,
      );
    });
  });

  group('source classification and provenance', () {
    test('all required source classifications are available', () {
      expect(DataSource.values, [
        DataSource.real,
        DataSource.demo,
        DataSource.test,
      ]);
    });

    test('provenance distinguishes every governed value category', () {
      expect(ValueProvenance.values, [
        ValueProvenance.measured,
        ValueProvenance.calculated,
        ValueProvenance.estimated,
        ValueProvenance.unavailable,
        ValueProvenance.demoDerived,
      ]);
    });

    test('demo readings are always explicitly demo-derived when available', () {
      final reading = RawReading.available(
        id: RawReadingId('demo-reading'),
        scanId: ScanId('demo-scan'),
        source: DataSource.demo,
        metricKey: MetricKey('battery.soc_percent'),
        pidKey: PidKey('demo_soc'),
        value: _percent(54),
        measuredAtUtc: _scanTime,
      );

      expect(reading.value.provenance, ValueProvenance.demoDerived);
    });

    test('real analysis and reports reject demo-derived values', () {
      expect(
        () => _analysis(sohPercent: MetricResult.demoDerived(_percent(98))),
        throwsArgumentError,
      );
      expect(
        () => _report(
          technicalItems: [
            ReportTechnicalItem(
              metricKey: MetricKey('battery.soc_percent'),
              label: 'State of charge',
              result: MetricResult.demoDerived(_percent(54)),
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('demo analysis and reports require demo-derived available values', () {
      expect(() => _analysis(source: DataSource.demo), throwsArgumentError);
      expect(() => _report(source: DataSource.demo), throwsArgumentError);
      expect(_demoAnalysis().source, DataSource.demo);
      expect(_demoReport().source, DataSource.demo);
    });

    test('test source may exercise production and demo provenance', () {
      expect(_analysis(source: DataSource.test).source, DataSource.test);
      expect(
        _report(
          source: DataSource.test,
          technicalItems: [
            ReportTechnicalItem(
              metricKey: MetricKey('battery.soc_percent'),
              label: 'State of charge',
              result: MetricResult.demoDerived(_percent(54)),
            ),
          ],
        ).source,
        DataSource.test,
      );
    });
  });

  group('collection immutability', () {
    test('scan snapshots defensively copy metric lists', () {
      final mutable = <MetricKey>[MetricKey('temperature.average_c')];
      final scan = _scan(unavailableMetricKeys: mutable);
      mutable.add(MetricKey('usage.charge_count'));

      expect(scan.unavailableMetricKeys, hasLength(1));
      expect(
        () => scan.unavailableMetricKeys.add(MetricKey('usage.charge_count')),
        throwsUnsupportedError,
      );
    });

    test('analysis defensively copies nested collections', () {
      final warnings = <AnalysisWarningCode>[
        AnalysisWarningCode('partial_data'),
      ];
      final inputs = <MetricKey>[MetricKey('battery.soh_percent')];
      final component = AnalysisComponentScore(
        component: AnalysisComponentKind.stateOfHealth,
        score: ProvenancedValue.calculated(BatteryScore(98)),
        weight: WeightBasisPoints(6000),
        ruleId: 'soh_v1',
        inputKeys: inputs,
      );
      final analysis = _analysis(
        componentScores: [component],
        warnings: warnings,
      );
      inputs.add(MetricKey('battery.soc_percent'));
      warnings.add(AnalysisWarningCode('another_warning'));

      expect(component.inputKeys, hasLength(1));
      expect(analysis.warnings, hasLength(1));
      expect(component.inputKeys.clear, throwsUnsupportedError);
      expect(analysis.componentScores.clear, throwsUnsupportedError);
      expect(analysis.warnings.clear, throwsUnsupportedError);
    });

    test('calculated metrics defensively copy input keys', () {
      final inputs = <MetricKey>[
        MetricKey('battery.current_nominal_capacity_ah'),
        MetricKey('battery.factory_capacity_ah'),
      ];
      final metric = MetricResult.calculated(
        value: _percent(98),
        inputKeys: inputs,
        formulaId: 'soh',
        algorithmVersion: VersionId('1.0.0'),
      );
      inputs.clear();

      expect(metric.inputKeys, hasLength(2));
      expect(metric.inputKeys.clear, throwsUnsupportedError);
    });

    test('report defensively copies item and supporting-metric lists', () {
      final supporting = <MetricKey>[MetricKey('battery.soh_percent')];
      final insights = <ReportInsightItem>[
        ReportInsightItem(
          id: ReportItemId('health-summary'),
          title: 'Battery health',
          body: 'Calculated from supported values.',
          supportingMetricKeys: supporting,
        ),
      ];
      final report = _report(insightItems: insights);
      supporting.add(MetricKey('battery.soc_percent'));
      insights.clear();

      expect(report.insightItems, hasLength(1));
      expect(report.insightItems.single.supportingMetricKeys, hasLength(1));
      expect(report.insightItems.clear, throwsUnsupportedError);
      expect(
        () => report.insightItems.single.supportingMetricKeys.clear(),
        throwsUnsupportedError,
      );
    });
  });
}

final _createdAt = DateTime.utc(2026, 7, 29, 10);
final _scanStart = DateTime.utc(2026, 7, 29, 10, 41, 55);
final _scanTime = DateTime.utc(2026, 7, 29, 10, 42);

VehicleProfileIdentity _profile() => VehicleProfileIdentity(
  id: VehicleProfileId('supported-profile'),
  version: VersionId('1.0.0'),
);

Vehicle _vehicle({
  int? modelYear,
  String? nickname,
  DateTime? lastConfirmedAtUtc,
  DateTime? updatedAtUtc,
}) => Vehicle(
  id: VehicleId('vehicle-1'),
  source: DataSource.real,
  manufacturer: 'Supported manufacturer',
  model: 'Supported model',
  variant: 'Supported variant',
  modelYear: modelYear,
  nickname: nickname,
  profile: _profile(),
  lastConfirmedAtUtc: lastConfirmedAtUtc ?? _createdAt,
  createdAtUtc: _createdAt,
  updatedAtUtc: updatedAtUtc ?? _createdAt,
);

Adapter _adapter({DateTime? lastConnectedAtUtc}) => Adapter(
  id: AdapterId('adapter-1'),
  source: DataSource.real,
  displayName: 'OBD adapter',
  adapterClass: 'ELM327-compatible',
  compatibilityStatus: AdapterCompatibilityStatus.unknown,
  lastConnectedAtUtc: lastConnectedAtUtc,
  createdAtUtc: _createdAt,
  updatedAtUtc: _createdAt,
);

BatteryScan _scan({
  DataSource source = DataSource.real,
  Object? adapterId = const _DefaultAdapterId(),
  int timezoneOffsetMinutes = 600,
  Iterable<MetricKey>? unavailableMetricKeys,
  Iterable<MetricKey> invalidMetricKeys = const [],
}) => BatteryScan(
  id: ScanId('scan-1'),
  vehicleId: VehicleId('vehicle-1'),
  adapterId: adapterId is _DefaultAdapterId
      ? AdapterId('adapter-1')
      : adapterId as AdapterId?,
  source: source,
  status: ScanStatus.partial,
  startedAtUtc: _scanStart,
  scannedAtUtc: _scanTime,
  timezoneOffsetMinutes: timezoneOffsetMinutes,
  profile: _profile(),
  pidMapVersion: VersionId('1.0.0'),
  parserVersion: VersionId('1.0.0'),
  appVersion: VersionId('1.0.0+1'),
  schemaVersion: SchemaVersion(1),
  conditions: ScanConditions(powerState: VehiclePowerState.on),
  unavailableMetricKeys:
      unavailableMetricKeys ?? [MetricKey('temperature.average_c')],
  invalidMetricKeys: invalidMetricKeys,
  createdAtUtc: _scanTime,
);

final class _DefaultAdapterId {
  const _DefaultAdapterId();
}

RawReading _reading() => RawReading.available(
  id: RawReadingId('reading-1'),
  scanId: ScanId('scan-1'),
  source: DataSource.real,
  metricKey: MetricKey('battery.soc_percent'),
  pidKey: PidKey('battery_soc'),
  value: _percent(54),
  measuredAtUtc: _scanTime,
  sourceNumericText: '54',
);

AnalysisComponentScore _component({int score = 98}) => AnalysisComponentScore(
  component: AnalysisComponentKind.stateOfHealth,
  score: ProvenancedValue.calculated(BatteryScore(score)),
  weight: WeightBasisPoints(6000),
  ruleId: 'soh_v1',
  inputKeys: [MetricKey('battery.soh_percent')],
);

AnalysisResult _analysis({
  DataSource source = DataSource.real,
  MetricResult? sohPercent,
  ProvenancedValue<AssessmentGrade>? overallGrade,
  Iterable<AnalysisComponentScore>? componentScores,
  Iterable<AnalysisWarningCode>? warnings,
}) => AnalysisResult(
  id: AnalysisResultId('analysis-1'),
  scanId: ScanId('scan-1'),
  source: source,
  engineVersion: VersionId('1.0.0'),
  scoringConfigVersion: VersionId('1.0.0'),
  thresholdConfigVersion: VersionId('1.0.0'),
  sohPercent:
      sohPercent ??
      MetricResult.calculated(
        value: _percent(98),
        inputKeys: [
          MetricKey('battery.current_nominal_capacity_ah'),
          MetricKey('battery.factory_capacity_ah'),
        ],
        formulaId: 'soh',
        algorithmVersion: VersionId('1.0.0'),
      ),
  cellDelta: MetricResult.calculated(
    value: MeasuredValue(
      scaledValue: 4,
      decimalScale: 3,
      unit: CanonicalUnit.volt,
    ),
    inputKeys: [
      MetricKey('cell.highest_voltage_v'),
      MetricKey('cell.lowest_voltage_v'),
    ],
    formulaId: 'cell_delta',
    algorithmVersion: VersionId('1.0.0'),
  ),
  temperatureSpread: MetricResult.calculated(
    value: MeasuredValue(
      scaledValue: 2,
      decimalScale: 0,
      unit: CanonicalUnit.celsius,
    ),
    inputKeys: [
      MetricKey('temperature.highest_c'),
      MetricKey('temperature.lowest_c'),
    ],
    formulaId: 'temperature_spread',
    algorithmVersion: VersionId('1.0.0'),
  ),
  equivalentFullCycles: MetricResult.unavailable(
    UnavailableReason.notCalculated,
  ),
  batteryScore: ProvenancedValue.calculated(BatteryScore(96)),
  overallGrade:
      overallGrade ?? ProvenancedValue.calculated(AssessmentGrade.excellent),
  capacityGrade: ProvenancedValue.calculated(AssessmentGrade.excellent),
  cellBalanceGrade: ProvenancedValue.calculated(AssessmentGrade.excellent),
  temperatureGrade: ProvenancedValue.unavailable(
    UnavailableReason.notCalculated,
  ),
  confidence: AnalysisConfidence.moderate,
  componentScores: componentScores ?? [_component()],
  warnings: warnings ?? [AnalysisWarningCode('partial_data')],
  createdAtUtc: _scanTime,
);

AnalysisResult _demoAnalysis() => AnalysisResult(
  id: AnalysisResultId('demo-analysis'),
  scanId: ScanId('demo-scan'),
  source: DataSource.demo,
  engineVersion: VersionId('demo-engine-1.0'),
  scoringConfigVersion: VersionId('demo-scoring-1.0'),
  thresholdConfigVersion: VersionId('demo-thresholds-1.0'),
  sohPercent: MetricResult.demoDerived(_percent(98)),
  cellDelta: MetricResult.demoDerived(
    MeasuredValue(scaledValue: 3, decimalScale: 3, unit: CanonicalUnit.volt),
  ),
  temperatureSpread: MetricResult.demoDerived(
    MeasuredValue(scaledValue: 2, decimalScale: 0, unit: CanonicalUnit.celsius),
  ),
  equivalentFullCycles: MetricResult.unavailable(
    UnavailableReason.notCalculated,
  ),
  batteryScore: ProvenancedValue.demoDerived(BatteryScore(96)),
  overallGrade: ProvenancedValue.demoDerived(AssessmentGrade.excellent),
  capacityGrade: ProvenancedValue.demoDerived(AssessmentGrade.excellent),
  cellBalanceGrade: ProvenancedValue.demoDerived(AssessmentGrade.excellent),
  temperatureGrade: ProvenancedValue.demoDerived(AssessmentGrade.excellent),
  confidence: AnalysisConfidence.high,
  componentScores: [
    AnalysisComponentScore(
      component: AnalysisComponentKind.stateOfHealth,
      score: ProvenancedValue.demoDerived(BatteryScore(98)),
      weight: WeightBasisPoints(6000),
      ruleId: 'demo_soh',
      inputKeys: [MetricKey('battery.soh_percent')],
    ),
  ],
  warnings: const [],
  createdAtUtc: _scanTime,
);

ReportInsightItem _insight() => ReportInsightItem(
  id: ReportItemId('health-summary'),
  title: 'Battery health',
  body: 'Calculated from supported values.',
  supportingMetricKeys: [MetricKey('battery.soh_percent')],
);

ReportTechnicalItem _technicalMeasured() => ReportTechnicalItem(
  metricKey: MetricKey('battery.soc_percent'),
  label: 'State of charge',
  result: MetricResult.measured(_percent(54)),
);

ReportSnapshot _report({
  DataSource source = DataSource.real,
  Iterable<ReportInsightItem>? insightItems,
  Iterable<ReportTechnicalItem>? technicalItems,
}) => ReportSnapshot(
  id: ReportSnapshotId('report-1'),
  scanId: ScanId('scan-1'),
  source: source,
  scanStatus: ScanStatus.partial,
  reportVersion: VersionId('1.0.0'),
  title: 'Battery health report',
  summaryText: 'A partial informational result.',
  insightItems: insightItems ?? [_insight()],
  technicalItems:
      technicalItems ??
      [
        _technicalMeasured(),
        ReportTechnicalItem(
          metricKey: MetricKey('battery.soh_percent'),
          label: 'State of health',
          result: MetricResult.calculated(
            value: _percent(98),
            inputKeys: [
              MetricKey('battery.current_nominal_capacity_ah'),
              MetricKey('battery.factory_capacity_ah'),
            ],
            formulaId: 'soh',
            algorithmVersion: VersionId('1.0.0'),
          ),
        ),
        ReportTechnicalItem(
          metricKey: MetricKey('temperature.average_c'),
          label: 'Average temperature',
          result: MetricResult.unavailable(UnavailableReason.commandTimeout),
        ),
      ],
  disclaimerVersion: VersionId('1.0.0'),
  generatedAtUtc: _scanTime,
  shareIdentifier: ShareIdentifier('share-1'),
);

ReportSnapshot _demoReport() => _report(
  source: DataSource.demo,
  technicalItems: [
    ReportTechnicalItem(
      metricKey: MetricKey('battery.soc_percent'),
      label: 'State of charge',
      result: MetricResult.demoDerived(_percent(54)),
    ),
    ReportTechnicalItem(
      metricKey: MetricKey('temperature.average_c'),
      label: 'Average temperature',
      result: MetricResult.unavailable(UnavailableReason.commandTimeout),
    ),
  ],
);

MeasuredValue _percent(int value) => MeasuredValue(
  scaledValue: value,
  decimalScale: 0,
  unit: CanonicalUnit.percent,
);

MeasuredValue _count(int value) => MeasuredValue(
  scaledValue: value,
  decimalScale: 0,
  unit: CanonicalUnit.count,
);
