import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:ev_health/app/theme/typography_tokens.dart';
import 'package:flutter/material.dart';

/// Central Material 3 theme definitions for EV Health.
abstract final class AppTheme {
  /// Light EV Health theme.
  static final ThemeData light = _build(EvHealthColors.light);

  /// Dark EV Health theme.
  static final ThemeData dark = _build(EvHealthColors.dark);

  static ThemeData _build(EvHealthColors colors) {
    final textTheme = AppTypography.textTheme(colors);
    final commonButtonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(0, AppSpacing.minimumTouchTarget),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.mediumSmall,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppSpacing.buttonRadius),
      ),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors.toColorScheme(),
      scaffoldBackgroundColor: colors.surface,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceAlt,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.cardRadius,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelLarge?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.textSecondary,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(style: commonButtonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: commonButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: commonButtonStyle.copyWith(
          foregroundColor: WidgetStatePropertyAll(colors.primary),
          side: WidgetStatePropertyAll(BorderSide(color: colors.outline)),
        ),
      ),
    );
  }
}
