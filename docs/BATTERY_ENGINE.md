# EV Health Battery Engine Specification

**Version:** 1.0  
**Status:** MVP baseline

## 1. Purpose

Define how validated BYD battery telemetry becomes calculated metrics, grades, scores, confidence labels, and plain-English report content. This document is subordinate to the SDS/Constitution, PRD, Architecture Specification, and UI/UX Specification.

## 2. Design rules

- Separate measured, calculated, estimated, and unavailable values.
- Never diagnose a fault, guarantee safety, certify warranty status, or predict remaining life in MVP.
- Reject implausible data rather than silently correcting it.
- Keep thresholds and weights in versioned configuration, never UI code.
- Preserve raw inputs and the analysis-engine version used for each report.
- A partial scan may produce a partial report only when the minimum calculation set is valid.

## 3. Processing pipeline

```text
Raw OBD response
→ protocol parser
→ typed reading
→ range and consistency validation
→ normalised units
→ immutable scan snapshot
→ derived metrics
→ metric grades
→ battery score
→ confidence result
→ plain-English insights
→ report snapshot
```

## 4. Required and optional inputs

### Required for Battery Health

- factory capacity, Ah
- current nominal capacity, Ah

### Required for Cell Balance

- highest reported cell voltage, V
- lowest reported cell voltage, V

### Required for Temperature Assessment

- highest battery temperature, °C
- lowest battery temperature, °C

### Optional supporting inputs

- SOC
- battery voltage
- battery current
- charge count
- accumulated charge energy, kWh
- accumulated discharge energy, kWh
- accumulated amp-hours
- scan power state
- adapter and vehicle-profile versions

## 5. Validation

Validation occurs before calculations.

### Generic rules

- Reject NaN, infinity, empty, malformed, or unit-ambiguous values.
- Reject negative capacity, negative accumulated energy, and highest values lower than lowest values.
- Record validation failures with typed error codes.
- Preserve valid metrics when non-critical readings fail.

### Configuration-driven plausibility ranges

Initial defaults are conservative placeholders and must be confirmed against the reference BYD Dolphin:

| Metric | Initial validation range |
|---|---:|
| factory capacity | 50–500 Ah |
| current nominal capacity | 25–550 Ah |
| cell voltage | 1.5–5.0 V |
| battery temperature | -40–90 °C |
| SOC | 0–100% |
| pack voltage | 100–1000 V |

A value outside the configured range is excluded and marked `invalid_reading`.

## 6. Derived metrics

### 6.1 State of Health

```text
SOH % = current nominal capacity Ah / factory capacity Ah × 100
```

Rules:

- Round to one decimal place for storage and whole percent for the hero UI unless design rules specify otherwise.
- Values above 105% require investigation and must not be shown as normal.
- Label as `Calculated from reported capacity`.

### 6.2 Cell voltage delta

```text
cell delta mV = (highest cell voltage V - lowest cell voltage V) × 1000
```

Initial grading configuration:

| Delta | Grade |
|---|---|
| <10 mV | Excellent |
| 10–<20 mV | Very good |
| 20–<40 mV | Acceptable |
| 40–<60 mV | Monitor |
| ≥60 mV | Investigate |

These are product thresholds, not manufacturer diagnostic thresholds. They must be versioned and validated through testing.

### 6.3 Temperature spread

```text
temperature spread °C = highest temperature - lowest temperature
```

The engine must grade both absolute temperature and spread. Initial thresholds remain configurable and unapproved until reference-vehicle testing. Until validated, the UI may show measured values and `Unable to assess` rather than a definitive grade.

### 6.4 Equivalent full cycles

When usable battery energy capacity is known:

```text
EFC charge = accumulated charge energy / nominal usable battery energy
EFC discharge = accumulated discharge energy / nominal usable battery energy
```

MVP presentation should prefer one clearly documented method, likely the average of valid charge and discharge estimates. It must be labelled `Calculated estimate`. Do not calculate EFC without a validated nominal usable-energy value for the exact vehicle profile.

## 7. Metric scoring

Each metric score is normalised to 0–100. The MVP architecture supports weighted scoring, but final production weights require approval.

Provisional SDS baseline:

| Metric | Weight |
|---|---:|
| SOH | 60% |
| Cell balance | 20% |
| Temperature | 10% |
| Charging behaviour | 10% |

Rules:

- Missing optional metrics cause weight redistribution only if the configuration explicitly allows it.
- Missing required SOH inputs means no overall Battery Health and normally no overall Battery Score.
- Charging behaviour must not influence the MVP score until a validated rule exists.
- Store component scores, weights, and final score in the report snapshot.

### Overall grade mapping

Initial configurable mapping:

| Score | Grade |
|---|---|
| 90–100 | Excellent |
| 80–89 | Good |
| 65–79 | Fair |
| 50–64 | Monitor |
| <50 | Unable to conclude without professional assessment |

Do not use `Poor`, `Unsafe`, `Faulty`, or similar diagnostic language without approved evidence.

## 8. Confidence

MVP confidence reflects scan completeness and data quality, not fleet-statistical certainty.

### High confidence

- required capacity values valid
- cell and temperature inputs valid
- no critical validation warnings
- supported vehicle profile confirmed

### Moderate confidence

- SOH valid
- one or more supporting metric groups unavailable

### Limited confidence

- only minimum SOH inputs are valid, or scan conditions are uncertain

No report may claim community or benchmark confidence before the fleet dataset exists.

## 9. Partial scans

- If required capacity values are invalid or missing, Battery Health is `Unable to assess`.
- If SOH is valid but cell or temperature data is missing, produce a partial report with an explicit notice.
- Never substitute demo values, previous-scan values, or profile defaults into a real scan report.
- Persist the exact list of unavailable and invalid metrics.

## 10. Insight generation

Insights are deterministic templates selected from versioned rules.

Example structure:

```text
Status: Excellent
What was measured: The battery reported 147.39 Ah versus 150.40 Ah factory capacity.
What it means: The calculated capacity result is close to the factory value.
Limitation: This is a single informational scan, not a manufacturer certificate.
```

The engine must not generate free-form safety, repair, warranty, or remaining-life advice in MVP.

## 11. Versioning

Persist:

- engine version
- scoring-config version
- threshold-config version
- vehicle-profile version
- PID-map version
- parser version

Historical reports are immutable. Re-analysis with a later engine must create a new derived view, never overwrite the original report snapshot.

## 12. Test vectors

### Valid demo case

```yaml
factory_capacity_ah: 150.40
current_nominal_capacity_ah: 147.39
highest_cell_voltage_v: 3.342
lowest_cell_voltage_v: 3.338
highest_temperature_c: 27
lowest_temperature_c: 25
expected_soh_percent: 98.0
expected_cell_delta_mv: 4
expected_temperature_spread_c: 2
```

### Required edge cases

- zero factory capacity
- negative capacity
- current capacity above configured maximum
- highest cell voltage below lowest
- missing temperature values
- partial scan with valid SOH
- malformed numeric response
- duplicate PID responses
- timeout after some valid readings
- demo data incorrectly entering the real-scan pipeline

## 13. Acceptance criteria

- Calculations are deterministic and unit tested.
- All thresholds are configuration-driven and versioned.
- Invalid inputs cannot create a normal-looking result.
- Partial reports clearly identify missing metrics.
- Historical reports retain original raw inputs and engine versions.
- UI receives typed result models and contains no scoring logic.
- No output makes unsupported safety, diagnostic, warranty, or life-expectancy claims.
