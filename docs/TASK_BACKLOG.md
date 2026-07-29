# EV Health MVP Task Backlog

**Version:** 1.0  
**Platform:** Android-first Flutter  
**Reference vehicle:** BYD Dolphin Premium

## 1. Execution rules

- Complete one numbered task at a time.
- Read `AGENTS.md` and governing documents before coding.
- Do not add unapproved features.
- Every task must include tests appropriate to the change.
- Prefer a working demo-data product before real Bluetooth integration.
- A task is complete only when formatting, static analysis, and tests pass.

## 2. Milestones

```text
M0 Repository readiness
M1 Clickable demo-data app
M2 Local persistence and reports
M3 Bluetooth and ELM327 transport
M4 BYD Dolphin real scan
M5 Reliability, accessibility, and beta release
```

## M0 — Repository readiness

### TASK-001 Initialise Flutter application

**Objective:** Create the Android-first Flutter project in the approved application directory.

**Dependencies:** None.

**Acceptance criteria:**
- App launches on an Android emulator.
- Package/application identifiers follow project naming rules.
- Generated sample counter code is removed.
- README contains setup commands.

**Tests:** Default smoke/widget test updated and passing.

### TASK-002 Configure analysis and formatting

**Objective:** Add strict Dart analysis, formatting rules, and project lints.

**Dependencies:** TASK-001.

**Acceptance criteria:**
- `flutter analyze` passes.
- No ignored warnings without documented reason.
- CI-ready commands are documented.

### TASK-003 Add approved dependencies

**Objective:** Add only architecture-approved packages for state management, navigation, immutable models, storage abstraction, and testing.

**Dependencies:** TASK-002.

**Acceptance criteria:**
- Versions are pinned according to project policy.
- Every dependency has a documented purpose.
- No Bluetooth or PDF package is added before its implementation task unless architecture requires it.

### TASK-004 Create application folder structure

**Objective:** Implement the Architecture Specification folder boundaries.

**Dependencies:** TASK-003.

**Acceptance criteria:**
- Core, domain, data, infrastructure, and presentation boundaries exist.
- Placeholder files are minimal.
- UI cannot import infrastructure implementations directly.

### TASK-005 Add CI workflow

**Objective:** Run formatting check, static analysis, and tests on pull requests.

**Dependencies:** TASK-002.

**Acceptance criteria:**
- CI runs on pull requests and main.
- Failed checks block completion expectations.

## M1 — Clickable demo-data app

### TASK-006 Implement design tokens and app theme

**Dependencies:** TASK-004.

**Acceptance criteria:**
- Typography, spacing, semantic colours, card, and button themes are centralised.
- No feature screen hardcodes brand styling.
- Large text does not break base components.

**Tests:** Theme and representative component widget tests.

### TASK-007 Implement navigation shell

**Dependencies:** TASK-006.

**Acceptance criteria:**
- Home, History, and Settings roots exist.
- Bottom navigation follows the UI/UX specification.
- Back navigation is predictable.

### TASK-008 Implement onboarding flow

**Dependencies:** TASK-007.

**Acceptance criteria:**
- Welcome, How It Works, Privacy, and Bluetooth explanation screens exist.
- System Bluetooth permission is not requested yet; use an injectable placeholder action.
- Onboarding completion persists through an in-memory repository.

**Tests:** First-launch and returning-user widget flows.

### TASK-009 Implement reusable UI components

**Dependencies:** TASK-006.

**Acceptance criteria:**
- Hero health indicator, metric card, scan-step row, insight card, empty state, error panel, and confidence label exist.
- Components contain no battery calculations.

### TASK-010 Create domain models

**Dependencies:** TASK-004.

**Acceptance criteria:**
- Immutable models exist for vehicle, adapter, scan, raw reading, analysis result, and report snapshot.
- Source classification supports real/demo/test.
- Serialisation concerns remain outside core domain where architecture requires.

**Tests:** Equality, validation, and construction tests.

### TASK-011 Implement demo repositories

**Dependencies:** TASK-010.

**Acceptance criteria:**
- Demo vehicle, scan, report, settings, and history are returned through repository interfaces.
- Demo data is clearly classified and separated.

**Tests:** Repository unit tests.

### TASK-012 Build Home screen with demo state

**Dependencies:** TASK-007, TASK-009, TASK-011.

**Acceptance criteria:**
- No-scan and recent-scan states match UI/UX specification.
- Primary action starts demo scan when demo mode is enabled.

### TASK-013 Build adapter discovery mock screens

**Dependencies:** TASK-009.

**Acceptance criteria:**
- Searching, results, no-device, disabled-Bluetooth, permission-denied, and error states are present using mocks.

### TASK-014 Build vehicle confirmation screen

**Dependencies:** TASK-010.

**Acceptance criteria:**
- BYD Dolphin Premium profile is shown.
- Unsupported-vehicle path exits safely.

### TASK-015 Build scan preparation screen

**Dependencies:** TASK-014.

**Acceptance criteria:**
- Safety copy is visible.
- Start action is explicit.
- Vehicle power-state instruction is configuration-driven.

### TASK-016 Build scan progress state machine UI

**Dependencies:** TASK-009, TASK-011.

**Acceptance criteria:**
- Real progress states are represented by typed state objects.
- Demo mode can simulate complete, partial, failed, and cancelled scans.
- No fake percentage is shown.

**Tests:** State transition and widget tests.

### TASK-017 Implement Battery Engine core calculations

**Dependencies:** TASK-010.

**Acceptance criteria:**
- SOH, cell delta, and temperature spread calculations follow `BATTERY_ENGINE.md`.
- Validation occurs before calculation.
- Thresholds are injected configuration.

**Tests:** All documented test vectors and edge cases.

### TASK-018 Implement deterministic insight templates

**Dependencies:** TASK-017.

**Acceptance criteria:**
- Plain-English content is selected from typed, versioned rules.
- No free-form diagnostic or safety advice is generated.

### TASK-019 Build scan result summary

**Dependencies:** TASK-009, TASK-017, TASK-018.

**Acceptance criteria:**
- Health, score, grade, confidence, key metrics, timestamp, and source classification render correctly.
- Demo banner is always visible for demo data.
- Missing values render as unavailable.

### TASK-020 Build full battery report

**Dependencies:** TASK-019.

**Acceptance criteria:**
- Summary, capacity, cell balance, temperature, usage, technical details, method, and limitations sections exist.
- Technical details are collapsed by default.

### TASK-021 Build metric detail screen

**Dependencies:** TASK-020.

**Acceptance criteria:**
- Metric value, interpretation, conditions, and limitations are displayed.
- Threshold details come from engine result/configuration, not duplicated UI constants.

### TASK-022 Build Settings and demo-mode controls

**Dependencies:** TASK-007, TASK-011.

**Acceptance criteria:**
- Vehicle, adapter placeholder, units, privacy, demo mode, about, and legal sections exist.
- Demo mode cannot be mistaken for a real scan.

## M2 — Persistence and reports

### TASK-023 Select and configure local persistence implementation

**Dependencies:** TASK-003, TASK-010.

**Acceptance criteria:**
- Selected package satisfies `DATA_MODEL.md` and Architecture Specification.
- Repository interfaces remain unchanged.
- In-memory implementation remains available for tests.

### TASK-024 Implement settings persistence

**Dependencies:** TASK-023.

**Acceptance criteria:** Onboarding, units, demo setting, and last selections survive restart.

### TASK-025 Implement transactional scan persistence

**Dependencies:** TASK-017, TASK-023.

**Acceptance criteria:**
- Scan, readings, analysis, and report save atomically.
- Failed transactions leave no partial record.
- Historical snapshots are immutable.

### TASK-026 Build History screen

**Dependencies:** TASK-025.

**Acceptance criteria:**
- Empty and populated states work offline.
- Newest scan appears first.
- Demo scans are separated from real scans.

### TASK-027 Build saved report screen

**Dependencies:** TASK-026.

**Acceptance criteria:**
- Historical values do not change when current configuration changes.
- Engine and profile versions are retained.

### TASK-028 Implement report deletion

**Dependencies:** TASK-025, TASK-026.

**Acceptance criteria:**
- Confirmation is required.
- Related records and generated files are removed transactionally.

### TASK-029 Implement PDF report generation

**Dependencies:** TASK-020, TASK-025.

**Acceptance criteria:**
- PDF works offline.
- It contains no VIN, MAC address, precise location, owner identity, or platform device ID.
- Demo PDFs are clearly labelled.

**Tests:** Snapshot/content tests for required fields and excluded identifiers.

### TASK-030 Implement PDF preview and share flow

**Dependencies:** TASK-029.

**Acceptance criteria:** User can preview, save, share, and close without losing app state.

### TASK-031 Implement schema migration framework

**Dependencies:** TASK-023.

**Acceptance criteria:**
- Database version is persisted.
- At least one no-op/test migration proves the framework.
- Migration failure is recoverable.

## M3 — Bluetooth and ELM327 transport

### TASK-032 Add Android Bluetooth permissions

**Dependencies:** TASK-008.

**Acceptance criteria:**
- Permission request is contextual.
- Denied and permanently denied states are recoverable.
- Platform code is behind an interface.

### TASK-033 Implement Bluetooth adapter discovery

**Dependencies:** TASK-032.

**Acceptance criteria:**
- Nearby devices are discovered and deduplicated.
- Platform identifiers remain internal.
- Search can be cancelled and retried.

### TASK-034 Implement adapter connection lifecycle

**Dependencies:** TASK-033.

**Acceptance criteria:**
- Connecting, connected, disconnected, timeout, cancelled, and failed states are typed.
- Connection cannot hang indefinitely.

### TASK-035 Implement ELM327 transport abstraction

**Dependencies:** TASK-034.

**Acceptance criteria:**
- Send command, receive response, timeout, cancellation, and serialisation are behind an interface.
- Only one command is active at a time.

### TASK-036 Implement ELM327 initialisation sequence

**Dependencies:** TASK-035.

**Acceptance criteria:**
- Sequence is configuration-driven.
- Echo, line endings, prompts, and known adapter errors are handled.
- Raw exceptions do not reach UI.

### TASK-037 Implement OBD response parser

**Dependencies:** TASK-035.

**Acceptance criteria:**
- Handles normal, multi-line, no-data, stopped, unable-to-connect, malformed, and timeout responses.
- Parser is fully unit tested with fixtures.

### TASK-038 Implement scan orchestration state machine

**Dependencies:** TASK-036, TASK-037.

**Acceptance criteria:**
- Connect, initialise, read, validate, analyse, persist, and complete stages are explicit.
- Cancellation safely stops pending work.
- Non-critical failures can produce partial scans.

## M4 — BYD Dolphin integration

### TASK-039 Define BYD Dolphin vehicle profile

**Dependencies:** TASK-010.

**Acceptance criteria:**
- Profile ID, version, supported variant, battery metadata, power-state instructions, and PID map references exist.
- No vehicle logic is embedded in UI.

### TASK-040 Implement BYD PID definitions

**Dependencies:** TASK-039.

**Acceptance criteria:**
- Factory/current capacity, cell high/low, temperature high/low, SOC, voltage, current, charge count, and accumulated energy mappings are defined where validated.
- Unknown formulas are marked unverified and excluded from production scan.

### TASK-041 Implement BYD PID parsers and fixtures

**Dependencies:** TASK-037, TASK-040.

**Acceptance criteria:**
- Captured known-good and malformed responses are stored as test fixtures without personal identifiers.
- Parsed units match canonical metric keys.

### TASK-042 Integrate real BYD battery scan

**Dependencies:** TASK-038, TASK-041, TASK-017, TASK-025.

**Acceptance criteria:**
- Reference vehicle can complete a real scan.
- Results persist and reopen offline.
- Missing PIDs create partial or unassessable outcomes according to spec.

### TASK-043 Validate reference vehicle power-state procedure

**Dependencies:** TASK-042.

**Acceptance criteria:**
- Repeatable instructions are documented from real tests.
- Scan does not instruct interaction while driving.

### TASK-044 Perform repeatability testing

**Dependencies:** TASK-042.

**Acceptance criteria:**
- Multiple scans under similar conditions are compared.
- Unexpected variation is documented before thresholds are approved.

### TASK-045 Finalise MVP threshold configuration

**Dependencies:** TASK-044.

**Acceptance criteria:**
- Cell balance and temperature rules are approved and versioned.
- Provisional labels are removed only when evidence supports them.

## M5 — Beta readiness

### TASK-046 Accessibility audit

**Dependencies:** M1 complete.

**Acceptance criteria:**
- Large text, screen reader labels, focus order, contrast, touch targets, and reduced motion are checked.

### TASK-047 Error and recovery audit

**Dependencies:** M4 complete.

**Acceptance criteria:** Every documented error has a plain-English message and recovery action.

### TASK-048 Privacy audit

**Dependencies:** TASK-029, TASK-042.

**Acceptance criteria:**
- Reports and logs exclude prohibited identifiers.
- Local deletion works.
- No network dependency exists for core scan.

### TASK-049 Performance and resource audit

**Dependencies:** M4 complete.

**Acceptance criteria:**
- No uncontrolled Bluetooth polling.
- Scan operations terminate cleanly.
- UI remains responsive during scan and PDF generation.

### TASK-050 End-to-end beta test

**Dependencies:** TASK-046–049.

**Acceptance criteria:**
- First launch to real report succeeds on the reference phone and vehicle.
- Demo and real flows remain distinct.
- All CI checks pass.
- Known limitations are documented.

### TASK-051 Prepare internal Android build

**Dependencies:** TASK-050.

**Acceptance criteria:**
- Version and build number are set.
- Release notes and installation instructions exist.
- Signing secrets are not committed.

## 3. Definition of done for every task

- Assigned scope only is implemented.
- Acceptance criteria pass.
- Tests are added and pass.
- Formatter and static analysis pass.
- Documentation is updated where behaviour changed.
- No secrets, personal data, or raw identifiers are committed.
- Commit message references the task.
- AI agent summarises changes, commands run, results, risks, and then stops.
