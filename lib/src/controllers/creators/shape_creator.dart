import 'dart:ui';

import '../drawables/shape/shape_drawable.dart';

/// An abstract class that defines an object that can create shape drawables.
abstract class ShapeCreator<T extends ShapeDrawable>{

  /// The paint to be used in the created drawable.
  final Paint? paint;

  /// Creates an instance of [ShapeCreator] with the given [paint].
  const ShapeCreator({
    Paint? paint,
  }) : paint = paint;

  /// Creates the desired shape drawable.
  /// Inheriting classes must override this method to create the appropriate [ShapeDrawable].
  T create(Offset position);
}