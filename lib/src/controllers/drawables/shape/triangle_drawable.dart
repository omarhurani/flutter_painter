import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// A drawable of an isosceles triangle.
class TriangleDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the triangle.
  @override
  Paint paint;

  /// Creates a new [TriangleDrawable] with the given [size] and [paint].
  TriangleDrawable({
    Paint? paint,
    required super.size,
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : paint = paint ?? ShapeDrawable.defaultPaint;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to half the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the triangle on the provided [canvas].
  @override
  void drawObject(Canvas canvas, Size size) {
    final drawingSize = this.size * scale;
    final halfWidth = drawingSize.width / 2;
    final halfHeight = drawingSize.height / 2;
    final path = Path()
      ..moveTo(position.dx, position.dy - halfHeight)
      ..lineTo(position.dx + halfWidth, position.dy + halfHeight)
      ..lineTo(position.dx - halfWidth, position.dy + halfHeight)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Creates a copy of this but with the given fields replaced with new values.
  @override
  TriangleDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
  }) {
    return TriangleDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      assistPaints: assistPaints,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      locked: locked ?? this.locked,
      paint: paint ?? this.paint,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = super.getSize();
    return Size(size.width, size.height);
  }
}
