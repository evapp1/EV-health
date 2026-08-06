import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic emphasis available to reusable EV Health presentation widgets.
enum EvHealthSemanticTone {
  /// A favourable, supported result.
  positive,

  /// Neutral explanatory information.
  information,

  /// A result that needs attention or has limited confidence.
  caution,

  /// A failed operation or serious data warning.
  critical,

  /// A value or step that is not available.
  unavailable,

  /// Fictional demo content.
  demo,
}

/// Theme-backed presentation for [EvHealthSemanticTone].
extension EvHealthSemanticTonePresentation on EvHealthSemanticTone {
  /// Returns the governed semantic colour for this tone.
  Color color(EvHealthColors colors) {
    return switch (this) {
      EvHealthSemanticTone.positive => colors.positive,
      EvHealthSemanticTone.information => colors.info,
      EvHealthSemanticTone.caution => colors.caution,
      EvHealthSemanticTone.critical => colors.critical,
      EvHealthSemanticTone.unavailable => colors.textSecondary,
      EvHealthSemanticTone.demo => colors.info,
    };
  }

  /// Returns the governed status icon for this tone.
  IconData get icon {
    return switch (this) {
      EvHealthSemanticTone.positive => Icons.check_circle_outline,
      EvHealthSemanticTone.information => Icons.info_outline,
      EvHealthSemanticTone.caution => Icons.warning_amber_rounded,
      EvHealthSemanticTone.critical => Icons.error_outline,
      EvHealthSemanticTone.unavailable => Icons.remove_circle_outline,
      EvHealthSemanticTone.demo => Icons.science_outlined,
    };
  }
}
