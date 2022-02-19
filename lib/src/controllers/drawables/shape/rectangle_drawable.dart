import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import 'shape_drawable.dart';
import '../sized2ddrawable.dart';

/// A drawable of a rectangle with a radius.
class RectangleDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// The border radius of the rectangle.
  /// The default value is a circular radius of 5 on all corners.
  BorderRadius borderRadius;

  /// Creates a new [RectangleDrawable] with the given [size], [paint] and [borderRadius].
  RectangleDrawable({
    Paint? paint,
    required Size size,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        super(
            size: size,
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final drawingSize = this.size * scale;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromCenter(
              center: position,
              width: drawingSize.width,
              height: drawingSize.height),
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ),
        paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  RectangleDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    BorderRadius? borderRadius,
  }) {
    return RectangleDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = super.getSize();
    return Size(size.width, size.height);
  }

  /// Compares two [RectangleDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is RectangleDrawable &&
  //       super == other &&
  //       other.paint == paint &&
  //       other.size == size;
  // }
  //
  // @override
  // int get hashCode => hashValues(
  //     hidden,
  //     locked,
  //     hashList(assists),
  //     hashList(assistPaints.entries),
  //     position,
  //     rotationAngle,
  //     scale,
  //     paint,
  //     size);
}
