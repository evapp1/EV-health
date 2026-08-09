import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('required architecture boundaries exist', () {
    const requiredDirectories = <String>[
      'lib/app',
      'lib/core',
      'lib/domain',
      'lib/application',
      'lib/data',
      'lib/features',
      'lib/infrastructure',
      'lib/infrastructure/bluetooth',
      'lib/infrastructure/elm327',
      'lib/infrastructure/obd',
      'lib/infrastructure/vehicles',
      'lib/infrastructure/persistence',
      'lib/infrastructure/export',
      'lib/infrastructure/battery',
    ];

    for (final path in requiredDirectories) {
      expect(Directory(path).existsSync(), isTrue, reason: '$path must exist');
    }
  });

  test('presentation does not import infrastructure', () {
    final presentationFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in presentationFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('infrastructure/')),
        reason: '${file.path} imports an infrastructure implementation',
      );
    }
  });

  test('Home presentation imports neither data nor infrastructure', () {
    final homeFiles = Directory('lib/features/home')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in homeFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        isNot(contains('package:ev_health/data/')),
        reason: '${file.path} imports a data implementation',
      );
      expect(
        source,
        isNot(contains('package:ev_health/infrastructure/')),
        reason: '${file.path} imports an infrastructure implementation',
      );
    }
  });

  test(
    'adapter discovery mock uses no platform Bluetooth or permission API',
    () {
      const forbiddenDetails = <String>[
        'package:ev_health/infrastructure/',
        'package:flutter/services.dart',
        'permission_handler',
        'MethodChannel',
        'BluetoothAdapter',
        'BluetoothDevice',
        'BLUETOOTH_SCAN',
        'BLUETOOTH_CONNECT',
      ];
      const roots = <String>[
        'lib/application/adapter_discovery',
        'lib/features/adapter_discovery',
      ];

      for (final root in roots) {
        final files = Directory(root)
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'));
        for (final file in files) {
          final source = file.readAsStringSync();
          for (final forbiddenDetail in forbiddenDetails) {
            expect(
              source,
              isNot(contains(forbiddenDetail)),
              reason: '${file.path} references real API $forbiddenDetail',
            );
          }
        }
      }

      final manifests = Directory('android')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('AndroidManifest.xml'));
      for (final manifest in manifests) {
        final source = manifest.readAsStringSync();
        expect(source, isNot(contains('BLUETOOTH_SCAN')));
        expect(source, isNot(contains('BLUETOOTH_CONNECT')));
      }
    },
  );

  test(
    'vehicle confirmation invokes no live vehicle, Bluetooth, OBD, or telemetry API',
    () {
      const forbiddenDetails = <String>[
        'package:ev_health/infrastructure/',
        'package:ev_health/data/',
        'package:flutter/services.dart',
        'MethodChannel',
        'BluetoothAdapter',
        'BluetoothDevice',
        'Elm327',
        'ObdCommand',
        'Telemetry',
        'readVin',
        'readVIN',
        'BLUETOOTH_SCAN',
        'BLUETOOTH_CONNECT',
      ];
      const roots = <String>[
        'lib/application/vehicle_confirmation',
        'lib/features/vehicle_confirmation',
      ];

      for (final root in roots) {
        final files = Directory(root)
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'));
        for (final file in files) {
          final source = file.readAsStringSync();
          for (final forbiddenDetail in forbiddenDetails) {
            expect(
              source,
              isNot(contains(forbiddenDetail)),
              reason: '${file.path} references live API $forbiddenDetail',
            );
          }
        }
      }
    },
  );

  test('scan preparation imports no data/infrastructure or live scan APIs', () {
    const forbiddenDetails = <String>[
      'package:ev_health/infrastructure/',
      'package:ev_health/data/',
      'package:flutter/services.dart',
      'MethodChannel',
      'BluetoothAdapter',
      'BluetoothDevice',
      'Elm327',
      'ObdCommand',
      'Telemetry',
      'ScanEngine',
      'readPid',
      'readPID',
      'BLUETOOTH_SCAN',
      'BLUETOOTH_CONNECT',
    ];
    const roots = <String>[
      'lib/application/scan_preparation',
      'lib/features/scan_preparation',
    ];

    for (final root in roots) {
      final files = Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final forbiddenDetail in forbiddenDetails) {
          expect(
            source,
            isNot(contains(forbiddenDetail)),
            reason: '${file.path} references live API $forbiddenDetail',
          );
        }
      }
    }
  });

  test('application does not import presentation or infrastructure', () {
    const forbiddenImports = <String>['features/', 'infrastructure/'];
    final applicationFiles = Directory('lib/application')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in applicationFiles) {
      final source = file.readAsStringSync();
      for (final forbiddenImport in forbiddenImports) {
        expect(
          source,
          isNot(contains(forbiddenImport)),
          reason: '${file.path} imports forbidden dependency $forbiddenImport',
        );
      }
    }
  });

  test('domain remains independent of framework and implementation layers', () {
    const forbiddenImports = <String>[
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:riverpod_annotation/',
      'package:drift/',
      'package:ev_health/app/',
      'package:ev_health/application/',
      'package:ev_health/data/',
      'package:ev_health/features/',
      'package:ev_health/infrastructure/',
    ];
    final domainFiles = Directory('lib/domain')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in domainFiles) {
      final source = file.readAsStringSync();
      for (final forbiddenImport in forbiddenImports) {
        expect(
          source,
          isNot(contains(forbiddenImport)),
          reason: '${file.path} imports forbidden dependency $forbiddenImport',
        );
      }
    }
  });

  test('repository interfaces expose no infrastructure details', () {
    const forbiddenDetails = <String>[
      'package:ev_health/infrastructure/',
      'package:ev_health/data/',
      'package:drift/',
      'sqlite',
      'json',
      'Map<String, dynamic>',
    ];
    final repositoryFiles = Directory('lib/domain/repositories')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in repositoryFiles) {
      final source = file.readAsStringSync();
      for (final forbiddenDetail in forbiddenDetails) {
        expect(
          source,
          isNot(contains(forbiddenDetail)),
          reason: '${file.path} exposes infrastructure detail $forbiddenDetail',
        );
      }
    }
  });
}
