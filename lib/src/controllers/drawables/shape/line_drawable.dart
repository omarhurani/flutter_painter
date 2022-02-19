import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import 'shape_drawable.dart';
import '../sized1ddrawable.dart';

/// A drawable of a simple line shape.
class LineDrawable extends Sized1DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Creates a new [LineDrawable] with the given [length] and [paint].
  LineDrawable({
    Paint? paint,
    required double length,
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
            length: length,
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the line.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the line on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    canvas.drawLine(position.translate(-length / 2 * scale, 0),
        position.translate(length / 2 * scale, 0), paint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  LineDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? length,
    Paint? paint,
    bool? locked,
  }) {
    return LineDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      length: length ?? this.length,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
    );
  }

  /// Compares two [LineDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is LineDrawable &&
  //       super == other &&
  //       other.paint == paint &&
  //       other.length == length;
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
  //     length);
}
