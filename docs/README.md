# EV Health Documentation

This directory is the index for the EV Health product and engineering documentation.

## Document authority

When documents conflict, use this order unless a later approved document explicitly changes it:

1. Software Design Specification / Constitution
2. Product Requirements Document
3. Architecture Specification
4. UI/UX Design Specification
5. Battery Engine Specification
6. Database Specification
7. Task Backlog and implementation notes

## Available in the repository

### Software Design Specification

The approved baseline is currently stored at:

- [`../EV_health_docs/EV_Health_SDS_v1.0.md`](../EV_health_docs/EV_Health_SDS_v1.0.md)

It defines the product principles, MVP scope, high-level architecture, engineering rules, AI coding rules, testing requirements, and definition of done.

## Completed documents awaiting consolidation

The following documents were created during project planning but were not accessible to the GitHub integration during this update, so they have not been recreated or replaced here:

- Product Requirements Document
- UI/UX Design Specification
- Architecture Specification

Their approved Markdown files should be added here unchanged once available. This avoids creating conflicting versions from conversation summaries.

## Recommended final structure

```text
docs/
├── README.md
├── 01-PRD.md
├── 02-SDS.md
├── 03-UI-UX-Specification.md
├── 04-Architecture-Specification.md
├── 05-Battery-Engine.md
├── 06-Database-Specification.md
├── 07-Task-Backlog.md
└── adr/
```

## MVP baseline

- Platform: Android
- Framework: Flutter
- Reference vehicle: BYD Dolphin Premium
- Adapter: ELM327-compatible Bluetooth OBD adapter
- Storage: local-first
- Core output: plain-English battery health report
- DTC scanning: deferred to Version 1.1

## Documentation rules

- Do not silently change approved requirements.
- Version algorithms and vehicle profiles.
- Label measured, calculated, estimated, and unavailable values clearly.
- Keep vehicle-specific logic outside UI code.
- Update documentation in the same pull request as material implementation changes.
- AI coding agents must read the governing documents before modifying code.
