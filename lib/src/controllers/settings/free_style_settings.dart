import 'package:flutter/material.dart';

/// Represents settings used to create and draw free-style drawables.
@immutable
class FreeStyleSettings {
  /// If free-style painting is enabled or not.
  final bool enabled;

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth] and [enabled] values.
  const FreeStyleSettings({
    this.enabled = true,
    this.color = Colors.black,
    this.strokeWidth = 1,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith(
      {bool? enabled, Color? color, double? strokeWidth}) {
    return FreeStyleSettings(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
