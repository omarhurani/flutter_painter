import 'package:flutter/material.dart';

/// Represents settings used to create and draw free-style drawables.
@immutable
class FreeStyleSettings {
  /// Free-style painting mode.
  final FreeStyleMode mode;

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  final double? polygonCloseDistance;
  final bool isPolygonFilled;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth], [polygonCloseDistance] and [mode] values.
  const FreeStyleSettings({
    this.mode = FreeStyleMode.none,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.polygonCloseDistance,
    this.isPolygonFilled = false,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith({
    FreeStyleMode? mode,
    Color? color,
    double? strokeWidth,
    bool? isPolygonFilled,
    double? polygonCloseDistance,
  }) {
    return FreeStyleSettings(
      mode: mode ?? this.mode,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isPolygonFilled: isPolygonFilled ?? this.isPolygonFilled,
      polygonCloseDistance: polygonCloseDistance ?? this.polygonCloseDistance,
    );
  }
}

/// Enum representing different states that free-style painting can be.
enum FreeStyleMode {
  /// Free-style painting is disabled.
  none,

  /// Free-style painting is enabled in drawing mode; used to draw scribbles.
  draw,

  /// Free-style painting is enabled in erasing mode; used to erase drawings.
  erase,

  /// Free-style painting is enabled in polygonal drawing mode;
  /// used to draw polygonal shapes.
  polygonalDraw
}

extension FreeStyleModeExtension on FreeStyleMode {
  T? whenOrNull<T extends Object?>({
    T Function()? none,
    T Function()? draw,
    T Function()? erase,
    T Function()? polygonalDraw,
  }) {
    switch (this) {
      case FreeStyleMode.none:
        return none?.call();
      case FreeStyleMode.draw:
        return draw?.call();
      case FreeStyleMode.erase:
        return erase?.call();
      case FreeStyleMode.polygonalDraw:
        return polygonalDraw?.call();
      default:
        return null;
    }
  }
}
