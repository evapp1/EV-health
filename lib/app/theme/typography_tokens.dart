import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Governed system-font typography for EV Health.
abstract final class AppTypography {
  /// Builds the Material text theme from the approved semantic type scale.
  static TextTheme textTheme(EvHealthColors colors) {
    return TextTheme(
      displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);
  }

  /// Technical detail style, reserved for Developer Mode values.
  static TextStyle technical(EvHealthColors colors) {
    return TextStyle(
      color: colors.textPrimary,
      fontFamily: 'monospace',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }
}
