import 'package:flutter/rendering.dart';

import '../drawables/shape/node_polygon_drawable.dart';
import 'shape_factory.dart';

/// A [NodePolygonDrawable] factory.
class NodePolygonFactory extends ShapeFactory<NodePolygonDrawable> {
  const NodePolygonFactory([this.polygonCloseRadius]);

  final double? polygonCloseRadius;

  /// Creates and returns a [NodePolygonDrawable] of zero size and the passed [position] and [paint].
  @override
  NodePolygonDrawable create(Offset position, [Paint? paint]) {
    return NodePolygonDrawable(
      size: Size.zero,
      position: position,
      vertices: [position],
      paint: paint,
      polygonCloseRadius: polygonCloseRadius,
    );
  }
}
