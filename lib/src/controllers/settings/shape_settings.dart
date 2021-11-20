import 'package:flutter/painting.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Represents settings used to control shape drawables in the UI
class ShapeSettings {
  /// A creator for the shape in the UI.
  /// If this is not null, whenever the user drags on the UI, a shape from the creator is drawn.
  final ShapeCreator? creator;

  /// Creates a new instance of [ShapeSettings] with the given [creator].
  const ShapeSettings({
    this.creator
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ShapeSettings copyWith({
    ShapeCreator? shapeCreator = _NoShapePassedCreator.instance,
  }) => ShapeSettings(
    creator: shapeCreator == _NoShapePassedCreator.instance ? this.creator : shapeCreator,
  );

}

class _NoShapePassedCreator extends ShapeCreator{

  static const _NoShapePassedCreator instance = _NoShapePassedCreator._();

  const _NoShapePassedCreator._();

  @override
  ShapeDrawable create(Offset position) {
    throw UnimplementedError();
  }

}