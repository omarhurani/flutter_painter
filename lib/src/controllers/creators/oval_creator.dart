import 'dart:ui';

import '../drawables/shape/oval_drawable.dart';
import 'shape_creator.dart';

/// A [OvalCreator] creator.
class OvalCreator extends ShapeCreator<OvalDrawable>{

  /// Creates an instance of [OvalCreator] with the given [paint].
  OvalCreator({Paint? paint}): super(paint: paint);

  /// Creates and returns a [OvalDrawable] of zero size and the passed [position].
  @override
  OvalDrawable create(Offset position) {
    return OvalDrawable(size: Size.zero, position: position, paint: paint);
  }

}