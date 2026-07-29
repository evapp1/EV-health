# EV Health Data Model Specification

**Version:** 1.0  
**Status:** MVP baseline

## 1. Purpose

Define the local-first data model for vehicles, adapters, scans, raw readings, calculated results, reports, settings, demo data, and future cloud extension points.

The MVP does not require accounts, VIN storage, GPS, or cloud synchronisation.

## 2. Principles

- Local-first and offline-capable.
- Immutable scan and report snapshots.
- Separate raw readings from derived metrics.
- Version schemas, parsers, vehicle profiles, and analysis rules.
- Never mix demo records with real scans.
- No silent migration or destructive data loss.
- Future cloud support must be additive and opt-in.

## 3. Entity overview

```text
AppSettings
VehicleProfile 1 ─── * Vehicle
Adapter 1 ─── * ScanSession
Vehicle 1 ─── * BatteryScan
BatteryScan 1 ─── * RawReading
BatteryScan 1 ─── 1 AnalysisResult
BatteryScan 1 ─── 1 ReportSnapshot
```

## 4. Core entities

### 4.1 AppSettings

| Field | Type | Notes |
|---|---|---|
| id | string | singleton key |
| schemaVersion | int | local settings schema |
| onboardingComplete | bool | first-run state |
| temperatureUnit | enum | celsius/fahrenheit |
| distanceUnit | enum | kilometres/miles |
| demoModeEnabled | bool | UI-only mode switch |
| lastVehicleId | string? | nullable |
| lastAdapterId | string? | nullable |
| createdAt | datetime | local timestamp |
| updatedAt | datetime | local timestamp |

### 4.2 Vehicle

| Field | Type | Notes |
|---|---|---|
| id | UUID | app-generated |
| make | string | `BYD` |
| model | string | `Dolphin Premium` |
| modelYear | int? | optional |
| vehicleProfileId | string | exact profile key |
| vehicleProfileVersion | string | immutable per scan snapshot |
| nickname | string? | user controlled |
| vinHash | string? | not used in MVP by default |
| createdAt | datetime | |
| updatedAt | datetime | |

The original VIN must not be stored by default.

### 4.3 Adapter

| Field | Type | Notes |
|---|---|---|
| id | UUID | app-generated |
| displayName | string | user-visible Bluetooth name |
| platformDeviceId | string | local platform identifier; never exported |
| adapterFamily | string? | e.g. ELM327-compatible |
| lastConnectedAt | datetime? | |
| compatibilityStatus | enum | unknown/working/failed |
| createdAt | datetime | |
| updatedAt | datetime | |

MAC addresses or platform identifiers must not appear in reports, PDFs, analytics, or cloud payloads.

### 4.4 ScanSession

Represents the live operational attempt and may be discarded after completion.

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| vehicleId | UUID | |
| adapterId | UUID | |
| source | enum | real/demo/test |
| state | enum | created/connecting/reading/analysing/completed/failed/cancelled |
| startedAt | datetime | |
| endedAt | datetime? | |
| failureCode | string? | typed code |
| completedSteps | list | progress restoration/debugging |

### 4.5 BatteryScan

Immutable completed or partial scan snapshot.

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| vehicleId | UUID | |
| adapterId | UUID? | null for demo |
| source | enum | real/demo/test |
| status | enum | complete/partial/unassessable |
| scannedAt | datetime | |
| vehicleProfileId | string | |
| vehicleProfileVersion | string | |
| pidMapVersion | string | |
| parserVersion | string | |
| appVersion | string | |
| schemaVersion | int | |
| socPercent | decimal? | measured |
| scanConditions | JSON | power state and notes |
| unavailableMetricKeys | list<string> | |
| invalidMetricKeys | list<string> | |
| createdAt | datetime | |

Once created, a BatteryScan is not updated except for safe migration of storage representation.

### 4.6 RawReading

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| scanId | UUID | |
| metricKey | string | canonical domain key |
| pidKey | string | vehicle-profile mapping key |
| rawResponse | string? | optional, redact sensitive values |
| parsedValue | decimal? | |
| unit | string | canonical SI/product unit |
| quality | enum | valid/invalid/missing/timeout/unsupported |
| measuredAt | datetime | |
| validationCode | string? | |

Raw protocol logs should be retained only when Developer Mode explicitly enables them. Normal scans need only the minimal raw value necessary for auditability.

### 4.7 AnalysisResult

Immutable result generated for a scan.

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| scanId | UUID | unique |
| engineVersion | string | |
| scoringConfigVersion | string | |
| thresholdConfigVersion | string | |
| sohPercent | decimal? | calculated |
| cellDeltaMv | decimal? | calculated |
| temperatureSpreadC | decimal? | calculated |
| equivalentFullCycles | decimal? | estimated |
| batteryScore | int? | 0–100 |
| overallGrade | enum | |
| capacityGrade | enum | |
| cellBalanceGrade | enum | |
| temperatureGrade | enum | |
| confidence | enum | high/moderate/limited/unavailable |
| componentScores | JSON | values and weights |
| warnings | list<string> | typed keys |
| createdAt | datetime | |

### 4.8 ReportSnapshot

Stores exactly what the user saw and shared.

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| scanId | UUID | unique |
| reportVersion | string | presentation schema |
| title | string | |
| summaryText | string | deterministic template output |
| insightItems | JSON | ordered cards |
| technicalItems | JSON | ordered rows |
| disclaimerVersion | string | |
| generatedAt | datetime | |
| pdfFilePath | string? | local only |
| shareIdentifier | string | random local ID, not VIN-based |

Historical report content must not change when templates or thresholds change later.

## 5. Canonical metric keys

Examples:

```text
battery.factory_capacity_ah
battery.current_nominal_capacity_ah
battery.pack_voltage_v
battery.pack_current_a
battery.soc_percent
cell.highest_voltage_v
cell.lowest_voltage_v
temperature.highest_c
temperature.lowest_c
usage.charge_count
usage.accumulated_charge_kwh
usage.accumulated_discharge_kwh
```

Vehicle-specific PID names map into these canonical keys.

## 6. Storage technology

The Architecture Specification selects the concrete Flutter persistence library. Required capabilities:

- typed local records
- indexed scan history by vehicle and date
- transactions
- schema migrations
- testable in-memory implementation
- export-safe serialisation

Repositories isolate the domain from the storage package.

## 7. Repository interfaces

```dart
abstract interface class VehicleRepository {
  Future<List<Vehicle>> listVehicles();
  Future<Vehicle?> getVehicle(String id);
  Future<void> saveVehicle(Vehicle vehicle);
}

abstract interface class ScanRepository {
  Future<void> saveCompletedScan(ScanBundle bundle);
  Future<List<BatteryScan>> listScans(String vehicleId);
  Future<ScanBundle?> getScan(String scanId);
  Future<void> deleteScan(String scanId);
}

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
```

A `ScanBundle` is written transactionally and contains the scan, readings, analysis result, and report snapshot.

## 8. Demo data separation

- `source=demo` is mandatory on all demo records.
- Demo scans use a separate repository or separate indexed partition.
- Demo reports must display `Demo data — not read from a vehicle`.
- Demo scans must not appear in real history by default.
- Demo data must never be uploaded to future benchmark services.

## 9. Deletion and retention

- Users may delete individual reports or all local data.
- Deleting a BatteryScan deletes associated RawReadings, AnalysisResult, ReportSnapshot, and generated files transactionally.
- Forgetting an adapter must not delete reports.
- No automatic expiration in MVP.
- Temporary protocol logs should be short-lived and disabled by default.

## 10. Schema versioning and migrations

Persist a database schema version. Every migration must:

1. be deterministic
2. preserve immutable scan meaning
3. be covered by migration tests
4. create a backup or fail safely where supported
5. never reinterpret historical analysis results

If new derived fields are introduced, historical records remain null unless a separate re-analysis record is explicitly created.

## 11. Privacy and export

Excluded from standard export and PDF:

- original VIN
- platform Bluetooth identifiers
- MAC address
- precise location
- owner identity
- raw protocol logs

JSON diagnostic export, if later added, requires explicit user action and clear disclosure.

## 12. Future cloud extension points

Future opt-in synchronisation may add:

- anonymous installation ID
- salted vehicle continuity token
- cloud upload state
- benchmark cohort keys
- consent record and consent version

These fields are not required for MVP. Cloud DTOs must be separate from local domain entities so private local fields cannot be uploaded accidentally.

## 13. Acceptance criteria

- Real, demo, and test data cannot be confused.
- Completed scans and reports are immutable snapshots.
- Scan bundles save atomically.
- Repository interfaces hide the storage implementation.
- Every record includes required schema and algorithm versions.
- Deletion removes dependent data and local files.
- Standard reports contain no personal or device identifiers.
- Migration tests cover every schema change.
