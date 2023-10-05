import 'package:flutter/rendering.dart';

import '../drawables/shape/node_polygon_drawable.dart';
import 'shape_factory.dart';

class NodePolygonFactory extends ShapeFactory<NodePolygonDrawable> {
  /// A [NodePolygonDrawable] factory.
  const NodePolygonFactory([this.polygonCloseRadius]);

  /// {@macro polygon_close_radius}
  final double? polygonCloseRadius;

  /// Creates and returns a [NodePolygonDrawable] of zero size and the passed
  /// [position], [polygonCloseRadius] and [paint]. Position is used here for
  /// the first vertex.
  @override
  NodePolygonDrawable create(Offset position, [Paint? paint]) =>
      NodePolygonDrawable(
        paint: paint,
        size: Size.zero,
        position: position,
        vertices: [position],
        polygonCloseRadius: polygonCloseRadius,
      );
}
