import 'package:flutter/widgets.dart';

/// Shared spacing, sizing, and shape tokens for EV Health presentation.
abstract final class AppSpacing {
  /// Base spacing unit.
  static const unit = 4.0;

  /// 4dp spacing.
  static const extraSmall = unit;

  /// 8dp spacing.
  static const small = unit * 2;

  /// 12dp spacing.
  static const mediumSmall = unit * 3;

  /// 16dp spacing.
  static const medium = unit * 4;

  /// 24dp spacing.
  static const large = unit * 6;

  /// 32dp spacing.
  static const extraLarge = unit * 8;

  /// 48dp spacing.
  static const extraExtraLarge = unit * 12;

  /// Compact screen horizontal inset.
  static const screenCompact = medium;

  /// Medium-width screen horizontal inset.
  static const screenMedium = large;

  /// Expanded screen horizontal inset.
  static const screenExpanded = extraLarge;

  /// Minimum internal padding for a card.
  static const cardPadding = medium;

  /// Minimum width and height of an interactive target.
  static const minimumTouchTarget = extraExtraLarge;

  /// Governed card corner radius.
  static const cardRadius = BorderRadius.all(Radius.circular(16));

  /// Governed button corner radius.
  static const buttonRadius = BorderRadius.all(Radius.circular(12));
}
