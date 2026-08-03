import 'package:ev_health/app/theme/app_theme.dart';
import 'package:ev_health/app/theme/color_tokens.dart';
import 'package:ev_health/app/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light theme exposes the approved Material 3 tokens', () {
      final theme = AppTheme.light;
      final colors = theme.extension<EvHealthColors>();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF155EEF));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(colors, isNotNull);
      expect(colors!.surfaceAlt, const Color(0xFFF2F4F7));
      expect(colors.positive, const Color(0xFF067647));
      expect(colors.caution, const Color(0xFFB54708));
      expect(colors.info, const Color(0xFF175CD3));
    });

    test('dark theme exposes the approved Material 3 tokens', () {
      final theme = AppTheme.dark;
      final colors = theme.extension<EvHealthColors>();

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF84ADFF));
      expect(theme.colorScheme.onPrimary, const Color(0xFF002A69));
      expect(theme.colorScheme.surface, const Color(0xFF101828));
      expect(colors, isNotNull);
      expect(colors!.surfaceAlt, const Color(0xFF1D2939));
      expect(colors.positive, const Color(0xFF6CE9A6));
      expect(colors.caution, const Color(0xFFFEC84B));
      expect(colors.info, const Color(0xFF84CAFF));
    });

    test('centralizes typography, card, and button dimensions', () {
      final theme = AppTheme.light;
      final filledStyle = theme.filledButtonTheme.style!;
      final outlinedStyle = theme.outlinedButtonTheme.style!;

      expect(theme.textTheme.displayLarge!.fontSize, 48);
      expect(theme.textTheme.displayLarge!.fontWeight, FontWeight.w700);
      expect(theme.textTheme.headlineMedium!.fontSize, 28);
      expect(theme.textTheme.titleLarge!.fontSize, 20);
      expect(theme.textTheme.bodyLarge!.fontSize, 16);
      expect(theme.textTheme.bodyMedium!.fontSize, 14);
      expect(theme.textTheme.labelLarge!.fontWeight, FontWeight.w600);
      expect(theme.cardTheme.color, EvHealthColors.light.surfaceAlt);
      expect(
        theme.cardTheme.shape,
        const RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
      );
      expect(
        filledStyle.minimumSize!.resolve(<WidgetState>{}),
        const Size(0, AppSpacing.minimumTouchTarget),
      );
      expect(
        outlinedStyle.minimumSize!.resolve(<WidgetState>{}),
        const Size(0, AppSpacing.minimumTouchTarget),
      );
    });

    test('centralizes bottom navigation colors and typography', () {
      final theme = AppTheme.light;
      final navigationTheme = theme.navigationBarTheme;

      expect(navigationTheme.backgroundColor, EvHealthColors.light.surface);
      expect(
        navigationTheme.indicatorColor,
        EvHealthColors.light.primary.withValues(alpha: 0.12),
      );
      expect(
        navigationTheme.iconTheme!.resolve(<WidgetState>{
          WidgetState.selected,
        })!.color,
        EvHealthColors.light.primary,
      );
      expect(
        navigationTheme.iconTheme!.resolve(<WidgetState>{})!.color,
        EvHealthColors.light.textSecondary,
      );
      expect(
        navigationTheme.labelTextStyle!.resolve(<WidgetState>{
          WidgetState.selected,
        })!.color,
        EvHealthColors.light.primary,
      );
    });
  });
}
