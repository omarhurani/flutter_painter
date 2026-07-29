import 'package:flutter/material.dart';

import 'object_drawable.dart';

/// Text Drawable
class TextDrawable extends ObjectDrawable {
  /// The text to be drawn.
  final String text;

  /// The style the text will be drawn with.
  final TextStyle style;

  /// The direction of the text to be drawn.
  final TextDirection direction;

  /// The alignment of the text within its available layout width.
  final TextAlign textAlign;

  // A text painter which will paint the text on the canvas.
  final TextPainter textPainter;

  /// Creates a [TextDrawable] to draw [text].
  ///
  /// The path will be drawn with the passed [style] if provided.
  TextDrawable({
    required this.text,
    required super.position,
    double rotation = 0,
    super.scale,
    this.style = const TextStyle(fontSize: 14, color: Colors.black),
    this.direction = TextDirection.ltr,
    this.textAlign = TextAlign.center,
    super.locked,
    super.hidden,
    super.assists,
    super.assistPaints,
  }) : textPainter = TextPainter(
         text: TextSpan(text: text, style: style),
         textAlign: textAlign,
         textScaler: TextScaler.linear(scale),
         textDirection: direction,
       ),
       super(rotationAngle: rotation);

  /// Draws the text on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    // Render the text according to the size of the canvas taking the scale in mind
    textPainter.layout(maxWidth: size.width * scale);

    // Paint the text on the canvas
    // It is shifted back by half of its width and height to be drawn in the center
    textPainter.paint(
      canvas,
      position - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  TextDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Map<ObjectDrawableAssist, Paint>? assistPaints,
    String? text,
    Offset? position,
    double? rotation,
    double? scale,
    TextStyle? style,
    bool? locked,
    TextDirection? direction,
    TextAlign? textAlign,
  }) {
    return TextDrawable(
      text: text ?? this.text,
      position: position ?? this.position,
      rotation: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      style: style ?? this.style,
      direction: direction ?? this.direction,
      textAlign: textAlign ?? this.textAlign,
      assists: assists ?? this.assists,
      assistPaints: assistPaints ?? this.assistPaints,
      hidden: hidden ?? this.hidden,
      locked: locked ?? this.locked,
    );
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    // Generate the text as a visual layout
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth * scale);
    return textPainter.size;
  }

  /// Compares two [TextDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is TextDrawable &&
  //       super == other &&
  //       other.text == text &&
  //       other.style == style &&
  //       other.direction == direction &&
  //       other.textAlign == textAlign;
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
  //     style,
  //     direction,
  //     textAlign);
}
