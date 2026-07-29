# EV Health

EV Health is an Android-first Flutter application that helps EV owners understand, monitor, and prove the health of their vehicle battery using Bluetooth OBD data.

The MVP is focused on the BYD Dolphin Premium and an ELM327-compatible Bluetooth OBD adapter. The product converts technical battery telemetry into plain-English health insights, saved scan history, and shareable reports.

## MVP scope

- Bluetooth OBD adapter discovery and connection
- BYD Dolphin Premium vehicle profile
- Battery health and battery score
- Capacity, cell-balance, and temperature analysis
- Local scan history
- PDF report export
- Demo mode for development and testing
- Offline-first operation

DTC scanning and plain-English fault-code explanations are planned for Version 1.1 and are not part of the initial MVP.

## Documentation

Project documentation is indexed in [`docs/README.md`](docs/README.md).

Key implementation documents now available:

- [`docs/BATTERY_ENGINE.md`](docs/BATTERY_ENGINE.md)
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md)
- [`docs/TASK_BACKLOG.md`](docs/TASK_BACKLOG.md)
- [`AGENTS.md`](AGENTS.md)

The approved Software Design Specification remains at [`EV_health_docs/EV_Health_SDS_v1.0.md`](EV_health_docs/EV_Health_SDS_v1.0.md).

The approved PRD, UI/UX Design Specification, and Architecture Specification should be added to the repository from their final source files before implementation tasks that depend on them begin.

## Project status

The project is at the implementation-blueprint stage. Research, MVP definition, SDS/Constitution, UI/UX planning, architecture planning, Battery Engine rules, local data model, AI-agent rules, and an initial 51-task development backlog have been defined.

The first coding milestone is a complete, clickable Flutter application using clearly labelled demo data. Real Bluetooth, ELM327, and BYD Dolphin integration follows only after the product shell, report flow, persistence, and automated tests are stable.

## Development approach

Development is performed in small, reviewable tasks using AI coding agents. All implementation must follow the approved documentation, preserve clean architectural boundaries, include tests, and avoid adding features outside the assigned task.

Read [`AGENTS.md`](AGENTS.md) before making code changes.
