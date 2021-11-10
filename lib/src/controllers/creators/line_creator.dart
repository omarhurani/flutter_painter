import 'dart:ui';

import '../drawables/shape/line_drawable.dart';
import 'shape_creator.dart';

/// A [LineDrawable] creator.
class LineCreator extends ShapeCreator<LineDrawable>{

  /// Creates an instance of [LineCreator] with the given [paint].
  LineCreator({Paint? paint}): super(paint: paint);

  /// Creates and returns a [LineDrawable] with length of 0 and the passed [position].
  @override
  LineDrawable create(Offset position) {
    return LineDrawable(length: 0, position: position, paint: paint);
  }

}