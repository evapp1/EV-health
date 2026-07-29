# EV Health Architecture Specification

**Version:** 1.0  
**Status:** Implementation baseline  
**Platform:** Android-first Flutter application  
**MVP vehicle:** BYD Dolphin Premium, one verified reference vehicle and battery variant  
**MVP adapter:** ELM327-compatible Bluetooth Classic OBD adapter using RFCOMM/SPP  
**Last updated:** 29 July 2026  
**Document owner:** EV Health product team

---

## 1. Purpose

This document defines the software architecture for the EV Health v1.0 MVP. It is the implementation contract for coding agents and future maintainers.

The architecture is deliberately small:

- One Flutter application.
- One local SQLite database.
- One active OBD session at a time.
- One production vehicle profile.
- One deterministic Battery Intelligence Engine.
- No account, backend, cloud sync, DTC scan, background monitor, or vehicle write operation.

The design still creates explicit boundaries around Bluetooth, ELM327, vehicle-specific data, calculations, persistence, reporting, and presentation. Those boundaries are required because the riskiest parts of this product—adapter behaviour, proprietary PIDs, scoring rules, and future vehicle support—will change at different rates.

This specification must be detailed enough that an AI coding agent does not need to choose a folder layout, dependency direction, state-management style, persistence model, error taxonomy, Bluetooth ownership model, or extension strategy.

---

## 2. Governing Documents and Precedence

The following project documents govern this specification:

1. Applicable law, Google Play policy, Android platform requirements, privacy commitments, and safety requirements.
2. `EV_Health_SDS_v1.0.md`, version 1.0, Approved Baseline.
3. The EV Health Product Requirements Document and its approved product decisions.
4. `EV_Health_UI_UX_Design_Specification_v1.0.md`, version 1.0.
5. This Architecture Specification.
6. Feature plans, tasks, generated code, and implementation notes.

Where a lower-precedence source is more recent and explicitly resolves an ambiguity without violating a higher-precedence requirement, this document records the resolution.

### 2.1 Resolutions carried into this architecture

- BYD Dolphin in the SDS means the single verified BYD Dolphin Premium reference vehicle for v1.0.
- Cloud sync is excluded from v1.0. Local-first operation is mandatory.
- PDF export is required for v1.0. The shareable image path described by the UI/UX specification uses the same export boundary and may be completed after PDF, but it must not contaminate the PDF or scan domain.
- DTC scanning is excluded from v1.0 and deferred to v1.1.
- Raw VIN may be used transiently for vehicle detection but is never displayed, logged, persisted, included in an export, or transmitted.
- Raw diagnostic data is visible only in explicitly enabled Developer Mode.
- Remaining-life estimates and recommendations must be deterministic, versioned, qualified, and approved. Until their policies are approved, the engine returns `Not calculated` or `No recommendation available from this scan`.
- Battery Score weights are constitutional for Engine v1: SOH 60%, cell balance 20%, temperature 10%, charging behaviour 10%. Normalisation curves and grade thresholds are calibration data and must not be invented by a coding agent.

### 2.2 Scope rule

Anything not expressly included in the governing documents or this specification is out of scope. In particular, a coding agent must not add:

- Network calls, remote configuration, analytics, crash reporting, advertising, or authentication.
- DTC reads or clears.
- ECU writes, resets, actuator tests, coding, or tuning.
- Background scans or continuous dashboards.
- Unverified vehicle profiles or proprietary PID guesses.
- Free-text AI recommendations.
- Certification, roadworthiness, warranty, diagnosis, or guaranteed-lifespan claims.

---

## 3. Architecture Goals

### 3.1 Primary goals

1. **Trustworthy data flow.** Every displayed result is traceable to a vehicle observation, a validation rule, and a versioned calculation.
2. **Safe read-only operation.** Only approved read commands and adapter-configuration commands are allowed. Vehicle write commands have no application API.
3. **Offline operation.** Connection, scanning, analysis, history, report viewing, PDF generation, settings, and demo mode work without internet.
4. **Replaceable hardware integration.** Bluetooth and ELM327 packages are hidden behind ports so a plugin can be replaced without changing application or UI code.
5. **Vehicle isolation.** BYD-specific commands, addressing, decoders, ranges, and verification evidence live in a versioned vehicle profile.
6. **Deterministic intelligence.** Battery analysis is a pure, versioned operation with no network or model dependency.
7. **Immutable history.** A completed scan is stored as an immutable snapshot. Later algorithm changes never silently rewrite old results.
8. **Honest partial data.** Missing, unsupported, invalid, and timed-out readings remain distinct and never become zero.
9. **AI-buildable simplicity.** Prefer a small number of explicit layers, typed contracts, generated immutable models, and deterministic tests.
10. **Future extension without premature infrastructure.** Make room for a backend and more vehicles through ports and identifiers, but do not implement them in v1.0.

### 3.2 Quality targets

| Quality | MVP target |
|---|---|
| Reference adapter connection | Within 5 seconds where possible under documented conditions |
| Reference vehicle scan | Under 10 seconds under documented conditions |
| Crash-free sessions | Greater than 99% for a documented release sample |
| Offline capability | 100% of core MVP functions |
| Data integrity | No fabricated zero, no unvalidated derived value |
| Scan persistence | Atomic and recoverable across app restart |
| Accessibility | Core flow usable with TalkBack and 200% font scale |
| Report quality | A4, unclipped, grayscale-readable, source values verified |

### 3.3 Non-goals

The architecture does not attempt to provide:

- A microservice or multi-package enterprise platform.
- Runtime-downloaded vehicle profiles.
- A generic OBD workshop toolkit.
- ISO 26262 functional-safety certification.
- Cryptographically certified public reports.
- High-frequency telemetry storage.
- Cross-device sync.
- A plugin marketplace inside the app.

---

## 4. Constraints and Assumptions

### 4.1 Fixed constraints

- Flutter and Dart are the application platform.
- Android is the only release platform for v1.0.
- Minimum Android version is Android 10, API 29.
- Build and target SDK use the current stable Android/Google Play requirement at release time.
- Bluetooth transport is Bluetooth Classic RFCOMM/SPP, not BLE GATT.
- Only one adapter connection and one scan may be active.
- The application must remain responsive; Bluetooth, parsing, database, and PDF work may not block the Flutter UI thread.
- The app is local-only and contains no secrets that need to be fetched from a server.
- The BYD Dolphin Premium PID set is proprietary empirical configuration. Exact request bytes are a verified data input, not something this document or a coding agent may guess.

### 4.2 Hardware assumptions that require validation

- The selected ELM327-compatible reference adapter exposes the standard Serial Port Profile UUID.
- The adapter can exchange prompt-delimited ASCII ELM commands and responses reliably.
- The selected BYD Dolphin Premium and battery variant expose all inputs required for the v1.0 result.
- A single ordered command queue is sufficient; commands are not pipelined.
- Scan completion under ten seconds is achievable with the final verified command set.

If any assumption fails, the transport or profile may change behind existing ports. Product-facing contracts must not change silently.

### 4.3 Release blockers, not architecture gaps

The following values must be supplied and approved before a production vehicle scan is enabled:

- Verified BYD request bytes, headers, protocol settings, response layouts, scaling, ranges, and test captures.
- Supported model year, region, battery capacity, BMS firmware, and variant evidence.
- Battery Score component normalisation curves.
- Grade boundaries.
- Remaining-life policy, if included.
- Controlled recommendation rules.
- Final legal disclaimer wording.

The app must fail closed when these assets are absent or marked unapproved. Demo mode remains available.

---

## 5. System Context

```text
┌─────────────────────────────────────────────────────────────────────┐
│                         EV Health Android App                       │
│                                                                     │
│  Flutter UI → Application use cases → Domain models and policies    │
│      ↑                  ↓                         ↑                  │
│  Riverpod       Repository / gateway ports       │                  │
│                         ↓                         │                  │
│  Drift database | PDF renderer | OBD session | Vehicle profiles     │
│                                      ↓                              │
│                     Bluetooth Classic RFCOMM adapter                │
└──────────────────────────────────────┬──────────────────────────────┘
                                       │ ordered ASCII/bytes
                              ┌────────▼────────┐
                              │ ELM327 adapter │
                              └────────┬────────┘
                                       │ read-only OBD/CAN requests
                              ┌────────▼────────────────┐
                              │ BYD Dolphin Premium BMS │
                              └─────────────────────────┘
```

There is no backend in the v1.0 system context.

---

## 6. Dependency Architecture

### 6.1 Layers

```text
Presentation
    │
    ▼
Application
    │
    ▼
Domain

Infrastructure ───────────────► Domain ports and domain models

App/bootstrap ────────────────► wires Presentation, Application,
                                 Domain policies, and Infrastructure
```

### 6.2 Responsibilities

| Layer | May contain | Must not contain |
|---|---|---|
| Domain | Entities, value objects, repository ports, validation results, policy interfaces, pure calculations | Flutter widgets, Riverpod, Drift, platform plugins, filesystem APIs |
| Application | Use cases, session orchestration, transaction boundaries, cancellation, DTO-to-domain coordination | Widget layout, SQLite tables, raw plugin objects |
| Presentation | Screens, components, Riverpod controllers/view models, navigation, controlled copy keys | Raw OBD commands, PID decoding, scoring formulas, database calls |
| Infrastructure | Bluetooth adapter, ELM protocol, vehicle-profile loader, Drift repositories, PDF renderer, local diagnostics | Product navigation, widget state, uncontrolled user-facing copy |
| App/bootstrap | Provider graph, environment selection, router construction, startup | Business rules |

### 6.3 Mandatory dependency-direction rules

1. Domain imports only Dart SDK libraries and narrowly approved utility packages.
2. Application imports Domain, never Presentation or concrete Infrastructure.
3. Presentation imports Application and Domain view data. It does not import `infrastructure/`.
4. Infrastructure implements Domain/Application ports. Domain never imports Infrastructure.
5. Only `app/di` selects concrete implementations.
6. A feature screen talks to one controller or query provider, not multiple low-level repositories.
7. Widgets never construct repositories, gateways, database connections, profile loaders, or engines.
8. Vehicle profiles never import UI code.
9. PDF generation consumes an immutable report model, not a widget tree or live providers.
10. Demo implementations satisfy the same ports as real implementations.
11. No circular imports between features. Shared concepts move downward to Domain or Core.
12. Generated database rows and plugin device objects do not cross Infrastructure boundaries.

### 6.4 Dependency test

The repository should include a lightweight architecture test or lint script that rejects:

- `presentation` importing `infrastructure`.
- `domain` importing Flutter, Riverpod, Drift, or plugin packages.
- UI files containing strings matching `AT`, PID request hex patterns, or ELM command APIs.
- Vehicle-specific names outside profiles, vehicle display catalogues, approved copy, tests, and demo fixtures.

---

## 7. Flutter Technology Stack

Package versions are pinned in `pubspec.lock`. The versions below are the v1.0 baseline as of 29 July 2026; patch upgrades are allowed after tests, while minor or major upgrades require a dependency review.

| Concern | Selection | Rule |
|---|---|---|
| SDK | Flutter stable 3.44.x with bundled Dart | Commit the Flutter version through FVM or an equivalent checked-in version file |
| UI | Flutter Material 3 | Android-first, responsive, light/dark/follow-system |
| State and DI | `flutter_riverpod` 3.4.x, `riverpod_annotation`, `riverpod_generator` | Use `(Async)Notifier`; do not use legacy `StateNotifier` |
| Navigation | `go_router` 17.x | Typed/named route definitions and shell navigation |
| Immutable models | `freezed_annotation` / `freezed` | Domain unions, errors, session states, snapshots |
| Serialization | `json_annotation` / `json_serializable` | Vehicle-profile assets and exportable support bundles only |
| Local database | `drift` 2.34.x and `drift_flutter` 0.3.x | SQLite, typed queries, explicit migrations, transactions |
| PDF | `pdf` 3.13.x | Pure Dart A4 document construction |
| PDF preview/share | `printing` 5.15.x and/or `share_plus` 13.x behind an export gateway | UI never calls plugin directly |
| Paths/files | `path_provider`, `path` | App-controlled storage and temporary exports |
| Permissions | A narrow `PermissionGateway`; implementation may use `permission_handler` | Request only contextually required permissions |
| Secure local key | `flutter_secure_storage` | Store one install-scoped HMAC key; no user secrets |
| IDs | `uuid` | UUID v4 for local entities |
| Formatting | `intl` | Presentation/export only; domain stores UTC and canonical units |
| Test support | `flutter_test`, `test`, `mocktail`, `integration_test` | Prefer hand-written fakes for core ports |
| Quality | `flutter_lints` plus project rules | `dart format`, `flutter analyze`, tests are required |

### 7.1 Bluetooth implementation selection

Bluetooth Classic package maturity and licensing must be validated on the reference adapter before adoption. The architecture therefore fixes the port, not a third-party API.

Implementation gate:

1. Create a hardware spike using an MIT/BSD-compatible Android Bluetooth Classic RFCOMM plugin.
2. Verify discovery/association, pairing, connection, byte streaming, cancellation, disconnect, Android 10–current permission behaviour, and reference-adapter stability.
3. Check licence compatibility and maintenance status.
4. If the plugin passes, wrap it in `BluetoothClassicTransportAdapter`.
5. If it fails, implement the same port with a small in-repository Kotlin plugin using Android `BluetoothSocket`.

A BLE-only package such as `flutter_blue_plus` is not acceptable for the v1.0 ELM327 Classic path.

### 7.2 Package rules

- No package is added because it is convenient for one screen.
- Every runtime dependency needs an owner, licence check, maintenance check, and removal strategy.
- Plugins are wrapped at Infrastructure boundaries.
- Generated code is committed only if the project convention requires it; the build must reproduce it.
- `dependency_overrides` are prohibited in release branches.
- Exact versions are upgraded deliberately, never by an unreviewed bulk update.

---

## 8. Proposed Repository and Folder Structure

```text
ev_health/
├── android/
│   └── app/
│       ├── src/dev/
│       ├── src/qa/
│       ├── src/prod/
│       └── src/main/AndroidManifest.xml
├── assets/
│   ├── legal/
│   ├── report/
│   │   ├── fonts/
│   │   └── images/
│   └── vehicle_profiles/
│       ├── schema/
│       │   └── vehicle_profile.schema.json
│       ├── production/
│       │   └── byd_dolphin_premium_v1.json
│       └── fixtures/
│           ├── byd_dolphin_premium_demo_v1.json
│           └── invalid_profile_cases/
├── lib/
│   ├── main_dev.dart
│   ├── main_qa.dart
│   ├── main_prod.dart
│   ├── bootstrap.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── config/
│   │   │   ├── app_environment.dart
│   │   │   └── release_config.dart
│   │   ├── di/
│   │   │   ├── providers.dart
│   │   │   └── provider_observer.dart
│   │   ├── navigation/
│   │   │   ├── app_router.dart
│   │   │   ├── route_names.dart
│   │   │   └── route_guards.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── color_tokens.dart
│   │       └── spacing_tokens.dart
│   ├── core/
│   │   ├── errors/
│   │   │   ├── app_failure.dart
│   │   │   ├── error_code.dart
│   │   │   └── recovery_action.dart
│   │   ├── result/
│   │   │   └── result.dart
│   │   ├── time/
│   │   │   └── clock.dart
│   │   ├── units/
│   │   │   ├── canonical_unit.dart
│   │   │   ├── measured_value.dart
│   │   │   └── unit_formatter.dart
│   │   └── validation/
│   │       └── validation_issue.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── vehicle.dart
│   │   │   ├── scan_snapshot.dart
│   │   │   ├── observation.dart
│   │   │   ├── battery_assessment.dart
│   │   │   └── report_record.dart
│   │   ├── value_objects/
│   │   │   ├── identifiers.dart
│   │   │   ├── metric_key.dart
│   │   │   ├── provenance.dart
│   │   │   ├── scan_completeness.dart
│   │   │   └── version_id.dart
│   │   ├── ports/
│   │   │   ├── adapter_repository.dart
│   │   │   ├── scan_repository.dart
│   │   │   ├── report_repository.dart
│   │   │   ├── settings_repository.dart
│   │   │   ├── vehicle_profile_repository.dart
│   │   │   ├── report_exporter.dart
│   │   │   └── diagnostic_sink.dart
│   │   └── policies/
│   │       ├── battery_intelligence_engine.dart
│   │       ├── scan_completeness_policy.dart
│   │       └── retention_policy.dart
│   ├── application/
│   │   ├── obd/
│   │   │   ├── obd_session_coordinator.dart
│   │   │   ├── obd_session_event.dart
│   │   │   └── obd_session_state.dart
│   │   ├── scan/
│   │   │   ├── run_battery_scan.dart
│   │   │   ├── finalize_scan.dart
│   │   │   └── scan_draft.dart
│   │   ├── reports/
│   │   │   ├── build_report_model.dart
│   │   │   ├── export_report.dart
│   │   │   └── delete_report.dart
│   │   ├── history/
│   │   │   ├── watch_scan_history.dart
│   │   │   └── delete_scan.dart
│   │   └── settings/
│   │       ├── delete_all_local_data.dart
│   │       └── forget_adapter.dart
│   ├── features/
│   │   ├── onboarding/presentation/
│   │   ├── setup/presentation/
│   │   ├── home/presentation/
│   │   ├── scan/presentation/
│   │   ├── battery_report/presentation/
│   │   ├── history/presentation/
│   │   ├── reports/presentation/
│   │   ├── settings/presentation/
│   │   ├── vehicle/presentation/
│   │   ├── demo/presentation/
│   │   └── developer/presentation/
│   └── infrastructure/
│       ├── bluetooth/
│       │   ├── bluetooth_classic_transport.dart
│       │   ├── bluetooth_transport_adapter.dart
│       │   ├── adapter_identity_store.dart
│       │   └── permission_gateway.dart
│       ├── elm327/
│       │   ├── elm327_client.dart
│       │   ├── elm327_command_queue.dart
│       │   ├── elm327_response_parser.dart
│       │   └── elm327_tokens.dart
│       ├── obd/
│       │   ├── obd_command_executor.dart
│       │   ├── can_response_assembler.dart
│       │   └── response_normalizer.dart
│       ├── vehicles/
│       │   ├── json_vehicle_profile_repository.dart
│       │   ├── vehicle_profile.dart
│       │   ├── pid_definition.dart
│       │   ├── pid_decoder.dart
│       │   └── profile_validator.dart
│       ├── battery/
│       │   ├── battery_intelligence_engine_v1.dart
│       │   ├── score_policy_v1.dart
│       │   └── recommendation_catalogue.dart
│       ├── persistence/
│       │   ├── app_database.dart
│       │   ├── daos/
│       │   ├── migrations/
│       │   ├── mappers/
│       │   └── repositories/
│       ├── export/
│       │   ├── pdf_report_exporter.dart
│       │   ├── image_summary_exporter.dart
│       │   ├── report_share_gateway.dart
│       │   └── export_file_store.dart
│       ├── demo/
│       │   ├── demo_scan_source.dart
│       │   ├── demo_repositories.dart
│       │   └── demo_fixture_loader.dart
│       └── diagnostics/
│           ├── local_diagnostic_sink.dart
│           ├── redactor.dart
│           └── diagnostic_bundle_builder.dart
├── packages/
│   └── evh_bluetooth_classic/
│       └── ...                         # created only if the package spike fails
├── test/
│   ├── architecture/
│   ├── unit/
│   ├── widget/
│   ├── golden/
│   ├── integration/
│   ├── fixtures/
│   │   ├── elm327/
│   │   ├── byd_dolphin_premium/
│   │   └── database/
│   └── support/
├── integration_test/
├── tool/
│   ├── validate_vehicle_profiles.dart
│   ├── verify_no_vehicle_logic_in_ui.dart
│   ├── render_pdf_fixtures.dart
│   └── verify_licenses.dart
├── docs/
│   ├── adr/
│   ├── hardware-validation/
│   ├── pid-evidence/
│   └── release/
├── analysis_options.yaml
├── build.yaml
├── pubspec.yaml
└── pubspec.lock
```

### 8.1 File-size and responsibility rules

- A file should normally contain one public type or one closely related sealed family.
- A controller coordinates a screen flow; it does not parse OBD or run SQL.
- A use case has one user-visible purpose.
- A repository implementation contains persistence mapping, not business policy.
- A PID decoder decodes one declared layout family and is reusable across profiles.
- Split files when multiple reasons to change appear; do not split solely to satisfy an arbitrary line count.

---

## 9. Feature Modules

| Feature | Owns | Depends on |
|---|---|---|
| Onboarding | First-use state, limitations entry, demo entry | Settings use cases |
| Setup | Permission explanation, adapter association/discovery, connection, troubleshooting, vehicle confirmation | OBD session coordinator |
| Home | Latest real result, setup state, primary action | History queries, settings |
| Scan | Preparation, progress, cancellation, partial recovery | Run scan use case, session state |
| Battery report | Summary, full report, metric detail, provenance | Immutable scan snapshot and report model |
| History | Local scan list, chart query, delete | Scan repository |
| Reports | Report records, preview, regenerate, share, delete | Report exporter/repository |
| Settings | Appearance, units, adapter, privacy, local deletion | Settings and deletion use cases |
| Vehicle | Active profile display and support statement | Vehicle-profile query |
| Demo | Clearly labelled fictional experience | Demo port overrides only |
| Developer | Raw in-memory/session diagnostics, redacted bundle | Diagnostic sink and session query |

Feature presentation folders may contain:

```text
presentation/
├── controllers/
├── models/       # screen-specific immutable view data
├── screens/
├── widgets/
└── copy/
```

They must not contain repositories, protocol code, calculations, or database rows.

---

## 10. Core Domain Model

### 10.1 Entity summary

```text
VehicleProfileIdentity
    └── identifies profile and version used by
        ScanSnapshot
          ├── Observation[*]
          ├── DerivedMetric[*]
          ├── ValidationIssue[*]
          ├── BatteryAssessment
          └── provenance/version metadata
                └── ReportRecord[*]
                      └── ExportArtifact metadata[*]
```

### 10.2 `Vehicle`

Represents the locally selected supported vehicle without a VIN.

```dart
class Vehicle {
  VehicleId id;
  String manufacturer;          // "BYD"
  String model;                 // "Dolphin"
  String variant;               // "Premium"
  VehicleProfileId profileId;
  VersionId profileVersion;
  DateTime lastConfirmedAtUtc;
}
```

No registration, raw VIN, Bluetooth address, or location belongs in this entity.

### 10.3 `Observation`

One attempted canonical metric reading.

```dart
sealed class Observation {
  MetricKey metric;
  DateTime observedAtUtc;
  Provenance provenance;        // vehicleReported
  String pidDefinitionId;
  ValidationStatus validation;
}

class AvailableObservation extends Observation {
  MeasuredValue value;          // exact scaled integer + canonical unit
  String sourceNumericText;     // optional, no transport headers
}

class MissingObservation extends Observation {
  MissingReason reason;         // unsupported, noData, timeout, parseFailure...
  ErrorCode? errorCode;
}
```

### 10.4 `MeasuredValue`

Floating-point values must not be the canonical persisted representation.

```dart
class MeasuredValue {
  int scaledValue;              // signed 64-bit
  int decimalScale;             // 0 = integer, 3 = milli precision
  CanonicalUnit unit;
}
```

Examples:

| Measurement | Canonical representation |
|---|---|
| Cell voltage 3.343 V | `3343`, scale `3`, unit `volt` |
| Capacity 147.39 Ah | `147390`, scale `3`, unit `ampHour` |
| Temperature 22.5 °C | `225`, scale `1`, unit `celsius` |
| SOH 98.00% | `9800`, scale `2`, unit `percent` |
| Energy 5,696 kWh | `5696000`, scale `0`, unit `wattHour` |

Conversions to display units occur only through the unit formatter. Calculations use rational/scaled arithmetic where practical and apply explicit rounding at output boundaries.

### 10.5 `DerivedMetric`

```dart
class DerivedMetric {
  MetricKey key;
  DerivedMetricStatus status;   // available, notCalculated, invalidInputs
  MeasuredValue? value;
  List<MetricKey> inputKeys;
  String formulaId;
  VersionId algorithmVersion;
  Provenance provenance;        // calculated or estimated
  List<ValidationIssue> issues;
}
```

### 10.6 `BatteryAssessment`

```dart
class BatteryAssessment {
  VersionId engineVersion;
  AssessmentAvailability availability;
  DerivedMetric soh;
  DerivedMetric remainingCapacity;
  DerivedMetric cellDelta;
  DerivedMetric temperatureSpread;
  ScoreResult batteryScore;
  GradeResult batteryGrade;
  EstimateResult remainingLife;
  List<ControlledRecommendation> recommendations;
  DataCompleteness completeness;
  List<AssessmentWarning> warnings;
}
```

### 10.7 `ScanSnapshot`

```dart
class ScanSnapshot {
  ScanId id;
  DateTime startedAtUtc;
  DateTime completedAtUtc;
  int timezoneOffsetMinutes;
  ScanMode mode;                // real only in persistent repository
  ScanOutcome outcome;          // complete or partial
  VehicleProfileIdentity profile;
  AdapterClass adapterClass;    // no address
  List<Observation> observations;
  List<DerivedMetric> derivedMetrics;
  BatteryAssessment assessment;
  VersionId engineVersion;
  VersionId schemaVersion;
  List<ScanEventSummary> eventSummary;
}
```

The snapshot contains everything required to render the result again without reconnecting or recalculating against a newer policy.

### 10.8 `ReportRecord`

```dart
class ReportRecord {
  ReportId id;
  ScanId scanId;
  DateTime createdAtUtc;
  VersionId templateVersion;
  ReportStatus status;
  List<ExportArtifact> artifacts;
}

class ExportArtifact {
  ExportId id;
  ExportFormat format;          // pdf or imageSummary
  DateTime generatedAtUtc;
  String appControlledPath;
  int byteLength;
  String mimeType;
}
```

The path is internal metadata. Once a file is shared or saved outside app-controlled storage, the app does not claim it still controls or can delete that copy.

### 10.9 Provenance

Every user-visible metric has exactly one provenance:

- `vehicleReported`
- `calculatedByEvHealth`
- `estimatedByEvHealth`
- `unavailable`

Demo provenance is separate and cannot be serialized as a real `ScanSnapshot`.

---

## 11. Repository and Gateway Interfaces

Interfaces live in Domain unless they are specifically application-session ports.

```dart
abstract interface class ScanRepository {
  Stream<List<ScanSummary>> watchHistory();
  Future<Result<ScanSnapshot, AppFailure>> getById(ScanId id);
  Future<Result<void, AppFailure>> insertFinal(ScanSnapshot snapshot);
  Future<Result<void, AppFailure>> delete(ScanId id);
  Future<Result<void, AppFailure>> deleteAll();
}

abstract interface class ReportRepository {
  Stream<List<ReportSummary>> watchReports();
  Future<Result<ReportRecord, AppFailure>> getById(ReportId id);
  Future<Result<void, AppFailure>> save(ReportRecord record);
  Future<Result<void, AppFailure>> delete(ReportId id);
}

abstract interface class VehicleProfileRepository {
  Future<Result<VehicleProfile, AppFailure>> loadProductionProfile(
    VehicleProfileId id,
  );
  Future<Result<void, AppFailure>> validateForProduction(
    VehicleProfile profile,
  );
}

abstract interface class SettingsRepository {
  Stream<AppSettings> watch();
  Future<Result<void, AppFailure>> update(AppSettings settings);
  Future<Result<void, AppFailure>> clear();
}

abstract interface class AdapterRepository {
  Future<Result<AdapterPreference?, AppFailure>> getPreference();
  Future<Result<void, AppFailure>> savePreference(AdapterPreference value);
  Future<Result<void, AppFailure>> forget();
}

abstract interface class ReportExporter {
  Future<Result<ExportPreview, AppFailure>> buildPreview(
    ImmutableReportModel report,
    ExportFormat format,
  );
  Future<Result<ExportArtifact, AppFailure>> persistExport(
    ImmutableReportModel report,
    ExportFormat format,
  );
}

abstract interface class ReportShareGateway {
  Future<Result<void, AppFailure>> share(ExportArtifact artifact);
  Future<Result<void, AppFailure>> saveCopy(ExportArtifact artifact);
}
```

### 11.1 Bluetooth and protocol ports

```dart
abstract interface class BluetoothClassicTransport {
  Stream<BluetoothAdapterState> watchAdapterState();
  Future<Result<List<AdapterCandidate>, AppFailure>> discoverOrAssociate();
  Future<Result<ConnectedByteChannel, AppFailure>> connect(
    TransientAdapterHandle handle, {
    required Duration timeout,
  });
  Future<Result<void, AppFailure>> cancelDiscovery();
  Future<Result<void, AppFailure>> disconnect();
}

abstract interface class ConnectedByteChannel {
  Stream<Uint8List> get input;
  Future<Result<void, AppFailure>> write(Uint8List bytes);
  Stream<TransportConnectionState> get states;
  Future<void> close();
}

abstract interface class Elm327Gateway {
  Future<Result<ElmIdentity, AppFailure>> initialize(
    ConnectedByteChannel channel,
    ElmInitScript script,
  );
  Future<Result<ElmResponse, AppFailure>> execute(
    ObdRequest request,
    CommandPolicy policy,
  );
  Future<void> close();
}
```

`TransientAdapterHandle` may contain a platform address in memory for the duration of discovery/connection. It may not be logged, persisted, exported, placed in Riverpod debug output, or included in an exception string.

### 11.2 Interface rules

- Repository methods return domain types, never Drift companions or JSON maps.
- Expected operational failures use `Result`, not unchecked exceptions.
- Programmer errors and violated invariants may throw in debug/test and are fatal in release diagnostics.
- Streams must document ownership and cancellation.
- Delete operations are explicit; no repository exposes a generic `executeSql`.

---

## 12. Riverpod State Management and Dependency Injection

### 12.1 Role of Riverpod

Riverpod is used for:

- Dependency injection at the app composition root.
- Async screen state.
- Long-lived OBD session ownership.
- Reactive database queries.
- Environment and demo overrides.

Riverpod is not the domain layer. Providers do not replace entities, repositories, or use cases.

### 12.2 Provider categories

```text
Configuration providers        keepAlive
Concrete gateway providers     keepAlive
Repository providers           keepAlive
OBD session controller         keepAlive while active
Database query providers       autoDispose unless used by app shell
Screen controllers             autoDispose
Pure formatting providers      Provider / function, no mutable state
```

### 12.3 Composition root pseudocode

```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.open(ref.watch(releaseConfigProvider));
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ScanRepository scanRepository(Ref ref) {
  return DriftScanRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
BluetoothClassicTransport bluetoothTransport(Ref ref) {
  return BluetoothTransportAdapter(
    permissions: ref.watch(permissionGatewayProvider),
    identityStore: ref.watch(adapterIdentityStoreProvider),
  );
}

@Riverpod(keepAlive: true)
class ObdSessionController extends _$ObdSessionController {
  @override
  ObdSessionState build() {
    ref.onDispose(_closeResources);
    return const ObdSessionState.idle();
  }

  Future<void> connectAndConfirm() async { /* call coordinator */ }
  Future<void> startScan() async { /* call use case */ }
  Future<void> cancel() async { /* idempotent cleanup */ }
}
```

### 12.4 Controller rules

- Public methods correspond to user intents such as `searchAdapters`, `connect`, `confirmVehicle`, `startScan`, `retry`, and `cancel`.
- Controllers set state; they do not decode PIDs, calculate metrics, or write SQL.
- Async operations check that the provider/controller is still mounted before committing state.
- Duplicate taps are ignored while the corresponding command is active.
- Cancellation is idempotent.
- Errors are mapped to a typed view state with approved recovery actions.
- A provider may call a use case or repository, not reach through one to its private implementation.

### 12.5 Demo overrides

Demo mode is entered through a dedicated `ProviderScope` override boundary:

```dart
ProviderScope(
  overrides: [
    scanSourceProvider.overrideWithValue(demoScanSource),
    scanRepositoryProvider.overrideWithValue(nonPersistingDemoRepository),
    reportExporterProvider.overrideWithValue(watermarkedDemoExporter),
  ],
  child: const DemoAppFlow(),
)
```

Real persistence providers are not available inside the demo flow. This structural separation prevents an accidental insert into real history.

### 12.6 Provider observation

The production `ProviderObserver` records only:

- Provider name/category.
- State transition category.
- Redacted error code.
- Duration bucket.

It must not log state objects containing readings, adapter handles, raw payloads, or VIN.

---

## 13. Navigation

Use `go_router` with stable route names. The route map follows the UI/UX specification.

```text
/splash
/onboarding
/setup/permissions
/setup/adapters
/setup/connecting
/setup/vehicle
/help/connection
/scan/prepare
/scan/progress
/scans/:scanId/summary
/scans/:scanId/report
/scans/:scanId/metrics/:metricKey
/reports/:reportId/export
/vehicle
/demo

Shell:
  /home
  /history
  /reports
  /settings
    /settings/privacy
    /settings/about
    /settings/developer
```

### 13.1 Navigation structure

```text
Root navigator
├── Splash/onboarding
├── Setup and scan flow
├── Result/report/detail
├── Demo flow
└── Stateful shell
    ├── Home branch
    ├── History branch
    ├── Reports branch
    └── Settings branch
```

### 13.2 Route rules

- The bottom navigation shell is absent during setup and active scanning.
- Route parameters contain local opaque IDs, never VIN, adapter address, or raw values.
- Saved result routes load only from the repository and never reconnect.
- Startup redirection is based on a resolved `StartupState`, not asynchronous work inside a widget.
- An unsupported or missing entity ID routes to a controlled local not-found state.
- Deep links are not a v1.0 feature, but route names and IDs remain stable for future use.
- Navigating back from scan progress invokes the stop confirmation. It never discards data silently.
- The router does not own the scan session. It reacts to the session controller.

### 13.3 Scan exit guard

```text
Back requested
    │
    ├─ session not scanning ───────────────► pop
    │
    └─ session scanning
           │
           ▼
      show confirmation
       ├─ keep scanning ───────────────────► remain
       └─ stop
            ▼
       coordinator.cancel()
            ▼
       finalize partial if usable
            ▼
          route to result or previous screen
```

---

## 14. Bluetooth Classic Architecture

### 14.1 Ownership

The Infrastructure `BluetoothClassicTransport` owns:

- Adapter-state observation.
- Android permission and association interaction through a separate gateway.
- Candidate discovery or system companion-device selection.
- Bonded-device lookup.
- RFCOMM connection.
- Input byte stream and ordered writes.
- Connection-state events.
- Cancellation, disconnect, and resource cleanup.

It does not know about ELM commands, vehicle profiles, PIDs, scans, scores, reports, or UI copy.

### 14.2 Android permissions

The Android manifest and runtime flow must:

- Declare Bluetooth Classic as a used feature.
- On Android 12/API 31 and later, request only `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` as needed.
- Mark scanning as `neverForLocation` when the chosen implementation genuinely does not derive location.
- On Android 10–11, prefer Android Companion Device Manager for first association so ordinary setup does not require the app to process a location-derived scan.
- Never request background location.
- Never request `BLUETOOTH_ADVERTISE`; EV Health does not advertise the phone.
- Explain the permission before launching the platform prompt.
- Permit demo mode when permission is denied.

Permission details are an Infrastructure concern surfaced as typed states:

```dart
sealed class BluetoothPermissionState {
  const factory BluetoothPermissionState.notRequested();
  const factory BluetoothPermissionState.granted();
  const factory BluetoothPermissionState.denied({required bool permanent});
  const factory BluetoothPermissionState.unsupported();
}
```

### 14.3 Adapter identity and auto-reconnect

The app must support reconnection without storing a raw Bluetooth MAC address.

The production strategy is:

1. Generate a random 256-bit install key and store it in Android Keystore-backed secure storage.
2. During a user-approved setup session, compute:

   ```text
   adapterKey = HMAC-SHA256(installKey, normalized transient adapter address)
   ```

3. Persist only:
   - `adapterKey`
   - user-visible device alias/name after sanitisation
   - adapter class
   - last successful connection time
4. On reconnect, enumerate currently bonded/associated candidates after permission is granted, compute their HMAC in memory, and select the match.
5. Never serialize the address, put it in logs, expose it to Riverpod state, or include it in reports.
6. Forget Adapter deletes the preference and, where appropriate, removes the app’s companion association. It does not unpair the device globally unless the user explicitly performs that platform action.

The HMAC is local, install-scoped, and not transmitted. If privacy review treats even this pseudonymous key as prohibited, cross-restart auto-reconnect must be removed rather than persisting the address.

### 14.4 Connection policy

```dart
class BluetoothConnectionPolicy {
  Duration softTarget = const Duration(seconds: 5);
  Duration connectTimeout = const Duration(seconds: 10);
  int automaticReconnectAttempts = 1;
  Duration reconnectDelay = const Duration(milliseconds: 500);
}
```

- Cancel Classic discovery before calling RFCOMM connect because discovery degrades connection performance.
- Try the standard SPP UUID first.
- Secure RFCOMM is preferred. An insecure socket is allowed only if the approved reference adapter cannot use secure RFCOMM and the decision is recorded in the hardware matrix.
- One transport connection exists at a time.
- A lost byte channel immediately stops new commands.
- Cleanup closes subscriptions, input/output streams, socket, parser buffer, and pending completions.
- Connect and disconnect operations are idempotent from the application’s perspective.

### 14.5 Native fallback plugin

If the third-party spike fails, `packages/evh_bluetooth_classic` exposes only this narrow surface:

```text
Method channel:
  getAdapterState
  launchAssociation
  getBondedCandidates
  connectRfcomm
  write
  disconnect

Event channels:
  adapterStateEvents
  discoveryEvents
  connectionEvents
  incomingBytes
```

The Kotlin implementation uses Android `BluetoothAdapter`, companion-device APIs where available, and `BluetoothDevice.createRfcommSocketToServiceRecord`. No Bluetooth API appears elsewhere in the app.

---

## 15. ELM327 and OBD Abstractions

### 15.1 Layering

```text
BluetoothClassicTransport
    ↓ raw byte stream
Elm327Client
    ↓ prompt-delimited ELM responses
ObdCommandExecutor
    ↓ normalised OBD/CAN payloads
VehicleProfile + PidDecoder
    ↓ canonical observations
Battery Intelligence Engine
```

### 15.2 `Elm327Client`

Responsibilities:

- Own the single command queue.
- Add carriage-return command terminators.
- Wait for the ELM prompt (`>`).
- Remove configured command echo.
- Normalize CR/LF and whitespace without deleting payload data.
- Recognize adapter tokens.
- Enforce per-command timeout.
- Cancel outstanding work on disconnect.
- Return the raw normalized lines and typed status.

It must not decode a BYD metric.

### 15.3 Command queue invariants

1. Exactly one ELM command is in flight.
2. The next command is written only after the previous prompt or terminal failure.
3. Commands are ASCII uppercase and validated against the approved command type.
4. A response completion belongs to the command that opened it.
5. A disconnect completes all pending operations with `TransportFailure.connectionLost`.
6. A retry creates a new attempt record and never silently overwrites the first failure.
7. Queue close is idempotent.

### 15.4 Read-only command allow-list

Commands are represented by types, not arbitrary strings:

```dart
sealed class ElmCommand {
  const factory ElmCommand.resetAdapter();
  const factory ElmCommand.configure(ApprovedElmSetting setting);
  const factory ElmCommand.readObd(ApprovedObdRequest request);
}
```

The production executor rejects:

- Commands not supplied by an approved vehicle profile or generic approved init script.
- Any request categorized as write, clear, reset ECU, actuator, coding, or unknown.
- DTC service requests in v1.0.
- User-entered commands, including from Developer Mode.

Developer Mode is read-only visibility; it is not a terminal.

### 15.5 ELM response model

```dart
sealed class ElmResponse {
  const factory ElmResponse.data({
    required List<String> lines,
    required Duration elapsed,
  });
  const factory ElmResponse.noData();
  const factory ElmResponse.stopped();
  const factory ElmResponse.unableToConnect();
  const factory ElmResponse.canError();
  const factory ElmResponse.busError();
  const factory ElmResponse.unknownCommand();
  const factory ElmResponse.timeout();
  const factory ElmResponse.malformed(List<String> lines);
}
```

Recognized informational tokens such as `SEARCHING...` are retained in diagnostics but do not become payload.

### 15.6 Initialization

Initialization is a versioned script selected by the approved vehicle profile. It may contain safe adapter configuration such as reset, echo/whitespace behavior, headers, adaptive timing, protocol selection, flow control, and receive filters.

The exact script is not hardcoded in the coordinator. A production script must include:

- Expected acknowledgement for each step.
- Timeout.
- Allowed retries.
- Required versus optional status.
- Hardware evidence reference.

Example structure, not production commands:

```json
{
  "id": "elm_init_byd_dolphin_premium_v1",
  "steps": [
    {
      "commandType": "approvedAdapterConfiguration",
      "commandRef": "CONFIG_ECHO_OFF",
      "required": true,
      "timeoutMs": 1500,
      "retries": 1
    }
  ]
}
```

### 15.7 OBD/CAN response processing

The `ObdCommandExecutor` performs:

1. Typed ELM request execution.
2. Removal of known non-payload tokens.
3. ASCII hex validation.
4. Header/address validation when the profile requires it.
5. ISO-TP/frame reassembly if the adapter configuration does not already provide a complete payload.
6. Positive-response service and identifier validation.
7. Negative-response conversion to a typed failure.
8. Delivery of exact payload bytes to the PID decoder.

The response assembler must reject:

- Odd-length hex.
- Non-hex payload characters.
- Truncated first/consecutive frames.
- Sequence-number gaps.
- Unexpected sender headers.
- Excess payload beyond the declared maximum.
- Positive responses for the wrong request.

Raw transport lines may be retained in memory for the active session. They are persisted only in the short-lived Developer Mode trace store described later, never in ordinary scan history.

---

## 16. OBD Session State Machine

### 16.1 State model

```text
idle
  │
  ▼
checkingPermissions
  ├─ denied ─────────────────────────────► permissionRequired
  ▼
discovering
  ├─ none/timeout ───────────────────────► recoverableFailure
  ▼
adapterSelected
  ▼
connectingBluetooth
  ├─ lost/timeout ───────────────────────► reconnecting (maximum once)
  ▼
initializingElm
  ├─ invalid adapter ────────────────────► recoverableFailure
  ▼
probingVehicle
  ├─ unsupported/unconfirmed ────────────► unsupportedVehicle
  ▼
awaitingVehicleConfirmation
  ├─ rejected ───────────────────────────► disconnecting
  ▼
readyToScan
  ▼
scanning
  ├─ transient transport loss ───────────► reconnecting
  ├─ non-critical PID failure ───────────► scanning (record missing)
  ├─ cancel/stop ────────────────────────► finalizingPartial
  ▼
analyzing
  ▼
persisting
  ├─ storage failure ────────────────────► completedUnsaved
  ▼
completedComplete / completedPartial
  ▼
disconnecting
  ▼
idle
```

`cancelled`, `recoverableFailure`, and `fatalFailure` are explicit states, not generic exceptions.

### 16.2 State pseudocode

```dart
@freezed
sealed class ObdSessionState with _$ObdSessionState {
  const factory ObdSessionState.idle() = Idle;
  const factory ObdSessionState.checkingPermissions() = CheckingPermissions;
  const factory ObdSessionState.discovering(
    List<AdapterCandidate> candidates,
  ) = Discovering;
  const factory ObdSessionState.connecting(SessionProgress progress) = Connecting;
  const factory ObdSessionState.awaitingVehicleConfirmation(
    DetectedVehicleSummary vehicle,
  ) = AwaitingVehicleConfirmation;
  const factory ObdSessionState.readyToScan() = ReadyToScan;
  const factory ObdSessionState.scanning(ScanProgress progress) = Scanning;
  const factory ObdSessionState.reconnecting(
    ScanProgress progress,
    int attempt,
  ) = Reconnecting;
  const factory ObdSessionState.finalizing() = Finalizing;
  const factory ObdSessionState.completed(ScanId id, ScanOutcome outcome) =
      Completed;
  const factory ObdSessionState.completedUnsaved(
    ScanSnapshot snapshot,
    AppFailure failure,
  ) = CompletedUnsaved;
  const factory ObdSessionState.failure(
    AppFailure failure,
    List<RecoveryAction> actions,
  ) = Failure;
}
```

### 16.3 State invariants

- `scanning` requires a connected and initialized ELM session and confirmed production profile.
- A raw VIN never appears in `ObdSessionState`.
- `persisting` accepts only a finalized immutable snapshot.
- A `completed` state always references a repository record.
- A partial snapshot needs at least one valid reportable observation.
- If no reportable observation exists, the scan attempt is not inserted as a scan snapshot; a redacted attempt summary may be kept in local diagnostics.
- `completedUnsaved` keeps the snapshot in memory and offers Try saving again or Continue without saving.
- The session cannot return to `readyToScan` after profile version changes without re-probing.

### 16.4 Timing and retry policy

| Operation | Soft target | Timeout/retry |
|---|---:|---|
| Bluetooth connection | 5 s | 10 s timeout, one automatic reconnect |
| ELM init step | 1.5 s typical | Per profile, at most one retry unless evidence approves more |
| PID request | Profile-defined | Normally 1.5 s, at most two total attempts |
| Reference scan | 10 s | At 10 s offer Keep waiting or Stop and review |
| Reconnect during scan | 5 s | One automatic attempt |
| Local save | 1 s | One user-triggered retry |

Retries apply only to timeouts, transient I/O, and approved negative/busy responses. Parse failures, wrong headers, invalid lengths, and out-of-range values are not retried automatically unless the profile explicitly identifies a known transient pattern.

### 16.5 Cancellation

Cancellation uses a session-scoped cancellation token checked:

- Before every command.
- After every awaited transport operation.
- Before analysis.
- Before persistence.

On cancellation:

1. Stop issuing commands.
2. Complete or cancel pending command futures.
3. Preserve valid completed observations in the current `ScanDraft`.
4. Finalize a partial snapshot only if the user chose Stop and review and the minimum partial-report rule passes.
5. Close ELM and Bluetooth resources.

---

## 17. Vehicle Profile Architecture

### 17.1 Purpose

A vehicle profile is a declarative, versioned contract that converts a supported vehicle’s responses into canonical EV Health observations.

Adding another vehicle must not require:

- A new screen.
- Changes to Riverpod controllers.
- Changes to the scan state machine.
- Changes to persistence tables.
- Changes to report templates for existing canonical metrics.
- Vehicle-name conditionals in shared code.

### 17.2 Profile structure

```dart
class VehicleProfile {
  VehicleProfileIdentity identity;
  VehicleCompatibility compatibility;
  ProductionApproval approval;
  ElmInitScript elmInit;
  VehicleDetectionPlan detection;
  List<PidDefinition> pids;
  ScanPlan scanPlan;
  List<EvidenceReference> evidence;
}
```

```json
{
  "schemaVersion": 1,
  "profileId": "byd_dolphin_premium_au",
  "profileVersion": "1.0.0",
  "display": {
    "manufacturer": "BYD",
    "model": "Dolphin",
    "variant": "Premium",
    "market": "AU"
  },
  "compatibility": {
    "modelYears": ["VERIFIED_RANGE_REQUIRED"],
    "batteryVariants": ["VERIFIED_VARIANT_REQUIRED"],
    "bmsFirmware": ["VERIFIED_OR_WILDCARD_WITH_EVIDENCE"]
  },
  "approval": {
    "productionEnabled": false,
    "approvedBy": null,
    "approvedAt": null,
    "evidenceIds": []
  },
  "elmInitScriptId": "VERIFIED_SCRIPT_REQUIRED",
  "detectionPlanId": "VERIFIED_DETECTION_REQUIRED",
  "scanPlan": {
    "metricDefinitionIds": [
      "capacity.factory",
      "capacity.current",
      "battery.soc",
      "cells.highestVoltage",
      "cells.lowestVoltage",
      "temperature.highest",
      "temperature.lowest",
      "temperature.average",
      "energy.chargeAccumulated",
      "energy.dischargeAccumulated",
      "charge.count",
      "pack.voltage",
      "pack.current"
    ]
  }
}
```

`VERIFIED_*` placeholders cause profile validation to fail. They cannot ship in the production asset directory.

### 17.3 PID definition

```dart
class PidDefinition {
  String id;
  MetricKey metric;
  ApprovedObdRequest request;
  ResponseContract response;
  DecoderSpec decoder;
  CanonicalUnit outputUnit;
  ValidRange range;
  CommandPolicy commandPolicy;
  RequirementLevel requirement;
  Set<EngineInputRole> engineRoles;
}
```

```json
{
  "id": "capacity.current",
  "metricKey": "battery.currentNominalCapacity",
  "request": {
    "service": "VERIFIED",
    "identifierHex": "VERIFIED",
    "targetHeader": "VERIFIED",
    "readOnlyClassification": "approvedRead"
  },
  "response": {
    "sourceHeaderMask": "VERIFIED",
    "positiveService": "VERIFIED",
    "identifierEcho": "VERIFIED",
    "minimumPayloadBytes": "VERIFIED"
  },
  "decoder": {
    "kind": "unsignedInteger",
    "offset": "VERIFIED",
    "length": "VERIFIED",
    "endian": "VERIFIED",
    "scaleNumerator": "VERIFIED",
    "scaleDenominator": "VERIFIED",
    "additiveOffset": "VERIFIED"
  },
  "outputUnit": "ampHour",
  "validation": {
    "minScaled": "VERIFIED",
    "maxScaled": "VERIFIED",
    "crossChecks": []
  },
  "requirement": "scoreRequired"
}
```

### 17.4 Decoder vocabulary

Profiles may choose only audited decoder types:

- Unsigned integer, 8/16/24/32/64-bit.
- Signed two’s-complement integer.
- Big- or little-endian.
- Bit field.
- BCD.
- ASCII for transient identity evidence.
- Enumerated value.
- Fixed rational scale and additive offset.

Profiles may not contain arbitrary Dart, JavaScript, regular-expression calculations over unbounded data, or executable formula strings.

### 17.5 Detection

The detection plan returns evidence, not a raw VIN:

```dart
class VehicleDetectionResult {
  DetectionStatus status;
  VehicleProfileId? matchedProfileId;
  DetectedVehicleSummary? summary;
  List<DetectionEvidence> evidence; // redacted, non-identifying
}
```

Detection may transiently read VIN or supported ECU identifiers. The detector:

1. Keeps raw identity bytes inside the stack frame/session object.
2. Matches them against approved rules.
3. Produces only make/model/variant and confidence evidence.
4. Zeroes/drops the raw value after detection.
5. Does not send it to diagnostics, provider state, database, or report.

The user still explicitly confirms BYD Dolphin Premium before scan.

### 17.6 Profile validation

At build time and startup, validation checks:

- Unique profile and PID IDs.
- Semantic version format.
- Production approval flag and non-empty evidence.
- All scan-plan references resolve.
- Every request is classified as approved read.
- No DTC or write service exists.
- Response lengths and decoder offsets are safe.
- Scale denominators are non-zero.
- Ranges use the output canonical unit.
- Required engine roles are satisfied.
- Metric keys are known.
- No duplicate producer exists for a metric unless an explicit fallback order is declared.
- No placeholder value remains.

Production boot fails into a recoverable “vehicle profile unavailable” screen if the only production profile is invalid. It does not continue with demo values.

---

## 18. Parsing, Validation, Units, and Derived Metrics

### 18.1 Data pipeline

```text
Incoming bytes
  → ELM framing
  → response token classification
  → ASCII-hex decode
  → CAN/ISO-TP validation and assembly
  → request/response correlation
  → PID decoder
  → canonical measured value
  → range and cross-metric validation
  → Observation
  → derived metrics
  → Battery Intelligence Engine
```

Every stage returns either a value or a typed issue. No stage returns an ambiguous null.

### 18.2 Validation levels

1. **Transport validation:** connected channel, prompt received, timeout.
2. **ELM validation:** recognized status, expected acknowledgement.
3. **Encoding validation:** valid even-length hex and bounded size.
4. **Protocol validation:** sender, service, identifier, frame sequence.
5. **Structural validation:** sufficient bytes for decoder.
6. **Numeric validation:** representable integer and safe scaling.
7. **Range validation:** within profile’s plausible bounds.
8. **Cross-metric validation:** e.g. highest cell voltage is not below lowest.
9. **Engine input validation:** required set and compatible timestamps.

### 18.3 Missing and invalid distinctions

```dart
enum MissingReason {
  unsupportedByProfile,
  noDataFromVehicle,
  commandTimeout,
  connectionLost,
  negativeResponse,
  malformedPayload,
  unexpectedHeader,
  insufficientBytes,
  outOfRange,
  cancelled,
}
```

The UI may group reasons into plain-language states, but Developer Mode can show the redacted technical reason.

### 18.4 Canonical units

| Metric family | Canonical unit |
|---|---|
| Cell and pack voltage | volt with scaled integer storage |
| Current | ampere, signed |
| Power | watt |
| Capacity | amp-hour |
| Energy throughput | watt-hour |
| Temperature | degrees Celsius |
| SOC/SOH/score component | percent |
| Cell delta | volt, displayed as millivolts |
| Count/cycles | count |
| Duration | millisecond |

Imperial settings do not change battery electrical units. Only units with an approved meaningful conversion are converted.

### 18.5 Derived formulas

Formulas have stable IDs and versions.

```text
SOH:
  currentNominalCapacity / factoryNominalCapacity × 100

Cell delta:
  highestCellVoltage - lowestCellVoltage

Temperature spread:
  highestBatteryTemperature - lowestBatteryTemperature

Pack power:
  packVoltage × packCurrent
  Sign convention must be declared by the profile.

Equivalent full cycles:
  Not calculated until the approved throughput basis and reference energy
  definition are supplied.
```

Rules:

- Division requires a positive denominator.
- Highest-minus-lowest results must not be negative.
- Inputs must be from the same scan and within the profile’s time-coherence window.
- Overflow-safe integer/rational arithmetic is used.
- Internal precision is retained; UI/PDF rounding follows the UI/UX rules.
- A derived metric stores its input keys, formula ID, and algorithm version.

### 18.6 Cross-check examples

- `0% ≤ SOC ≤ 100%`.
- `0% < calculated SOH ≤ approved upper tolerance`; values outside are invalid, not clamped.
- Highest cell voltage ≥ lowest cell voltage.
- Highest temperature ≥ average ≥ lowest when all are available.
- Reported capacity and factory capacity use compatible units.
- Power calculated from voltage/current agrees with a separately reported power metric within an approved tolerance, if both exist.
- Accumulated counters must not be negative.

Tolerances are profile or policy data and require evidence.

---

## 19. Battery Intelligence Engine

### 19.1 Purpose

The Battery Intelligence Engine turns validated observations into deterministic, explainable, versioned assessments. It is a pure service:

```dart
abstract interface class BatteryIntelligenceEngine {
  Result<BatteryAssessment, EngineFailure> assess(
    AssessmentInput input,
    BatteryEnginePolicy policy,
  );
}
```

It performs no I/O, reads no provider, uses no current time directly, and contains no Flutter code.

### 19.2 Inputs

`AssessmentInput` contains:

- Validated canonical observations.
- Vehicle-profile identity/version.
- Scan start/completion times.
- Explicit engine policy version.
- No adapter identifiers, VIN, location, or UI settings.

### 19.3 Processing stages

```text
Validated observations
    ↓
Derived metrics
    ↓
Component assessments
  ├─ SOH component
  ├─ Cell-balance component
  ├─ Temperature component
  └─ Charging-behaviour component
    ↓
Minimum-input rule
    ↓
Weighted Battery Score
    ↓
Battery Grade
    ↓
Controlled remaining-life policy
    ↓
Controlled recommendation rules
    ↓
Immutable BatteryAssessment
```

### 19.4 Engine v1 weighting

| Component | Weight |
|---|---:|
| State of Health | 60% |
| Cell balance | 20% |
| Temperature | 10% |
| Charging behaviour | 10% |

When all four approved component scores exist:

```text
scoreRaw =
    sohComponent × 0.60
  + cellBalanceComponent × 0.20
  + temperatureComponent × 0.10
  + chargingBehaviourComponent × 0.10

batteryScore = roundHalfUp(scoreRaw)
```

The result is bounded to `0..100` only after input and component validation. Invalid values are rejected, not silently clamped.

### 19.5 Minimum-data rule

For production Engine v1:

- All four components are required to produce Battery Score and Grade.
- SOH requires valid current and factory nominal capacity.
- Cell balance requires valid highest and lowest cell voltage.
- Temperature requires the policy-declared required temperature inputs.
- Charging behaviour requires the policy-declared throughput/count inputs.
- If any required component is unavailable, Battery Score and Grade are `Not calculated`.
- Individual component insights may still be shown.

This matches the project’s honest-incompleteness rule and avoids reweighting available components without product approval.

### 19.6 Policy data

Normalisation curves and grade boundaries are data:

```dart
class BatteryEnginePolicy {
  VersionId version;
  bool productionApproved;
  PiecewiseCurve sohCurve;
  PiecewiseCurve cellBalanceCurve;
  TemperaturePolicy temperaturePolicy;
  ChargingBehaviourPolicy chargingPolicy;
  List<GradeBoundary> gradeBoundaries;
  RemainingLifePolicy? remainingLifePolicy;
  List<RecommendationRule> recommendationRules;
  ApprovalMetadata approval;
}
```

The policy lives in audited Dart constants or a signed-at-build local asset. It is not remotely loaded.

A coding agent must not choose:

- Curve points.
- “Excellent/Good/Review” thresholds.
- Grade cut-offs.
- Life-expectancy models.
- Confidence claims.
- Recommendation triggers.

Until approved, `productionApproved` is false and real score-dependent outputs remain unavailable. Demo uses a separate, clearly named demo policy that cannot be imported by production engine providers.

### 19.7 Assessment explanations

Each output includes machine-readable explanation data:

```dart
class ScoreComponentResult {
  String componentId;
  int score;
  int weightBasisPoints;
  List<MetricKey> inputs;
  String ruleId;
  String explanationCopyKey;
}
```

The UI selects approved copy by key. The engine does not return unrestricted prose.

### 19.8 Remaining-life estimate

The interface exists because it is required by the governing specifications, but a production result is gated:

- It must be a range, not a date.
- It must include policy version and limitations.
- It must define minimum observations and confidence method.
- It must pass product, mechanical/data, and legal approval.
- Without the approved policy, return `Not calculated`.

No linear extrapolation from one scan is permitted.

### 19.9 Recommendations

Recommendations are deterministic catalogue entries:

```dart
class ControlledRecommendation {
  String ruleId;
  String titleCopyKey;
  String bodyCopyKey;
  List<MetricKey> supportingMetrics;
  RecommendationSeverity severity; // info or review, never emergency diagnosis
  VersionId policyVersion;
}
```

Rules may suggest comparable future scans or explain context. They may not diagnose, declare safety, decide warranty, prescribe repair, or blame the user.

### 19.10 Algorithm versioning

- `engineVersion` uses semantic versioning.
- A patch fixes implementation without changing outputs for existing valid fixtures.
- A minor version may add an output while preserving existing meaning.
- A major version changes a score, threshold, required input, grade, or interpretation.
- Every snapshot stores the full produced assessment and engine version.
- History does not silently recalculate old records.
- A future “re-evaluate with current engine” feature must create a separate derived assessment and is out of v1.0.

---

## 20. Local Persistence

### 20.1 Database choice

Use Drift over SQLite because the data is relational, locally queried, versioned, transactional, and benefits from typed schema/migrations.

The database is app-private. No account or network identifier is required.

### 20.2 Schema

```text
vehicles
  id TEXT PK
  manufacturer TEXT
  model TEXT
  variant TEXT
  profile_id TEXT
  profile_version TEXT
  last_confirmed_at_utc INTEGER

scan_snapshots
  id TEXT PK
  vehicle_id TEXT FK vehicles
  started_at_utc INTEGER
  completed_at_utc INTEGER
  timezone_offset_minutes INTEGER
  outcome TEXT CHECK complete|partial
  profile_id TEXT
  profile_version TEXT
  engine_version TEXT
  snapshot_schema_version INTEGER
  completeness_obtained INTEGER
  completeness_expected INTEGER
  created_at_utc INTEGER

observations
  scan_id TEXT FK scan_snapshots ON DELETE CASCADE
  metric_key TEXT
  status TEXT
  scaled_value INTEGER NULL
  decimal_scale INTEGER NULL
  canonical_unit TEXT NULL
  source_numeric_text TEXT NULL
  observed_at_utc INTEGER
  provenance TEXT
  pid_definition_id TEXT
  validation_status TEXT
  missing_reason TEXT NULL
  error_code TEXT NULL
  PRIMARY KEY (scan_id, metric_key)

derived_metrics
  scan_id TEXT FK scan_snapshots ON DELETE CASCADE
  metric_key TEXT
  status TEXT
  scaled_value INTEGER NULL
  decimal_scale INTEGER NULL
  canonical_unit TEXT NULL
  provenance TEXT
  formula_id TEXT
  algorithm_version TEXT
  input_keys_json TEXT
  issues_json TEXT
  PRIMARY KEY (scan_id, metric_key)

assessment_components
  scan_id TEXT FK scan_snapshots ON DELETE CASCADE
  component_id TEXT
  status TEXT
  score INTEGER NULL
  weight_basis_points INTEGER
  rule_id TEXT
  input_keys_json TEXT
  PRIMARY KEY (scan_id, component_id)

battery_assessments
  scan_id TEXT PK FK scan_snapshots ON DELETE CASCADE
  availability TEXT
  score INTEGER NULL
  grade TEXT NULL
  remaining_life_json TEXT NULL
  recommendations_json TEXT
  warnings_json TEXT
  engine_version TEXT

reports
  id TEXT PK
  scan_id TEXT FK scan_snapshots ON DELETE CASCADE
  template_version TEXT
  status TEXT
  created_at_utc INTEGER

export_artifacts
  id TEXT PK
  report_id TEXT FK reports ON DELETE CASCADE
  format TEXT
  app_controlled_path TEXT
  mime_type TEXT
  byte_length INTEGER
  generated_at_utc INTEGER

settings
  key TEXT PK
  value_json TEXT
  updated_at_utc INTEGER

adapter_preferences
  singleton_id INTEGER PK CHECK singleton_id = 1
  adapter_key_hmac TEXT
  display_alias TEXT
  adapter_class TEXT
  last_connected_at_utc INTEGER

developer_traces
  id TEXT PK
  session_id TEXT
  created_at_utc INTEGER
  expires_at_utc INTEGER
  category TEXT
  redacted_payload TEXT
```

`FleetStatistics` is not created or populated in v1.0. The future concept does not justify an active table.

### 20.3 Indexes

- `scan_snapshots(completed_at_utc DESC)`
- `scan_snapshots(vehicle_id, completed_at_utc DESC)`
- `reports(scan_id)`
- `export_artifacts(report_id)`
- `developer_traces(expires_at_utc)`

Do not add indexes without a query.

### 20.4 Transaction rules

Final scan insertion is one transaction:

```text
insert/confirm vehicle
  → insert scan snapshot
  → insert observations
  → insert derived metrics
  → insert assessment components
  → insert battery assessment
  → commit
```

If any step fails, nothing is committed. The in-memory completed snapshot is retained for Save again.

Report record and artifact metadata are inserted only after bytes are successfully written and validated.

### 20.5 Immutable scan snapshots

Application repositories expose no update method for a finalized snapshot.

Allowed operations:

- Insert once.
- Read.
- Delete one.
- Delete all.

Corrections to a parsing or engine bug require a new scan or a future explicitly versioned reprocessing feature. Direct SQL updates of historical metrics are prohibited.

### 20.6 Schema migrations

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    await transaction(() async {
      if (from < 2) await migrateV1ToV2(m);
      if (from < 3) await migrateV2ToV3(m);
    });
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
    await verifySchema(details.versionNow);
    await purgeExpiredDeveloperTraces();
  },
);
```

Rules:

- Each version has a named migration function and fixture.
- Never edit an already-released migration.
- Destructive migration is prohibited unless the user explicitly chose Delete all data.
- Migration tests open a copy of every supported prior schema, upgrade it, and verify row meaning.
- A migration failure shows a recoverable startup error and never silently creates a blank database over the old one.
- Before a risky migration, copy the app-private database to a temporary rollback file; delete it only after successful verification.

### 20.7 Backup and encryption

MVP decision:

- Do not add SQLCipher in v1.0.
- Rely on Android app sandbox and device encryption.
- Disable or explicitly exclude the database, secure key, adapter preference, reports, and traces from Android cloud backup/data extraction.
- Persist no raw VIN, Bluetooth address, location, account token, or contact data.
- Revisit database encryption before storing identifiable vehicle data, accounts, or cloud credentials.

This decision minimizes native complexity while meeting the current data-minimization model.

### 20.8 Deletion

- Deleting a scan cascades to its assessment, report records, and app-controlled export metadata/files.
- Before file deletion, resolve and validate that the path is inside the app-controlled export directory.
- Delete all local data closes active sessions, deletes app-controlled database and exports, clears adapter HMAC and install key, then recreates a clean database.
- Files the user saved or shared outside the app may remain and must be explained.

---

## 21. Scan Snapshot Lifecycle

### 21.1 Mutable draft, immutable result

```text
ScanDraft (session-owned, mutable accumulator)
    │
    ├─ add observation attempt
    ├─ add session event summary
    ├─ preserve completed readings across reconnect
    │
    ▼
FinalizeScan use case
    ├─ validate coherence
    ├─ derive metrics
    ├─ run Engine with explicit policy
    ├─ classify complete/partial/not-reportable
    └─ freeze all collections
    │
    ▼
ScanSnapshot (immutable)
    │
    ▼ atomic insert
Local history
```

The draft is never exposed to history or report screens. Presentation receives an immutable `ScanProgressViewData` projection.

### 21.2 Completion policy

A scan is:

- **Complete** when every production profile reading required by the MVP summary and Engine v1 is valid.
- **Partial** when one or more required/non-critical readings are unavailable but at least one approved reportable metric exists.
- **Not reportable** when no trustworthy result can be shown.

Battery Score availability is evaluated independently according to the Engine minimum-data rule. A partial report normally has no score or grade.

### 21.3 Snapshot reproducibility

To reproduce what the user saw, a snapshot stores:

- Original validated source observations in canonical units.
- Missing/invalid reasons.
- Derived outputs.
- Score components, weight, grade, recommendations, warnings.
- Profile, engine, formula, schema, and report-template version references.
- Timestamps and timezone offset.

It does not depend on a current vehicle profile or current engine policy when reopened.

### 21.4 Concurrency

- Only the session coordinator may mutate `ScanDraft`.
- Parsing may occur off the UI isolate, but results are committed to the draft in command order.
- Database insertion occurs after draft finalization.
- The history stream observes only committed snapshots.

---

## 22. PDF and Export Architecture

### 22.1 Separation

```text
ScanSnapshot
    ↓
BuildReportModel use case
    ↓ immutable, presentation-neutral
ImmutableReportModel
    ├──────────────► In-app report view model
    ├──────────────► PdfReportExporter
    └──────────────► ImageSummaryExporter
```

The PDF is not generated by taking screenshots of Flutter widgets. The in-app report and PDF share the same report model and copy catalogue, preventing data drift while allowing format-specific layout.

### 22.2 `ImmutableReportModel`

```dart
class ImmutableReportModel {
  ReportIdentity identity;
  ReportStatus status;          // complete, partial, demo
  VehicleDisplayData vehicle;
  DateTimeDisplay scanTime;
  List<ReportSection> sections;
  DataCompleteness completeness;
  VersionReferences versions;
  List<LimitationCopyKey> limitations;
}
```

No section contains a provider, callback, database row, plugin object, or file path.

### 22.3 PDF generation steps

1. Load the saved snapshot.
2. Build the immutable report model using the snapshot’s stored outputs.
3. Validate that required disclaimer, status, version, and provenance fields exist.
4. Render a multi-page A4 PDF with embedded local fonts.
5. Write bytes to a temporary file in app-controlled storage.
6. Reopen and validate non-zero size and expected page count range.
7. Atomically rename to the final app-controlled export path.
8. Insert artifact metadata.
9. Build preview from the exact final bytes.
10. Share or save a copy only after explicit user action.

### 22.4 Required PDF content

- EV Health name and “Informational battery report.”
- BYD Dolphin Premium.
- Unambiguous scan date/time and timezone.
- Complete/partial/demo status on page one.
- Battery Score/Grade/SOH only when available.
- Remaining capacity, cell balance, temperature analysis, and other available metrics.
- Units and provenance.
- Data completeness and missing inputs.
- Formula/source notes for calculated values.
- Vehicle-profile, engine, and template versions.
- Local-generation statement.
- Limitations/disclaimer.
- Demo watermark on every demo page.

It must omit VIN, adapter address/key, internal device ID, app database path, and raw diagnostic payloads.

### 22.5 Report file naming

Use non-identifying names:

```text
EV_Health_BYD_Dolphin_Premium_2026-07-29_<shortReportId>.pdf
```

Do not include VIN, registration, adapter name, user name, or location.

### 22.6 Preview and sharing

- Preview renders the exact generated artifact.
- Share uses Android’s share sheet through `ReportShareGateway`.
- Save a copy uses an Android document destination selected by the user.
- Temporary share files have a retention policy and are removed opportunistically.
- Export failure never deletes or mutates the scan.
- The app does not claim to manage a copy after it leaves app-controlled storage.

### 22.7 PDF validation

Automated and manual QA:

- Render each fixture PDF to page images.
- Compare critical layouts against approved goldens with a tolerance.
- Extract text and assert required labels/versions/values.
- Verify A4 dimensions, page count, no clipped bounds, embedded font glyphs, and grayscale readability.
- Compare every displayed metric against the source fixture.
- Test complete, partial, missing-value, long-copy, large-text-equivalent, and demo cases.

---

## 23. Mock and Demo Architecture

### 23.1 Goals

Demo and mocks have different purposes:

- **Demo mode** is a user-visible fictional experience with permanent labelling.
- **Fakes** are deterministic test implementations.
- **Captured fixtures** are redacted real hardware responses used for parser/profile regression.
- **Mocks** verify a narrow interaction only and are not the default for domain tests.

### 23.2 Demo data

The fixed dataset from the UI/UX specification is represented as a `DemoScanFixture`, not as production PID responses.

Rules:

- Demo policy ID contains `demo`.
- Demo report model status is always `demo`.
- Every demo screen shows `DEMO DATA`.
- Every demo PDF/image contains `DEMO — NOT A VEHICLE REPORT`.
- Demo repository `insertFinal` returns a typed prohibited-operation failure.
- Demo data does not appear in real history or production database.
- Demo requires no Bluetooth permission.

### 23.3 Test fakes

```dart
class FakeBluetoothTransport implements BluetoothClassicTransport {
  final Queue<FakeTransportEvent> script;
  // Deterministically emits connect, bytes, loss, reconnect...
}

class FakeElm327Gateway implements Elm327Gateway {
  final Map<ApprovedObdRequest, Queue<ElmResponse>> responses;
}

class InMemoryScanRepository implements ScanRepository {
  // Preserves the same insert-once semantics as production.
}
```

Fakes support virtual/deterministic time through an injected `Clock` and scheduler. Tests do not sleep.

### 23.4 Captured fixtures

Fixture format:

```json
{
  "fixtureVersion": 1,
  "vehicleProfileId": "byd_dolphin_premium_au",
  "vehicleProfileVersion": "1.0.0",
  "adapterClass": "redacted_reference_adapter",
  "requestDefinitionId": "capacity.current",
  "chunksHex": ["3431...", "0D0A3E"],
  "expectedNormalizedPayloadHex": "...",
  "expectedObservation": {
    "metricKey": "battery.currentNominalCapacity",
    "scaledValue": 147390,
    "decimalScale": 3,
    "unit": "ampHour"
  },
  "evidenceId": "PID-EVIDENCE-..."
}
```

Fixtures must be manually reviewed to ensure they contain no VIN, adapter address, registration, location, or unrelated ECU data.

---

## 24. Typed Errors and Recovery

### 24.1 Failure taxonomy

```dart
@freezed
sealed class AppFailure with _$AppFailure {
  const factory AppFailure.permission(PermissionFailure detail) = Permission;
  const factory AppFailure.bluetooth(BluetoothFailure detail) = Bluetooth;
  const factory AppFailure.elm(ElmFailure detail) = Elm;
  const factory AppFailure.vehicle(VehicleFailure detail) = Vehicle;
  const factory AppFailure.protocol(ProtocolFailure detail) = Protocol;
  const factory AppFailure.validation(DataFailure detail) = Validation;
  const factory AppFailure.engine(EngineFailure detail) = Engine;
  const factory AppFailure.persistence(StorageFailure detail) = Persistence;
  const factory AppFailure.export(ExportFailure detail) = Export;
  const factory AppFailure.configuration(ConfigFailure detail) = Configuration;
  const factory AppFailure.cancelled() = Cancelled;
  const factory AppFailure.unexpected(ErrorReference reference) = Unexpected;
}
```

Every failure has:

- Stable internal code.
- Category.
- Safe diagnostic context.
- Retryability.
- User-visible copy key.
- Permitted recovery actions.
- Whether usable scan data remains.

It does not expose a plugin exception string directly.

### 24.2 Mapping boundary

Concrete adapters catch package/platform exceptions and map them:

```dart
try {
  await plugin.connect(...);
  return const Result.success(unit);
} on PlatformException catch (error, stack) {
  diagnosticSink.record(redactor.platformFailure(error, stack));
  return Result.failure(mapBluetoothPlatformError(error));
}
```

Unknown failures receive a random support reference and redacted local diagnostic. User copy remains generic.

### 24.3 Recovery matrix

| Failure | Automatic action | User actions | Preserve observations |
|---|---|---|---|
| Bluetooth off | None | Open settings, Demo | Not applicable |
| Permission denied | None | Open settings, Demo | Not applicable |
| No adapter found | Stop discovery | Search again, Help | Not applicable |
| Connect timeout | One retry if known adapter | Try again, Help | Not applicable |
| ELM no response | At most one init retry | Try again, Compatibility help | No scan yet |
| Vehicle not responding | None | Try again, Help | No scan yet |
| Connection lost mid-scan | One reconnect | Reconnect, Stop and review | Yes |
| One PID timeout | Profile retry | Continue partial, Try scan again | Yes |
| Parse/out-of-range | No blind retry | Continue partial, Technical details | Yes |
| Score missing input | None | Review available data, Scan again | Yes |
| Save failure | Keep snapshot in memory | Save again, Continue unsaved | Yes |
| PDF failure | Keep scan/report | Try again, Close | Yes |
| Migration failure | Preserve old DB | Retry startup, Support | Yes |

### 24.4 Consumer versus Developer Mode

Consumer presentation gets:

- Plain title.
- What happened.
- What to do.
- Whether data was saved.

Developer Mode may additionally get:

- Internal code.
- Stage.
- Duration.
- Attempt number.
- Profile/PID definition ID.
- Redacted response classification.

Never include raw VIN or adapter address in either.

---

## 25. Privacy, Security, and Offline Operation

### 25.1 Data classification

| Data | v1.0 handling |
|---|---|
| Raw VIN | Transient memory only; discard after detection |
| Vehicle make/model/variant | Local persistence and reports |
| Battery readings/assessments | Local persistence; explicit user export |
| Bluetooth address | Transient memory only |
| Install-scoped adapter HMAC | Local secure/private storage only |
| Location | Never collected |
| DTCs | Not read |
| Raw diagnostic payload | Active memory; optional short-lived local Developer trace |
| PDF/image | App-private until user explicitly shares/saves |
| Analytics/network telemetry | None |

### 25.2 Security controls

- Read-only OBD command allow-list.
- No arbitrary command console.
- Input-size limits at Bluetooth, ELM, CAN, profile, JSON, database, and export boundaries.
- Strict profile schema and production approval.
- Android app sandbox and device encryption.
- Keystore-backed install key for HMAC.
- Backup exclusions.
- Export path validation.
- Redaction before diagnostics.
- Dependency and licence review.
- Release signing credentials outside the repository.
- No secrets in `--dart-define`, assets, source, or logs.

### 25.3 Offline guarantee

The production app must declare and function without internet access. Prefer omitting the Android `INTERNET` permission entirely in v1.0.

The following work in airplane mode with Bluetooth enabled:

- Startup after first install.
- Demo.
- Adapter setup/connection where Android permits.
- Vehicle scan.
- Battery analysis.
- History/report view.
- PDF/image generation.
- Share sheet/save copy.
- Privacy/legal documents.
- Data deletion.

An optional future online feature must be a separate adapter and failure domain. It must not become a transitive requirement for scan or report rendering.

### 25.4 Developer traces

- Disabled by default.
- Enabling Developer Mode requires two explicit confirmations.
- Default retention is the shorter of 24 hours or disabling Developer Mode.
- Store only redacted protocol lines needed for debugging.
- Maximum total size is bounded, for example 2 MB; oldest trace is purged first.
- A copied diagnostic bundle repeats that it may contain vehicle technical data.
- Redaction tests include VIN-like strings, MAC formats, paths, and identifiers.

### 25.5 Threat considerations

| Threat | Mitigation |
|---|---|
| Malicious/buggy adapter sends unbounded data | Buffer and response-size caps, timeouts, parser fuzzing |
| Wrong profile produces plausible bad result | Detection + explicit confirmation + versioned profile + strict range/cross-checks |
| Debug logs leak identifiers | Central redactor, no raw plugin logging, retention cap |
| Export reveals hidden metadata | Construct local metadata explicitly; omit identifiers |
| Local DB copied through backup | Android backup/data-extraction exclusions |
| Package compromise | Minimal dependencies, lockfile, licence/advisory review |
| Stale result mistaken as current | Snapshot date/time mandatory in every view/export |
| Demo mistaken for real | Structural repository separation and persistent watermark |

---

## 26. Testing Strategy

### 26.1 Test pyramid

```text
                 Hardware-in-loop / release checks
                       Integration tests
                    Widget and golden tests
              Repository, migration, PDF contract tests
        Parser, profile, validation, engine unit/property tests
```

Most coverage belongs below the UI because parsing and calculations carry the highest integrity risk.

### 26.2 Domain and engine unit tests

- Every derived formula: normal, boundary, missing, zero denominator, overflow.
- Scaled-value conversions and rounding.
- Every score curve point and just-below/at/just-above boundary.
- Minimum-data rule.
- Every grade boundary.
- Every recommendation trigger and prohibited combination.
- Algorithm version fixture stability.
- No clock/timezone dependence.

Use table-driven approved fixtures. Never create expected values by calling the same production helper under test.

### 26.3 Parser and protocol tests

- Arbitrary byte chunk boundaries.
- Multiple response lines in one chunk.
- Prompt split across chunks.
- Echo on/off.
- CR, LF, CRLF, spaces.
- `SEARCHING...`, `NO DATA`, `STOPPED`, `?`, connection/CAN errors.
- Lower/uppercase input.
- Headers on/off according to contract.
- ISO-TP single/multi-frame, missing sequence, duplicate frame, overflow.
- Unexpected ECU/header/service/PID echo.
- Odd hex, non-hex, truncated payload.
- Slow response and cancellation.
- Connection loss mid-command.
- Fuzz/property tests with buffer caps and “never crash” assertion.

### 26.4 Profile tests

- JSON/schema validation.
- No placeholders in production.
- No write or DTC requests.
- Every request/response fixture decodes to the approved value.
- All required engine inputs mapped.
- Range and cross-check evidence.
- Production approval/evidence present.
- Profile version change requires fixture change and review.

### 26.5 Persistence tests

- Atomic insert and rollback.
- Immutable insert-once behavior.
- History ordering.
- Cascade delete.
- Delete all.
- Path-safe artifact deletion.
- Every schema migration from each released version.
- Failed migration preserves source database.
- Reopen app and reconstruct exact snapshot.
- Large but bounded history.

### 26.6 Riverpod/application tests

Use `ProviderContainer` overrides:

- First connection success.
- Permission denial and recovery.
- Duplicate tap suppression.
- One reconnect.
- Partial scan continuation.
- Cancel and finalize partial.
- Completed-unsaved retry.
- Provider disposal closes resources.
- Demo overrides cannot reach production database.

### 26.7 Widget and accessibility tests

For every applicable screen:

- Loading, success, empty, partial, recoverable error, non-recoverable error.
- Light/dark.
- 360 dp width and tablet width.
- 200% font scaling.
- TalkBack semantics/focus order.
- Back/cancel behavior.
- No raw diagnostics outside Developer Mode.
- No old result without date.

Golden targets follow the UI/UX specification.

### 26.8 Integration tests

With scripted fake transport:

1. First launch → Demo → demo report/PDF → exit.
2. Permission granted → associate adapter → connect → confirm → complete scan.
3. Permission denied → settings recovery.
4. No adapter → search again.
5. Adapter connected, vehicle no response.
6. Connection loss → automatic reconnect → completion.
7. PID failure → partial result.
8. Capacity missing → no SOH/Score/Grade.
9. Save → restart → history.
10. PDF preview/share.
11. Developer Mode enable/inspect/redact/disable.
12. Delete one and delete all.

### 26.9 Hardware-in-the-loop matrix

Each candidate release records:

- Phone model, Android version, architecture.
- Adapter make/model/chip/firmware where knowable.
- Vehicle model year, market, battery variant, BMS firmware evidence where available.
- Cold/warm app.
- First association and reconnect.
- Vehicle off/on/ready.
- Other OBD app holding connection.
- Slow response and transient disconnect.
- Five-second connection and ten-second scan measurements.
- Ten consecutive complete scans.
- Partial/invalid response injection where feasible.

Reference captures are reviewed and added to fixtures only after redaction.

### 26.10 Release quality gates

Required:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test test/architecture
flutter test test/unit
flutter test test/widget
flutter test test/golden
flutter test integration_test
profile validator
licence/dependency check
release AAB build
PDF fixture render/verification
```

Hardware gates cannot be replaced by fake tests.

---

## 27. Environments and Release Configuration

### 27.1 Flavors

| Flavor | Application ID | Purpose | Vehicle profiles |
|---|---|---|---|
| `dev` | `com.evhealth.app.dev` | Local development, fake transport, demo, Developer Mode | Fixtures plus explicitly selected unapproved local profiles |
| `qa` | `com.evhealth.app.qa` | Release-like automated/manual/hardware validation | Candidate profile with visible QA banner |
| `prod` | `com.evhealth.app` | Public release | Approved production profiles only |

### 27.2 Compile-time configuration

```dart
class ReleaseConfig {
  AppEnvironment environment;
  bool allowFakeTransport;
  bool allowUnapprovedProfiles;
  bool developerModeAvailable;
  bool networkEnabled;          // false for all v1.0 flavors by default
  Duration developerTraceTtl;
}
```

Rules:

- Production flags are compile-time constants.
- The production build cannot enable fake transport or unapproved profiles at runtime.
- No secret is stored in configuration.
- Feature flags do not bypass governing scope.
- The app/version/profile/engine/template identifiers are visible in About.

### 27.3 Android configuration

- `minSdk = 29`.
- `compileSdk` and `targetSdk` match the current stable toolchain and Play requirement at release.
- Java 17 and the Flutter-supported Kotlin/Gradle versions.
- ARM64 required; include other supported Android ABIs only if tested.
- R8/resource shrinking enabled for production after integration tests.
- App backup/data extraction explicitly configured.
- Network security config does not permit cleartext; ideally no Internet permission.
- Release signing uses protected CI/local credentials outside source control.

### 27.4 Versioning

- App version follows semantic versioning with monotonically increasing Android build number.
- Vehicle profile, Engine policy, database schema, report template, and demo fixture have independent versions.
- A release manifest records all versions:

```json
{
  "appVersion": "1.0.0",
  "buildNumber": 100,
  "databaseSchema": 1,
  "vehicleProfiles": {
    "byd_dolphin_premium_au": "1.0.0"
  },
  "batteryEngine": "1.0.0",
  "reportTemplate": "1.0.0",
  "demoFixture": "1.0.0"
}
```

### 27.5 CI/CD

CI stages:

1. Restore pinned Flutter SDK.
2. Fetch locked dependencies.
3. Generate code.
4. Format/analyze/architecture checks.
5. Unit/widget/golden/integration tests.
6. Validate profiles and engine policies.
7. Build dev/qa.
8. Produce release candidate AAB only from a tagged, clean commit.
9. Attach checksums, dependency list, licence report, test evidence, and release manifest.

Publishing to Google Play remains a reviewed human/product-owner action.

---

## 28. Future Backend Extension Points

No backend code, SDK, endpoint, account, or sync table is included in v1.0.

The architecture leaves these seams:

```dart
abstract interface class ScanRepository { /* local contract */ }

abstract interface class SyncCoordinator {
  Future<Result<SyncSummary, AppFailure>> syncApprovedRecords();
}

abstract interface class RemoteScanDataSource {
  Future<Result<void, AppFailure>> upload(
    ApprovedUploadEnvelope envelope,
  );
}
```

Future rules:

- Remote DTOs live in a separate Infrastructure module.
- Domain entities do not gain Supabase/Firebase/API annotations.
- Local IDs remain primary; server IDs are mapping metadata.
- An outbox pattern is preferred for explicit opt-in uploads.
- Sync state must not alter immutable scan values.
- Authentication and sync failures never block local scan/report use.
- Upload envelopes use explicit allow-lists, not generic entity serialization.
- VIN, adapter identifiers, report content, exact readings, or benchmark contribution require new product/privacy approval.
- Network permission and privacy policy changes are release-level ADRs.

The earlier PRD’s possible Supabase direction is a future option, not an architectural dependency.

---

## 29. Additional Vehicle Support

### 29.1 Extension path

To add a vehicle:

1. Create a new profile with a unique ID/version.
2. Supply compatibility and detection rules.
3. Supply verified init/request/response/decoder definitions.
4. Map outputs to existing canonical metric keys.
5. Add new canonical keys only through an engine/report design review.
6. Add redacted request/response fixtures.
7. Pass profile schema, parser, range, cross-check, and hardware tests.
8. Add controlled display/support copy.
9. Record evidence and approval.
10. Enable the profile in the production catalogue.

Core scan orchestration must not change.

### 29.2 Profile catalogue

```dart
class VehicleProfileCatalogue {
  Map<VehicleProfileId, ProfileAssetReference> approvedProfiles;
}
```

Profiles are bundled locally for v1.0 and near-term releases. Runtime-downloaded profiles are deferred because they would introduce signature, rollback, privacy, network, and safety concerns.

### 29.3 Variant discipline

A model name alone is not enough. A production profile declares:

- Market/region.
- Model years.
- Trim/variant.
- Battery capacity/chemistry where relevant.
- BMS/ECU compatibility evidence.
- Known exclusions.

If detection cannot distinguish variants safely, the app requires explicit confirmation and must refuse unsupported combinations.

### 29.4 Engine compatibility

A vehicle profile declares which Engine input roles it satisfies. A new profile may:

- Produce the complete Engine v1 contract.
- Produce a partial informational report with Score unavailable.

It may not change Engine v1 weights or silently substitute unrelated metrics.

---

## 30. AI Coding-Agent Rules

These rules are mandatory for all implementation tasks.

### 30.1 Before editing

1. Read the SDS/Constitution, PRD decisions, UI/UX specification, this architecture, applicable ADRs, and repository instructions.
2. Identify the assigned feature, acceptance criteria, relevant ports, and layer.
3. Inspect existing code and tests before creating a new abstraction.
4. State any governing-document conflict. Do not silently resolve it in code.
5. Do not begin work that requires an unresolved calibration/PID value.

### 30.2 Scope

- Implement only the assigned slice.
- Do not add adjacent features, analytics, networking, DTCs, write commands, accounts, or additional vehicles.
- Do not “temporarily” hardcode production PID bytes, score thresholds, demo values, or legal copy.
- Do not replace unavailable data with a placeholder that can reach a real report.
- Do not weaken privacy or validation to make a test pass.

### 30.3 Architecture

- Respect dependency direction.
- Use existing ports; add a port only when an actual alternate implementation or boundary exists.
- Never import Infrastructure from Presentation.
- Never put business logic in a widget or Riverpod provider body.
- Never expose plugin/platform objects outside Infrastructure.
- Never use global mutable singletons. Riverpod owns lifecycle.
- Prefer composition over inheritance.
- Keep one active OBD session and one in-flight ELM command.
- Use immutable domain and state models.
- Close streams, sockets, database resources, timers, and subscriptions.

### 30.4 Data integrity

- Preserve source observations separately from derived outputs.
- Carry unit, scale, timestamp, provenance, profile/PID ID, and validation status.
- Treat missing, unsupported, timeout, parse failure, and invalid range as different cases.
- Do not clamp invalid input into a plausible result unless an approved policy explicitly says so.
- Do not calculate an output when a required input is missing.
- Do not recalculate stored snapshots silently.
- Use UTC for storage and explicit timezone offset for report context.

### 30.5 Bluetooth/OBD

- UI and application code never contain raw ELM or OBD commands.
- Only approved read/configuration command types may be serialized.
- No arbitrary command text field, including Developer Mode.
- Do not persist or log raw VIN or Bluetooth address.
- Enforce buffer sizes, timeouts, and cancellation.
- Add a fixture for every new parser behavior or PID mapping.
- Hardware success must be reported honestly; a fake test is not hardware validation.

### 30.6 Battery Engine

- Engine code is deterministic and pure.
- Do not invent thresholds, grade boundaries, confidence, life estimates, or recommendation text.
- Keep Engine and profile versions explicit.
- Add boundary tests for any approved policy change.
- A changed historical expected score is a breaking policy decision, not a casual test update.

### 30.7 UI and content

- Use design tokens and governed reusable components.
- Implement loading, empty, partial, error, offline, stale, and success states where applicable.
- Keep technical raw data inside explicitly enabled Developer Mode.
- Use controlled copy keys.
- Preserve demo/partial labels everywhere.
- Support TalkBack, 200% font scale, light/dark, Android back, and 48 dp targets.
- Never use colour as the only status signal.

### 30.8 Persistence and files

- Use repository/DAO methods; no SQL in controllers or screens.
- Final snapshot insert is atomic.
- Never edit a released migration.
- Validate file paths before deletion.
- Do not write exports outside app-controlled storage until the user chooses a destination.
- Do not claim external copies were deleted.

### 30.9 Dependencies

- Prefer the standard library or existing dependency.
- Before adding a package, document why, licence, maintenance state, platform support, privacy/network behavior, and alternative.
- Wrap plugins.
- Do not upgrade unrelated dependencies in a feature task.
- Do not commit secrets or machine-specific paths.

### 30.10 Tests and completion report

Every implementation task must:

1. Add/update tests for success, missing, invalid, cancellation, and failure paths relevant to the change.
2. Run formatting, analysis, and targeted tests.
3. Run broader regression tests in proportion to risk.
4. Report:
   - Files changed.
   - Behavior implemented.
   - Tests and results.
   - Assumptions.
   - Hardware actually used, if any.
   - Known limitations/unresolved decisions.
5. Stop after the assigned task. Do not start the next sequence item without instruction.

---

## 31. Implementation Sequence

The sequence is vertical and risk-driven. A later phase must not force structural rewrites of an accepted earlier phase.

### Phase 0 — Repository foundation

Deliver:

- Flutter project and flavors.
- Pinned SDK/dependencies.
- Folder structure.
- Lints and architecture checks.
- Freezed/Riverpod/Drift generation pipeline.
- Core `Result`, failure, clock, IDs, units.
- CI skeleton.

Exit criteria:

- Empty app builds in dev/qa/prod.
- Format/analyze/tests pass.
- Production config cannot enable fake transport.

### Phase 1 — Domain contract and demo vertical slice

Deliver:

- Domain entities and ports.
- Exact governed demo fixture.
- Demo repository/provider overrides.
- App shell, theme, navigation.
- Onboarding, Demo disclosure, Demo Home.
- Result summary, full report, metric detail.
- Demo PDF with watermark.

Exit criteria:

- Demo never opens Bluetooth or production database.
- Demo cannot enter real history.
- Core UI accepted at 200% font and TalkBack.
- PDF values match fixture and every page is watermarked.

This follows the UI/UX specification’s recommended first build slice.

### Phase 2 — Local persistence and history

Deliver:

- Drift schema v1 and repositories.
- Startup/migration handling.
- Immutable snapshot insert/read/delete.
- History and reports screens.
- Settings persistence, privacy, delete one/all.
- Backup exclusion.

Exit criteria:

- Snapshot round-trip is exact.
- Restart preserves history.
- Atomic failure leaves no partial rows.
- Delete behavior and migration fixtures pass.

### Phase 3 — Bluetooth Classic hardware spike

Deliver:

- Package/licence evaluation.
- `BluetoothClassicTransport` adapter.
- Permission/association flow on Android 10 and current Android.
- Reference-adapter byte echo/AT proof.
- Cancellation, disconnect, one reconnect.
- Decision record choosing wrapped package or native Kotlin fallback.

Exit criteria:

- Reference adapter connects repeatedly.
- No raw address is logged/persisted.
- Connection timing evidence recorded.
- Other OBD app contention and Bluetooth-off cases tested.

Do not implement BYD PIDs in this phase.

### Phase 4 — ELM327 client and protocol parser

Deliver:

- Single-flight command queue.
- Prompt parser and typed tokens.
- OBD/CAN normalizer and frame assembler.
- Buffer/timeout/cancellation limits.
- Scripted fake transport and malformed-input/fuzz tests.
- Local Developer trace/redaction foundation.

Exit criteria:

- Captured generic/reference adapter fixtures pass.
- Parser survives arbitrary chunking and malformed input.
- No user-entered command path exists.

### Phase 5 — Verified BYD Dolphin Premium profile

Deliver:

- Profile schema/loader/validator.
- Detection plan with transient VIN handling.
- Verified init script.
- Verified PID definitions and redacted captures.
- Canonical decoders, ranges, cross-checks.
- Hardware evidence and compatibility statement.

Exit criteria:

- No placeholders.
- Every PID has traceable evidence and fixture.
- Unsupported vehicle cannot scan.
- Raw VIN lifecycle test passes.
- Ten consecutive raw observation scans on the reference setup meet reliability expectations.

### Phase 6 — Scan orchestration

Deliver:

- Full OBD session state machine.
- Setup, connection, vehicle confirmation.
- Preparation, actual scan progress, cancel.
- Reconnect and partial preservation.
- Finalize/atomic save.
- User-facing recovery catalogue.

Exit criteria:

- Complete and partial flows pass with fake and hardware transport.
- Actual step progress, not timers.
- Five-/ten-second measurements recorded.
- Completed readings survive one transient disconnect.

### Phase 7 — Battery Intelligence Engine v1

Deliver:

- Approved derived formulas.
- Approved normalisation curves and grade boundaries.
- Fixed 60/20/10/10 weighting.
- Minimum-data rule.
- Controlled recommendation catalogue.
- Remaining-life output only if approved.
- Golden engine fixtures and versioning.

Exit criteria:

- Mechanical/product/legal approvals attached to policy.
- All boundary and missing-input tests pass.
- Real snapshots produce explainable outputs.
- No production import of demo policy.

This phase can be coded structurally earlier, but production policy activation waits for approval.

### Phase 8 — Real report integration and PDF

Deliver:

- Real result summary/full report/metric detail.
- Report model from immutable snapshot.
- PDF preview/generate/share/save.
- Partial PDF behavior.
- Saved report management.
- Image summary if required for v1.0 release.

Exit criteria:

- In-app and PDF values match snapshot.
- A4/grayscale/glyph QA passes.
- No prohibited identifiers/claims.
- Export failure leaves scan intact.

### Phase 9 — Developer Mode, accessibility, reliability

Deliver:

- Explicit Developer Mode enable/disable.
- Raw session diagnostics with redaction and retention.
- Copy diagnostic bundle.
- Dark theme refinement.
- TalkBack, font scale, responsive/golden completion.
- Performance and crash measurement instrumentation that remains local unless separately approved.

Exit criteria:

- Raw data absent outside Developer Mode.
- Disabling purges/stops trace logging.
- Core flow passes accessibility checklist.
- No critical/high defect remains.

### Phase 10 — Release candidate

Deliver:

- Full test and hardware matrix.
- Profile/engine/report release manifest.
- Legal/privacy/trademark review outcomes.
- Dependency/licence report.
- Signed release AAB.
- Rollback/support notes.

Exit criteria:

- All MVP acceptance criteria and Definition of Done pass.
- DTC remains absent.
- Product owner approves the documented reference-hardware evidence.

---

## 32. Risks and Mitigations

| ID | Risk | Likelihood / impact | Mitigation | Release gate |
|---|---|---|---|---|
| R-01 | BYD proprietary PID mapping is wrong or variant-specific | High / Critical | Evidence-backed profiles, detection, fixtures, range/cross-checks, one reference variant | All production PIDs approved |
| R-02 | Cheap ELM327 clone behaves inconsistently | High / High | Reference adapter list, strict init, timeouts, one-flight queue, compatibility messaging | Hardware matrix |
| R-03 | Flutter Classic Bluetooth plugin is immature/incompatible | Medium / High | Port boundary, licence spike, native Kotlin fallback | ADR after spike |
| R-04 | Ten-second scan target conflicts with command count | Medium / Medium | Measure early, prioritize scan plan, adaptive timing, no fake percentage | Reference timing evidence |
| R-05 | Score appears authoritative despite uncertain data | Medium / Critical | Minimum-data rule, provenance, controlled copy, no score for partial data | Policy/legal approval |
| R-06 | Normalisation thresholds are invented by code generation | Medium / Critical | Production policy fail-closed, approval metadata, fixtures | `productionApproved=true` only after review |
| R-07 | Raw VIN/MAC leaks via exceptions/logs | Medium / High | Transient handles, central redactor, HMAC preference, log tests | Privacy tests |
| R-08 | Demo data contaminates history or exports | Low / High | ProviderScope repository separation, type distinction, watermarks | Demo isolation tests |
| R-09 | Database migration loses history | Low / High | Named additive migrations, prior-schema fixtures, rollback copy | Migration suite |
| R-10 | PDF differs from in-app result | Medium / High | Shared immutable report model, text/value assertions, rendered QA | PDF contract tests |
| R-11 | Old scan is mistaken for current condition | Medium / Medium | Timestamp mandatory in cards, routes, PDF, history | UI acceptance |
| R-12 | Derived metric uses incompatible units/sign | Medium / High | Typed canonical units, profile sign convention, cross-checks | Decoder/formula fixtures |
| R-13 | Auto reconnect conflicts with adapter-identifier privacy | Medium / Medium | Install-scoped HMAC only, never export/transmit, privacy review fallback disables persistence | Privacy approval |
| R-14 | AI agent creates unnecessary abstractions/dependencies | High / Medium | Fixed tree/ports, phase scope, architecture tests, dependency rules | PR/task review |
| R-15 | No backend limits crash measurement | Expected / Low | Local QA counters and documented test samples; add telemetry only after privacy decision | Honest release reporting |
| R-16 | Remaining-life estimate is scientifically weak | High / Critical | Fail closed to Not calculated until model/data/legal approval | Separate policy approval |
| R-17 | Android permission behavior varies by OS | Medium / Medium | API-specific gateway, Companion Device Manager preference, OS matrix | Android 10/current tests |
| R-18 | App interaction distracts a driver | Low / Critical | Parked instructions, no background/live dashboard, no driving advice | Safety content review |

---

## 33. Architectural Decision Records

Detailed ADR files should be stored in `docs/adr/`. The following records are part of this baseline.

### ADR-001 — Layered clean architecture with feature presentation modules

**Status:** Accepted  
**Decision:** Use Domain, Application, Presentation, Infrastructure, and App/bootstrap layers. Organize screens by feature under Presentation.  
**Reason:** Keeps the hardware and vehicle-specific risks isolated without creating a package-per-feature enterprise structure.  
**Consequences:** Dependency rules require enforcement; some cross-feature entities live centrally in Domain.

### ADR-002 — Riverpod is state management and composition root

**Status:** Accepted  
**Decision:** Use Riverpod 3 `(Async)Notifier` providers for lifecycle, async state, and DI; no GetIt/service locator and no legacy `StateNotifier`.  
**Reason:** One testable graph can supply real, fake, QA, and demo implementations.  
**Consequences:** Business rules must stay out of providers; long-lived session providers require explicit cleanup.

### ADR-003 — Bluetooth Classic RFCOMM behind an application-owned port

**Status:** Accepted  
**Decision:** Do not expose a Bluetooth package API. Hardware-spike a compatible plugin; fall back to a small Kotlin adapter.  
**Reason:** ELM327 Classic uses RFCOMM/SPP, while Flutter package maturity and licensing vary.  
**Consequences:** A hardware spike is a blocking early phase; a small native module may be needed.

### ADR-004 — Profile-driven vehicle support

**Status:** Accepted  
**Decision:** Store commands, response contracts, decoders, ranges, and evidence in strict versioned local profile assets.  
**Reason:** Vehicle logic must not leak into UI/core, and proprietary values need independent verification.  
**Consequences:** A schema validator and evidence workflow are mandatory. Profiles cannot contain arbitrary executable formulas.

### ADR-005 — Drift/SQLite local-first persistence

**Status:** Accepted  
**Decision:** Use Drift over SQLite; no backend in v1.0.  
**Reason:** Typed local relational queries, transactions, migrations, and offline streams match scan/history/report needs.  
**Consequences:** Generated schema and migration testing are required.

### ADR-006 — Immutable finalized scan snapshots

**Status:** Accepted  
**Decision:** Insert a complete snapshot once; never update its readings or assessment.  
**Reason:** Historical trust and reproducibility require preserving what the user saw with its profile/engine versions.  
**Consequences:** Algorithm fixes do not rewrite history; future reprocessing must create a separate versioned artifact.

### ADR-007 — Deterministic, data-calibrated Battery Engine

**Status:** Accepted  
**Decision:** Pure engine with fixed v1 weights and approved local policy data; no AI/free-text/model call.  
**Reason:** Explainability, offline use, testability, and safety.  
**Consequences:** Score/grade/life/recommendations fail closed until calibration is approved.

### ADR-008 — Canonical scaled integers for persisted measurements

**Status:** Accepted  
**Decision:** Persist scaled integers, decimal scale, and unit instead of canonical floating-point values.  
**Reason:** Reproducibility and explicit precision.  
**Consequences:** Unit/value-object helpers are required; report formatting cannot read SQLite `REAL` directly.

### ADR-009 — Shared immutable report model, format-specific renderers

**Status:** Accepted  
**Decision:** Build in-app and PDF/image outputs from one report model; generate PDF as a document, not a screenshot.  
**Reason:** Prevent value/copy drift and ensure accessible A4 output.  
**Consequences:** PDF layout has separate tests and templates.

### ADR-010 — Structurally isolated demo mode

**Status:** Accepted  
**Decision:** Use ProviderScope overrides and a non-persisting demo repository/exporter.  
**Reason:** Labels alone are insufficient to prevent fictional data entering history.  
**Consequences:** Demo navigation is a scoped flow and every export renderer must understand demo status.

### ADR-011 — Local adapter HMAC for reconnect

**Status:** Accepted pending privacy review  
**Decision:** Persist an install-scoped HMAC derived from the transient address, never the address itself.  
**Reason:** Reconcile auto-reconnect with data minimization.  
**Consequences:** Requires a Keystore-backed install key and bonded-candidate enumeration; disable cross-restart reconnect if rejected.

### ADR-012 — No database encryption or cloud backup in v1.0

**Status:** Accepted  
**Decision:** Use app sandbox/device encryption, exclude app data from backup, and store no direct identifiers; do not add SQLCipher.  
**Reason:** Current threat model does not justify native encryption complexity.  
**Consequences:** Revisit before accounts, raw identifiers, or cloud features.

### ADR-013 — No Internet permission/backend in v1.0

**Status:** Accepted  
**Decision:** Core build contains no network integration and preferably no Android Internet permission.  
**Reason:** Governing local-first scope, privacy, reliability, and MVP simplicity.  
**Consequences:** Crash metrics are local/manual until separately approved.

### ADR-014 — DTC support deferred to v1.1

**Status:** Accepted  
**Decision:** No DTC command, entity, route, table, copy, or UI in v1.0.  
**Reason:** Explicit product scope and separate safety/content needs.  
**Consequences:** v1.1 adds a separate feature and service allow-list revision; it must not overload battery scan snapshots.

### ADR-015 — Bundled profiles; no runtime profile download

**Status:** Accepted  
**Decision:** Vehicle profiles ship with the signed application.  
**Reason:** Runtime downloads require authenticity, rollback, remote configuration, and privacy architecture that v1.0 does not have.  
**Consequences:** New/updated vehicle support requires an app release.

---

## 34. Architecture Acceptance Criteria

### 34.1 Structure and dependencies

- [ ] Repository follows the proposed layers or an approved ADR documents a change.
- [ ] Domain has no Flutter/Riverpod/Drift/plugin imports.
- [ ] Presentation has no Infrastructure imports.
- [ ] No raw OBD command or vehicle-specific parser exists in UI/application.
- [ ] Concrete dependencies are selected only in `app/di`.
- [ ] Architecture checks run in CI.

### 34.2 Bluetooth and OBD

- [ ] Bluetooth Classic RFCOMM works on the reference Android/adapter setup.
- [ ] BLE-only transport is not used for the reference Classic adapter.
- [ ] One command is in flight.
- [ ] Timeouts, cancellation, disconnect, and one reconnect are deterministic.
- [ ] Production command allow-list contains no write, clear, actuator, coding, or DTC operation.
- [ ] Raw VIN and adapter address are never persisted/logged/exported.
- [ ] Reference connection timing is documented.

### 34.3 Vehicle profile and parsing

- [ ] BYD Dolphin Premium production profile is versioned, approved, and contains no placeholders.
- [ ] Every PID mapping has evidence and a redacted fixture.
- [ ] Parser validates header/service/identifier/length/range.
- [ ] Unsupported/wrong vehicle cannot proceed.
- [ ] Missing/invalid data never becomes zero.
- [ ] A new vehicle can be added without changing UI/session/database core.

### 34.4 Battery Intelligence

- [ ] Engine is pure and deterministic.
- [ ] v1 weights are exactly 60/20/10/10.
- [ ] Normalisation, grade, remaining-life, and recommendation policies contain approval metadata.
- [ ] Score/grade are unavailable when any required component is unavailable.
- [ ] Every output records inputs, rule/formula, provenance, and version.
- [ ] Old snapshots render without current-engine recalculation.

### 34.5 Persistence

- [ ] Final snapshot insertion is atomic.
- [ ] Repository exposes no finalized-snapshot update.
- [ ] Every released schema has a tested migration path.
- [ ] Startup does not destroy a database after migration failure.
- [ ] Individual/all-data deletion is correct and path-safe.
- [ ] Android backup exclusions are verified.
- [ ] Demo data cannot be persisted.

### 34.6 Reports

- [ ] PDF is built from the immutable report model.
- [ ] Preview and final export use the same bytes.
- [ ] Complete/partial/demo state is prominent.
- [ ] Values/units/provenance match the saved snapshot.
- [ ] No prohibited identifier or claim appears.
- [ ] A4, grayscale, page-break, glyph, and clipping checks pass.
- [ ] Export failure does not modify/delete the scan.

### 34.7 Privacy/security/offline

- [ ] App works without internet and contains no unapproved network SDK.
- [ ] Location is not collected.
- [ ] Developer traces are opt-in, redacted, size/time bounded, and purged on disable.
- [ ] Report sharing is explicit and previewed.
- [ ] Buffer and payload limits exist at untrusted input boundaries.
- [ ] Dependencies and licences are reviewed.

### 34.8 Quality

- [ ] Complete and partial fake end-to-end flows pass.
- [ ] Reference hardware flow passes.
- [ ] TalkBack and 200% font core flow pass.
- [ ] Required release commands pass.
- [ ] Five-second connection and ten-second scan targets are measured under documented conditions.
- [ ] Greater than 99% crash-free target is evaluated using a documented sample and honest methodology.

---

## 35. Definition of Done

### 35.1 Feature Definition of Done

A feature is done only when:

1. Its governing acceptance criteria are met.
2. Code is in the correct layer and follows dependency rules.
3. Success, missing/partial, invalid, cancellation, and relevant failure states are implemented.
4. Data has unit, provenance, version, and validation metadata where applicable.
5. Privacy and redaction requirements are tested.
6. Unit/widget/integration tests appropriate to the change pass.
7. `dart format` and `flutter analyze` pass.
8. Accessibility and theme requirements are verified for changed UI.
9. Documentation/ADRs/profile evidence/migrations are updated.
10. No critical/high defect remains.
11. Hardware-dependent behavior is tested on hardware or clearly marked unverified.
12. The completion report lists changes, tests, assumptions, and limitations.

### 35.2 MVP Definition of Done

EV Health v1.0 is done only when:

- A user can complete onboarding or enter clearly labelled Demo mode.
- A user can associate/connect the approved ELM327-compatible Bluetooth Classic adapter.
- The app confirms the verified BYD Dolphin Premium profile.
- The read-only reference scan completes reliably, preserving partial results when appropriate.
- Battery health, Battery Score/Grade, cell balance, temperature analysis, and other approved outputs are produced only from valid data.
- Score policy/calibration is approved; otherwise the release does not pretend the score is available.
- Scan snapshots persist locally and remain exact across restart.
- History, report storage, deletion, and privacy controls work offline.
- A complete or partial report generates, previews, saves, and shares as a compliant PDF.
- Demo records and exports remain unmistakably fictional.
- Developer Mode is disabled by default and redacted.
- DTC behavior is absent.
- No vehicle write path exists.
- The reference hardware, parser/profile fixtures, engine fixtures, migrations, accessibility, PDF, and release suites pass.
- Product, safety/legal/privacy, and vehicle-profile approvals are recorded.
- A signed Android release artifact and release manifest are produced.

---

## 36. Traceability Matrix

| Governing requirement | Architectural response |
|---|---|
| Android-first Flutter | Sections 4, 7, 27 |
| BYD Dolphin Premium | Sections 17, 29 |
| ELM327 Bluetooth OBD | Sections 14–16 |
| Battery health/score | Sections 18–19 |
| Cell balance | Canonical cell observations and cell-delta formula |
| Temperature analysis | Temperature observations, spread, Engine component |
| Scan history/local reports | Sections 20–22 |
| Demo mode | Section 23 and ADR-010 |
| PDF export | Section 22 and ADR-009 |
| DTC deferred to v1.1 | Scope rule, ADR-014 |
| Raw data only in Developer Mode | Sections 15, 24–25 |
| Modular vehicles | Profile boundary, Section 29 |
| Versioned engine | Section 19 |
| Offline-first/privacy | Sections 25, 28 |
| AI coding rules | Section 30 |
| Tests/manual BYD validation | Section 26 |
| Definition of Done | Section 35 |

---

## 37. External Implementation References

These links support technology/platform decisions; the governing project documents remain the product source of truth.

- [Flutter supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms)
- [Android Bluetooth permissions](https://developer.android.com/develop/connectivity/bluetooth/bt-permissions)
- [Android companion device pairing](https://developer.android.com/develop/connectivity/bluetooth/companion-device-pairing)
- [Android RFCOMM `BluetoothDevice` API](https://developer.android.com/reference/android/bluetooth/BluetoothDevice)
- [Riverpod providers and Notifier model](https://riverpod.dev/docs/concepts2/providers)
- [Riverpod code generation guidance](https://riverpod.dev/docs/concepts/about_code_generation)
- [Flutter `go_router`](https://pub.dev/packages/go_router)
- [Drift persistence](https://pub.dev/packages/drift)
- [Dart/Flutter PDF generation](https://pub.dev/packages/pdf)
- [Flutter PDF preview/printing](https://pub.dev/packages/printing)
- [Android platform share integration via `share_plus`](https://pub.dev/packages/share_plus)

---

## 38. Revision Log

| Version | Date | Summary |
|---|---|---|
| 1.0 | 29 July 2026 | Initial implementation baseline for the Android-first BYD Dolphin Premium EV Health MVP |

