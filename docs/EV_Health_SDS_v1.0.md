# EV Health Software Design Specification (SDS)

**Version:** 1.0\
**Status:** Approved Baseline

------------------------------------------------------------------------

# 1. Purpose

This document is the single source of truth for the EV Health
application.

It defines **what** the application does, **how** it is structured, and
the engineering rules that every implementation must follow.

If implementation differs from this document, the SDS takes precedence
until formally updated.

------------------------------------------------------------------------

# 2. Product Vision

EV Health makes EV battery health simple.

The application converts complex battery telemetry into clear, visual
reports that any EV owner can understand without technical knowledge.

The long-term vision is to become the trusted platform for EV battery
health and ownership intelligence.

------------------------------------------------------------------------

# 3. Design Principles

-   Simplicity over complexity.
-   Beautiful, modern interface.
-   Offline-first where practical.
-   Fast and reliable.
-   Explain technical information in plain language.
-   Raw diagnostic data available only in Developer Mode.
-   Support additional vehicles without changing core architecture.

------------------------------------------------------------------------

# 4. MVP Scope

## Reference Vehicle

**BYD Dolphin**

The BYD Dolphin is the reference implementation for the MVP.

Vehicle support must remain modular so future vehicles require only new
driver profiles.

## Included

-   Bluetooth connection
-   OBD communication
-   Vehicle detection
-   Battery scan
-   Battery Health Report
-   Local history
-   PDF/Image export

## Excluded

-   iOS
-   Dealer Portal
-   Cloud Sync
-   Fleet Analytics

------------------------------------------------------------------------

# 5. Functional Requirements

## Bluetooth

-   Discover compatible ELM327 adapters.
-   Connect within 5 seconds where possible.
-   Auto reconnect.
-   Graceful disconnect handling.

## Vehicle Detection

-   Detect supported vehicle.
-   Load correct PID profile.
-   Read VIN where available.

## Battery Scan

-   Read all supported battery PIDs.
-   Validate collected data.
-   Handle unsupported values safely.

## Battery Report

Display: - Battery Score - Battery Grade - SOH - Remaining Capacity -
Cell Balance - Temperature Summary - Recommendations - Technical Details
(collapsed)

------------------------------------------------------------------------

# 6. Non-Functional Requirements

-   Scan completes in under 10 seconds.
-   Responsive UI.
-   Minimal battery usage.
-   Offline operation.
-   Crash-free target \>99%.

------------------------------------------------------------------------

# 7. User Flow

Launch App → Connect Adapter → Detect Vehicle → Scan Battery → Generate
Report → Save History → Share Report

------------------------------------------------------------------------

# 8. Screen Inventory

-   Splash
-   Onboarding
-   Dashboard
-   Scan Progress
-   Battery Report
-   History
-   Vehicle Details
-   Settings
-   Developer Mode

------------------------------------------------------------------------

# 9. Architecture

Flutter UI

↓

Application Services

↓

Battery Health Engine

↓

Vehicle Driver Layer

↓

Bluetooth / OBD Transport

↓

ELM327 Adapter

Business logic must never exist inside UI widgets.

------------------------------------------------------------------------

# 10. Battery Health Engine

## Version 1 Weighting

  Metric                 Weight
  -------------------- --------
  State of Health           60%
  Cell Balance              20%
  Temperature               10%
  Charging Behaviour        10%

Outputs:

-   Battery Score
-   Grade
-   Remaining Life Estimate
-   Recommendations

Algorithm versions must be versioned for future compatibility.

------------------------------------------------------------------------

# 11. Database

Core tables

-   Vehicles
-   BatteryScans
-   Reports
-   FleetStatistics

Cloud synchronization is optional for MVP.

------------------------------------------------------------------------

# 12. Privacy

-   User owns all personal data.
-   VIN anonymised before upload.
-   Anonymous fleet data only.
-   Opt-in cloud services.
-   No sale of personal data.

------------------------------------------------------------------------

# 13. Development Rules

These rules are mandatory.

1.  Never hardcode vehicle logic in UI.
2.  One driver profile per vehicle.
3.  Business logic belongs in services.
4.  UI displays data only.
5.  Keep functions small and focused.
6.  No duplicated logic.
7.  Prefer composition over inheritance.
8.  Every feature must be independently testable.
9.  Every new vehicle should require only a new driver/profile.
10. Preserve backward compatibility unless intentionally changed.

------------------------------------------------------------------------

# 14. AI Coding Rules

The AI implementation must:

-   Produce clean, readable code.
-   Prefer maintainability over cleverness.
-   Follow single-responsibility principles.
-   Reuse components.
-   Avoid unnecessary dependencies.
-   Fail gracefully.
-   Use meaningful names.
-   Keep files logically organised.
-   Add documentation for public APIs.
-   Refactor repeated code rather than copy it.

------------------------------------------------------------------------

# 15. Testing Requirements

Every completed feature must include:

-   Unit tests
-   Integration tests where applicable
-   Manual validation against BYD Dolphin
-   No regressions

------------------------------------------------------------------------

# 16. Development Priorities

## P0

-   Bluetooth
-   Vehicle Detection
-   Battery Scan
-   Dashboard
-   Report
-   History

## P1

-   PDF Export
-   Cloud Sync
-   Additional Vehicles

## P2

-   Fleet Comparisons
-   AI Insights
-   Dealer Features

------------------------------------------------------------------------

# 17. Backlog Policy

Ideas are added to the project backlog first.

Only approved features are added to this SDS.

The SDS remains stable during active development.

------------------------------------------------------------------------

# 18. Definition of Done

A feature is complete only when:

-   Acceptance criteria pass.
-   Tests pass.
-   Documentation updated.
-   No critical defects remain.
-   Code follows Development Rules.
-   Code follows AI Coding Rules.

------------------------------------------------------------------------

# 19. Future Vision

Future releases may include:

-   Multi-vehicle support
-   AI degradation prediction
-   EV Health Certificate verification
-   Marketplace integration
-   Dealer platform
-   Fleet benchmarking
-   Warranty prediction

------------------------------------------------------------------------

# 20. Final Principle

The primary goal of EV Health is **trust**.

Every design decision should improve one or more of the following:

-   Accuracy
-   Simplicity
-   Reliability
-   Transparency
-   User confidence

If a decision makes the product more complicated without improving these
principles, it should be reconsidered.
