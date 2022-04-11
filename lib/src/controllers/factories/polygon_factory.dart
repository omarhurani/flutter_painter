import 'dart:ui';

import '../drawables/shape/polygon_drawable.dart';
import 'shape_factory.dart';

/// A [PolygonDrawable] factory.
class PolygonFactory extends ShapeFactory<PolygonDrawable> {
  /// Creates an instance of [PolygonFactory].
  PolygonFactory() : super();

  /// Creates and returns a [PolygonDrawable] of zero size and the passed [position] and [paint].
  @override
  PolygonDrawable create(Offset position, [Paint? paint]) {
    return PolygonDrawable(size: Size.zero, position: position, paint: paint);
  }
}
