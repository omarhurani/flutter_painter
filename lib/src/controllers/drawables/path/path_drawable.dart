import 'dart:ui';

import 'package:flutter/material.dart';

import '../drawable.dart';

/// Free-style Drawable (hand scribble).
abstract class PathDrawable extends Drawable {
  /// List of points representing the path to draw.
  final List<Offset> path;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  /// Creates a [PathDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [strokeWidth] if provided.
  PathDrawable({
    required this.path,
    this.strokeWidth = 1,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  PathDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
  });

  @protected
  Paint get paint;

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    // Create a UI path to draw
    final path = Path();

    // Start path from the first point
    path.moveTo(this.path[0].dx, this.path[0].dy);
    path.lineTo(this.path[0].dx, this.path[0].dy);

    // Draw a line between each point on the free path
    this.path.sublist(1).forEach((point) {
      path.lineTo(point.dx, point.dy);
    });

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }
}
