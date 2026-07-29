import 'dart:ui';

import '../drawables/shape/labeled_shape_drawable.dart';
import '../drawables/sized1ddrawable.dart';
import '../drawables/sized2ddrawable.dart';
import 'shape_factory.dart';

/// Wraps any sized [ShapeFactory] with a centered text label.
class LabeledShapeFactory extends ShapeFactory<LabeledShapeDrawable> {
  /// The factory that creates the underlying shape.
  final ShapeFactory factory;

  /// The label drawn over each created shape.
  final ShapeLabel label;

  /// Creates a labeled shape factory.
  const LabeledShapeFactory({required this.factory, required this.label});

  @override
  LabeledShapeDrawable create(Offset position, [Paint? paint]) {
    final shape = factory.create(position, paint);
    if (shape is Sized1DDrawable) {
      final sizedShape = shape as Sized1DDrawable;
      return LabeledSized1DShapeDrawable(
        shape: shape,
        label: label,
        length: sizedShape.length,
        position: shape.position,
        paint: shape.paint,
        rotationAngle: shape.rotationAngle,
        scale: shape.scale,
        assists: shape.assists,
        assistPaints: shape.assistPaints,
        locked: shape.locked,
        hidden: shape.hidden,
      );
    }
    if (shape is Sized2DDrawable) {
      final sizedShape = shape as Sized2DDrawable;
      return LabeledSized2DShapeDrawable(
        shape: shape,
        label: label,
        size: sizedShape.size,
        position: shape.position,
        paint: shape.paint,
        rotationAngle: shape.rotationAngle,
        scale: shape.scale,
        assists: shape.assists,
        assistPaints: shape.assistPaints,
        locked: shape.locked,
        hidden: shape.hidden,
      );
    }
    throw UnsupportedError(
      'LabeledShapeFactory requires a shape that extends '
      'Sized1DDrawable or Sized2DDrawable.',
    );
  }
}
