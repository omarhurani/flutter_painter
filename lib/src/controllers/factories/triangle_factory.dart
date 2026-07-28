import 'dart:ui';

import '../drawables/shape/triangle_drawable.dart';
import 'shape_factory.dart';

/// A [TriangleDrawable] factory.
class TriangleFactory extends ShapeFactory<TriangleDrawable> {
  /// Creates an instance of [TriangleFactory].
  TriangleFactory() : super();

  /// Creates a zero-sized [TriangleDrawable] at [position] using [paint].
  @override
  TriangleDrawable create(Offset position, [Paint? paint]) {
    return TriangleDrawable(size: Size.zero, position: position, paint: paint);
  }
}
