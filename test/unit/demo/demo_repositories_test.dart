import 'package:ev_health/domain/models/domain_models.dart';
import 'package:ev_health/domain/repositories/repositories.dart';
import 'package:ev_health/infrastructure/demo/demo_repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoVehicleRepository', () {
    test(
      'returns the approved fictional BYD Dolphin Premium profile',
      () async {
        final VehicleRepository repository = DemoVehicleRepository();

        final firstRead = await repository.listVehicles();
        final secondRead = await repository.listVehicles();
        final vehicle = firstRead.single;

        expect(secondRead, firstRead);
        expect(vehicle.source, DataSource.demo);
        expect(vehicle.manufacturer, 'BYD');
        expect(vehicle.model, 'Dolphin');
        expect(vehicle.variant, 'Premium');
        expect(vehicle.modelYear, 2024);
        expect(vehicle.profile.id.value, contains('demo'));
        expect(vehicle.profile.version.value, 'byd_dolphin_premium_demo_1.0');
        expect(await repository.getVehicle(vehicle.id), vehicle);
        expect(await repository.getVehicle(VehicleId('missing')), isNull);
        expect(firstRead.clear, throwsUnsupportedError);
      },
    );

    test('supports an immutable empty state and rejects writes', () async {
      final repository = DemoVehicleRepository.empty();

      final vehicles = await repository.listVehicles();

      expect(vehicles, isEmpty);
      expect(() => vehicles.add(DemoFixture.vehicle), throwsUnsupportedError);
      await expectLater(
        repository.saveVehicle(DemoFixture.vehicle),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
    });
  });

  group('DemoScanRepository', () {
    test(
      'returns deterministic completed scan data and typed models',
      () async {
        final ScanRepository repository = DemoScanRepository();
        final vehicleId = DemoFixture.vehicle.id;

        final firstRead = await repository.listScans(vehicleId);
        final secondRead = await repository.listScans(vehicleId);
        final scan = firstRead.single;
        final bundle = await repository.getScan(scan.id);

        expect(secondRead, firstRead);
        expect(scan.source, DataSource.demo);
        expect(scan.status, ScanStatus.complete);
        expect(scan.adapterId, isNull);
        expect(scan.profile.version.value, 'byd_dolphin_premium_demo_1.0');
        expect(scan.scannedAtUtc, DateTime.utc(2026, 7, 29, 10, 42));
        expect(bundle, isNotNull);
        expect(bundle!.scan, scan);
        expect(bundle.readings, hasLength(13));
        expect(bundle.analysis.batteryScore.value!.value, 96);
        expect(bundle.analysis.sohPercent.value.value!.scaledValue, 980);
        expect(bundle.analysis.cellDelta.value.value!.scaledValue, 3);
        expect(bundle.analysis.temperatureSpread.value.value!.scaledValue, 2);
        expect(
          _reading(
            bundle,
            'battery.current_nominal_capacity_ah',
          ).value.value!.scaledValue,
          147390,
        );
        expect(
          _reading(
            bundle,
            'battery.factory_capacity_ah',
          ).value.value!.scaledValue,
          150400,
        );
        expect(
          _reading(bundle, 'battery.pack_voltage_v').value.value!.scaledValue,
          410,
        );
        expect(firstRead.clear, throwsUnsupportedError);
        expect(bundle.readings.clear, throwsUnsupportedError);
        _expectBundleIsOnlyDemo(bundle);
      },
    );

    test('supports filtered, missing, and empty states', () async {
      final repository = DemoScanRepository();
      final emptyRepository = DemoScanRepository.empty();

      expect(await repository.listScans(VehicleId('missing')), isEmpty);
      expect(await repository.getScan(ScanId('missing')), isNull);
      expect(await emptyRepository.listScans(DemoFixture.vehicle.id), isEmpty);
      expect(
        await emptyRepository.getScan(DemoFixture.completeScanBundle.scan.id),
        isNull,
      );
    });

    test('cannot persist or delete demo scans', () async {
      final repository = DemoScanRepository();
      final bundle = DemoFixture.completeScanBundle;

      await expectLater(
        repository.saveCompletedScan(bundle),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
      await expectLater(
        repository.deleteScan(bundle.scan.id),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
    });
  });

  group('DemoReportRepository', () {
    test(
      'returns a deterministic and permanently labelled demo report',
      () async {
        final ReportRepository repository = DemoReportRepository();

        final firstRead = await repository.listReports();
        final secondRead = await repository.listReports();
        final report = firstRead.single;

        expect(secondRead, firstRead);
        expect(report.source, DataSource.demo);
        expect(report.scanStatus, ScanStatus.complete);
        expect(report.title, 'Demo battery health report');
        expect(
          report.summaryText,
          contains('Demo data — not read from a vehicle'),
        );
        expect(report.reportVersion.value, contains('demo'));
        expect(report.technicalItems, isNotEmpty);
        expect(
          report.technicalItems.every(
            (item) =>
                item.result.value.provenance == ValueProvenance.demoDerived ||
                item.result.value.provenance == ValueProvenance.unavailable,
          ),
          isTrue,
        );
        expect(await repository.getReport(report.id), report);
        expect(await repository.getReport(ReportSnapshotId('missing')), isNull);
        expect(firstRead.clear, throwsUnsupportedError);
        expect(report.technicalItems.clear, throwsUnsupportedError);
      },
    );

    test('supports an empty state and cannot persist demo reports', () async {
      final emptyRepository = DemoReportRepository.empty();
      final repository = DemoReportRepository();
      final report = DemoFixture.completeScanBundle.report;

      expect(await emptyRepository.listReports(), isEmpty);
      await expectLater(
        repository.saveReport(report),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
      await expectLater(
        repository.deleteReport(report.id),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
    });
  });

  group('DemoSettingsRepository', () {
    test('returns deterministic metric demo-mode settings', () async {
      const SettingsRepository repository = DemoSettingsRepository();

      final firstRead = await repository.load();
      final secondRead = await repository.load();

      expect(secondRead, firstRead);
      expect(firstRead.source, DataSource.demo);
      expect(firstRead.demoModeEnabled, isTrue);
      expect(firstRead.onboardingComplete, isTrue);
      expect(firstRead.temperatureUnit, TemperatureUnit.celsius);
      expect(firstRead.distanceUnit, DistanceUnit.kilometres);
      expect(firstRead.lastVehicleId, DemoFixture.vehicle.id);
      expect(firstRead.lastAdapterId, isNull);
    });

    test('cannot persist demo settings', () async {
      const repository = DemoSettingsRepository();

      await expectLater(
        repository.save(DemoFixture.settings),
        throwsA(isA<DemoRepositoryWriteException>()),
      );
    });
  });

  group('DemoHistoryRepository', () {
    test('returns deterministic immutable scan and report history', () async {
      final HistoryRepository repository = DemoHistoryRepository();

      final firstRead = await repository.listHistory();
      final secondRead = await repository.listHistory();

      expect(secondRead, firstRead);
      expect(firstRead, hasLength(1));
      expect(firstRead.single.scan.status, ScanStatus.complete);
      expect(firstRead.single.report.scanId, firstRead.single.scan.id);
      expect(firstRead.clear, throwsUnsupportedError);
      _expectBundleIsOnlyDemo(firstRead.single);
    });

    test('supports an immutable empty history state', () async {
      final repository = DemoHistoryRepository.empty();

      final history = await repository.listHistory();

      expect(history, isEmpty);
      expect(
        () => history.add(DemoFixture.completeScanBundle),
        throwsUnsupportedError,
      );
    });
  });
}

RawReading _reading(ScanBundle bundle, String metricKey) => bundle.readings
    .singleWhere((reading) => reading.metricKey.value == metricKey);

void _expectBundleIsOnlyDemo(ScanBundle bundle) {
  expect(bundle.source, DataSource.demo);
  expect(bundle.scan.source, DataSource.demo);
  expect(bundle.analysis.source, DataSource.demo);
  expect(bundle.report.source, DataSource.demo);
  expect(
    bundle.readings.every((reading) => reading.source == DataSource.demo),
    isTrue,
  );
  expect(
    bundle.readings.every(
      (reading) => reading.value.provenance == ValueProvenance.demoDerived,
    ),
    isTrue,
  );
  expect(<DataSource>[
    bundle.scan.source,
    bundle.analysis.source,
    bundle.report.source,
    ...bundle.readings.map((reading) => reading.source),
  ], isNot(contains(DataSource.real)));
}
