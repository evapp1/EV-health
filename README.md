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

The approved Software Design Specification currently remains available at [`EV_health_docs/EV_Health_SDS_v1.0.md`](EV_health_docs/EV_Health_SDS_v1.0.md).

## Project status

The project is currently in the product-blueprint stage. Research, MVP definition, the SDS/Constitution, UI/UX specification, and architecture planning have been completed or are being consolidated before Flutter implementation begins.

## Development approach

Development will be performed in small, reviewable tasks using AI coding agents. All implementation must follow the approved project documentation, preserve clean architectural boundaries, include tests, and avoid adding features outside the assigned task.
