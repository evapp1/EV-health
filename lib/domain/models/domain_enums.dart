/// Classifies whether a domain record is real, fictional demo, or test data.
enum DataSource {
  /// Data captured through the production path.
  real,

  /// Permanently labelled fictional demonstration data.
  demo,

  /// Deterministic data used only by tests.
  test,
}

/// Describes how an individual value was obtained.
enum ValueProvenance {
  /// Measured and reported by the vehicle.
  measured,

  /// Calculated by EV Health from measured inputs.
  calculated,

  /// Estimated by EV Health using a stated method.
  estimated,

  /// Not available during the scan or not calculated.
  unavailable,

  /// Fictional or derived exclusively for the labelled demo experience.
  demoDerived,
}

/// Why a requested value is unavailable.
enum UnavailableReason {
  /// The active profile does not support the metric.
  unsupportedByProfile,

  /// The vehicle returned no data.
  noDataFromVehicle,

  /// The command timed out.
  commandTimeout,

  /// The connection was lost.
  connectionLost,

  /// The vehicle returned a negative response.
  negativeResponse,

  /// The payload was malformed.
  malformedPayload,

  /// The response header was not expected.
  unexpectedHeader,

  /// The payload did not contain enough bytes.
  insufficientBytes,

  /// The decoded value was outside its approved range.
  outOfRange,

  /// The operation was cancelled.
  cancelled,

  /// A required calculation input was unavailable.
  missingRequiredInput,

  /// No approved calculation or policy was available.
  notCalculated,
}

/// Adapter compatibility observed locally.
enum AdapterCompatibilityStatus {
  /// Compatibility has not been established.
  unknown,

  /// The adapter has worked with the supported flow.
  working,

  /// The adapter failed compatibility validation.
  failed,
}

/// Final completeness classification of an immutable scan.
enum ScanStatus {
  /// All required production readings were valid.
  complete,

  /// At least one approved result exists, with some data unavailable.
  partial,

  /// No trustworthy assessment can be produced.
  unassessable,
}

/// Coarse vehicle power state captured as a scan condition.
enum VehiclePowerState {
  /// The state was not available.
  unavailable,

  /// Vehicle power was off.
  off,

  /// Accessory power was active.
  accessory,

  /// Vehicle power was on.
  on,
}

/// Quality classification for one raw-reading attempt.
enum ReadingQuality {
  /// Parsing and validation succeeded.
  valid,

  /// A value was present but failed validation.
  invalid,

  /// No value was present.
  missing,

  /// The command timed out.
  timeout,

  /// The profile does not support the value.
  unsupported,
}

/// Canonical units used by domain measurements.
enum CanonicalUnit {
  /// Volt.
  volt,

  /// Ampere.
  ampere,

  /// Watt.
  watt,

  /// Amp-hour.
  ampHour,

  /// Watt-hour.
  wattHour,

  /// Degrees Celsius.
  celsius,

  /// Percent.
  percent,

  /// Dimensionless count.
  count,

  /// Millisecond.
  millisecond,
}

/// Governed assessment grade values.
enum AssessmentGrade {
  /// Excellent.
  excellent,

  /// Good.
  good,

  /// Fair.
  fair,

  /// Monitoring is recommended by an approved rule.
  monitor,
}

/// Confidence based on scan completeness and data quality.
enum AnalysisConfidence {
  /// Required and supporting inputs were valid.
  high,

  /// State of health was valid with some supporting inputs unavailable.
  moderate,

  /// Only the minimum inputs were valid or scan conditions were uncertain.
  limited,

  /// Confidence could not be assessed.
  unavailable,
}

/// Battery Engine component identifiers.
enum AnalysisComponentKind {
  /// State of health.
  stateOfHealth,

  /// Cell balance.
  cellBalance,

  /// Temperature.
  temperature,

  /// Charging behaviour.
  chargingBehaviour,
}
