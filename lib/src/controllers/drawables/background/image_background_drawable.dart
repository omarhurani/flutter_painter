import 'dart:math' as math;
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

  /// The number of clockwise quarter turns applied to the background image.
  ///
  /// Only the image is rotated; the painter and its drawables keep their
  /// original coordinate space.
  final int quarterTurns;

  /// Creates a [ImageBackgroundDrawable] to use an image as a background.
  const ImageBackgroundDrawable({
    required this.image,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.backgroundColor,
    this.quarterTurns = 0,
  });

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    if (backgroundColor case final color?) {
      canvas.drawColor(color, BlendMode.src);
    }

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final normalizedQuarterTurns = quarterTurns % 4;
    if (normalizedQuarterTurns == 0) {
      _drawImage(canvas, imageSize, Offset.zero & size);
      return;
    }

    final isSideways = normalizedQuarterTurns.isOdd;
    final rotatedSize = isSideways ? size.flipped : size;
    final unrotatedAlignment = switch (normalizedQuarterTurns) {
      1 => Alignment(alignment.y, -alignment.x),
      2 => Alignment(-alignment.x, -alignment.y),
      3 => Alignment(-alignment.y, alignment.x),
      _ => alignment,
    };

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(normalizedQuarterTurns * math.pi / 2);
    _drawImage(
      canvas,
      imageSize,
      Rect.fromCenter(
        center: Offset.zero,
        width: rotatedSize.width,
        height: rotatedSize.height,
      ),
      imageAlignment: unrotatedAlignment,
    );
    canvas.restore();
  }

  void _drawImage(
    Canvas canvas,
    Size imageSize,
    Rect destinationBounds, {
    Alignment? imageAlignment,
  }) {
    final effectiveAlignment = imageAlignment ?? alignment;
    final fittedSizes = applyBoxFit(fit, imageSize, destinationBounds.size);
    final sourceRect = effectiveAlignment.inscribe(
      fittedSizes.source,
      Offset.zero & imageSize,
    );
    final destinationRect = effectiveAlignment.inscribe(
      fittedSizes.destination,
      destinationBounds,
    );

    canvas.drawImageRect(image, sourceRect, destinationRect, Paint());
  }

  /// Returns a copy rotated by [quarterTurns] additional clockwise turns.
  ImageBackgroundDrawable rotated([int quarterTurns = 1]) {
    return ImageBackgroundDrawable(
      image: image,
      fit: fit,
      alignment: alignment,
      backgroundColor: backgroundColor,
      quarterTurns: this.quarterTurns + quarterTurns,
    );
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
