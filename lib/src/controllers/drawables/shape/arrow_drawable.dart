import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import 'shape_drawable.dart';
import '../sized1ddrawable.dart';
import '../../../extensions/paint_copy_extension.dart';

/// A drawable of a simple arrow shape.
class ArrowDrawable extends Sized1DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// The size of the arrow head.
  ///
  /// If null, the arrow head size will be 3 times the [paint] strokeWidth.
  double? arrowHeadSize;

  /// Creates a new [ArrowDrawable] with the given [length], [paint] and [arrowHeadSize].
  ArrowDrawable({
    Paint? paint,
    this.arrowHeadSize,
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

  /// The actual arrow head size used in drawing.
  double get _arrowHeadSize => arrowHeadSize ?? paint.strokeWidth * 3;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the line and the size of the arrow head.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.symmetric(
      horizontal: paint.strokeWidth / 2,
      vertical: paint.strokeWidth / 2 + (_arrowHeadSize / 2));

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final arrowHeadSize = _arrowHeadSize;

    final dx = length / 2 * scale - arrowHeadSize;

    final start = position.translate(-length / 2 * scale, 0);
    final end = position.translate(dx, 0);

    if ((end - start).dx > 0) canvas.drawLine(start, end, paint);

    final pathDx = dx /*.clamp(-arrowHeadSize/2, double.infinity)*/;

    final path = Path();
    path.moveTo(position.dx + pathDx + arrowHeadSize, position.dy);
    path.lineTo(position.dx + pathDx, position.dy - (arrowHeadSize / 2));
    path.lineTo(position.dx + pathDx, position.dy + (arrowHeadSize / 2));
    path.lineTo(position.dx + pathDx + arrowHeadSize, position.dy);

    final headPaint = paint.copyWith(
      style: PaintingStyle.fill,
    );

    canvas.drawPath(path, headPaint);
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ArrowDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? length,
    Paint? paint,
    bool? locked,
    double? arrowHeadSize,
  }) {
    return ArrowDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      length: length ?? this.length,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      arrowHeadSize: arrowHeadSize ?? this.arrowHeadSize,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = super.getSize();
    return Size(size.width, size.height);
  }

  /// Compares two [ArrowDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is ArrowDrawable &&
  //       super == other &&
  //       other.paint == paint &&
  //       other.length == length &&
  //       other.arrowHeadSize == arrowHeadSize;
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
  //     length,
  //     arrowHeadSize);
}
