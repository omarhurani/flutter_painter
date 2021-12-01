import 'dart:ui';

import '../drawables/shape/shape_drawable.dart';

/// An abstract class that defines an object that can create shape drawables.
abstract class ShapeFactory<T extends ShapeDrawable> {
  /// Creates an instance of [ShapeFactory].
  const ShapeFactory();

  /// Creates the desired shape drawable.
  /// Inheriting classes must override this method to create the appropriate [ShapeDrawable].
  T create(Offset position, [Paint? paint]);
}
