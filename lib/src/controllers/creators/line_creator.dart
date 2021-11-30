import 'dart:ui';

import '../drawables/shape/line_drawable.dart';
import 'shape_creator.dart';

/// A [LineDrawable] creator.
class LineCreator extends ShapeCreator<LineDrawable>{

  /// Creates an instance of [LineCreator].
  LineCreator(): super();

  /// Creates and returns a [LineDrawable] with length of 0 and the passed [position] and [paint].
  @override
  LineDrawable create(Offset position, [Paint? paint]) {
    return LineDrawable(length: 0, position: position, paint: paint);
  }

}