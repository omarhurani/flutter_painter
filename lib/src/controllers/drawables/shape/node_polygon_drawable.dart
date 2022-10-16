import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../object_drawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// A drawable of a rectangle with a radius.
class NodePolygonDrawable extends Sized2DDrawable implements ShapeDrawable {
  /// The paint to be used for the line drawable.
  @override
  Paint paint;

  /// Creates a new [NodePolygonDrawable] with the given [size], [paint] and [borderRadius].
  NodePolygonDrawable({
    required this.vertices,
    required Size size,
    required Offset position,
    Paint? paint,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    Offset? shiftOffset,
    this.polygonCloseDistance,
  })  : paint = paint ?? ShapeDrawable.defaultPaint,
        _shiftOffset = shiftOffset,
        super(
          size: size,
          position: position,
          rotationAngle: rotationAngle,
          scale: scale,
          assists: assists,
          assistPaints: assistPaints,
          locked: locked,
          hidden: hidden,
        );

  final double? polygonCloseDistance;
  final List<Offset> vertices;
  final Offset? _shiftOffset;

  /// Getter for padding of drawable.
  ///
  /// Add padding equal to the stroke width of the paint.
  @protected
  @override
  EdgeInsets get padding => EdgeInsets.all(paint.strokeWidth / 2);

  /// Draws the arrow on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;
    final path = Path()
      ..moveTo(vertices.first.dx, vertices.first.dy)
      ..addPolygon(vertices, isClosed);
    final shiftedPath = _shiftOffset == null ? path : path.shift(_shiftOffset!);
    final scalingMatrix4 = Float64List.fromList(
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 / scale]);
    final scaledPath = shiftedPath.transform(scalingMatrix4);
    canvas.drawPath(scaledPath, paint);
  }

  bool get isClosed {
    if (vertices.isEmpty) return false;
    return vertices.first == vertices.last;
  }

  bool _shouldBeClosed(Offset? vertex) {
    if (polygonCloseDistance == null) return false;
    if (vertex == null || vertices.isEmpty) return false;
    final distance = (vertices.first - vertex).distance;

    return distance <= (polygonCloseDistance ?? 0);
  }

  NodePolygonDrawable updateWith({
    List<Offset>? vertices,
    Offset? vertex,
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Paint? paint,
    bool? locked,
    Size? size,
    Offset? shiftOffset,
    double? polygonCloseDistance,
  }) {
    final newVertex = _shouldBeClosed(vertex) ? this.vertices.first : vertex;
    final drawable = copyWith(
      paint: paint ?? this.paint,
      vertices: newVertex != null
          ? [...this.vertices, newVertex]
          : vertices ?? this.vertices,
    );
    return NodePolygonDrawable(
      position: position ?? drawable.centroid(drawable.paint.strokeWidth),
      size: size ?? drawable.getSize(),
      vertices: drawable.vertices,
      paint: drawable.paint,
      scale: scale ?? this.scale,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      rotationAngle: rotation ?? rotationAngle,
      shiftOffset: shiftOffset ?? _shiftOffset,
      polygonCloseDistance: polygonCloseDistance ?? this.polygonCloseDistance,
    );
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  NodePolygonDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    List<Offset>? vertices,
    double? polygonCloseDistance,
  }) {
    final isPanEnd = position == null && (assists?.isEmpty ?? false);
    final newPosition = centroid(paint?.strokeWidth ?? this.paint.strokeWidth);
    final shift = (position ?? Offset.zero) - newPosition;
    return NodePolygonDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position != null ? newPosition + shift : this.position,
      polygonCloseDistance: polygonCloseDistance ?? this.polygonCloseDistance,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      size: size ?? this.size,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      vertices: vertices ?? this.vertices,
      shiftOffset: isPanEnd
          ? _shiftOffset
          : position != null
              ? shift / (scale ?? 1)
              : this.position,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    if (vertices.isEmpty) {
      final superSize = super.getSize();
      return Size(superSize.width, superSize.height);
    } else {
      return Size(width * scale, height * scale);
    }
  }

  Offset centroid([double? padding]) {
    final verticesList = List.of(vertices);
    if (isClosed) verticesList.removeLast();
    final dxSum = verticesList.map((vertex) => vertex.dx * scale).sum;
    final dySum = verticesList.map((vertex) => vertex.dy * scale).sum;
    final dx = dxSum / verticesList.length;
    final dy = dySum / verticesList.length;

    if (padding == null) return Offset(dx, dy);
    return Offset(dx + (padding / 2), dy + (padding / 2));
  }

  double get height {
    final dys = vertices.map((vertex) => vertex.dy);
    final maximum = dys.reduce(max);
    final minimum = dys.reduce(min);

    return maximum - minimum;
  }

  double get width {
    final dxs = vertices.map((vertex) => vertex.dx);
    final maximum = dxs.reduce(max);
    final minimum = dxs.reduce(min);

    return maximum - minimum;
  }

  /// Compares two [NodePolygonDrawable]s for equality.
  @override
  bool operator ==(Object other) {
    if (other is! NodePolygonDrawable) return false;
    final isSame = other.scale == scale &&
        other.position == position &&
        other.size == size &&
        other._shiftOffset == _shiftOffset &&
        other.assists.length == assists.length &&
        (const ListEquality().equals(vertices, other.vertices)) &&
        other.paint == paint;

    return isSame;
  }

  @override
  String toString() => '''NodePolygonDrawable(
vertices: $vertices,
size: $size,
hidden: $hidden,
locked: $locked,
assists: $assists,
assistPaints: ${assistPaints.entries},
position: $position,
rotationAngle: $rotationAngle,
scale: $scale,
paint: $paint,
shiftOffset: $_shiftOffset,
)''';

  @override
  int get hashCode => hashValues(
        hidden,
        locked,
        hashList(assists),
        hashList(assistPaints.entries),
        rotationAngle,
        scale,
        paint,
        position,
        size,
        vertices,
      );
}
