# AGENTS.md

This file defines mandatory operating rules for AI coding agents working on EV Health.

## 1. Authority order

When documents conflict, follow this order unless a later approved decision explicitly changes it:

1. `EV_health_docs/EV_Health_SDS_v1.0.md` — SDS / Constitution
2. Approved Product Requirements Document
3. Approved Architecture Specification
4. Approved UI/UX Design Specification
5. `docs/BATTERY_ENGINE.md`
6. `docs/DATA_MODEL.md`
7. `docs/TASK_BACKLOG.md`
8. Task-specific issue or prompt
9. Existing implementation

Never silently resolve a conflict. Stop and report it.

## 2. Mandatory reading before coding

Read:

- this file
- the SDS / Constitution
- the Architecture Specification
- the relevant feature sections in the PRD and UI/UX Specification
- the assigned task in `docs/TASK_BACKLOG.md`
- `docs/BATTERY_ENGINE.md` for any battery result logic
- `docs/DATA_MODEL.md` for persistence or report work

Do not begin implementation when a required approved document is missing and the task depends on it.

## 3. Task execution protocol

1. Restate the assigned task and acceptance criteria internally.
2. Inspect existing code and tests before editing.
3. Identify the smallest compliant change.
4. Implement only the assigned task.
5. Add or update tests.
6. Run formatting, static analysis, and relevant tests.
7. Review the diff for architecture, privacy, and scope violations.
8. Report files changed, commands run, test results, limitations, and risks.
9. Stop. Do not begin the next backlog task.

## 4. Architecture boundaries

- UI widgets display state and dispatch user intent only.
- UI must not contain Bluetooth commands, PID parsing, scoring, thresholds, persistence queries, or PDF composition logic.
- Domain code must not import Flutter UI or platform Bluetooth packages.
- Vehicle-specific logic belongs in versioned vehicle profiles and PID mappings.
- Infrastructure implementations depend on domain interfaces, not the reverse.
- Repositories hide storage implementation details.
- State management coordinates use cases; it does not become a second business-logic layer.
- Use dependency injection for transports, repositories, clocks, UUID generation, configuration, and demo services.

## 5. Battery and report rules

- Never invent missing vehicle data.
- Never substitute demo, previous-scan, or default values into a real scan.
- Label measured, calculated, estimated, and unavailable values.
- Keep thresholds and score weights in versioned configuration.
- Historical scan and report snapshots are immutable.
- Do not claim safety, manufacturer certification, warranty eligibility, fault absence, or remaining battery life.
- DTC scanning is out of MVP scope and must not be added before Version 1.1 approval.

## 6. Privacy and security

Do not commit or expose:

- secrets, tokens, signing keys, or credentials
- VINs or owner identifiers
- precise location
- Bluetooth MAC addresses or platform device identifiers
- unredacted personal logs
- proprietary raw captures containing identifiers

Core scanning and report viewing must remain offline-capable.

## 7. Code quality rules

- Prefer clear, maintainable code over clever abstractions.
- Keep functions small and single-purpose.
- Use immutable typed models.
- Avoid duplicate logic.
- Avoid global mutable state.
- Avoid unnecessary dependencies.
- Document public APIs and non-obvious protocol behaviour.
- Do not suppress lints or exceptions without a documented reason.
- Do not leave placeholder production behaviour disguised as complete.

## 8. Testing requirements

Every task requires the smallest meaningful test set.

Expected layers:

- unit tests for calculations, parsing, validation, repositories, and state machines
- widget tests for loading, empty, error, partial, and success states
- integration tests for complete flows
- fixture-based tests for ELM327 and BYD responses
- migration tests for every schema change
- manual validation on the reference BYD Dolphin for vehicle-specific work

Tests must include failure and cancellation paths, not only happy paths.

## 9. Standard commands

After the Flutter project exists, run as applicable:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

For targeted work, run focused tests first, then the complete test suite before task completion.

If project scripts replace these commands, update this file and use the documented scripts.

## 10. Git discipline

- Work on a dedicated branch.
- Keep commits small and task-focused.
- Use clear commit messages, preferably including the backlog task ID.
- Do not rewrite or delete approved documentation without explicit instruction.
- Do not merge pull requests.
- Do not force-push unless explicitly authorised.
- Do not combine unrelated refactors with feature work.

## 11. Prohibited shortcuts

Do not:

- build the whole app from one broad prompt
- hardcode vehicle logic in screens
- hardcode score thresholds in widgets
- bypass repository or transport abstractions
- swallow errors and show false success
- use fake progress percentages
- add cloud services to solve local MVP problems
- add analytics that include raw battery data or identifiers
- update historical report results in place
- introduce unsupported vehicles or iOS work into MVP tasks
- create free-form AI diagnostic advice

## 12. Stop conditions

Stop and report rather than guessing when:

- governing documents conflict
- required PID formulas are unverified
- a task requires credentials, signing keys, or external accounts
- a change could affect vehicle safety or write to a vehicle ECU
- a dependency choice changes the approved architecture
- tests reveal unexplained vehicle-data variation
- the requested change expands scope beyond the assigned task
- required final PRD, UI/UX, or Architecture documents are unavailable

## 13. Completion report template

```text
Task:
Summary:
Files changed:
Tests added/updated:
Commands run:
Results:
Known limitations:
Risks or follow-up:
```

Then stop.
