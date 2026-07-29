import 'dart:ui';

import '../drawables/path/path_drawable.dart';

/// Creates custom [PathDrawable]s for free-style drawing gestures.
abstract class FreeStyleFactory<T extends PathDrawable> {
  /// Creates a [FreeStyleFactory].
  const FreeStyleFactory();

  /// Creates the first drawable for a free-style gesture.
  ///
  /// The returned drawable's [PathDrawable.copyWith] implementation must
  /// preserve its runtime type when the painter appends points to [path].
  T create({
    required List<Offset> path,
    required Color color,
    required double strokeWidth,
  });
}
