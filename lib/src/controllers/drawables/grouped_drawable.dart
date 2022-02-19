import 'dart:ui';

import 'drawable.dart';

class GroupedDrawable extends Drawable {
  /// The list of drawables in this group.
  final List<Drawable> drawables;

  /// Creates a new [GroupedDrawable] with the list of [drawables].
  GroupedDrawable({
    required List<Drawable> drawables,
    bool hidden = false,
  })  : drawables = List.unmodifiable(drawables),
        super(hidden: hidden);

  /// Draw all the drawables in the group on [canvas] of [size].
  @override
  void draw(Canvas canvas, Size size) {
    for (final drawable in drawables) {
      drawable.draw(canvas, size);
    }
  }

  /// Compares two [GroupedDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is GroupedDrawable &&
  //       super == other &&
  //       ListEquality().equals(drawables, other.drawables);
  // }
  //
  // @override
  // int get hashCode => hashValues(hidden, hashList(drawables));
}
