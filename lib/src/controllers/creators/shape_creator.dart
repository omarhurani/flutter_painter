import 'dart:ui';

import '../drawables/shape/shape_drawable.dart';

/// An abstract class that defines an object that can create shape drawables.
abstract class ShapeCreator<T extends ShapeDrawable>{

  /// Creates an instance of [ShapeCreator] with the given [paint].
  const ShapeCreator();

  /// Creates the desired shape drawable.
  /// Inheriting classes must override this method to create the appropriate [ShapeDrawable].
  T create(Offset position, [Paint? paint]);
}