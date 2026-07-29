# EV Health Documentation

This directory indexes the EV Health product and engineering documentation.

## Document authority

When documents conflict, use this order unless a later approved document explicitly changes it:

1. Software Design Specification / Constitution
2. Product Requirements Document
3. Architecture Specification
4. UI/UX Design Specification
5. Battery Engine Specification
6. Data Model Specification
7. Task Backlog and implementation notes

## Available in the repository

### Software Design Specification

- [`../EV_health_docs/EV_Health_SDS_v1.0.md`](../EV_health_docs/EV_Health_SDS_v1.0.md)

Defines the approved product principles, MVP scope, high-level architecture, development rules, testing requirements, and definition of done.

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

## Completed documents awaiting repository consolidation

The following approved documents were created during planning but are not yet present in this repository:

- Product Requirements Document
- UI/UX Design Specification
- Architecture Specification

Add their final approved Markdown files unchanged when available. Do not reconstruct them from summaries if an approved source exists elsewhere.

## Recommended final structure

```text
docs/
├── README.md
├── 01-PRD.md
├── 02-SDS.md
├── 03-UI-UX-Specification.md
├── 04-Architecture-Specification.md
├── BATTERY_ENGINE.md
├── DATA_MODEL.md
├── TASK_BACKLOG.md
└── adr/
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

## Documentation rules

- Do not silently change approved requirements.
- Version algorithms, scoring configurations, PID maps, and vehicle profiles.
- Label measured, calculated, estimated, and unavailable values clearly.
- Keep vehicle-specific logic and all business logic outside UI code.
- Historical scan and report snapshots remain immutable.
- Update documentation in the same pull request as material behaviour changes.
- AI coding agents must read the governing documents before modifying code.
