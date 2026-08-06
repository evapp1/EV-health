import 'package:ev_health/application/home/home_controller.dart';
import 'package:ev_health/domain/models/analysis_result.dart';
import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/measured_value.dart';
import 'package:ev_health/domain/models/raw_reading.dart';
import 'package:ev_health/domain/models/scan_bundle.dart';

/// Preformatted presentation data for the Home screen.
final class HomeViewData {
  /// Maps repository-backed application state into display-only values.
  factory HomeViewData.from(HomeData home) {
    final vehicle = home.vehicle;
    final latest = home.latestScan;

    return HomeViewData._(
      isDemo: home.isDemoMode,
      vehicleName:
          '${vehicle.manufacturer} ${vehicle.model} ${vehicle.variant}',
      vehicleDetail: [
        if (vehicle.modelYear != null) vehicle.modelYear.toString(),
        'Demo vehicle profile',
      ].join(' • '),
      profileVersion: vehicle.profile.version.value,
      recentScan: latest == null ? null : RecentHomeScanViewData.from(latest),
    );
  }

  const HomeViewData._({
    required this.isDemo,
    required this.vehicleName,
    required this.vehicleDetail,
    required this.profileVersion,
    required this.recentScan,
  });

  /// Whether every displayed value belongs to demo mode.
  final bool isDemo;

  /// Supported vehicle display name.
  final String vehicleName;

  /// Model-year and profile classification summary.
  final String vehicleDetail;

  /// Exact demo profile version.
  final String profileVersion;

  /// Latest completed demo result, or null for the no-scan state.
  final RecentHomeScanViewData? recentScan;
}

/// Preformatted latest-result content for Home.
final class RecentHomeScanViewData {
  /// Maps the immutable latest bundle without recalculating battery results.
  factory RecentHomeScanViewData.from(ScanBundle bundle) {
    final analysis = bundle.analysis;
    final scan = bundle.scan;
    final readings = bundle.readings;

    return RecentHomeScanViewData._(
      healthValue: _formatPercent(analysis.sohPercent.value.value),
      scoreValue: _formatScore(analysis.batteryScore.value),
      gradeValue: _formatGrade(analysis.overallGrade.value),
      healthStatus: 'Excellent — demo placeholder',
      scanTimeLabel: _formatScanTime(
        scan.scannedAtUtc,
        scan.timezoneOffsetMinutes,
      ),
      completenessLabel: '12 of 12 required demo readings available',
      confidence: analysis.confidence,
      remainingCapacity: _formatReading(
        readings,
        'battery.current_nominal_capacity_ah',
        suffix: 'Ah',
      ),
      cellDelta: _formatMillivolts(analysis.cellDelta.value.value),
      temperatureSpread: _formatTemperature(
        analysis.temperatureSpread.value.value,
      ),
    );
  }

  const RecentHomeScanViewData._({
    required this.healthValue,
    required this.scoreValue,
    required this.gradeValue,
    required this.healthStatus,
    required this.scanTimeLabel,
    required this.completenessLabel,
    required this.confidence,
    required this.remainingCapacity,
    required this.cellDelta,
    required this.temperatureSpread,
  });

  /// Demo state-of-health summary.
  final String healthValue;

  /// Demo battery score summary.
  final String scoreValue;

  /// Demo grade summary.
  final String gradeValue;

  /// Controlled demo-only health status.
  final String healthStatus;

  /// Unambiguous snapshot time.
  final String scanTimeLabel;

  /// Demo fixture completeness.
  final String completenessLabel;

  /// Confidence already classified by the immutable analysis snapshot.
  final AnalysisConfidence confidence;

  /// Fictional remaining-capacity sample.
  final String remainingCapacity;

  /// Cell voltage difference calculated in the demo fixture.
  final String cellDelta;

  /// Temperature spread calculated in the demo fixture.
  final String temperatureSpread;
}

String _formatPercent(MeasuredValue? value) {
  return value == null ? 'Unavailable' : '${_decimalText(value)}%';
}

String _formatScore(BatteryScore? value) {
  return value == null ? 'Not calculated' : '${value.value}/100';
}

String _formatGrade(AssessmentGrade? value) {
  return switch (value) {
    AssessmentGrade.excellent => 'A',
    AssessmentGrade.good => 'B',
    AssessmentGrade.fair => 'C',
    AssessmentGrade.monitor => 'D',
    null => 'Not calculated',
  };
}

String _formatReading(
  List<RawReading> readings,
  String metricKey, {
  required String suffix,
}) {
  for (final reading in readings) {
    if (reading.metricKey.value == metricKey) {
      final value = reading.value.value;
      return value == null ? 'Unavailable' : '${_decimalText(value)} $suffix';
    }
  }
  return 'Unavailable';
}

String _formatMillivolts(MeasuredValue? value) {
  if (value == null) {
    return 'Unavailable';
  }
  final millivolts = value.decimalScale == 3
      ? value.scaledValue
      : (value.scaledValue * 1000) ~/ _powerOfTen(value.decimalScale);
  return '$millivolts mV';
}

String _formatTemperature(MeasuredValue? value) {
  return value == null ? 'Unavailable' : '${_decimalText(value)} °C';
}

String _decimalText(MeasuredValue value) {
  final negative = value.scaledValue < 0;
  final digits = value.scaledValue.abs().toString().padLeft(
    value.decimalScale + 1,
    '0',
  );
  if (value.decimalScale == 0) {
    return '${negative ? '-' : ''}$digits';
  }

  final split = digits.length - value.decimalScale;
  final fraction = digits.substring(split).replaceFirst(RegExp(r'0+$'), '');
  final sign = negative ? '-' : '';
  return fraction.isEmpty
      ? '$sign${digits.substring(0, split)}'
      : '$sign${digits.substring(0, split)}.$fraction';
}

int _powerOfTen(int exponent) {
  var result = 1;
  for (var index = 0; index < exponent; index += 1) {
    result *= 10;
  }
  return result;
}

String _formatScanTime(DateTime utc, int offsetMinutes) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = utc.add(Duration(minutes: offsetMinutes));
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'am' : 'pm';
  final zone = offsetMinutes == 600 ? 'AEST' : _offsetLabel(offsetMinutes);
  return 'Scanned ${local.day} ${months[local.month - 1]} ${local.year}, '
      '$hour:$minute $period $zone';
}

String _offsetLabel(int offsetMinutes) {
  final sign = offsetMinutes < 0 ? '-' : '+';
  final absolute = offsetMinutes.abs();
  final hours = (absolute ~/ 60).toString().padLeft(2, '0');
  final minutes = (absolute % 60).toString().padLeft(2, '0');
  return 'UTC$sign$hours:$minutes';
}
