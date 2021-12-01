import 'package:flutter/painting.dart';
import '../drawables/shape/shape_drawable.dart';
import '../factories/shape_factory.dart';

/// Represents settings used to control shape drawables in the UI
class ShapeSettings {
  /// A factory for the shape in the UI.
  /// If this is not null, whenever the user drags on the UI, a shape from the factory is drawn.
  final ShapeFactory? factory;

  /// If the shape should be drawn once or continuously.
  /// If `true`, after the shape is drawn, the [factory] will be set back to `null`.
  /// If `false`, the user will be able to keep drawing shapes until [factory] is set to `null` explicitly.
  final bool drawOnce;

  /// The paint to be used when new shapes are drawn.
  /// If `null`, the [ShapeDrawable.defaultPaint] will be used.
  final Paint? paint;

  /// Creates a new instance of [ShapeSettings] with the given [factory].
  const ShapeSettings({
    this.factory,
    this.drawOnce = true,
    this.paint,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ShapeSettings copyWith({
    ShapeFactory? factory = _NoShapePassedFactory.instance,
    bool? drawOnce,
    Paint? paint,
  }) =>
      ShapeSettings(
        factory:
            factory == _NoShapePassedFactory.instance ? this.factory : factory,
        drawOnce: drawOnce ?? this.drawOnce,
        paint: paint ?? this.paint,
      );
}

/// Private class that is used internally to represent no
/// [ShapeFactory] argument passed for [ShapeSettings.copyWith].
class _NoShapePassedFactory extends ShapeFactory {
  /// Single instance.
  static const _NoShapePassedFactory instance = _NoShapePassedFactory._();

  /// Private constructor.
  const _NoShapePassedFactory._();

  /// Unimplemented implementation of the create method.
  @override
  ShapeDrawable create(Offset position, [Paint? paint]) {
    throw UnimplementedError();
  }
}
