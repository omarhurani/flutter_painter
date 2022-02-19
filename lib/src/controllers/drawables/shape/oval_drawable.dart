import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import 'shape_drawable.dart';
import '../sized2ddrawable.dart';

/// A drawable of an oval.
class OvalDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Creates a new [OvalDrawable] with the given [size] and [paint].
  OvalDrawable({
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
    canvas.drawOval(
        Rect.fromCenter(
            center: position,
            width: drawingSize.width,
            height: drawingSize.height),
        paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  OvalDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
  }) {
    return OvalDrawable(
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
    return Size(size.width, size.height);
  }

  /// Compares two [OvalDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is OvalDrawable &&
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
