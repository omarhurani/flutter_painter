import 'dart:ui';

import 'package:flutter/material.dart' as mt;

import 'background_drawable.dart';

/// Drawable to use an image as a background.
@mt.immutable
class ImageBackgroundDrawable extends BackgroundDrawable {
  /// The image to be used as a background.
  final Image image;

  /// Creates a [ImageBackgroundDrawable] to use an image as a background.
  const ImageBackgroundDrawable({required this.image});

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    // Draw the image onto the canvas.
    canvas.drawImageRect(
        image,
        Rect.fromPoints(Offset.zero,
            Offset(image.width.toDouble(), image.height.toDouble())),
        Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
        Paint());
  }

  // /// Compares two [ImageBackgroundDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is ImageBackgroundDrawable && other.image == image;
  // }
  //
  // @override
  // int get hashCode => image.hashCode;
}

/// An extension on ui.Image to create a background drawable easily.
extension ImageBackgroundDrawableGetter on Image {
  /// Returns an [ImageBackgroundDrawable] of the current [Image].
  ImageBackgroundDrawable get backgroundDrawable =>
      ImageBackgroundDrawable(image: this);
}
