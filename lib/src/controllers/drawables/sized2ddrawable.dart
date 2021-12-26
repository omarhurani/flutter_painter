import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'object_drawable.dart';

/// A drawable that explicitly defines its size in two dimensions (width and height).
abstract class Sized2DDrawable extends ObjectDrawable {
  /// The size of the drawable.
  final Size size;

  /// Creates a new [Sized2DDrawable] with the given [size] and [painting].
  const Sized2DDrawable({
    required this.size,
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
  Sized2DDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    bool? locked,
  });

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      (size.width * scale + padding.horizontal).clamp(0, double.infinity),
      (size.height * scale + padding.vertical).clamp(0, double.infinity),
    );
  }
}
