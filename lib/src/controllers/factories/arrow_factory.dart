import 'dart:ui';

import '../drawables/shape/arrow_drawable.dart';
import 'shape_factory.dart';

/// A [ArrowDrawable] factory.
class ArrowFactory extends ShapeFactory<ArrowDrawable> {
  /// The size of the arrow head to be used in created [ArrowDrawable]s.
  double? arrowHeadSize;

  /// Creates an instance of [ArrowFactory] with the given [arrowHeadSize].
  ArrowFactory({this.arrowHeadSize}) : super();

  /// Creates and returns a [ArrowDrawable] with length of 0 and the passed [position] and [paint].
  @override
  ArrowDrawable create(Offset position, [Paint? paint]) {
    return ArrowDrawable(
        length: 0,
        position: position,
        paint: paint,
        arrowHeadSize: arrowHeadSize);
  }
}
