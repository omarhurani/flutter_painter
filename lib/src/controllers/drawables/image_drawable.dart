import 'dart:ui';

import 'object_drawable.dart';

/// A drawable of an image as an object.
class ImageDrawable extends ObjectDrawable {
  /// The image to be drawn.
  final Image image;

  /// Creates a [ImageDrawable] with the given [image].
  ImageDrawable({
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool hidden = false,
    required this.image,
  }) : super(
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ImageDrawable copyWith(
      {bool? hidden,
      Set<ObjectDrawableAssist>? assists,
      Offset? position,
      double? rotation,
      double? scale,
      Image? image}) {
    return ImageDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? this.rotationAngle,
      scale: scale ?? this.scale,
      image: image ?? this.image,
    );
  }

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledSize = Offset(image.width.toDouble(), image.height.toDouble()) * scale;
    // Draw the image onto the canvas.
    canvas.drawImageRect(
        image,
        Rect.fromPoints(Offset.zero,
            Offset(image.width.toDouble(), image.height.toDouble())),
        Rect.fromPoints(position - scaledSize/2, position + scaledSize/2),
        Paint());
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      image.width * scale,
      image.height * scale,
    );
  }

  /// Compares two [ImageDrawable]s for equality.
  @override
  bool operator ==(Object other) {
    return other is ImageDrawable &&
        super == other &&
        other.image == image;
  }

  @override
  int get hashCode => hashValues(
      hidden,
      hashList(assists),
      hashList(assistPaints.entries),
      position,
      rotationAngle,
      scale,
      image);
}
