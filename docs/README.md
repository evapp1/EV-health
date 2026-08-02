# EV Health Documentation

This directory indexes the EV Health product and engineering documentation.

## Document authority

When documents conflict, use this order unless a later approved decision explicitly changes it:

1. SDS / Constitution and product-requirements baseline
2. Architecture Specification
3. UI/UX Design Specification
4. Battery Engine Specification
5. Data Model Specification
6. Task Backlog
7. Task-specific implementation notes
8. Existing implementation

The approved SDS intentionally combines the Constitution, product requirements, high-level design rules, and development rules. A separate PRD is not required for the current MVP baseline.

## Approved baselines

### SDS / Constitution and product requirements

- [`../EV_health_docs/EV_Health_SDS_v1.0.md`](../EV_health_docs/EV_Health_SDS_v1.0.md)

This is the highest-authority project document and serves as both the SDS/Constitution and the product-requirements baseline.

### Architecture Specification

- [`EV_Health_Architecture_Specification_v1.0.md`](EV_Health_Architecture_Specification_v1.0.md)

Defines the Android-first Flutter architecture, dependency boundaries, state management, navigation, Bluetooth and ELM327 abstractions, OBD pipeline, vehicle-profile structure, persistence, testing strategy, and extension points.

### UI/UX Design Specification

- [`EV_Health_UI_UX_Design_Specification_v1.0.md`](EV_Health_UI_UX_Design_Specification_v1.0.md)
- [`UI_UX_BASELINE_APPROVAL.md`](UI_UX_BASELINE_APPROVAL.md)

The UI/UX Design Specification is approved as the MVP implementation baseline. The approval record governs its status even where the original document header still contains earlier draft wording.

### Battery Engine Specification

- [`BATTERY_ENGINE.md`](BATTERY_ENGINE.md)

Defines validation, SOH, cell delta, temperature spread, score architecture, confidence, partial scans, deterministic insights, versioning, and test vectors.

### Data Model Specification

- [`DATA_MODEL.md`](DATA_MODEL.md)

Defines local-first entities, immutable scan snapshots, raw readings, derived results, reports, demo-data separation, migrations, deletion, privacy, and future cloud boundaries.

### MVP Task Backlog

- [`TASK_BACKLOG.md`](TASK_BACKLOG.md)

Breaks the Android-first Flutter MVP into small AI-friendly tasks, prioritising a complete demo-data application before Bluetooth and BYD integration.

### AI agent rules

- [`../AGENTS.md`](../AGENTS.md)

Defines mandatory reading, architecture boundaries, task execution, testing, privacy, Git discipline, prohibited shortcuts, and stop conditions for Codex and other coding agents.

## Repository documentation structure

```text
EV_health_docs/
└── EV_Health_SDS_v1.0.md

docs/
├── README.md
├── EV_Health_Architecture_Specification_v1.0.md
├── EV_Health_UI_UX_Design_Specification_v1.0.md
├── UI_UX_BASELINE_APPROVAL.md
├── BATTERY_ENGINE.md
├── DATA_MODEL.md
├── TASK_BACKLOG.md
└── adr/

AGENTS.md
README.md
```

## MVP baseline

- Platform: Android
- Framework: Flutter
- Reference vehicle: BYD Dolphin Premium
- Adapter: ELM327-compatible Bluetooth OBD adapter
- Storage: local-first
- Core output: plain-English battery health report
- Demo-first implementation: required
- DTC scanning: deferred to Version 1.1

## Flutter readiness

The governing baseline documents are available. Flutter development may begin with `TASK-001 — Initialise Flutter application`.

Agents must complete one numbered task at a time, run the required checks, report results, and stop before starting the next task.

## Documentation rules

- Do not silently change approved requirements.
- Version algorithms, scoring configurations, PID maps, and vehicle profiles.
- Label measured, calculated, estimated, demo, and unavailable values clearly.
- Keep vehicle-specific logic and all business logic outside UI code.
- Historical scan and report snapshots remain immutable.
- Update documentation in the same pull request as material behaviour changes.
- AI coding agents must read the governing documents before modifying code.