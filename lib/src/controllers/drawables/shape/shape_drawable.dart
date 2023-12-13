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
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : paint = paint ?? defaultPaint;

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
