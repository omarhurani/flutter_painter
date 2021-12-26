import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'object_drawable.dart';

/// A drawable that explicitly defines its size in one dimension (length).
///
/// This doesn't necessarily mean that the object only has a size in one dimension,
/// just that it defines one dimension.
abstract class Sized1DDrawable extends ObjectDrawable {
  /// The length of the drawable.
  final double length;

  /// Creates a new [Sized1DDrawable] with the given [length] and [padding].
  const Sized1DDrawable({
    required this.length,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  }) : super(
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            locked: locked,
            hidden: hidden);

  /// Getter for padding of drawable.
  ///
  /// This padding is added to the size in the [getSize] method.
  /// Implementing classes can change this getter to increase/decrease the size.
  @protected
  EdgeInsets get padding => EdgeInsets.zero;

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  Sized1DDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? length,
    bool? locked,
  });

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      (length * scale + padding.horizontal).clamp(0, double.infinity),
      padding.vertical.clamp(0, double.infinity),
    );
  }
}
