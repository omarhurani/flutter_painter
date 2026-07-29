import 'package:flutter/material.dart';

import '../drawables/path/free_style_drawable.dart';
import '../drawables/path/path_drawable.dart';
import '../factories/free_style_factory.dart';

/// Represents settings used to create and draw free-style drawables.
@immutable
class FreeStyleSettings {
  /// Free-style painting mode.
  final FreeStyleMode mode;

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// The optional factory used to create custom free-style drawables.
  ///
  /// When `null`, drawing creates the built-in [FreeStyleDrawable]. The
  /// factory is ignored in erase and fill modes.
  final FreeStyleFactory? factory;

  /// The per-channel flood-fill tolerance as a percentage from 0 to 100.
  ///
  /// Zero fills only pixels matching the tapped pixel exactly. Higher values
  /// include nearby color shades.
  final int fillTolerance;

  /// Creates a [FreeStyleSettings] with the given [color]
  /// and [strokeWidth], [mode], and [factory] values.
  const FreeStyleSettings({
    this.mode = FreeStyleMode.none,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.factory,
    this.fillTolerance = 8,
  }) : assert(
         fillTolerance >= 0 && fillTolerance <= 100,
         'fillTolerance must be between 0 and 100',
       );

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleSettings copyWith({
    FreeStyleMode? mode,
    Color? color,
    double? strokeWidth,
    FreeStyleFactory? factory = _NoFreeStyleFactory.instance,
    int? fillTolerance,
  }) {
    return FreeStyleSettings(
      mode: mode ?? this.mode,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fillTolerance: fillTolerance ?? this.fillTolerance,
      factory: identical(factory, _NoFreeStyleFactory.instance)
          ? this.factory
          : factory,
    );
  }
}

/// Private sentinel used to distinguish an omitted factory from `null`.
class _NoFreeStyleFactory extends FreeStyleFactory<PathDrawable> {
  static const _NoFreeStyleFactory instance = _NoFreeStyleFactory._();

  const _NoFreeStyleFactory._();

  @override
  PathDrawable create({
    required List<Offset> path,
    required Color color,
    required double strokeWidth,
  }) {
    throw UnimplementedError();
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

  /// Paint-bucket mode; tapping fills a connected region of the composed
  /// painter using [FreeStyleSettings.color].
  fill,
}
