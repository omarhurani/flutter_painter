import 'dart:ui';

import 'object_drawable.dart';

/// The clipping shape used by an [ImageDrawable].
enum ImageDrawableShape {
  /// Clips the image to its rectangular bounds.
  rectangle,

  /// Clips the image to an oval inscribed in its bounds.
  oval,
}

/// A drawable of an image as an object.
class ImageDrawable extends ObjectDrawable {
  /// The image to be drawn.
  final Image image;

  /// An optional application-defined tag for identifying this image.
  ///
  /// This is useful for distinguishing sticker types and is preserved when
  /// the drawable is copied by object interactions.
  final String? tag;

  /// The source pixels from [image] that are drawn.
  ///
  /// This rectangle is expressed in image pixel coordinates and must be
  /// finite, non-empty, and contained by [fullSourceRect].
  final Rect sourceRect;

  /// Whether this drawable renders less than the full source image.
  bool get isCropped => sourceRect != fullSourceRect(image);

  /// Whether the image is flipped or not.
  final bool flipped;

  /// The opacity used to draw the image, between 0 (transparent) and 1 (opaque).
  final double opacity;

  /// The standard deviation of the image blur in logical pixels.
  ///
  /// A value of zero disables blur. Use a cropped [sourceRect] and position the
  /// drawable over the matching background area to obscure source-image
  /// pixels in rendered output.
  final double blurSigma;

  /// The shape used to clip this image.
  final ImageDrawableShape shape;

  /// Whether free-style erasing can affect this image.
  ///
  /// Non-erasable images remain selectable and movable in erase mode.
  @override
  final bool erasable;

  /// Creates an [ImageDrawable] with the given [image].
  ImageDrawable({
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
    required this.image,
    this.tag,
    Rect? sourceRect,
    this.flipped = false,
    double opacity = 1,
    double blurSigma = 0,
    this.shape = ImageDrawableShape.rectangle,
    this.erasable = true,
  }) : assert(opacity.isFinite && opacity >= 0 && opacity <= 1),
       opacity = opacity.isFinite ? opacity.clamp(0.0, 1.0) : 1,
       blurSigma = _validateBlurSigma(blurSigma),
       sourceRect = _validateSourceRect(image, sourceRect);

  /// Creates an [ImageDrawable] with the given [image], and calculates the scale based on the given [size].
  /// The scale will be calculated such that the size of the drawable fits into the provided size.
  ///
  /// For example, if the image was 512x256 and the provided size was 128x128, the scale would be 0.25,
  /// fitting the width of the image into the size (128x64).
  ImageDrawable.fittedToSize({
    required Offset position,
    required Size size,
    double rotationAngle = 0,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    required Image image,
    String? tag,
    Rect? sourceRect,
    bool flipped = false,
    double opacity = 1,
    double blurSigma = 0,
    ImageDrawableShape shape = ImageDrawableShape.rectangle,
    bool erasable = true,
  }) : this(
         position: position,
         rotationAngle: rotationAngle,
         scale: _calculateScaleFittedToSize(
           sourceRect?.size ?? fullSourceRect(image).size,
           size,
         ),
         assists: assists,
         assistPaints: assistPaints,
         image: image,
         tag: tag,
         sourceRect: sourceRect,
         flipped: flipped,
         opacity: opacity,
         blurSigma: blurSigma,
         shape: shape,
         erasable: erasable,
         hidden: hidden,
         locked: locked,
       );

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ImageDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Map<ObjectDrawableAssist, Paint>? assistPaints,
    Offset? position,
    double? rotation,
    double? scale,
    Image? image,
    String? tag,
    Rect? sourceRect,
    bool? flipped,
    double? opacity,
    double? blurSigma,
    ImageDrawableShape? shape,
    bool? erasable,
    bool? locked,
  }) {
    final nextImage = image ?? this.image;
    final nextSourceRect =
        sourceRect ?? (image != null && !isCropped ? null : this.sourceRect);

    return ImageDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      assistPaints: assistPaints ?? this.assistPaints,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      image: nextImage,
      tag: tag ?? this.tag,
      sourceRect: nextSourceRect,
      flipped: flipped ?? this.flipped,
      opacity: opacity ?? this.opacity,
      blurSigma: blurSigma ?? this.blurSigma,
      shape: shape ?? this.shape,
      erasable: erasable ?? this.erasable,
      locked: locked ?? this.locked,
    );
  }

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledSize = Offset(sourceRect.width, sourceRect.height) * scale;
    final position = this.position.scale(flipped ? -1 : 1, 1);
    final destinationRect = Rect.fromPoints(
      position - scaledSize / 2,
      position + scaledSize / 2,
    );

    if (flipped) canvas.scale(-1, 1);

    canvas.save();
    switch (shape) {
      case ImageDrawableShape.rectangle:
        canvas.clipRect(destinationRect);
      case ImageDrawableShape.oval:
        canvas.clipPath(Path()..addOval(destinationRect));
    }

    final paint = Paint()..color = Color.fromRGBO(255, 255, 255, opacity);
    if (blurSigma > 0) {
      paint
        ..filterQuality = FilterQuality.high
        ..imageFilter = ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.clamp,
        );
    }

    canvas.drawImageRect(image, sourceRect, destinationRect, paint);
    canvas.restore();
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return sourceRect.size * scale;
  }

  /// Returns the rectangle containing every pixel in [image].
  static Rect fullSourceRect(Image image) {
    return Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  }

  /// Compares two [ImageDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is ImageDrawable &&
  //       super == other &&
  //       other.image == image;
  // }
  //
  // @override
  // int get hashCode => hashValues(
  //     hidden,
  //     hashList(assists),
  //     hashList(assistPaints.entries),
  //     position,
  //     rotationAngle,
  //     scale,
  //     image);

  static double _calculateScaleFittedToSize(Size sourceSize, Size size) {
    if (sourceSize.width >= sourceSize.height) {
      return size.width / sourceSize.width;
    } else {
      return size.height / sourceSize.height;
    }
  }

  static Rect _validateSourceRect(Image image, Rect? sourceRect) {
    final rect = sourceRect ?? fullSourceRect(image);
    if (!rect.isFinite ||
        rect.width <= 0 ||
        rect.height <= 0 ||
        rect.left < 0 ||
        rect.top < 0 ||
        rect.right > image.width ||
        rect.bottom > image.height) {
      throw ArgumentError.value(
        sourceRect,
        'sourceRect',
        'must be a finite, non-empty rectangle inside the image bounds',
      );
    }
    return rect;
  }

  static double _validateBlurSigma(double blurSigma) {
    if (!blurSigma.isFinite || blurSigma < 0) {
      throw ArgumentError.value(
        blurSigma,
        'blurSigma',
        'must be finite and non-negative',
      );
    }
    return blurSigma;
  }
}
