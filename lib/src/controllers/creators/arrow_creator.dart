import 'dart:ui';

import '../drawables/shape/arrow_drawable.dart';
import 'shape_creator.dart';

/// A [ArrowCreator] creator.
class ArrowCreator extends ShapeCreator<ArrowDrawable>{

  /// The size of the arrow head to be used in created [ArrowDrawable]s.
  double? arrowHeadSize;

  /// Creates an instance of [ArrowCreator] with the given [paint] and [arrowHeadSize].
  ArrowCreator({Paint? paint, this.arrowHeadSize}): super(paint: paint);

  /// Creates and returns a [ArrowDrawable] with length of 0 and the passed [position].
  @override
  ArrowDrawable create(Offset position) {
    return ArrowDrawable(length: 0, position: position, paint: paint, arrowHeadSize: arrowHeadSize);
  }

}