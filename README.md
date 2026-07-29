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

## Governing documentation

Project documentation is indexed in [`docs/README.md`](docs/README.md).

The approved implementation baselines are:

- [`EV_health_docs/EV_Health_SDS_v1.0.md`](EV_health_docs/EV_Health_SDS_v1.0.md) — combined SDS / Constitution and product-requirements baseline
- [`docs/EV_Health_Architecture_Specification_v1.0.md`](docs/EV_Health_Architecture_Specification_v1.0.md) — Architecture Specification
- [`docs/EV_Health_UI_UX_Design_Specification_v1.0.md`](docs/EV_Health_UI_UX_Design_Specification_v1.0.md) — UI/UX MVP baseline
- [`docs/UI_UX_BASELINE_APPROVAL.md`](docs/UI_UX_BASELINE_APPROVAL.md) — approval record for the UI/UX baseline
- [`docs/BATTERY_ENGINE.md`](docs/BATTERY_ENGINE.md) — Battery Engine Specification
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) — Data Model Specification
- [`docs/TASK_BACKLOG.md`](docs/TASK_BACKLOG.md) — numbered MVP implementation backlog
- [`AGENTS.md`](AGENTS.md) — mandatory operating rules for AI coding agents

The SDS is intentionally serving as both the Constitution and the product-requirements baseline for this project. A separate PRD is not required unless the product team later decides to split those responsibilities.

## Project status

The implementation blueprint is complete and the repository is ready to begin the Flutter stage.

The first coding milestone is a complete, clickable Flutter application using clearly labelled demo data. Real Bluetooth, ELM327, and BYD Dolphin integration follows only after the product shell, report flow, persistence, and automated tests are stable.

Development begins with `TASK-001 — Initialise Flutter application` in [`docs/TASK_BACKLOG.md`](docs/TASK_BACKLOG.md). Complete one task at a time.

## Development approach

Development is performed in small, reviewable tasks using AI coding agents. All implementation must follow the approved documentation, preserve clean architectural boundaries, include tests, and avoid adding features outside the assigned task.

Read [`AGENTS.md`](AGENTS.md) before making code changes.