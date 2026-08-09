import 'package:ev_health/domain/models/domain_enums.dart';
import 'package:ev_health/domain/models/identifiers.dart';
import 'package:ev_health/domain/models/model_support.dart';

/// Evidence status attached to a vehicle-profile preparation instruction.
enum PreparationInstructionBasis {
  /// Fictional setup guidance used only by the disclosed demo flow.
  demoAssumption,

  /// A real-flow procedure that has not completed reference-vehicle testing.
  unvalidatedProcedure,

  /// A procedure supported by recorded reference-vehicle validation.
  referenceVehicleValidated,
}

/// Typed, profile-specific preparation content supplied to the application.
final class VehiclePreparationInstructions {
  /// Creates validated preparation instructions for one exact profile version.
  VehiclePreparationInstructions({
    required this.profile,
    required this.source,
    required String powerStateInstruction,
    required this.basis,
  }) : powerStateInstruction = requireText(
         powerStateInstruction,
         'powerStateInstruction',
       ) {
    if (source == DataSource.demo &&
        basis != PreparationInstructionBasis.demoAssumption) {
      throw ArgumentError(
        'Demo preparation instructions must be labelled as a demo assumption.',
      );
    }
    if (source == DataSource.real &&
        basis == PreparationInstructionBasis.demoAssumption) {
      throw ArgumentError(
        'Real preparation instructions cannot use a demo-only basis.',
      );
    }
  }

  /// Exact profile version these instructions belong to.
  final VehicleProfileIdentity profile;

  /// Data source allowed to consume these instructions.
  final DataSource source;

  /// Vehicle-specific power-state direction; never selected by a widget.
  final String powerStateInstruction;

  /// Evidence status used to qualify the instruction honestly.
  final PreparationInstructionBasis basis;
}

/// Immutable local catalogue of profile-specific preparation instructions.
final class ScanPreparationConfiguration {
  /// Creates a catalogue and rejects duplicate profile/source entries.
  ScanPreparationConfiguration(
    Iterable<VehiclePreparationInstructions> instructions,
  ) : _instructions = List.unmodifiable(instructions) {
    final keys = <String>{};
    for (final instruction in _instructions) {
      final key = _key(instruction.profile, instruction.source);
      if (!keys.add(key)) {
        throw ArgumentError('Duplicate scan preparation configuration: $key');
      }
    }
  }

  final List<VehiclePreparationInstructions> _instructions;

  /// Returns instructions only for the exact confirmed profile and source.
  VehiclePreparationInstructions? forProfile(
    VehicleProfileIdentity profile,
    DataSource source,
  ) {
    for (final instruction in _instructions) {
      if (instruction.profile == profile && instruction.source == source) {
        return instruction;
      }
    }
    return null;
  }

  static String _key(VehicleProfileIdentity profile, DataSource source) =>
      '${profile.id.value}:${profile.version.value}:${source.name}';
}
