import 'dart:ui';

import 'package:flutter/rendering.dart';

import '../drawables/shape/rectangle_drawable.dart';
import 'shape_creator.dart';

/// A [RectangleCreator] creator.
class RectangleCreator extends ShapeCreator<RectangleDrawable>{

  /// The border radius of the [RectangleDrawable]s created by this creator.
  BorderRadius? borderRadius;

  /// Creates an instance of [RectangleCreator].
  RectangleCreator({this.borderRadius});

  /// Creates and returns a [RectangleDrawable] of zero size and the passed [position] and [paint].
  @override
  RectangleDrawable create(Offset position, [Paint? paint]) {
    final borderRadius = this.borderRadius;
    if(borderRadius != null)
      return RectangleDrawable(size: Size.zero, position: position, borderRadius: borderRadius, paint: paint);
    return RectangleDrawable(size: Size.zero, position: position, paint: paint);
  }

}