import 'dart:ui';

import 'package:flutter/material.dart' as mt;
import 'package:flutter/painting.dart' show Alignment, BoxFit, applyBoxFit;

import 'background_drawable.dart';

/// Drawable to use an image as a background.
@mt.immutable
class ImageBackgroundDrawable extends BackgroundDrawable {
  /// The image to be used as a background.
  final Image image;

  /// How the image should be inscribed into the available background space.
  ///
  /// Defaults to [BoxFit.fill] to preserve the original stretching behavior.
  final BoxFit fit;

  /// How to align the image within the available background space.
  final Alignment alignment;

  /// The color painted behind the image.
  ///
  /// This is visible when [fit] does not cover the entire background.
  final Color? backgroundColor;

  /// Creates a [ImageBackgroundDrawable] to use an image as a background.
  const ImageBackgroundDrawable({
    required this.image,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.backgroundColor,
  });

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    if (backgroundColor case final color?) {
      canvas.drawColor(color, BlendMode.src);
    }

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(fit, imageSize, size);
    final sourceRect = alignment.inscribe(
      fittedSizes.source,
      Offset.zero & imageSize,
    );
    final destinationRect = alignment.inscribe(
      fittedSizes.destination,
      Offset.zero & size,
    );

    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
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
