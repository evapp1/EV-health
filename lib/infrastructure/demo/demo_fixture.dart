import 'package:ev_health/domain/models/domain_models.dart';

/// Fixed fictional dataset approved for demo mode and deterministic tests.
///
/// These values are not captured from or validated against a vehicle.
abstract final class DemoFixture {
  /// UTC equivalent of 29 July 2026, 8:42 pm AEST.
  static final scanTimeUtc = DateTime.utc(2026, 7, 29, 10, 42);

  /// Approved fictional BYD Dolphin Premium profile identity.
  static final profile = VehicleProfileIdentity(
    id: VehicleProfileId('byd_dolphin_premium_demo'),
    version: VersionId('byd_dolphin_premium_demo_1.0'),
  );

  /// Fictional demo vehicle. This does not claim production vehicle support.
  static final vehicle = Vehicle(
    id: VehicleId('demo-vehicle-byd-dolphin-premium'),
    source: DataSource.demo,
    manufacturer: 'BYD',
    model: 'Dolphin',
    variant: 'Premium',
    modelYear: 2024,
    profile: profile,
    lastConfirmedAtUtc: scanTimeUtc,
    createdAtUtc: scanTimeUtc,
    updatedAtUtc: scanTimeUtc,
  );

  /// Deterministic settings for the explicitly disclosed demo experience.
  static final settings = AppSettings(
    id: 'demo-settings',
    source: DataSource.demo,
    schemaVersion: SchemaVersion(1),
    onboardingComplete: true,
    temperatureUnit: TemperatureUnit.celsius,
    distanceUnit: DistanceUnit.kilometres,
    demoModeEnabled: true,
    lastVehicleId: vehicle.id,
    lastAdapterId: null,
    createdAtUtc: scanTimeUtc,
    updatedAtUtc: scanTimeUtc,
  );

  /// Representative completed fictional scan and its immutable report.
  static final completeScanBundle = ScanBundle(
    scan: _scan,
    readings: _readings,
    analysis: _analysis,
    report: _report,
  );

  static final _scan = BatteryScan(
    id: ScanId('demo-scan-complete-2026-07-29'),
    vehicleId: vehicle.id,
    adapterId: null,
    source: DataSource.demo,
    status: ScanStatus.complete,
    startedAtUtc: DateTime.utc(2026, 7, 29, 10, 41, 55),
    scannedAtUtc: scanTimeUtc,
    timezoneOffsetMinutes: 600,
    profile: profile,
    pidMapVersion: VersionId('demo_pid_map_1.0'),
    parserVersion: VersionId('demo_parser_1.0'),
    appVersion: VersionId('1.0.0+1'),
    schemaVersion: SchemaVersion(1),
    conditions: ScanConditions(
      powerState: VehiclePowerState.on,
      notes: 'Fictional demo conditions — no vehicle connection.',
    ),
    unavailableMetricKeys: const [],
    invalidMetricKeys: const [],
    createdAtUtc: scanTimeUtc,
  );

  static final _readings = <RawReading>[
    _reading(
      id: 'soc',
      metric: 'battery.soc_percent',
      value: _value(54, CanonicalUnit.percent),
    ),
    _reading(
      id: 'factory-capacity',
      metric: 'battery.factory_capacity_ah',
      value: _value(150400, CanonicalUnit.ampHour, scale: 3),
    ),
    _reading(
      id: 'current-capacity',
      metric: 'battery.current_nominal_capacity_ah',
      value: _value(147390, CanonicalUnit.ampHour, scale: 3),
    ),
    _reading(
      id: 'highest-cell',
      metric: 'cell.highest_voltage_v',
      value: _value(3343, CanonicalUnit.volt, scale: 3),
    ),
    _reading(
      id: 'lowest-cell',
      metric: 'cell.lowest_voltage_v',
      value: _value(3340, CanonicalUnit.volt, scale: 3),
    ),
    _reading(
      id: 'highest-temperature',
      metric: 'temperature.highest_c',
      value: _value(23, CanonicalUnit.celsius),
    ),
    _reading(
      id: 'lowest-temperature',
      metric: 'temperature.lowest_c',
      value: _value(21, CanonicalUnit.celsius),
    ),
    _reading(
      id: 'average-temperature',
      metric: 'temperature.average_c',
      value: _value(22, CanonicalUnit.celsius),
    ),
    _reading(
      id: 'accumulated-charge',
      metric: 'usage.accumulated_charge_kwh',
      value: _value(5696000, CanonicalUnit.wattHour),
    ),
    _reading(
      id: 'accumulated-discharge',
      metric: 'usage.accumulated_discharge_kwh',
      value: _value(5778000, CanonicalUnit.wattHour),
    ),
    _reading(
      id: 'charge-count',
      metric: 'usage.charge_count',
      value: _value(435, CanonicalUnit.count),
    ),
    _reading(
      id: 'pack-voltage',
      metric: 'battery.pack_voltage_v',
      value: _value(410, CanonicalUnit.volt),
    ),
    _reading(
      id: 'pack-current',
      metric: 'battery.pack_current_a',
      value: _value(12, CanonicalUnit.ampere, scale: 1),
    ),
  ];

  static final _analysis = AnalysisResult(
    id: AnalysisResultId('demo-analysis-complete-2026-07-29'),
    scanId: _scan.id,
    source: DataSource.demo,
    engineVersion: VersionId('demo_engine_1.0'),
    scoringConfigVersion: VersionId('demo_scoring_1.0'),
    thresholdConfigVersion: VersionId('demo_thresholds_1.0'),
    sohPercent: MetricResult.demoDerived(
      _value(980, CanonicalUnit.percent, scale: 1),
    ),
    cellDelta: MetricResult.demoDerived(
      _value(3, CanonicalUnit.volt, scale: 3),
    ),
    temperatureSpread: MetricResult.demoDerived(
      _value(2, CanonicalUnit.celsius),
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
      _component(
        kind: AnalysisComponentKind.stateOfHealth,
        score: 98,
        weight: 6000,
        ruleId: 'demo_soh_placeholder',
        input: 'battery.soh_percent',
      ),
      _component(
        kind: AnalysisComponentKind.cellBalance,
        score: 100,
        weight: 2000,
        ruleId: 'demo_cell_balance_placeholder',
        input: 'cell.delta_v',
      ),
      _component(
        kind: AnalysisComponentKind.temperature,
        score: 100,
        weight: 1000,
        ruleId: 'demo_temperature_placeholder',
        input: 'temperature.spread_c',
      ),
      _component(
        kind: AnalysisComponentKind.chargingBehaviour,
        score: 72,
        weight: 1000,
        ruleId: 'demo_charging_placeholder',
        input: 'usage.charge_count',
      ),
    ],
    warnings: const [],
    createdAtUtc: scanTimeUtc,
  );

  static final _report = ReportSnapshot(
    id: ReportSnapshotId('demo-report-complete-2026-07-29'),
    scanId: _scan.id,
    source: DataSource.demo,
    scanStatus: ScanStatus.complete,
    reportVersion: VersionId('demo_report_1.0'),
    title: 'Demo battery health report',
    summaryText:
        'Demo data — not read from a vehicle. Fictional sample values for '
        'product demonstration only.',
    insightItems: [
      ReportInsightItem(
        id: ReportItemId('demo-disclosure'),
        title: 'Demo data',
        body:
            'This fictional snapshot is not a vehicle assessment or vehicle '
            'validation.',
        supportingMetricKeys: const [],
      ),
      ReportInsightItem(
        id: ReportItemId('demo-periodic-scans'),
        title: 'Demo recommendation',
        body:
            'Demo placeholder: continue periodic scans under similar charge '
            'and temperature conditions.',
        supportingMetricKeys: [MetricKey('battery.soh_percent')],
      ),
      ReportInsightItem(
        id: ReportItemId('demo-cell-snapshot'),
        title: 'Demo cell snapshot',
        body:
            'Demo placeholder: this fictional snapshot contains a 3 mV cell '
            'voltage difference.',
        supportingMetricKeys: [MetricKey('cell.delta_v')],
      ),
    ],
    technicalItems: [
      ..._readings.map(
        (reading) => ReportTechnicalItem(
          metricKey: reading.metricKey,
          label: _labelFor(reading.metricKey.value),
          result: MetricResult.demoDerived(reading.value.value!),
        ),
      ),
      ReportTechnicalItem(
        metricKey: MetricKey('battery.soh_percent'),
        label: 'Calculated state of health — demo',
        result: _analysis.sohPercent,
      ),
      ReportTechnicalItem(
        metricKey: MetricKey('cell.delta_v'),
        label: 'Cell voltage difference — demo',
        result: _analysis.cellDelta,
      ),
      ReportTechnicalItem(
        metricKey: MetricKey('temperature.spread_c'),
        label: 'Temperature spread — demo',
        result: _analysis.temperatureSpread,
      ),
    ],
    disclaimerVersion: VersionId('demo_disclaimer_1.0'),
    generatedAtUtc: scanTimeUtc,
    shareIdentifier: ShareIdentifier('demo-share-not-vehicle-derived'),
  );

  static RawReading _reading({
    required String id,
    required String metric,
    required MeasuredValue value,
  }) => RawReading.available(
    id: RawReadingId('demo-reading-$id'),
    scanId: _scan.id,
    source: DataSource.demo,
    metricKey: MetricKey(metric),
    pidKey: PidKey('demo_fixture.$id'),
    value: value,
    measuredAtUtc: scanTimeUtc,
  );

  static MeasuredValue _value(
    int scaledValue,
    CanonicalUnit unit, {
    int scale = 0,
  }) =>
      MeasuredValue(scaledValue: scaledValue, decimalScale: scale, unit: unit);

  static AnalysisComponentScore _component({
    required AnalysisComponentKind kind,
    required int score,
    required int weight,
    required String ruleId,
    required String input,
  }) => AnalysisComponentScore(
    component: kind,
    score: ProvenancedValue.demoDerived(BatteryScore(score)),
    weight: WeightBasisPoints(weight),
    ruleId: ruleId,
    inputKeys: [MetricKey(input)],
  );

  static String _labelFor(String metricKey) => '$metricKey — demo';
}
