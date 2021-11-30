import 'dart:ui';

import '../drawables/shape/oval_drawable.dart';
import 'shape_creator.dart';

/// A [OvalCreator] creator.
class OvalCreator extends ShapeCreator<OvalDrawable>{

  /// Creates an instance of [OvalCreator].
  OvalCreator(): super();

  /// Creates and returns a [OvalDrawable] of zero size and the passed [position] and [paint].
  @override
  OvalDrawable create(Offset position, [Paint? paint]) {
    return OvalDrawable(size: Size.zero, position: position, paint: paint);
  }

}