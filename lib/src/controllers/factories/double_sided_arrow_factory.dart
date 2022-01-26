import 'dart:ui';

import '../drawables/shape/double_sided_arrow_drawable.dart';
import 'shape_factory.dart';

/// A [DoubleSidedArrowFactory] factory.
class DoubleSidedArrowFactory extends ShapeFactory<DoubleSidedArrowDrawable> {
  /// The size of the arrow head to be used in created [DoubleSidedArrowDrawable]s.
  double? arrowHeadSize;

  /// Creates an instance of [DoubleSidedArrowFactory] with the given [arrowHeadSize].
  DoubleSidedArrowFactory({this.arrowHeadSize}) : super();

  /// Creates and returns a [DoubleSidedArrowDrawable] with length of 0 and the passed [position] and [paint].
  @override
  DoubleSidedArrowDrawable create(Offset position, [Paint? paint]) {
    return DoubleSidedArrowDrawable(
        length: 0,
        position: position,
        paint: paint,
        arrowHeadSize: arrowHeadSize);
  }
}
