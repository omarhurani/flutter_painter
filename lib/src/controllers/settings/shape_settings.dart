import 'package:flutter/painting.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Represents settings used to control shape drawables in the UI
class ShapeSettings {
  /// A creator for the shape in the UI.
  /// If this is not null, whenever the user drags on the UI, a shape from the creator is drawn.
  final ShapeCreator? creator;

  /// If the shape should be drawn once or continuously.
  /// If `true`, after the shape is drawn, the [creator] will be set back to `null`.
  /// If `false`, the user will be able to keep drawing shapes until [creator] is set to `null` explicitly.
  final bool drawOnce;

  /// The paint to be used when new shapes are drawn.
  /// If `null`, the [ShapeDrawable.defaultPaint] will be used.
  final Paint? paint;

  /// Creates a new instance of [ShapeSettings] with the given [creator].
  const ShapeSettings({
    this.creator,
    this.drawOnce = true,
    this.paint,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ShapeSettings copyWith({
    ShapeCreator? shapeCreator = _NoShapePassedCreator.instance,
    bool? drawOnce,
    Paint? paint,
  }) => ShapeSettings(
    creator: shapeCreator == _NoShapePassedCreator.instance ? this.creator : shapeCreator,
    drawOnce: drawOnce ?? this.drawOnce,
    paint: paint ?? this.paint,
  );

}

/// Private class that is used internally to represent no
/// [ShapeCreator] argument passed for [ShapeSettings.copyWith].
class _NoShapePassedCreator extends ShapeCreator{

  /// Single instance.
  static const _NoShapePassedCreator instance = _NoShapePassedCreator._();

  /// Private constructor.
  const _NoShapePassedCreator._();

  /// Unimplemented implementation of the create method.
  @override
  ShapeDrawable create(Offset position, [Paint? paint]) {
    throw UnimplementedError();
  }

}