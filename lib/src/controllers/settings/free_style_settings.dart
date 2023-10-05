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

  /// {@template polygon_close_radius}
  /// The radius within which a touch/tap will be considered as a touch/tap
  /// on the first vertex. This will usually close the path.
  /// {@endtemplate}
  ///
  /// {@template is_polygon_filled_sense}
  /// Makes only sense to use together with [isPolygonFilled] flag set to `true`.
  /// {@endtemplate}
  final double? polygonCloseRadius;

  /// Allows you to fill polygons with the selected [color].
  /// If set to `false`, it will only shape polygons using their outlines.
  final bool isPolygonFilled;

  /// Background color on which the polygons will be created.
  /// Default to `null` ([Colors.transparent] fallback).
  /// {@macro is_polygon_filled_sense}
  final Color? backgroundColor;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth], [polygonCloseRadius] and [mode] values.
  const FreeStyleSettings({
    this.mode = FreeStyleMode.none,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.backgroundColor,
    this.polygonCloseRadius,
    this.isPolygonFilled = false,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith({
    FreeStyleMode? mode,
    Color? color,
    double? strokeWidth,
    bool? isPolygonFilled,
    Color? backgroundColor,
    double? polygonCloseRadius,
  }) {
    return FreeStyleSettings(
      mode: mode ?? this.mode,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isPolygonFilled: isPolygonFilled ?? this.isPolygonFilled,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      polygonCloseRadius: polygonCloseRadius ?? this.polygonCloseRadius,
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

/// Extensions on the [FreeStyleMode] class.
extension FreeStyleModeExtension on FreeStyleMode {
  /// Convention pattern matching for comparison of different
  /// [FreeStyleMode] modes with a `null` fallback.
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
