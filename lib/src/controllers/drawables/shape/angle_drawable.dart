import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../extensions/paint_copy_extension.dart';
import '../object_drawable.dart';
import 'shape_drawable.dart';

/// A two-ray angle with an arc showing its clockwise sweep.
///
/// [position] is the vertex, [rotationAngle] points the first ray, and
/// [sweepAngle] rotates clockwise from that ray in radians.
class AngleDrawable extends ObjectDrawable implements ShapeDrawable {
  /// A complete turn in radians.
  static const double fullTurn = math.pi * 2;

  /// The length of both rays before [scale] is applied.
  final double radius;

  /// The clockwise angle between the rays in radians.
  final double sweepAngle;

  /// The unscaled radius of the arc drawn between the rays.
  final double arcRadius;

  /// The paint used for the rays and arc.
  @override
  Paint paint;

  /// Creates an angle drawable.
  AngleDrawable({
    required double radius,
    required double sweepAngle,
    double arcRadius = 24,
    Paint? paint,
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : radius = _validateNonNegative(radius, 'radius'),
       sweepAngle = normalizeSweepAngle(sweepAngle),
       arcRadius = _validateNonNegative(arcRadius, 'arcRadius'),
       paint = paint ?? ShapeDrawable.defaultPaint;

  /// Converts [degrees] to radians.
  static double degreesToRadians(double degrees) {
    if (!degrees.isFinite) {
      throw ArgumentError.value(degrees, 'degrees', 'must be finite');
    }
    return degrees * math.pi / 180;
  }

  /// Converts [radians] to degrees.
  static double radiansToDegrees(double radians) {
    if (!radians.isFinite) {
      throw ArgumentError.value(radians, 'radians', 'must be finite');
    }
    return radians * 180 / math.pi;
  }

  /// Normalizes a finite sweep to the clockwise range from zero to one turn.
  ///
  /// An exact complete turn is preserved instead of becoming zero.
  static double normalizeSweepAngle(double sweepAngle) {
    if (!sweepAngle.isFinite) {
      throw ArgumentError.value(sweepAngle, 'sweepAngle', 'must be finite');
    }
    if (sweepAngle == fullTurn) return fullTurn;

    final normalized = sweepAngle.remainder(fullTurn);
    if (normalized == 0) return 0;
    return normalized < 0 ? normalized + fullTurn : normalized;
  }

  /// The clockwise angle between the rays in degrees.
  double get sweepAngleDegrees => radiansToDegrees(sweepAngle);

  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledRadius = radius * scale;
    if (scaledRadius == 0) return;

    final strokePaint = paint.style == PaintingStyle.stroke
        ? paint
        : paint.copyWith(style: PaintingStyle.stroke);
    canvas
      ..drawLine(
        position,
        position + Offset.fromDirection(0, scaledRadius),
        strokePaint,
      )
      ..drawLine(
        position,
        position + Offset.fromDirection(sweepAngle, scaledRadius),
        strokePaint,
      );

    final scaledArcRadius = math.min(arcRadius * scale, scaledRadius);
    if (scaledArcRadius > 0 && sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: position, radius: scaledArcRadius),
        0,
        sweepAngle,
        false,
        strokePaint,
      );
    }
  }

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final diameter = radius * scale * 2 + paint.strokeWidth;
    return Size.square(diameter);
  }

  @override
  AngleDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? radius,
    double? sweepAngle,
    double? arcRadius,
    Paint? paint,
    bool? locked,
  }) {
    return AngleDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      assistPaints: assistPaints,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      radius: radius ?? this.radius,
      sweepAngle: sweepAngle ?? this.sweepAngle,
      arcRadius: arcRadius ?? this.arcRadius,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
    );
  }

  static double _validateNonNegative(double value, String name) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError.value(value, name, 'must be finite and non-negative');
    }
    return value;
  }
}
