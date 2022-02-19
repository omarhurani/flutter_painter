import 'dart:ui';

import 'package:flutter/material.dart';

import 'path_drawable.dart';

/// Free-style Drawable (hand scribble).
class FreeStyleDrawable extends PathDrawable {
  /// The color the path will be drawn with.
  final Color color;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  FreeStyleDrawable({
    required List<Offset> path,
    double strokeWidth = 1,
    this.color = Colors.black,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(path: path, strokeWidth: strokeWidth, hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  FreeStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    Color? color,
    double? strokeWidth,
  }) {
    return FreeStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @protected
  @override
  Paint get paint => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color
    ..strokeWidth = strokeWidth;

  /// Compares two [FreeStyleDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is FreeStyleDrawable &&
  //       super == other &&
  //       other.color == color &&
  //       other.strokeWidth == strokeWidth &&
  //       ListEquality().equals(other.path, path);
  // }
  //
  // @override
  // int get hashCode => hashValues(hidden, hashList(path), color, strokeWidth);
}
