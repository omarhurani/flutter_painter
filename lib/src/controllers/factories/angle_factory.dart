import 'dart:math' as math;
import 'dart:ui';

import '../drawables/shape/angle_drawable.dart';
import 'shape_factory.dart';

/// Creates [AngleDrawable]s whose sweep is defined by the drawing gesture.
class AngleFactory extends ShapeFactory<AngleDrawable> {
  /// The direction of the first ray in radians.
  final double startAngle;

  /// The sweep used before the pointer moves.
  final double initialSweepAngle;

  /// The unscaled radius of the arc drawn between the rays.
  final double arcRadius;

  /// Creates an angle factory.
  const AngleFactory({
    this.startAngle = 0,
    this.initialSweepAngle = math.pi / 4,
    this.arcRadius = 24,
  });

  @override
  AngleDrawable create(Offset position, [Paint? paint]) {
    return AngleDrawable(
      radius: 0,
      sweepAngle: initialSweepAngle,
      arcRadius: arcRadius,
      position: position,
      rotationAngle: startAngle,
      paint: paint,
    );
  }
}
