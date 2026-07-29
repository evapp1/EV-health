# EV Health — UI/UX Design Specification

**Version:** 1.0  
**Status:** Draft for MVP implementation  
**Platform:** Android first  
**Initial vehicle:** BYD Dolphin Premium  
**Initial adapter class:** ELM327-compatible Bluetooth OBD adapter  
**Governing constitution:** `EV_Health_SDS_v1.0.md` — Approved Baseline  
**SDS SHA-256:** `B15E9DBFBD75D05BB1CC51A56D4F4B0F66E5D4397D87FBC1ADD6C3BD0CAE808A`  
**Last updated:** 29 July 2026  
**Document owner:** EV Health product team

---

## 1. Document Purpose and Precedence

### 1.1 Purpose

This document defines the user experience, screen behaviour, content, visual language, states, and acceptance criteria for the EV Health Android MVP.

It is intended to be directly usable by:

- Product and design contributors.
- AI coding agents.
- Flutter/Android developers.
- QA testers.
- Future contributors adding vehicle profiles.

The MVP must let a non-technical BYD Dolphin Premium owner connect a compatible Bluetooth OBD adapter, complete a guided battery scan, understand the result, save it locally, review scan history, and export a clear PDF or image report.

### 1.2 Source of truth

For UI and UX behaviour, this document is the source of truth.

If project documents conflict, use this order:

1. Applicable law, platform policy, privacy commitments, and safety requirements.
2. The project constitution/SDS.
3. Product Requirements Document.
4. This UI/UX Design Specification.
5. Technical architecture and data model documents.
6. Task descriptions, tickets, mock-ups, and generated code.

If a higher-precedence document conflicts with this specification, do not silently choose one. Record the conflict and request a product decision.

### 1.3 Requirement language

- **Must**: required for MVP acceptance.
- **Should**: expected unless a documented constraint prevents it.
- **May**: optional enhancement.
- **Deferred**: explicitly excluded from MVP.

### 1.4 Product definition

EV Health is an owner-focused battery intelligence application, not a workshop diagnostic tool. It translates supported vehicle data into understandable, appropriately qualified battery-health information.

**Core promise:** Understand the health of your EV battery in a simple, trustworthy report.

### 1.5 Terminology

| Term | Meaning in this document |
|---|---|
| Battery health / SOH | Remaining nominal capacity divided by factory nominal capacity, expressed as a percentage, when both supported values are available |
| Battery score | A product-level summary score derived from supported metrics; it must never conceal missing data or be presented as a safety certification |
| Battery grade | A controlled presentation of the Battery Score using versioned grade boundaries |
| Remaining capacity | The supported current nominal capacity of the battery, shown with precise provenance and units |
| Remaining life estimate | A versioned, uncertainty-bounded estimate from the Battery Health Engine; never a guarantee, warranty decision, or precise failure date |
| Recommendation | Controlled educational guidance generated from versioned rules; never a diagnosis, repair instruction, or safe-to-drive determination |
| Scan | One timestamped attempt to collect supported battery data from the vehicle |
| Complete scan | A scan containing every metric required for the MVP summary |
| Partial scan | A usable scan missing one or more non-critical metrics |
| Report | A saved presentation of scan data and derived interpretations |
| Vehicle profile | A versioned mapping of supported commands, PIDs, units, formulas, validation rules, and labels for a vehicle |
| Expected range | A clearly labelled estimate, not the vehicle’s official rated range or a guarantee |
| Demo mode | A local, simulated experience using the clearly labelled demo dataset in Section 28 |
| Developer Mode | An explicitly enabled advanced view containing raw diagnostic fields and PID-level details; disabled by default |

### 1.6 SDS baseline and conformance

This specification was audited against the approved `EV_Health_SDS_v1.0.md` identified by the SHA-256 hash in the document header.

The following SDS rules are constitutional requirements for this specification:

- Simple, modern, plain-English presentation.
- Offline-first operation where practical.
- Raw diagnostic data only in Developer Mode.
- Modular vehicle drivers with no vehicle logic in UI widgets.
- Bluetooth/OBD connection, vehicle detection, scan, report, history, and PDF/image export.
- Battery Score, Battery Grade, SOH, Remaining Capacity, Cell Balance, Temperature Summary, Recommendations, and collapsed Technical Details.
- A versioned Battery Health Engine.
- Read VIN where available, while applying the privacy rules in Section 16.
- Auto-reconnect and graceful disconnect handling.
- Connection within five seconds where possible and scan completion under ten seconds as performance targets.
- Unit, integration, and reference-vehicle testing.

Two internal SDS ambiguities are resolved for this UI/UX baseline as follows:

1. Cloud Sync is listed as excluded from MVP in SDS Section 4 but as P1 in SDS Section 16. The explicit MVP exclusion and the project’s local-first decision govern: Cloud Sync is out of v1.0.
2. PDF/Image export is included in SDS Section 4 but PDF Export is P1 in SDS Section 16. It remains required for the v1.0 release, implemented after the P0 scan/report/history path.

Any future interpretation that changes these resolutions requires an SDS revision or an approved product decision recorded in Section 32.

---

## 2. Product Experience Goals

### 2.1 Primary experience goals

1. A first-time user understands the product’s purpose within 15 seconds.
2. A user can start a supported scan without prior OBD knowledge.
3. The app presents conclusions before technical measurements.
4. Every result explains what was measured, calculated, estimated, or unavailable.
5. A user can distinguish a real scan from demo data at all times.
6. A saved report remains useful offline and can be shared as a PDF or image.
7. The experience feels calm, credible, and modern rather than mechanical or alarmist.
8. The user controls local data, analytics consent, and report sharing.
9. A validated reference-hardware connection completes within five seconds where possible.
10. A validated reference-vehicle battery scan completes in under ten seconds under documented test conditions.
11. The release target is greater than 99% crash-free sessions, measured with a documented sample and privacy-approved instrumentation.

### 2.2 Desired first-use outcome

After completing the primary flow, a user should be able to say:

> “I know the reported condition of my battery, what the main measurements mean, and which values were unavailable.”

### 2.3 Success signals

- High completion rate from adapter discovery to saved result.
- Low abandonment at Bluetooth permission and connection steps.
- Users open metric explanations instead of leaving to search technical terms.
- Users return to compare scans over time.
- PDF and image reports communicate data provenance without requiring the app.

### 2.4 Non-goals

The MVP does not aim to:

- Replace a qualified technician.
- Determine roadworthiness or whether a vehicle is safe to drive.
- Diagnose component failures.
- Clear fault codes.
- Present an unversioned, unsupported, or guaranteed remaining-life prediction.
- Guarantee battery condition, resale value, range, or warranty eligibility.
- Compete with engineering-grade live dashboards.

### 2.5 SDS non-functional experience requirements

- The core connection, scan, report, history, and export experience operates offline.
- The interface remains responsive during Bluetooth and OBD work; transport operations never block the UI thread.
- Background work is limited to what is necessary for the active user-initiated scan, preserving phone battery where practical.
- Connection and scan resources are released promptly after completion, cancellation, or failure.
- The validated reference adapter should connect within five seconds where possible.
- The validated reference-vehicle scan must complete in under ten seconds under documented conditions.
- The release target is greater than 99% crash-free sessions.

---

## 3. MVP Scope

### 3.1 In scope for v1.0

- Android phone application.
- BYD Dolphin as the SDS reference vehicle, with the initial verified driver profile limited to the available BYD Dolphin Premium test vehicle.
- Compatible ELM327-style Bluetooth adapter connection.
- Guided adapter discovery, pairing guidance, connection, auto-reconnection, and troubleshooting.
- Vehicle detection, transient VIN reading where available, driver-profile selection, and vehicle confirmation before scanning.
- Battery scan using verified BYD Dolphin Premium parameters.
- Plain-English battery-health result.
- Versioned Battery Health Engine output:
  - Battery Score.
  - Battery Grade.
  - SOH.
  - Remaining Capacity.
  - Cell Balance.
  - Temperature Summary.
  - Remaining Life Estimate.
  - Controlled Recommendations.
- Supported raw and derived metrics, subject to validation:
  - Factory nominal capacity.
  - Current nominal capacity.
  - Calculated SOH.
  - Battery SOC.
  - Highest and lowest cell voltage.
  - Cell voltage delta.
  - Highest, lowest, and average battery temperature where available.
  - Temperature spread.
  - Accumulated charge energy.
  - Accumulated discharge energy.
  - Charge count.
  - Pack voltage, current, and power where available.
  - Estimated equivalent full cycles when the necessary data is valid.
- Partial-data handling.
- Result summary and detailed report.
- Per-metric explanations and provenance.
- Local scan history.
- Locally saved reports.
- PDF and image generation, preview, and Android share sheet.
- Developer Mode for raw diagnostic and PID-level data, disabled by default.
- Local-first settings and privacy controls.
- Demo mode using fixed, labelled data.
- Light and dark themes, including follow-system.
- Metric and imperial display preferences where relevant.
- Accessibility support defined in Section 21.

### 3.2 Explicitly out of scope for v1.0

- DTC scanning, interpretation, prioritisation, or clearing.
- “Can I drive?” or repair-urgency advice.
- Other BYD models or Dolphin variants unless separately verified and approved.
- iOS.
- Wi-Fi, USB, BLE-only, or proprietary adapters unless verified as compatible.
- Continuous background vehicle monitoring.
- Live driving dashboards.
- Cloud accounts, login, or cross-device synchronisation.
- Community benchmarking and percentile claims.
- User-submitted benchmark uploads.
- AI-generated diagnoses.
- Dealer, fleet, marketplace, or workshop portals.
- Battery warranty decisions or claim assessment.
- Used-vehicle valuation.
- Cryptographic report certification.
- PDF verification service or public report URL.
- Persistent storage or display of a raw VIN outside a time-limited detection session.
- Location tracking.
- Automatic firmware/update tracking.
- Active vehicle commands, coding, ECU tuning, or write operations.

### 3.3 Deferred to v1.1

- Read-only DTC scan.
- Plain-English DTC explanations.
- Active versus historical status where supported.
- Conservative system categorisation.
- Questions to ask a qualified service provider.
- DTC-specific privacy, safety, content, and legal review.

### 3.4 Scope-change rule

Any feature not explicitly listed in Section 3.1 is excluded unless added through a documented product decision. AI coding agents must not infer adjacent features.

---

## 4. Target Users

### 4.1 Primary: everyday BYD Dolphin Premium owner

**Needs**

- Reassurance without technical overload.
- A repeatable battery-health check.
- Simple explanations.
- A history that can reveal trends.

**Constraints**

- May never have used OBD hardware.
- May not know the difference between SOC and SOH.
- May be concerned by unfamiliar numbers.
- May have a low-cost adapter with inconsistent performance.

### 4.2 Secondary: prospective used-EV buyer

**Needs**

- A quick, understandable snapshot.
- Clear distinction between measured data and estimates.
- A portable report for later review.

**Constraints**

- Limited time with the vehicle.
- May not be authorised to pair hardware or access the vehicle.
- Must not mistake the report for a full pre-purchase inspection.

### 4.3 Secondary: EV seller

**Needs**

- A credible, readable report.
- A timestamped history.
- Control over what is shared.

**Constraints**

- May be motivated to overstate favourable results; report language must remain neutral.

### 4.4 Tertiary: EV enthusiast

**Needs**

- Access to underlying values, units, formula details, and timestamps.

**Constraint**

- Advanced detail must not dominate the everyday-owner experience.

---

## 5. UX Principles

### 5.1 Answers before numbers

Show a human-readable status first, then the measurement and technical detail.

Example:

```text
Cell balance
Excellent
3 mV difference
[How this is assessed]
```

### 5.2 Progressive disclosure

Use three layers:

1. Status and short explanation.
2. Supporting measurement and context.
3. Advanced details, formula, source PID, and limitations.

### 5.3 Trust through provenance

Every metric must identify its type:

- **Reported by vehicle**
- **Calculated by EV Health**
- **Estimated by EV Health**
- **Not available**

Plain-English metric inputs and formulas may be shown to all users. Raw diagnostic payloads, PID identifiers, command responses, adapter details, and engineering logs are available only after Developer Mode is explicitly enabled.

### 5.4 Calm, controlled communication

- Never use fear to drive engagement.
- Never imply certainty not supported by the data.
- Never use “verified,” “certified,” or “safe” unless an approved verification system exists.
- Use neutral language for unusual or incomplete data.

### 5.5 Local-first by default

- Core scanning and report history must work without an account.
- Scan records must stay on the device in v1.0.
- The user explicitly initiates PDF or image sharing.
- Analytics must not contain raw battery values, VIN, adapter identifiers, or report contents.

### 5.6 Recovery over blame

Errors must explain:

1. What happened.
2. What the user can do.
3. Whether any data was saved.

### 5.7 One primary action per screen

Secondary actions must not visually compete with the task that advances the main flow.

### 5.8 Honest incompleteness

A partial result is preferable to a fabricated value. Missing metrics must be visible and must reduce confidence or score availability as defined by the battery-engine rules.

### 5.9 No write operations

The MVP is read-only. The interface must never offer code clearing, ECU reset, actuator tests, coding, or configuration changes.

### 5.10 Versioned recommendations

Recommendations must be deterministic outputs of the versioned Battery Health Engine. They must:

- Explain battery-care or monitoring context in plain language.
- State which measurements caused the recommendation.
- Avoid diagnosis, repair instructions, warranty conclusions, and safe-to-drive advice.
- Fall back to “No recommendation available from this scan” when required data is missing.

---

## 6. Information Architecture

### 6.1 Top-level structure

```text
EV Health
├── Home
│   ├── Start scan
│   ├── Last result
│   └── Demo mode entry
├── History
│   ├── Scan history
│   └── Scan result
├── Reports
│   ├── Saved reports
│   └── PDF/image preview and share
└── Settings
    ├── Vehicle
    ├── Adapter
    ├── Appearance and units
    ├── Privacy
    ├── About and legal
    ├── Demo mode
    └── Developer Mode
```

### 6.2 Setup and scan flow

```text
Onboarding
  → Bluetooth permission
  → Adapter discovery
  → Connection
  → Vehicle confirmation
  → Scan preparation
  → Scan progress
  → Result summary
  → Full report
```

### 6.3 Report hierarchy

```text
Result Summary
├── Overall status
├── Battery health
├── Battery grade
├── Cell balance
├── Temperature uniformity
├── Capacity
├── Remaining life estimate
├── Recommendations
├── Data completeness
└── View full report

Full Report
├── Overview
├── Capacity and SOH
├── Battery Score and Grade
├── Cell balance
├── Temperature
├── Usage and throughput
├── Electrical data
├── Remaining life estimate
├── Recommendations
├── Data quality and provenance
└── Limitations
```

### 6.4 SDS data entities relevant to UI

The SDS defines four core tables/entities:

- `Vehicles`
- `BatteryScans`
- `Reports`
- `FleetStatistics`

For the local-first v1.0 UI:

- `Vehicles`, `BatteryScans`, and `Reports` are active local entities.
- `FleetStatistics` is a reserved schema boundary only. No community or cloud fleet data is collected, displayed, or transmitted in v1.0.
- UI view models must not depend directly on persistence-table structure.
- Any future Cloud Sync or FleetStatistics UI requires the SDS ambiguity in Section 1.6 to be formally resolved and a separate privacy design.

---

## 7. Navigation

### 7.1 Primary navigation

Use a bottom navigation bar after onboarding:

1. **Home**
2. **History**
3. **Reports**
4. **Settings**

On compact screens, show icon plus label for all four destinations. Do not use icon-only navigation.

### 7.2 Navigation rules

- A brief Splash screen performs local startup checks and routes without requiring user interaction.
- Setup and scanning use a focused, linear flow outside the bottom navigation shell.
- Back navigation must never silently discard an in-progress scan.
- Leaving scan progress shows a confirmation sheet:

```text
Stop this scan?
The current scan will end. Any complete readings already collected may be saved as a partial scan.

[Keep scanning]  [Stop scan]
```

- Returning from a metric detail restores the previous scroll position.
- Opening a saved result never reconnects to the vehicle.
- PDF preview is read-only and returns to the originating report.
- Vehicle Details is reachable from Home and Settings.
- Developer Mode is reachable only through Settings and remains visually distinct from the consumer report experience.

### 7.3 Home destination logic

| User state | Home primary content |
|---|---|
| No setup, no history | Set up adapter and run first scan |
| Setup complete, no history | Start first scan |
| Previous scan exists | Latest result plus “Scan again” |
| Demo mode active | Persistent demo banner plus demo result |
| Unsupported/incomplete setup | Resume setup |

### 7.4 Deep links

Not required for MVP. Internal navigation routes should still use stable, named identifiers for future deep-link support.

---

## 8. Global UI States

Every data-bearing screen must implement loading, empty, error, and partial-data states where relevant.

### 8.1 Loading

Requirements:

- Use skeleton placeholders for saved local content expected within one second.
- Use labelled progress for connection and scan work.
- Never show an indefinite spinner without explanatory text.
- For the validated reference setup, target connection within five seconds where possible and a completed scan within ten seconds.
- If connection exceeds five seconds or a scan exceeds ten seconds, show a helpful secondary message and record a performance diagnostic locally.
- If an operation has a known sequence, show steps rather than a fake percentage.

Example:

```text
Reading battery data…
The reference scan normally completes in under 10 seconds.

[progress indicator]
```

### 8.2 Empty

Empty states must contain:

- A short explanation.
- One primary action.
- Optional secondary education.

Example:

```text
No scans yet
Connect your adapter to create your first battery health report.

[Start a scan]
```

### 8.3 Error

Errors must:

- Use plain language.
- Avoid internal codes in the headline.
- Preserve any usable readings.
- Offer a relevant recovery action.
- Put diagnostic detail behind Developer Mode; keep consumer-facing recovery detail plain and redacted.

### 8.4 Partial data

Partial scans must be clearly labelled:

```text
Partial result
Some supported readings were unavailable. Available measurements are shown below; no overall score was produced.

[Review available data]  [Try again]
```

Rules:

- Never replace missing values with zero.
- Never infer a measurement unless the metric is explicitly defined as an estimate.
- A PDF generated from partial data must repeat the partial-result label on its first page.
- Score availability follows the battery-engine specification, not ad hoc UI logic.

### 8.5 Offline

- Local history and reports remain available.
- Scanning should work if the OBD path does not require internet.
- PDF generation remains local.
- If optional online content is introduced later, it must fail independently.

### 8.6 Stale data

Saved results must always show scan date and odometer when available. Do not present an old scan as the vehicle’s current condition.

---

## 9. Visual Design System

### 9.1 Design character

The interface should feel:

- Calm.
- Clear.
- Credible.
- Modern.
- Friendly without being playful.
- Technical only when the user asks for detail.

Avoid:

- Automotive gauge clusters.
- Racing aesthetics.
- Neon “scanner” visuals.
- Excessive gradients.
- Fake certification seals.
- Dense tables on primary screens.

### 9.2 Platform foundation

- Use Material 3 components and interaction conventions.
- Support Android system back behaviour.
- Support light, dark, and follow-system themes.
- Prefer native Android share and document behaviours.

### 9.3 Colour tokens

Final colour values remain subject to brand review. The initial accessible token set is:

| Token | Light | Dark | Use |
|---|---:|---:|---|
| `primary` | `#155EEF` | `#84ADFF` | Primary actions, selected navigation |
| `onPrimary` | `#FFFFFF` | `#002A69` | Text/icons on primary |
| `surface` | `#FFFFFF` | `#101828` | Main surfaces |
| `surfaceAlt` | `#F2F4F7` | `#1D2939` | Cards and secondary surfaces |
| `textPrimary` | `#101828` | `#F9FAFB` | Main text |
| `textSecondary` | `#475467` | `#D0D5DD` | Supporting text |
| `positive` | `#067647` | `#6CE9A6` | Favourable supported status |
| `caution` | `#B54708` | `#FEC84B` | Needs attention or low confidence |
| `critical` | `#B42318` | `#FDA29B` | Failed operation or serious data warning |
| `info` | `#175CD3` | `#84CAFF` | Informational state |
| `outline` | `#D0D5DD` | `#475467` | Dividers and boundaries |

Colour must never be the sole indicator of status.

### 9.4 Status presentation

Every status uses:

- Text label.
- Optional icon.
- Colour as reinforcement only.

Approved icons:

- Positive: check circle.
- Informational: info circle.
- Caution: alert triangle.
- Unavailable: minus circle.
- Error: error outline.

### 9.5 Typography

Use the Android system typeface unless branding later specifies an embedded accessible font.

| Style | Suggested size | Weight | Use |
|---|---:|---:|---|
| Display | 48sp | 700 | SOH or score hero value |
| Headline | 28sp | 700 | Screen titles |
| Title | 20sp | 600 | Card and section titles |
| Body | 16sp | 400 | Main content |
| Body small | 14sp | 400 | Supporting detail |
| Label | 14sp | 600 | Buttons and controls |
| Technical | 14sp | 500 monospace optional | PID/value detail only |

Requirements:

- Respect Android font scaling to at least 200%.
- Do not encode meaning through font size alone.
- Avoid all-caps body labels.

### 9.6 Spacing and layout

- Base spacing unit: 4dp.
- Standard rhythm: 8, 12, 16, 24, 32, 48dp.
- Screen horizontal padding: 16dp compact, 24dp medium, 32dp expanded.
- Card internal padding: 16dp minimum.
- Minimum touch target: 48 × 48dp.
- Card corner radius: 16dp.
- Button corner radius: 12dp.
- Use subtle elevation or tonal contrast, not heavy shadows.

### 9.7 Iconography

- Use one consistent rounded Material icon family.
- Pair unfamiliar icons with text.
- Do not use a shield, tick, or badge in a way that implies third-party certification.

### 9.8 Motion

- Standard duration: 150–250ms.
- Scan progression may animate between completed steps.
- Respect “Remove animations” or reduced-motion settings.
- Do not animate key numeric results upward in a way that delays comprehension.
- Never use celebratory animation for a health result.

### 9.9 Charts

- History uses simple line or dot charts.
- Always include readable date and value alternatives.
- Do not smooth data in a way that invents measurements.
- Mark gaps and partial scans.
- Avoid dual axes in MVP.
- Technical values must remain inspectable in an accessible list.

---

## 10. Reusable Components

### 10.1 `AppScaffold`

Provides safe area, app bar, background, optional bottom navigation, and consistent horizontal padding.

### 10.2 `PrimaryButton`

One prominent full-width or content-width action. Supports loading and disabled states with an explanatory accessible label.

### 10.3 `SecondaryButton`

Outlined or tonal action. Must not compete with the primary action.

### 10.4 `StatusChip`

Shows text, icon, and semantic colour:

- Excellent
- Within expected range
- Review recommended
- Limited data
- Unavailable
- Demo

### 10.5 `ProvenanceBadge`

Values:

- Vehicle reported
- EV Health calculated
- EV Health estimated
- Unavailable

### 10.6 `MetricCard`

Required fields:

- Plain-English title.
- Status.
- Primary value where available.
- One-sentence interpretation.
- Provenance.
- Tap target to metric details.

### 10.7 `HeroHealthCard`

Displays Battery Score, Battery Grade, SOH, scan time, and data completeness. It must not imply certification.

### 10.8 `ScanStep`

States:

- Waiting.
- Active.
- Complete.
- Retrying.
- Skipped.
- Failed.

### 10.9 `AdapterListItem`

Displays:

- Device name or “Unnamed adapter.”
- Pairing/connection state.
- Optional signal information only if meaningful and supported.
- Clear selection affordance.

Do not display a full MAC address by default.

### 10.10 `EmptyState`

Illustration or icon, title, body, and one primary action.

### 10.11 `InlineNotice`

Variants:

- Information.
- Caution.
- Error.
- Privacy.
- Demo.

### 10.12 `DataCompletenessCard`

Shows:

- Complete or partial.
- Number of supported readings obtained.
- Missing readings.
- Effect on score or interpretation.

### 10.13 `HistoryItem`

Displays:

- Date/time.
- SOH if available.
- Overall status or partial label.
- Odometer if available.
- Demo marker if applicable.

### 10.14 `TechnicalDetailsDisclosure`

Collapsed by default in Developer Mode only. Contains command/PID identifiers, raw value, parsed value, unit, source profile version, and validation result. Consumer screens may show formula explanations and friendly source labels but must not expose raw diagnostic payloads.

### 10.15 `ConsentToggleRow`

Contains a clear label and an explanation of consequences. It must never be preselected for optional analytics or future data contribution.

### 10.16 `BatteryGradeBadge`

Displays the grade produced by the versioned Battery Health Engine. It must:

- Appear beside, not instead of, the Battery Score.
- Include an accessible expanded label such as “Battery Grade A.”
- Link to an explanation of the algorithm version and available inputs.
- Show “Not calculated” if minimum input requirements are not met.

### 10.17 `RecommendationCard`

Displays one controlled recommendation with:

- Short title.
- Plain-English explanation.
- The measurements that caused it.
- A limitations link.

It must never contain model-generated free text in v1.0.

### 10.18 `ExportFormatSheet`

Offers:

- Shareable PDF report.
- Shareable image summary.

The selected format must be previewed before the Android share sheet opens.

---

## 11. Detailed Screen Specifications

### 11.1 S01 — Welcome and Onboarding

**Purpose:** Explain the product, limitations, and local-first approach before setup.

**Entry:** First launch or “View onboarding again.”

**Layout**

```text
[EV Health mark]

Understand your EV battery
Connect a compatible adapter to create a clear battery health report.

[illustration]

• Plain-English battery insights
• Reports saved on this device
• Read-only vehicle connection

[Get started]
[Try demo mode]

Privacy  •  Important limitations
```

**Interactions**

- `Get started` → Bluetooth permissions.
- `Try demo mode` → Demo disclosure, then demo Home.
- Privacy and limitations open local documents.

**Content rules**

- Do not promise a 30-second result until scan duration is validated.
- State that v1.0 supports BYD Dolphin Premium only.

**Acceptance criteria**

- The supported vehicle and Android/adapter requirement are visible before connection.
- Demo mode is clearly available without granting Bluetooth permission.
- The user can reach privacy and limitations before continuing.
- Completion state is stored locally.

---

### 11.2 S02 — Bluetooth Permissions

**Purpose:** Explain and request only the Android permissions needed to discover and connect to an adapter.

**Layout**

```text
[Bluetooth icon]

Connect to your adapter
EV Health needs nearby-device access to find and connect to your OBD adapter.

We do not use this permission to track your location.

[Allow nearby devices]
[Not now]

Why is this needed?
```

**Behaviour**

- Trigger the system permission prompt only after the user taps the primary button.
- Request the minimum permission set for the supported Android versions.
- If a legacy Android version technically requires location permission for discovery, explain the platform requirement before requesting it and do not collect location.

**Denied state**

```text
Bluetooth access is off
Allow nearby-device access in Android Settings to connect an adapter.

[Open settings]
[Use demo mode]
```

**Acceptance criteria**

- No permission prompt appears on app launch without context.
- Permanent denial routes to system settings.
- The user can continue to demo mode.
- Copy does not falsely claim that Android never associates scanning with location permissions.

---

### 11.3 S03 — Adapter Discovery

**Purpose:** Find nearby paired or discoverable Bluetooth adapters.

**Layout**

```text
Choose your adapter

[Searching indicator] Searching nearby…

Known devices
[ OBDII                         ]
[ ELM327                        ]

Other nearby devices
[ Unnamed adapter               ]

[Search again]

Adapter not listed?
[Connection help]
```

**Behaviour**

- Group paired/known devices before other discoverable devices.
- Selecting a device begins connection on a separate state or screen.
- Discovery times out gracefully and remains restartable.
- Deduplicate repeated device results.

**Empty state**

```text
No adapters found
Check that the adapter is plugged into the vehicle and Bluetooth is on.

[Search again]
[Connection help]
```

**Acceptance criteria**

- Device names are readable and accessible.
- Duplicate results do not appear.
- Search can be cancelled and restarted.
- Full hardware addresses are never shown; Developer Mode may show a redacted adapter reference.

---

### 11.4 S04 — Adapter Connection

**Purpose:** Establish and validate a read-only ELM327 session.

**Layout**

```text
Connecting to OBDII

[progress]
1. Bluetooth connection          ✓
2. Adapter response              …
3. Vehicle communication         ○

Keep the vehicle on and stay nearby.

[Cancel]
```

**Success**

→ Vehicle confirmation.

**Failure**

Show the most specific recoverable reason:

```text
Adapter connected, but the vehicle did not respond
Make sure the vehicle is switched on and ready, then try again.

[Try again]
[Connection help]
```

**Acceptance criteria**

- A previously approved adapter receives one automatic reconnect attempt before the user is returned to discovery.
- Bluetooth connection, ELM response, and vehicle communication are represented as distinct stages.
- Cancellation closes resources and returns to discovery.
- No write command is sent.
- The reference setup connects within five seconds where possible; slower connections remain recoverable and visibly explained.
- Support diagnostics are copyable only from Developer Mode and must not expose stored personal data.

---

### 11.5 S05 — Connection Troubleshooting

**Purpose:** Give concise, ordered recovery steps.

**Layout**

```text
Connection help

Start here
1. Plug the adapter firmly into the OBD port.
2. Switch the vehicle on and ready.
3. Turn Android Bluetooth on.
4. Close other OBD apps.
5. Return and search again.

[Search again]

Still not working?
• Pairing-code help
• Adapter compatibility
• Permission settings
• Open Developer Mode
```

**Rules**

- Do not tell the user to interact with the adapter while driving.
- Mention that another OBD app can hold the connection.
- Explain that inexpensive adapters vary in compatibility.

**Acceptance criteria**

- Every listed recovery step is actionable.
- Troubleshooting is available from discovery, connection, and scan errors.
- The screen includes a safety reminder to set up only while parked.

---

### 11.6 S06 — Vehicle Confirmation

**Purpose:** Prevent use of the Dolphin Premium profile on an unconfirmed vehicle.

**Layout**

```text
Confirm the vehicle

Supported profile
BYD Dolphin Premium

Is this the vehicle currently connected?

[Yes, continue]
[No, disconnect]

Why confirmation matters
EV battery data uses vehicle-specific definitions. Using the wrong profile can produce incorrect results.
```

**Behaviour**

- Detect the supported vehicle and load its modular driver profile before scanning.
- Read the VIN where available for in-session vehicle detection, but do not show, log, persist, or transmit the raw VIN in v1.0.
- Discard the raw VIN when the detection session ends. Any future opt-in upload must anonymise it before upload under an approved privacy design.
- If reliable automatic identification is available, show the detected make/model/variant without showing the VIN and ask for confirmation.
- If the user says no, disconnect and explain that other vehicles are not supported.

**Acceptance criteria**

- The user explicitly confirms the supported vehicle.
- Unsupported selection cannot proceed to a real scan.
- A missing VIN is handled gracefully, and a raw VIN is never persisted.

---

### 11.7 S07 — Scan Preparation

**Purpose:** Place the vehicle in a consistent, safe state and explain what the scan will do.

**Layout**

```text
Ready for a battery scan?

Before you start
✓ Park safely
✓ Select Park and apply the parking brake
✓ Keep the vehicle switched on and ready
✓ Keep your phone near the adapter
✓ Close other OBD apps

This is a read-only scan. EV Health will not change vehicle settings or clear faults.

[Start scan]
[Cancel]
```

**Optional contextual inputs**

- Odometer may be read from the vehicle. If unavailable, the report may omit it rather than interrupt the MVP scan.
- Manual odometer entry is deferred unless specifically approved.

**Acceptance criteria**

- The parked-state instruction is visible.
- Read-only behaviour is stated.
- The user can cancel without losing setup.

---

### 11.8 S08 — Scan Progress

**Purpose:** Show real progress while collecting and validating data.

**Layout**

```text
Checking your battery

[progress visual]

Connected to vehicle             ✓
Reading battery capacity         ✓
Checking cell balance            …
Reading temperatures             ○
Calculating result               ○
Saving scan                      ○

Keep the app open and stay near the vehicle.

[Stop scan]
```

**Behaviour**

- Steps reflect actual state, not timed animation.
- Retry transient command failures using battery-engine rules.
- Attempt automatic reconnect after a transient disconnect before asking the user to intervene.
- If enough data exists after a non-critical failure, continue and create a partial scan.
- If connection drops, offer reconnect without discarding completed readings.

**Long-running state**

After 10 seconds:

```text
This is taking longer than the reference scan target.
The adapter or vehicle is responding slowly. You can keep waiting or stop and review any readings collected.

[Keep waiting] [Stop and review]
```

**Acceptance criteria**

- Progress is based on actual work.
- The validated reference scan completes in under ten seconds under documented test conditions.
- Completed readings survive a recoverable disconnect during the same scan attempt.
- The screen is accessible to TalkBack.
- The user is warned before discarding collected data.

---

### 11.9 S09 — Result Summary

**Purpose:** Deliver the primary “answer, not numbers” experience.

**Layout**

```text
Battery health report
29 Jul 2026, 8:42 pm

[Partial result banner, only if applicable]

Battery health
98%
Excellent
Calculated from current and factory nominal capacity.

[Battery score]
96 / 100
Based only on available supported metrics.

Battery grade
A
Derived from Battery Health Engine v1.

Key checks
[ Remaining capacity      Excellent   147.39 Ah]
[ Cell balance            Excellent       3 mV ]
[ Temperature spread      Even             2°C ]
[ Lifetime throughput     Recorded      5.8 MWh]

Estimated remaining life
[Range from approved engine, or Not calculated]
An estimate with stated confidence—not a failure date or guarantee.

Recommendations
[1–3 controlled recommendations, or No recommendation available]

Data completeness
12 of 12 supported readings available

[View full report]
[Export report]

Important: This report is informational and is not a safety, roadworthiness, diagnostic, or warranty assessment. Any remaining-life figure is an estimate, not a guarantee.
```

**Rules**

- If SOH cannot be calculated, do not display `0%`; use “Unavailable.”
- If score rules do not permit a score, show “Not calculated.”
- Battery Grade must be derived from the same versioned engine result as Battery Score.
- Remaining Capacity must show its original supported unit and provenance.
- Remaining Life Estimate must show a range, confidence/limitations, and algorithm version. It must never show a guaranteed date.
- Recommendations must come from controlled, versioned rules and identify their supporting measurements.
- Percentile and “better than X%” claims are prohibited in MVP. Precise, unsupported, or guaranteed remaining-life claims are also prohibited.
- “Excellent” thresholds must come from the approved battery-engine specification.

**Acceptance criteria**

- The top result includes date/time and provenance.
- Missing data is visible before the user opens details.
- The limitation statement is readable without navigating elsewhere.
- Every metric card opens the relevant detail screen.
- Battery Score, Grade, SOH, Remaining Capacity, Cell Balance, Temperature Summary, Remaining Life Estimate, and Recommendations each have a visible output or an explicit “Not calculated/Unavailable” state.
- A result is saved locally before leaving the screen, unless storage fails and the user is told.

---

### 11.10 S10 — Full Report

**Purpose:** Present a complete, structured view of the scan.

**Layout**

```text
Full battery report
[date]  [Complete/Partial]

Overview
[Battery health]
[Battery score]
[Battery grade]
[Data completeness]

Capacity and health
[Factory nominal capacity]
[Current nominal capacity]
[Calculated SOH]
[Remaining capacity]

Cell balance
[Highest cell voltage]
[Lowest cell voltage]
[Cell delta]

Temperature
[Highest temperature]
[Lowest temperature]
[Average temperature]
[Temperature spread]

Usage and throughput
[Accumulated charge energy]
[Accumulated discharge energy]
[Equivalent full cycles — estimated]
[Charge count]

Electrical snapshot
[Pack voltage]
[Current]
[Power]
[SOC]

Estimated remaining life
[Range, confidence, engine version, and limitations]

Recommendations
[Controlled recommendation cards with supporting measurements]

How this report was created
[Vehicle profile version]
[Battery Health Engine version]
[Calculation and limitations]

[Export PDF or image]
```

**Behaviour**

- Sections with no values remain visible only if the absence helps explain a partial report; otherwise collapse them into the data completeness section.
- Units are consistent with settings.
- Consumer-facing formula inputs and provenance appear behind a disclosure.
- Raw PID identifiers, command responses, and diagnostic payloads appear only in Developer Mode.

**Acceptance criteria**

- Every shown value includes unit and provenance.
- Calculated values link to their formula explanation.
- Report sections appear in the same order in-app, in PDF, and in the shareable image where practical.
- Partial metrics cannot be mistaken for measured zero values.
- Battery Health Engine and vehicle-driver versions are recorded with the saved report.

---

### 11.11 S11 — Metric Detail

**Purpose:** Explain one metric without overwhelming the summary.

**Layout**

```text
Cell balance

Excellent
3 mV difference
[Vehicle reported inputs] [EV Health calculated]

What this means
The highest and lowest reported cell voltages were very close during this scan.

How it is calculated
Highest cell voltage − lowest cell voltage
3.343 V − 3.340 V = 0.003 V (3 mV)

What can affect this reading
State of charge, load, charging state, temperature, and measurement timing.

Limitations
One scan is a snapshot. A small difference does not certify battery condition.

[Calculation inputs ▾]
[Open raw details in Developer Mode — only when enabled]
```

**Required content**

- Plain-English definition.
- Current status and value.
- Provenance.
- Formula for calculated metrics.
- Factors affecting the reading.
- Limitations.
- Historical chart if more than one comparable scan exists.
- A route to raw data only when Developer Mode is enabled.

**Acceptance criteria**

- No metric explanation contains unsupported diagnostic or guaranteed remaining-life claims.
- Consumer calculation inputs are selectable/copyable where useful; raw diagnostic values remain restricted to Developer Mode.
- The detail remains usable at 200% font scale.

---

### 11.12 S12 — Scan History

**Purpose:** Let users review changes over time.

**Layout**

```text
Scan history

[SOH history chart]

29 Jul 2026   98%   Complete
12 Jun 2026   98%   Complete
03 May 2026    —    Partial

[Start a new scan]
```

**Empty state**

```text
No scan history
Your completed and partial scans will appear here.

[Start a scan]
```

**Behaviour**

- Sort newest first.
- Charts must not interpolate missing results.
- Demo records never appear in real history.
- Deletion is available from item details or an overflow action with confirmation.

**Acceptance criteria**

- Complete and partial scans are visually distinguishable.
- Each row opens the saved result.
- Deleting one scan does not delete exported PDFs outside app-controlled storage.
- History works offline.

---

### 11.13 S13 — Saved Reports

**Purpose:** Organise locally generated report records, PDFs, and image summaries.

**Layout**

```text
Saved reports

BYD Dolphin Premium
29 Jul 2026 • Complete • PDF ready

BYD Dolphin Premium
12 Jun 2026 • Complete • Exports not generated

[Generate from selected scan]
```

**Rules**

- Distinguish a saved scan/report record from exported PDF and image files.
- Do not claim an export still exists after it has been shared to another app or moved outside controlled storage.
- Provide delete and regenerate actions.

**Acceptance criteria**

- The user can preview, regenerate, share, or delete a locally controlled report.
- Export generation failure does not delete the underlying scan.
- Demo PDFs and images carry a demo watermark.

---

### 11.14 S14 — Report Export and Preview

**Purpose:** Let the user select PDF or image format and inspect the exact report before sharing.

**Layout**

```text
Export report

[PDF] [Image]

[Page preview]

Page 1 of 3

[Share]
[Save a copy]
```

**PDF minimum content**

- EV Health name and report title.
- “Informational battery report” label.
- Vehicle: BYD Dolphin Premium.
- Scan date/time and timezone.
- Complete or partial status.
- SOH and provenance if available.
- Key measurements and units.
- Data completeness.
- Formula/source notes for calculated values.
- Vehicle-profile version.
- Limitations and local generation note.
- Demo watermark when applicable.

**Image minimum content**

- EV Health name and `Informational battery summary`.
- Vehicle model, scan date/time, and complete/partial status.
- Battery Score, Battery Grade, SOH, Remaining Capacity, Cell Balance, and Temperature Summary where available.
- A short limitations footer.
- `DEMO — NOT A VEHICLE REPORT` watermark when applicable.

The shareable image is a summary, not a replacement for the detailed PDF.

**Prohibited PDF language**

- Certified.
- Verified.
- Roadworthy.
- Safe to drive.
- Guaranteed remaining life.
- Warranty approved/valid.

**Acceptance criteria**

- Preview matches exported content.
- The PDF is readable on A4 without clipped text.
- The PDF remains understandable in grayscale.
- The image is readable at common social-sharing sizes and remains clearly informational.
- Sharing occurs only after an explicit user action.
- No VIN, Bluetooth hardware address, or internal device identifier is included.

---

### 11.15 S15 — Settings

**Purpose:** Manage app preferences and locally stored data.

**Layout**

```text
Settings

Vehicle
BYD Dolphin Premium

Adapter
OBDII • Not connected

Appearance
Follow system

Units
Metric

Privacy
Local data and analytics

Demo mode
Off

Developer Mode
Off

About and legal
Version 1.0.0
```

**Actions**

- Vehicle → supported-vehicle information; switching is unavailable in MVP.
- Adapter → forget/reconnect.
- Appearance → system/light/dark.
- Units → metric/imperial where a valid conversion exists.
- Privacy → Privacy screen.
- Demo mode → Demo mode disclosure.
- Developer Mode → warning and explicit enable flow.
- About/legal → About and legal.

**Acceptance criteria**

- Preferences persist locally.
- Forgetting the adapter requires confirmation but does not delete scan history.
- Deleting all local data is available under Privacy, not hidden.
- Developer Mode is disabled by default and never required for an ordinary scan.

---

### 11.16 S16 — Privacy

**Purpose:** Make local storage and optional telemetry understandable and controllable.

**Layout**

```text
Privacy

Your scan data
Battery scans and reports are stored on this device in v1.0.

Analytics
[toggle off by default or per final consent decision]
Share anonymous app-usage events
Never includes VIN, raw battery readings, adapter address, report content, or location.

Data controls
[Export app data — deferred unless implemented]
[Delete all local data]

Privacy policy
[Read policy]
```

**Delete confirmation**

```text
Delete all EV Health data?
This removes local scan history, report records, adapter settings, and preferences from this device. PDFs saved or shared outside EV Health may remain.

[Cancel] [Delete local data]
```

**Acceptance criteria**

- Local-first behaviour is accurately described.
- Optional analytics consent is not bundled with core functionality.
- The user can delete app-controlled local data.
- The screen accurately explains limits of deletion for externally saved PDFs and platform backups.

---

### 11.17 S17 — About and Legal

**Purpose:** Provide version, support, licences, safety limits, and legal documents.

**Layout**

```text
About EV Health
Version 1.0.0 (build 100)

Supported vehicle
BYD Dolphin Premium

Vehicle driver
[driver version]

Battery Health Engine
[algorithm version]

Important limitations
EV Health provides informational interpretations of vehicle-reported data. It is not a safety inspection, diagnosis, warranty assessment, or guarantee of battery condition or range.

[Terms of use]
[Privacy policy]
[Open-source licences]
[Support information]
[Copy diagnostic app info]
```

**Acceptance criteria**

- App and vehicle-profile versions are available for support.
- Legal documents are accessible offline if the app makes offline privacy claims.
- No unauthorised affiliation with BYD is implied.

---

### 11.18 S18 — Demo Mode

**Purpose:** Let users understand the product without a vehicle or adapter.

**Entry disclosure**

```text
Try EV Health with sample data
Demo mode uses fictional sample readings. It does not connect to a vehicle, create a real battery assessment, or contribute to your scan history.

[Start demo]
[Cancel]
```

**Persistent treatment**

- A visible `DEMO DATA` banner appears on every demo screen.
- Demo mode uses a distinct but accessible banner colour.
- Demo PDF pages and shareable images show a diagonal or header watermark: `DEMO — NOT A VEHICLE REPORT`.
- Exiting demo returns to the real Home state.

**Acceptance criteria**

- Demo values cannot be saved into real history.
- Demo data cannot be mistaken for live vehicle data in-app, in screenshots, in PDF, or in a shareable image.
- No Bluetooth permission is required.
- The dataset exactly matches Section 28.

---

### 11.19 S19 — Home / Dashboard

**Purpose:** Fulfil the SDS Dashboard requirement and provide the fastest route to the next useful action.

**First-use layout**

```text
EV Health

Check your BYD Dolphin Premium battery
Connect a compatible Bluetooth OBD adapter to create a clear report.

[Set up and scan]
[Try demo mode]
```

**Returning-user layout**

```text
EV Health

Latest battery report
96/100 • Grade A • 98% SOH
Scanned 29 Jul 2026

[Scan again]
[View report]

Recent history
[latest three scans]
```

**Acceptance criteria**

- The screen never presents an old result without its date.
- The primary action reflects setup state.
- Demo mode is always clearly labelled.

---

### 11.20 S20 — Splash

**Purpose:** Perform fast local startup checks and route to the correct first screen.

**Layout**

```text
[EV Health mark]
EV Health
```

**Behaviour**

- Show only while loading local settings, database availability, and onboarding state.
- Do not add an artificial minimum delay.
- Route to Onboarding on first launch or Home/Dashboard for a returning user.
- If local startup fails, show a recoverable startup error rather than looping.

**Acceptance criteria**

- Normal startup does not pause for branding animation.
- The screen supports light and dark system themes.
- No Bluetooth or network permission is requested from Splash.

---

### 11.21 S21 — Vehicle Details

**Purpose:** Show the active modular vehicle profile without exposing private identifiers.

**Layout**

```text
Vehicle details

BYD Dolphin Premium
Reference vehicle profile

Driver version
[version]

Last confirmed
[date/time]

VIN
Read temporarily for detection when available; not stored

[Reconnect vehicle]
[About vehicle support]
```

**Acceptance criteria**

- Raw VIN is never displayed or persisted.
- Driver/profile version is visible.
- The screen makes clear that only the verified Dolphin Premium profile is supported initially.
- Vehicle logic remains in the driver layer, not the screen.

---

### 11.22 S22 — Developer Mode

**Purpose:** Provide advanced raw diagnostic visibility required by the SDS without exposing it in the ordinary owner experience.

**Enable flow**

```text
Developer Mode

Advanced diagnostic data
This mode shows raw PID values, commands, parsing results, and adapter diagnostics. It is intended for development and troubleshooting.

Raw values can be misunderstood and are not diagnoses.

[Enable Developer Mode]
[Cancel]
```

Require a second confirmation before enabling. Do not use a hidden gesture that makes the feature undiscoverable to authorised testers.

**Enabled layout**

```text
Developer Mode                                      ON

Connection
[adapter protocol and session state]

Vehicle driver
[profile ID and version]

Battery Health Engine
[algorithm version and input availability]

Raw PID readings
[search/filter]
[PID key] [raw response] [parsed value] [unit] [validation]

[Copy redacted diagnostic bundle]
[Disable Developer Mode]
```

**Rules**

- Disabled by default.
- Never required to complete a consumer scan or report.
- Redact raw VIN, Bluetooth hardware address, location, and personal data.
- Do not offer OBD write commands, DTC clearing, actuator tests, or configuration changes.
- Developer-mode logs remain local and follow a documented retention limit.

**Acceptance criteria**

- Raw diagnostic data is absent from consumer screens.
- Enabling requires explicit acknowledgement.
- The copied diagnostic bundle is redacted and covered by tests.
- Disabling immediately removes raw diagnostic views and stops additional developer logging.

---

## 12. Primary User Flows

### 12.1 First real scan

```text
Splash
→ Onboarding
→ Get started
→ Permission explanation
→ Android permission
→ Adapter discovery
→ Select adapter
→ Connection validation
→ Confirm BYD Dolphin Premium
→ Scan preparation
→ Start scan
→ Scan progress
→ Result summary
→ Full report or export
```

**Success criterion:** A non-technical user completes the flow without external instructions.

### 12.2 Returning scan

```text
Home
→ Scan again
→ Reconnect known adapter
→ Confirm vehicle
→ Scan preparation
→ Scan
→ Result
```

If the known adapter is unavailable, route to discovery without losing the saved adapter preference.

### 12.3 Recover from connection failure

```text
Connection
→ Specific error
→ Try again
or
→ Connection help
→ Search again
```

### 12.4 Recover a partial scan

```text
Scan progress
→ Non-critical reading fails
→ Remaining readings continue
→ Partial result
→ Review available data
or
→ Try again
```

### 12.5 Review history

```text
History
→ Select scan
→ Saved result
→ Metric detail
or
→ Preview/generate PDF or image
```

### 12.6 Share report

```text
Result or saved report
→ Choose PDF or image
→ Preview
→ Share export
→ Android share sheet
```

### 12.7 Demo

```text
Welcome/Home/Settings
→ Demo disclosure
→ Demo Home
→ Demo result/report/details
→ Optional demo PDF or image
→ Exit demo
```

### 12.8 Delete local data

```text
Settings
→ Privacy
→ Delete all local data
→ Confirmation
→ Delete
→ First-use Home
```

### 12.9 Developer inspection

```text
Settings
→ Developer Mode
→ Read warning
→ Confirm enable
→ Run or open a scan
→ Inspect raw PID and engine diagnostics
→ Copy redacted diagnostic bundle if needed
→ Disable Developer Mode
```

---

## 13. Controlled Status Language

All status labels and interpretations must come from approved, versioned rules. AI-generated free text is not permitted in the MVP result path.

### 13.1 Approved general labels

- Excellent
- Good
- Within expected range
- Review recommended
- Limited data
- Unavailable
- Not calculated
- Complete
- Partial result
- Grade A / B / C / D only after grade boundaries are approved.

### 13.2 Approved provenance phrases

- Reported by the vehicle.
- Calculated by EV Health from vehicle-reported values.
- Estimated by EV Health using the stated formula.
- This value was not available during the scan.

### 13.3 Approved uncertainty phrases

- Based on the readings available during this scan.
- This is a snapshot and may vary with charge level, temperature, and vehicle state.
- More scans over time can provide better context.
- There was not enough supported data to calculate this result.
- This estimate is not a direct measurement.
- Estimated remaining life: [approved range], based on Battery Health Engine [version].
- Recommendation based on: [named supported measurements].

### 13.4 Prohibited phrases

- Your battery is definitely healthy.
- Your battery will last exactly X years.
- Safe to drive.
- No action required.
- Guaranteed.
- Certified or verified report.
- Better than X% of vehicles, until a valid benchmark product exists.
- Normal for all BYD vehicles.
- Warranty valid, covered, approved, or void.
- Fault-free, unless the app has actually performed an approved DTC scan; deferred in v1.0.
- No evidence of degradation, when only one capacity snapshot exists.
- Recommendations generated from unrestricted free text or an unversioned model.

### 13.5 Safety boundary

If vehicle data is unusual or invalid, use:

> “One or more readings were outside the expected data format. EV Health could not interpret them reliably. Try another scan or seek qualified assistance if the vehicle is showing warnings.”

Do not turn anomalous data into a diagnosis.

---

## 14. Error Message Catalogue

Error identifiers may be logged locally and shown in Developer Mode. User-facing titles remain plain language.

| ID | User-facing title | Body | Primary action | Secondary action |
|---|---|---|---|---|
| BT-001 | Bluetooth is off | Turn on Bluetooth to find your adapter. | Open Bluetooth settings | Use demo mode |
| BT-002 | Bluetooth access is needed | Allow nearby-device access in Android Settings to connect an adapter. | Open settings | Use demo mode |
| BT-003 | No adapters found | Check that the adapter is plugged in and discoverable. | Search again | Connection help |
| BT-004 | Could not connect to the adapter | The adapter may be paired with another app or out of range. | Try again | Connection help |
| BT-005 | Connection was lost | Stay near the vehicle and reconnect to continue. Completed readings are still available. | Reconnect | Stop and review |
| ELM-001 | The adapter did not respond | EV Health connected over Bluetooth but did not receive a valid adapter response. | Try again | Compatibility help |
| ELM-002 | Adapter response was too slow | This adapter may not reliably support the scan. | Try again | Stop |
| VEH-001 | The vehicle did not respond | Make sure the vehicle is on and ready, then try again. | Try again | Connection help |
| VEH-002 | Vehicle not supported | The MVP is verified only for the BYD Dolphin Premium. | Disconnect | Use demo mode |
| VEH-003 | Vehicle could not be confirmed | EV Health could not safely select a vehicle profile. | Try again | Disconnect |
| SCAN-001 | The scan could not start | The vehicle connection is not ready. | Reconnect | Cancel |
| SCAN-002 | Some readings were unavailable | The scan can still show supported measurements, but the result will be partial. | Review result | Try again |
| SCAN-003 | Not enough data for a report | Key battery-capacity readings were unavailable. | Try again | View details |
| DATA-001 | A reading could not be interpreted | The vehicle returned a value outside the supported format. | Try again | View details |
| DATA-002 | Battery health could not be calculated | Factory or current nominal capacity was unavailable or invalid. | Review available data | Try again |
| SAVE-001 | The scan could not be saved | The result is still open, but local storage failed. | Try saving again | Continue without saving |
| PDF-001 | The PDF could not be created | The scan is still saved. Try generating the PDF again. | Try again | Close |
| PDF-002 | The PDF could not be shared | No compatible share destination was available. | Save a copy | Close |
| IMG-001 | The image could not be created | The scan is still saved. Try creating the image again. | Try again | Close |
| STORAGE-001 | Storage space is low | Free some device storage before creating another PDF. | Open storage settings | Cancel |
| DEMO-001 | Demo data only | This screen uses fictional sample data and is not a vehicle report. | Continue demo | Exit demo |
| UNKNOWN | Something went wrong | Your saved scans were not changed. Try again. | Try again | Copy support reference |

### 14.1 Error-writing pattern

Use:

> **What happened**  
> What the user can check or do. State whether existing data is safe.

Avoid:

- “Invalid state.”
- “Unknown exception.”
- “User error.”
- Raw protocol text as the headline.

---

## 15. Content Style

### 15.1 Voice

- Direct.
- Calm.
- Respectful.
- Specific.
- Transparent about uncertainty.

### 15.2 Reading level

Aim for clear consumer language. Explain specialist terms on first use.

Example:

> “State of health (SOH) estimates how much nominal capacity remains compared with the factory value.”

### 15.3 Formatting

- Use sentence case.
- Keep headings short.
- Prefer one idea per paragraph.
- Use numerals for measurements.
- Include a space between value and unit: `22 °C`, `147.39 Ah`, `5.8 MWh`.
- Display cell delta in millivolts: `3 mV`.
- Use local date formatting while including an unambiguous date in PDF and image exports.

### 15.4 Explain the result, not the user

Use:

> “The cell-voltage difference was small during this scan.”

Avoid:

> “You have treated your battery perfectly.”

### 15.5 No gamification in MVP

No streaks, trophies, ranks, confetti, or moral judgement about charging habits.

---

## 16. Privacy Rules

### 16.1 MVP data model principle

Scan data is stored locally on the user’s device. No account is required.

### 16.2 Data that must not be persisted or transmitted in v1.0

- Raw VIN. It may be read transiently where available for SDS-required vehicle detection, then discarded when the detection session ends.
- Registration.
- Precise or background location.
- Bluetooth MAC address or persistent hardware identifier.
- Raw battery readings through analytics.
- Report contents through analytics.
- User contacts.
- Driving routes.
- DTCs, because DTC scanning is deferred.

### 16.3 PDF and image sharing

- Sharing is user initiated.
- The preview must show what will be shared.
- The report must not include hidden identifiers or metadata unnecessary to the report.
- The app must state that once shared or saved outside EV Health, the file is controlled by the destination.

### 16.4 Analytics consent

If analytics is included:

- Use a separate consent choice.
- Prefer opt-in for non-essential analytics.
- Do not degrade scanning when the user declines.
- Document event names and permitted properties.
- Never send exact measurement values.

### 16.5 Future anonymous benchmark data

Not part of MVP. It requires:

- A separate product and legal design.
- Explicit, informed opt-in.
- A defined retention and deletion policy.
- Re-identification risk analysis.
- Australian Privacy Act and applicable privacy-law review.
- Clear separation from ordinary app analytics.

### 16.6 Screenshots and screen recording

Do not block screenshots in MVP. Ensure demo screens, PDFs, and shareable images remain visibly labelled. Reconsider privacy-screen protection only if later versions store identifiable vehicle data.

---

## 17. Safety and Product-Liability Rules

### 17.1 Product boundary

EV Health interprets vehicle-reported battery measurements. It does not physically inspect the vehicle.

### 17.2 Required disclaimer locations

- Onboarding limitations link.
- Scan preparation.
- Result summary.
- PDF first or final page and image-summary footer.
- About/legal.

### 17.3 Required disclaimer concept

> EV Health provides informational interpretations of supported vehicle data. It is not a diagnosis, safety or roadworthiness inspection, warranty assessment, or guarantee of battery condition, range, or remaining life. Any remaining-life output is a modelled estimate with uncertainty.

Final wording requires legal review before public release.

### 17.4 Driving restriction

- Setup and scanning instructions must say to park safely.
- The MVP must not encourage screen interaction while driving.
- If the app detects motion later, behaviour requires a separate design.

### 17.5 Advice limits

The UI must not:

- Tell a user that a vehicle is safe to drive.
- Advise delaying a repair.
- State that no professional inspection is needed.
- Attribute blame to a manufacturer, seller, or repairer.
- State that a battery qualifies for warranty replacement.
- Present a recommendation as a diagnosis or instruction to continue driving, delay repair, or alter the vehicle.

---

## 18. Analytics Event Suggestions

These are suggestions, not automatic authorisation to implement analytics.

### 18.1 Permitted event shape

Events may contain:

- App version.
- Android major version.
- Coarse screen or flow name.
- Boolean success/failure.
- Error category.
- Duration bucket.
- Permission outcome.
- Demo versus real mode.
- Complete versus partial scan.

Events must not contain exact vehicle readings, VIN, location, adapter address, user-entered free text, or report contents.

### 18.2 Suggested events

| Event | Suggested properties |
|---|---|
| `onboarding_viewed` | `entry_point` |
| `onboarding_completed` | none |
| `demo_started` | `entry_point` |
| `demo_exited` | `screen` |
| `permission_explainer_viewed` | `android_version_bucket` |
| `bluetooth_permission_result` | `granted`, `permanently_denied` |
| `adapter_search_started` | none |
| `adapter_search_result` | `result_count_bucket`, `duration_bucket` |
| `adapter_connection_result` | `success`, `error_category`, `duration_bucket` |
| `vehicle_confirmation_result` | `confirmed_supported` |
| `scan_started` | `mode` |
| `scan_completed` | `complete_or_partial`, `duration_bucket`, `metric_count_bucket` |
| `scan_failed` | `error_category`, `stage` |
| `metric_detail_viewed` | `metric_key` |
| `history_viewed` | `scan_count_bucket` |
| `pdf_generation_result` | `success`, `complete_or_partial` |
| `pdf_share_opened` | none |
| `image_generation_result` | `success`, `complete_or_partial` |
| `image_share_opened` | none |
| `local_data_deleted` | `scope` |
| `analytics_consent_changed` | `enabled` |

### 18.3 Analytics acceptance criteria

- Analytics-disabled behaviour is covered by tests.
- No event payload contains prohibited fields.
- Network inspection verifies the event schema before release.

---

## 19. Responsive Behaviour

### 19.1 Supported form factors

- Primary: portrait Android phones from 360dp width.
- Required: larger phones and compact tablets.
- Landscape: must remain functional, though not separately optimised for the MVP.

### 19.2 Breakpoints

| Width | Behaviour |
|---|---|
| `<600dp` | Single-column layout; bottom navigation |
| `600–839dp` | Centred content with max width; cards may use two columns |
| `≥840dp` | Navigation rail may replace bottom navigation; report uses two-column sections |

### 19.3 Layout rules

- Set readable content max width of approximately 720dp for prose.
- Hero metrics remain centred but must not occupy the full tablet width.
- Metric cards may form a two-column grid only when text remains readable.
- PDF preview uses available width with page controls outside the document.
- No horizontal scrolling for ordinary content.

### 19.4 Small-screen behaviour

- Buttons may stack vertically.
- Long device names wrap to two lines.
- Status chips wrap without truncating meaning.
- Technical identifiers may use horizontal scroll only inside a dedicated code/value field.

---

## 20. Accessibility

### 20.1 Standards target

Aim for WCAG 2.2 AA principles and Android accessibility guidance.

### 20.2 Required behaviour

- Minimum 4.5:1 contrast for normal text and 3:1 for large text and meaningful UI components.
- Minimum touch target 48 × 48dp.
- Full TalkBack labels and logical focus order.
- Support 200% font scaling without clipping or loss of action.
- Do not communicate status by colour alone.
- Charts require text summaries.
- Progress changes announce meaningful stage changes, not every animation frame.
- Permission and error dialogs have descriptive titles.
- Keyboard/switch navigation works on all actionable controls.
- Focus returns predictably after dialogs and bottom sheets.
- Reduced-motion settings are respected.

### 20.3 Numeric pronunciation

Accessible labels should expand abbreviations where helpful:

- `98%` → “98 percent battery state of health.”
- `3 mV` → “3 millivolts cell voltage difference.”
- `147.39 Ah` → “147 point 39 amp hours.”

### 20.4 Accessibility acceptance criteria

- Core first-scan flow completes using TalkBack.
- Core flow completes at 200% font size.
- All primary controls pass automated semantic checks.
- Status remains understandable in grayscale.

---

## 21. UI Testing Requirements

### 21.1 Test layers

1. Unit tests for formatting, status mapping, and UI view models.
2. Widget tests for components and screen states.
3. Golden/screenshot tests for core light/dark layouts.
4. Integration tests for first scan, partial scan, failure recovery, history, and PDF/image export flow.
5. Manual testing on the reference BYD Dolphin Premium and adapter.

### 21.2 Required screen-state coverage

Each applicable screen must test:

- Loading.
- Success.
- Empty.
- Partial data.
- Recoverable error.
- Non-recoverable error.
- Light theme.
- Dark theme.
- 200% font scale.
- TalkBack semantics.

### 21.3 Required end-to-end scenarios

1. First launch → permission granted → scan success.
2. Permission denied → settings recovery → scan success.
3. No adapter found → search again.
4. Adapter connects but vehicle does not respond.
5. Connection drops mid-scan → reconnect and complete.
6. Non-critical PID fails → partial report.
7. Required capacity value fails → no SOH and no fabricated score.
8. Save scan → close/reopen app → history persists.
9. Generate and preview complete PDF.
10. Generate partial PDF with clear label.
11. Generate and preview a shareable image summary.
12. Enter and exit demo mode without contaminating history.
13. Enable Developer Mode, inspect raw data, copy a redacted bundle, then disable it.
14. Delete all app-controlled local data.

### 21.4 Visual regression targets

- Welcome.
- Adapter discovery.
- Scan progress.
- Complete result.
- Partial result.
- Full report.
- History empty and populated.
- PDF/image export preview.
- Privacy.
- Demo result.
- Vehicle Details.
- Developer Mode enabled and disabled.

### 21.5 Hardware test matrix

At minimum:

- Reference Android phone and known working ELM327 adapter.
- One recent Android version.
- One older supported Android version.
- Bluetooth permission denial/permanent denial.
- Adapter already connected to another OBD app.
- Vehicle on/off/not-ready states.
- Slow adapter response.
- Automatic reconnect after one transient disconnection.
- Connection-time measurement against the five-second target.
- Scan-time measurement against the ten-second target.

### 21.6 PDF QA

- Render PDFs to images during automated or manual QA.
- Check A4 page clipping, page breaks, grayscale readability, missing glyphs, and demo watermark.
- Verify displayed values against the source scan record.
- Verify image exports at common Android share resolutions and confirm their demo/partial labels.

### 21.7 Reliability acceptance

- Instrument non-identifying crash and fatal-error counts if approved under the privacy design.
- The release target is greater than 99% crash-free sessions.
- Performance and crash-free results must state sample size, app version, and test period.

---

## 22. MVP Acceptance Criteria

The MVP is acceptable only when all criteria below pass.

### 22.1 Setup and compatibility

- [ ] A new user can understand supported hardware and vehicle requirements.
- [ ] Nearby-device permissions are requested contextually.
- [ ] The reference adapter can be discovered and connected.
- [ ] A known reference adapter automatically reconnects after a transient disconnect.
- [ ] Connection completes within five seconds where possible under documented reference conditions.
- [ ] VIN is read where available for in-session detection, then discarded without display, logging, persistence, or transmission.
- [ ] The app confirms BYD Dolphin Premium before using its profile.
- [ ] Unsupported vehicles cannot proceed to a real scan.

### 22.2 Scan

- [ ] The scan is read-only.
- [ ] Actual progress is shown.
- [ ] Transient failures are recoverable.
- [ ] The reference scan completes in under ten seconds under documented test conditions.
- [ ] Partial results preserve usable readings.
- [ ] Missing readings are never represented as zero.
- [ ] Raw values pass documented validation before interpretation.

### 22.3 Results

- [ ] SOH is calculated only when valid factory and current nominal capacities are available.
- [ ] Provenance is visible for every metric.
- [ ] Controlled status language is used.
- [ ] No benchmarking claim appears.
- [ ] Battery Score, Battery Grade, SOH, Remaining Capacity, Cell Balance, Temperature Summary, Remaining Life Estimate, and Recommendations are produced by the versioned Battery Health Engine or explicitly marked unavailable.
- [ ] Remaining Life Estimate includes a range, limitations, and engine version.
- [ ] Recommendations are controlled, traceable to supported measurements, and non-diagnostic.
- [ ] No diagnosis, safety, guaranteed remaining-life, or warranty decision appears.
- [ ] Result date/time is prominent.

### 22.4 Local data

- [ ] Scans and report records persist locally across app restarts.
- [ ] Core use requires no account.
- [ ] The user can delete individual scans.
- [ ] The user can delete all app-controlled local data.
- [ ] Demo data never enters real history.

### 22.5 PDF and image export

- [ ] A complete or partial scan can generate a PDF.
- [ ] A complete or partial scan can generate a shareable image summary.
- [ ] Partial reports are clearly marked.
- [ ] Demo PDFs and images are clearly watermarked.
- [ ] The user previews before sharing.
- [ ] Exports omit prohibited identifiers.

### 22.6 Quality

- [ ] Core flow passes on the reference vehicle and adapter.
- [ ] Core flow works with TalkBack.
- [ ] Core flow works at 200% font scale.
- [ ] Light and dark themes meet contrast requirements.
- [ ] Required automated tests pass.
- [ ] No critical or high-severity crash remains open.
- [ ] Measured crash-free sessions exceed 99% for the documented release sample.
- [ ] Raw PID and diagnostic data appears only in explicitly enabled Developer Mode.

---

## 23. Implementation Priority

### P0 — Required foundation

1. App shell and design tokens.
2. Local navigation and onboarding state.
3. Permission education and handling.
4. Bluetooth discovery and connection.
5. ELM327 session validation.
6. BYD Dolphin Premium vehicle profile.
7. Scan state machine and data validation.
8. Versioned Battery Health Engine, including the SDS v1 weighting model.
9. Local scan persistence.

### P0 — Required user value

10. Home/Dashboard.
11. Scan preparation and progress.
12. Result summary with Score, Grade, SOH, Remaining Capacity, Cell Balance, Temperature Summary, Remaining Life Estimate, and Recommendations.
13. Metric detail.
14. Full report.
15. Partial-data behaviour.
16. History.
17. Privacy controls and data deletion.

### P1 — Required for the v1.0 release after the P0 path

18. PDF and image generation, preview, and sharing.
19. Demo mode.
20. Developer Mode.
21. Dark theme.
22. Accessibility refinement.
23. Troubleshooting catalogue.
24. Golden tests and PDF/image visual QA.

### P2 — Optional before closed beta

25. Additional history chart refinements.
26. Export of app-controlled structured data.
27. More adapter compatibility guidance.
28. Optional privacy-preserving product analytics after consent review.
29. Additional vehicle profiles after separate verification.

### Deferred

- DTC support.
- Benchmarking.
- Cloud Sync and other cloud services unless the SDS ambiguity documented in Section 1.6 is formally resolved.
- Other vehicle profiles.

---

## 24. Unresolved Design Decisions

These decisions must be resolved before the affected feature is implemented. Do not let an AI coding agent choose silently.

| ID | Decision | Current default | Owner |
|---|---|---|---|
| U-01 | Final product name and brand mark | Use “EV Health” as working name | Product |
| U-02 | Final SOH and metric status thresholds | Must come from battery-engine validation | Product/mechanical |
| U-03 | Battery Score normalisation, minimum-data rule, and Grade boundaries within the SDS v1 weighting | Score and Grade are mandatory outputs, but production rules require validation | Product/mechanical/legal |
| U-04 | Exact BYD Dolphin Premium model years and battery variants supported | One verified reference vehicle only | Engineering/product |
| U-05 | Minimum Android version | Choose after Bluetooth-library validation | Engineering |
| U-06 | Exact Flutter Bluetooth package and Bluetooth Classic support strategy | Unselected | Engineering |
| U-07 | Whether manual odometer entry belongs in MVP | Omit unless vehicle odometer is unavailable and need is validated | Product |
| U-08 | Analytics inclusion and consent default | No analytics until privacy review; if added, opt-in preferred | Product/legal |
| U-09 | PDF/image visual brand and PDF page count | Functional A4 report and readable image summary first | Design |
| U-10 | Retention limits for local scan history | Retain until user deletes, subject to storage review | Product |
| U-11 | Local database encryption requirement | Assess threat model before beta | Security |
| U-12 | App backup behaviour through Android | Document and configure intentionally | Security/product |
| U-13 | Use of “Excellent,” “Good,” and “Review recommended” for cell/temperature metrics | Controlled but thresholds unresolved | Product/mechanical |
| U-14 | Whether equivalent full cycles uses charge energy, discharge energy, or both | Define in battery-engine specification | Mechanical/data |
| U-15 | Legal disclaimer wording | Current copy is provisional | Legal |
| U-16 | BYD trademark and compatibility wording | Use nominative compatibility language pending review | Legal |
| U-17 | Remaining Life Estimate model, range format, confidence method, and minimum inputs | Mandatory SDS output; show “Not calculated” until a versioned model is approved | Product/mechanical/data/legal |
| U-18 | Controlled recommendation rules and allowed categories | Mandatory SDS output; deterministic and non-diagnostic only | Product/mechanical/legal |
| U-19 | VIN anonymisation method for any future opt-in upload | No upload in v1.0; raw VIN remains transient only | Privacy/security |
| U-20 | Developer Mode local-log retention | Keep minimal and clear when mode is disabled, pending engineering validation | Security/engineering |

---

## 25. AI Coding-Agent Rules

### 25.1 Scope

- Read this document and all higher-precedence project documents before editing code.
- Implement only the assigned task.
- Do not add deferred or “helpful” adjacent features.
- Do not change product language, status thresholds, formulas, or privacy behaviour without explicit instruction.

### 25.2 Architecture

- Keep Flutter UI, application services, Battery Health Engine, vehicle driver layer, Bluetooth/OBD transport, persistence, PDF/image generation, and ELM327 integration separated.
- UI code must not issue raw OBD commands.
- Business logic must never exist inside UI widgets.
- The battery analysis layer must be deterministic and testable.
- Vehicle-specific mappings must be versioned and isolated from generic UI.
- Each vehicle must have one modular driver profile; a new vehicle must not require core-architecture changes.
- Use immutable models where practical.
- Keep functions small and focused, remove duplicated logic, prefer composition over inheritance, and preserve backward compatibility unless intentionally changed.

### 25.3 Data integrity

- Preserve raw vehicle-reported values separately from calculated presentation values.
- Store units and timestamps.
- Never convert parse failure, missing data, or unsupported data to zero.
- Never display a calculated value unless all required inputs pass validation.
- Do not invent benchmark data, thresholds, confidence, or conclusions.
- Use the demo dataset only when demo mode is explicitly active.

### 25.4 Privacy and safety

- Do not add network calls, cloud SDKs, analytics, crash reporting, or remote logging without approval.
- A raw VIN may be read transiently where available for vehicle detection, as required by the SDS. Never show, log, persist, or transmit it in v1.0.
- Never store or transmit location, Bluetooth hardware address, or raw report data unless requirements are formally changed.
- Do not implement OBD write commands.
- Do not add diagnostic, repair, safety-to-drive, warranty, or guaranteed remaining-life claims.
- Remaining Life Estimates and Recommendations must use only approved, versioned Battery Health Engine rules.

### 25.5 UI implementation

- Use design tokens rather than hard-coded repeated values.
- Build reusable components listed in Section 10.
- Implement all relevant loading, empty, error, and partial states.
- Support light/dark themes, large text, and TalkBack from the first implementation.
- Use controlled copy from this document or an approved content catalogue.
- Keep demo labelling persistent.
- Keep raw PID identifiers, responses, and diagnostic logs inside explicitly enabled Developer Mode.

### 25.6 Testing

- Add or update tests with each feature.
- Test success, missing-data, invalid-data, and failure paths.
- Do not mark a task complete without formatting, static analysis, and relevant test results.
- When hardware is required, provide a deterministic simulator/fake transport for automated tests.

### 25.7 Change reporting

At completion, report:

1. Files changed.
2. Behaviour implemented.
3. Tests run and results.
4. Assumptions made.
5. Known limitations or unresolved decisions.

Then stop. Do not start the next backlog item without instruction.

---

## 26. Screen Inventory

| ID | Screen | Route suggestion | MVP | Primary action |
|---|---|---|:---:|---|
| S01 | Welcome/onboarding | `/onboarding` | Yes | Get started |
| S02 | Bluetooth permissions | `/setup/permissions` | Yes | Allow nearby devices |
| S03 | Adapter discovery | `/setup/adapters` | Yes | Select adapter |
| S04 | Adapter connection | `/setup/connecting` | Yes | Automatic/try again |
| S05 | Connection troubleshooting | `/help/connection` | Yes | Search again |
| S06 | Vehicle confirmation | `/setup/vehicle` | Yes | Confirm vehicle |
| S07 | Scan preparation | `/scan/prepare` | Yes | Start scan |
| S08 | Scan progress | `/scan/progress` | Yes | Complete scan |
| S09 | Result summary | `/scans/:id/summary` | Yes | View full report |
| S10 | Full report | `/scans/:id/report` | Yes | Export report |
| S11 | Metric detail | `/scans/:id/metrics/:key` | Yes | Return/report history |
| S12 | Scan history | `/history` | Yes | Open scan/start scan |
| S13 | Saved reports | `/reports` | Yes | Preview/generate |
| S14 | Report export/preview | `/reports/:id/export` | Yes | Share PDF/image |
| S15 | Settings | `/settings` | Yes | Open setting |
| S16 | Privacy | `/settings/privacy` | Yes | Manage local data |
| S17 | About/legal | `/settings/about` | Yes | Open document |
| S18 | Demo mode disclosure/experience | `/demo` | Yes | Start/exit demo |
| S19 | Home/Dashboard | `/home` | Yes | Set up/scan again |
| S20 | Splash | `/splash` | Yes | Automatic route |
| S21 | Vehicle Details | `/vehicle` | Yes | Reconnect/view support |
| S22 | Developer Mode | `/settings/developer` | Yes | Enable/inspect/disable |
| S23 | DTC scan | Deferred | v1.1 | Scan faults |
| S24 | DTC detail | Deferred | v1.1 | Understand code |

---

## 27. Data-to-UI Mapping

This section defines the minimum presentation contract. Exact source commands and validation belong in the vehicle-profile and battery-engine specifications.

| UI metric | Required inputs | Type | Missing-data behaviour |
|---|---|---|---|
| Battery SOH | Current nominal capacity, factory nominal capacity | Calculated | Show unavailable; explain missing input |
| Remaining capacity | Supported current nominal capacity | Vehicle reported | Show unavailable |
| Current nominal capacity | Supported BMS value | Vehicle reported | Show unavailable |
| Factory nominal capacity | Supported BMS value/profile rule | Vehicle reported or profile-defined; label precisely | Show unavailable |
| Cell delta | Highest cell voltage, lowest cell voltage | Calculated | Show unavailable |
| Temperature spread | Highest battery temperature, lowest battery temperature | Calculated | Show unavailable |
| Average temperature | Supported BMS value | Vehicle reported | Show unavailable |
| Accumulated charge energy | Supported BMS value | Vehicle reported | Omit insight; show unavailable in details |
| Accumulated discharge energy | Supported BMS value | Vehicle reported | Omit insight; show unavailable in details |
| Equivalent full cycles | Approved energy throughput and approved reference capacity | Estimated/calculated per final rule | Do not calculate |
| Charge count | Supported BMS value | Vehicle reported | Show unavailable |
| Battery Score | SOH, Cell Balance, Temperature, Charging Behaviour using SDS v1 weights and approved normalisation rules | Calculated | Show “Not calculated” |
| Battery Grade | Battery Score and approved grade boundaries | Calculated | Show “Not calculated” |
| Remaining Life Estimate | Approved versioned model and minimum inputs | Estimated | Show “Not calculated” with reason |
| Recommendations | Approved versioned rules and named supporting measurements | Calculated controlled content | Show “No recommendation available from this scan” |
| Expected range | Approved model plus required inputs | Estimated | Omit from MVP result until model is approved |

### 27.1 SDS Battery Health Engine v1 contract

The SDS mandates these Battery Score weights:

| Metric | Weight |
|---|---:|
| State of Health | 60% |
| Cell Balance | 20% |
| Temperature | 10% |
| Charging Behaviour | 10% |

The weights are fixed for Engine v1. The normalisation curve for each metric, minimum-data rule, Grade boundaries, Remaining Life Estimate model, and Recommendation rules remain unresolved decisions in Section 24. The UI and demo may use clearly labelled placeholders, but production code must not invent those rules.

### 27.2 Calculation example

SOH:

```text
current nominal capacity ÷ factory nominal capacity × 100
147.39 Ah ÷ 150.40 Ah × 100 = 97.998…%
Displayed: 98%
```

Cell delta:

```text
highest cell voltage − lowest cell voltage
3.343 V − 3.340 V = 0.003 V
Displayed: 3 mV
```

### 27.3 Rounding rules

- Preserve full parsed precision internally.
- SOH summary: nearest whole percent.
- SOH details: one decimal place only if input precision supports it.
- Cell delta: whole millivolts.
- Temperature: whole degrees in summary; one decimal only where reliable.
- Energy: one decimal MWh or whole kWh depending magnitude.
- Do not show precision greater than the source supports.

---

## 28. Demo Dataset — Fictional Sample Data

> **DEMO DATA — NOT A VEHICLE REPORT**
>
> The following fixed dataset exists only for UI development, automated tests, screenshots, and demo mode. It must never be stored as a real scan, uploaded as benchmark data, or represented as measurements from the user’s vehicle.

### 28.1 Demo vehicle

| Field | Demo value |
|---|---|
| Vehicle | BYD Dolphin Premium |
| Model year | 2024 |
| Scan date | 29 July 2026, 8:42 pm AEST |
| Odometer | 38,420 km |
| Vehicle-profile version | `byd_dolphin_premium_demo_1.0` |
| Battery Health Engine version | `demo_engine_1.0` |
| Scan status | Complete demo |

### 28.2 Demo battery readings

| Metric | Demo value | Provenance |
|---|---:|---|
| Battery SOC | 54% | Fictional vehicle-reported sample |
| Factory nominal capacity | 150.40 Ah | Fictional vehicle-reported sample |
| Current nominal capacity | 147.39 Ah | Fictional vehicle-reported sample |
| Calculated SOH | 98.0% | Calculated from fictional samples |
| Highest cell voltage | 3.343 V | Fictional vehicle-reported sample |
| Lowest cell voltage | 3.340 V | Fictional vehicle-reported sample |
| Cell delta | 3 mV | Calculated from fictional samples |
| Highest battery temperature | 23 °C | Fictional vehicle-reported sample |
| Lowest battery temperature | 21 °C | Fictional vehicle-reported sample |
| Average battery temperature | 22 °C | Fictional vehicle-reported sample |
| Temperature spread | 2 °C | Calculated from fictional samples |
| Accumulated charge energy | 5,696 kWh | Fictional vehicle-reported sample |
| Accumulated discharge energy | 5,778 kWh | Fictional vehicle-reported sample |
| Charge count | 435 | Fictional vehicle-reported sample |
| Pack voltage | 410 V | Fictional vehicle-reported sample |
| Pack current | 1.2 A | Fictional vehicle-reported sample |
| Instantaneous power | 0.49 kW | Calculated from fictional samples |

### 28.3 Demo derived presentation

These labels are placeholders for UI testing only and do not approve production thresholds:

| Presentation | Demo value |
|---|---|
| Battery health status | Excellent — demo placeholder |
| Cell-balance status | Excellent — demo placeholder |
| Temperature-uniformity status | Excellent — demo placeholder |
| Battery score | 96/100 — demo placeholder only |
| Battery grade | A — demo placeholder only |
| Remaining capacity | 147.39 Ah — fictional sample |
| Remaining Life Estimate | 12–16 years — demo placeholder only; not an approved production model |
| Recommendation 1 | Continue periodic scans under similar charge and temperature conditions — demo placeholder |
| Recommendation 2 | No unusual cell-voltage difference was present in this fictional snapshot — demo placeholder |
| Data completeness | 12 of 12 required demo readings |

### 28.4 Demo partial dataset

For partial-state testing:

- Remove current nominal capacity.
- Remove average battery temperature.
- Retain highest and lowest cell voltage.
- Expected UI:
  - `Partial result`.
  - SOH `Unavailable`.
  - Battery score `Not calculated`.
  - Battery grade `Not calculated`.
  - Remaining Life Estimate `Not calculated`.
  - Recommendations `No recommendation available from this scan`.
  - Cell delta `3 mV`.
  - Temperature spread `2 °C`.

---

## 29. Detailed Component Acceptance Criteria

### 29.1 Metric card

- [ ] Shows title, status/value, one-sentence explanation, and provenance.
- [ ] Supports unavailable and partial states.
- [ ] Has a minimum 48dp tap target.
- [ ] Does not truncate the status at 200% font scale.
- [ ] Has an accessible combined label.

### 29.2 Status chip

- [ ] Contains a text label.
- [ ] Remains understandable without colour.
- [ ] Uses only controlled labels.
- [ ] Does not imply certification.

### 29.3 Scan step

- [ ] Announces transitions to TalkBack.
- [ ] Does not announce unchanged progress repeatedly.
- [ ] Separates skipped from failed.
- [ ] Reflects actual scan state.

### 29.4 History chart

- [ ] Has a text equivalent.
- [ ] Does not interpolate missing SOH.
- [ ] Labels demo content if used in demo.
- [ ] Shows scan dates and values on focus/tap.

### 29.5 Report export

- [ ] Matches the saved scan record.
- [ ] Shows complete/partial/demo status on page one.
- [ ] Includes provenance and limitations.
- [ ] Is readable in grayscale and at A4 size.
- [ ] Shareable image contains the required summary, limitations footer, and status label.

---

## 30. Definition of Done for a Screen

A screen is not complete until:

1. Its main success path is implemented.
2. Relevant loading, empty, partial, and error states are implemented.
3. Copy follows controlled language.
4. Light and dark themes are verified.
5. 200% font scaling is verified.
6. TalkBack labels and focus order are verified.
7. Navigation and Android back behaviour are tested.
8. Analytics, if approved, contains no prohibited data.
9. Widget/golden tests cover critical states.
10. The implementation matches this specification or an approved documented change.

---

## 31. Recommended First Build Slice

The first vertical slice should not connect to real hardware. It should prove the full user experience using the fixed demo dataset:

```text
Welcome
→ Demo disclosure
→ Demo Home
→ Demo result summary with Score, Grade, SOH, Remaining Capacity, Cell Balance, Temperature Summary, Remaining Life Estimate, and Recommendations
→ Full report
→ Metric detail
→ Save demo PDF or image with watermark
→ Exit demo
```

After that slice is visually and accessibly accepted, replace the demo transport with:

```text
Permission
→ Discovery
→ Connection
→ Detect vehicle and load modular driver profile
→ Real scan
→ Same result/report UI
```

This order validates the core product experience while the hardware layer is developed behind a stable interface.

---

## 32. Change Control

Any change affecting the following requires an explicit product decision and document update:

- Supported vehicles or adapters.
- Health formulas or status thresholds.
- Battery score.
- Privacy or analytics.
- Network use.
- Safety or legal wording.
- PDF claims.
- Demo labelling.
- DTC scope.
- Storage or retention.

Record changes in a future revision log with:

- Version.
- Date.
- Decision owner.
- Sections changed.
- Reason.

---

## 33. Revision Log

| Version | Date | Summary |
|---|---|---|
| 1.0 | 29 July 2026 | Initial Android-first BYD Dolphin Premium MVP UI/UX specification; audited and aligned to approved `EV_Health_SDS_v1.0.md` baseline |
