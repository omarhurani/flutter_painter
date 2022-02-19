import 'package:flutter/rendering.dart';

import '../object_drawable.dart';

/// Abstract class representing a drawable of a shape.
abstract class ShapeDrawable extends ObjectDrawable {
  /// Default value for [paint].
  static final defaultPaint = Paint()
    ..strokeWidth = 2
    ..color = const Color(0xFF000000)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  /// The paint to be used for the shape drawable.
  Paint paint;

  /// Default constructor for [ObjectDrawable].
  ShapeDrawable({
    Paint? paint,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  })  : paint = paint ?? defaultPaint,
        super(
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ShapeDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Paint? paint,
    bool? locked,
  });
}
