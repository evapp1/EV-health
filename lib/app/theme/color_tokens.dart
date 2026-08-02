import 'package:flutter/material.dart';

/// Semantic EV Health colours for the active brightness.
@immutable
class EvHealthColors extends ThemeExtension<EvHealthColors> {
  /// Creates an EV Health semantic colour palette.
  const EvHealthColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.positive,
    required this.caution,
    required this.critical,
    required this.info,
    required this.outline,
  });

  /// The approved accessible light palette.
  static const light = EvHealthColors(
    brightness: Brightness.light,
    primary: Color(0xFF155EEF),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF2F4F7),
    textPrimary: Color(0xFF101828),
    textSecondary: Color(0xFF475467),
    positive: Color(0xFF067647),
    caution: Color(0xFFB54708),
    critical: Color(0xFFB42318),
    info: Color(0xFF175CD3),
    outline: Color(0xFFD0D5DD),
  );

  /// The approved accessible dark palette.
  static const dark = EvHealthColors(
    brightness: Brightness.dark,
    primary: Color(0xFF84ADFF),
    onPrimary: Color(0xFF002A69),
    surface: Color(0xFF101828),
    surfaceAlt: Color(0xFF1D2939),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFFD0D5DD),
    positive: Color(0xFF6CE9A6),
    caution: Color(0xFFFEC84B),
    critical: Color(0xFFFDA29B),
    info: Color(0xFF84CAFF),
    outline: Color(0xFF475467),
  );

  /// Brightness represented by this palette.
  final Brightness brightness;

  /// Primary actions and selected controls.
  final Color primary;

  /// Content displayed on [primary].
  final Color onPrimary;

  /// Main application surfaces.
  final Color surface;

  /// Cards and secondary surfaces.
  final Color surfaceAlt;

  /// Primary text.
  final Color textPrimary;

  /// Supporting text.
  final Color textSecondary;

  /// Favourable supported status.
  final Color positive;

  /// Needs-attention or low-confidence status.
  final Color caution;

  /// Failed-operation or serious-warning status.
  final Color critical;

  /// Informational status.
  final Color info;

  /// Dividers and boundaries.
  final Color outline;

  /// Maps the governed palette onto Material's standard colour roles.
  ColorScheme toColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: info,
      surface: surface,
      onSurface: textPrimary,
      error: critical,
      onError: brightness == Brightness.light
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF601410),
      outline: outline,
    );
  }

  @override
  EvHealthColors copyWith({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? positive,
    Color? caution,
    Color? critical,
    Color? info,
    Color? outline,
  }) {
    return EvHealthColors(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      positive: positive ?? this.positive,
      caution: caution ?? this.caution,
      critical: critical ?? this.critical,
      info: info ?? this.info,
      outline: outline ?? this.outline,
    );
  }

  @override
  EvHealthColors lerp(covariant EvHealthColors? other, double t) {
    if (other == null) {
      return this;
    }

    return EvHealthColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      info: Color.lerp(info, other.info, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}
