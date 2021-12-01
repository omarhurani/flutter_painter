import 'dart:ui';

import '../drawables/shape/oval_drawable.dart';
import 'shape_factory.dart';

/// A [OvalDrawable] factory.
class OvalFactory extends ShapeFactory<OvalDrawable> {
  /// Creates an instance of [OvalFactory].
  OvalFactory() : super();

  /// Creates and returns a [OvalDrawable] of zero size and the passed [position] and [paint].
  @override
  OvalDrawable create(Offset position, [Paint? paint]) {
    return OvalDrawable(size: Size.zero, position: position, paint: paint);
  }
}
