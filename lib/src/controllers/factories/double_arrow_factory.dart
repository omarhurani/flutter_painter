import 'dart:ui';

import '../drawables/shape/double_arrow_drawable.dart';
import 'shape_factory.dart';

/// A [DoubleArrowFactory] factory.
class DoubleArrowFactory extends ShapeFactory<DoubleArrowDrawable> {
  /// The size of the arrow head to be used in created [DoubleArrowDrawable]s.
  double? arrowHeadSize;

  /// Creates an instance of [DoubleArrowFactory] with the given [arrowHeadSize].
  DoubleArrowFactory({this.arrowHeadSize}) : super();

  /// Creates and returns a [DoubleArrowDrawable] with length of 0 and the passed [position] and [paint].
  @override
  DoubleArrowDrawable create(Offset position, [Paint? paint]) {
    return DoubleArrowDrawable(
        length: 0,
        position: position,
        paint: paint,
        arrowHeadSize: arrowHeadSize);
  }
}
