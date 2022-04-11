import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import 'shape_drawable.dart';
import '../sized2ddrawable.dart';

/// A drawable of an oval.
class PolygonDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Creates a new [PolygonDrawable] with the given [size] and [paint].
  PolygonDrawable({
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
    canvas.drawCircle(position, 5, paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  PolygonDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
  }) {
    return PolygonDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
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
    return Size(10, 10);
  }

  /// Compares two [PolygonDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is PolygonDrawable &&
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
