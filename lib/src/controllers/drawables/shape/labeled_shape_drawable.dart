import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../object_drawable.dart';
import '../sized1ddrawable.dart';
import '../sized2ddrawable.dart';
import 'shape_drawable.dart';

/// Text and background styling for a label drawn on a shape.
@immutable
class ShapeLabel {
  /// The label text.
  final String text;

  /// The text style.
  final TextStyle style;

  /// The text direction.
  final TextDirection direction;

  /// The alignment used for multi-line text.
  final TextAlign textAlign;

  /// Space between the text and its optional background.
  final EdgeInsets padding;

  /// The color behind the label, or `null` for no background.
  final Color? backgroundColor;

  /// The radius of the label background corners.
  final BorderRadius borderRadius;

  /// The label offset from the shape center before rotation.
  final Offset offset;

  /// Creates a shape label.
  const ShapeLabel({
    required this.text,
    this.style = const TextStyle(fontSize: 14, color: Colors.black),
    this.direction = TextDirection.ltr,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.offset = Offset.zero,
  });

  /// Returns a copy of this label with new [text].
  ShapeLabel withText(String text) {
    return ShapeLabel(
      text: text,
      style: style,
      direction: direction,
      textAlign: textAlign,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      offset: offset,
    );
  }

  TextPainter _textPainter(double scale) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: direction,
      textScaler: TextScaler.linear(scale),
    )..layout();
  }

  Size _getSize(double scale) {
    final textPainter = _textPainter(scale);
    try {
      final scaledPadding = padding * scale;
      return Size(
        textPainter.width + scaledPadding.horizontal,
        textPainter.height + scaledPadding.vertical,
      );
    } finally {
      textPainter.dispose();
    }
  }

  Size _getCenteredBoundsSize(double scale) {
    final size = _getSize(scale);
    return Size(
      size.width + offset.dx.abs() * scale * 2,
      size.height + offset.dy.abs() * scale * 2,
    );
  }

  void _draw(Canvas canvas, Offset shapeCenter, double scale) {
    final textPainter = _textPainter(scale);
    try {
      final scaledPadding = padding * scale;
      final labelCenter = shapeCenter + offset * scale;
      final backgroundRect = Rect.fromCenter(
        center: labelCenter,
        width: textPainter.width + scaledPadding.horizontal,
        height: textPainter.height + scaledPadding.vertical,
      );
      final backgroundColor = this.backgroundColor;
      if (backgroundColor != null) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            backgroundRect,
            topLeft: borderRadius.topLeft * scale,
            topRight: borderRadius.topRight * scale,
            bottomLeft: borderRadius.bottomLeft * scale,
            bottomRight: borderRadius.bottomRight * scale,
          ),
          Paint()..color = backgroundColor,
        );
      }
      textPainter.paint(
        canvas,
        labelCenter - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    } finally {
      textPainter.dispose();
    }
  }
}

/// Common interface for one- and two-dimensional labeled shapes.
abstract interface class LabeledShapeDrawable implements ShapeDrawable {
  /// The shape used for drawing.
  ShapeDrawable get shape;

  /// The label drawn over the shape.
  ShapeLabel get label;

  /// Returns a copy with [label].
  LabeledShapeDrawable copyWithLabel(ShapeLabel label);
}

/// A labeled wrapper for a [Sized1DDrawable] shape.
class LabeledSized1DShapeDrawable extends Sized1DDrawable
    implements LabeledShapeDrawable {
  @override
  final ShapeDrawable shape;

  @override
  final ShapeLabel label;

  @override
  Paint paint;

  /// Creates a labeled one-dimensional shape.
  LabeledSized1DShapeDrawable({
    required ShapeDrawable shape,
    required this.label,
    required super.length,
    required super.position,
    Paint? paint,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : shape = _requireSized1D(shape),
       paint = paint ?? shape.paint;

  ShapeDrawable get _effectiveShape {
    final positionedShape = shape.copyWith(
      position: position,
      rotation: 0,
      scale: scale,
      paint: paint,
      assists: const <ObjectDrawableAssist>{},
      locked: locked,
      hidden: hidden,
    );
    return (positionedShape as Sized1DDrawable).copyWith(length: length)
        as ShapeDrawable;
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    _effectiveShape.drawObject(canvas, size);
    label._draw(canvas, position, scale);
  }

  @override
  Size getSize({double minWidth = 0, double maxWidth = double.infinity}) {
    final shapeSize = _effectiveShape.getSize(
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
    final labelSize = label._getCenteredBoundsSize(scale);
    return Size(
      math.max(shapeSize.width, labelSize.width),
      math.max(shapeSize.height, labelSize.height),
    );
  }

  @override
  LabeledSized1DShapeDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Map<ObjectDrawableAssist, Paint>? assistPaints,
    Offset? position,
    double? rotation,
    double? scale,
    double? length,
    Paint? paint,
    bool? locked,
    ShapeDrawable? shape,
    ShapeLabel? label,
  }) {
    return LabeledSized1DShapeDrawable(
      shape: shape ?? this.shape,
      label: label ?? this.label,
      length: length ?? this.length,
      position: position ?? this.position,
      paint: paint ?? this.paint,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      assists: assists ?? this.assists,
      assistPaints: assistPaints ?? this.assistPaints,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  LabeledSized1DShapeDrawable copyWithLabel(ShapeLabel label) {
    return copyWith(label: label);
  }

  static ShapeDrawable _requireSized1D(ShapeDrawable shape) {
    if (shape is! Sized1DDrawable) {
      throw ArgumentError.value(
        shape,
        'shape',
        'must also extend Sized1DDrawable',
      );
    }
    return shape;
  }
}

/// A labeled wrapper for a [Sized2DDrawable] shape.
class LabeledSized2DShapeDrawable extends Sized2DDrawable
    implements LabeledShapeDrawable {
  @override
  final ShapeDrawable shape;

  @override
  final ShapeLabel label;

  @override
  Paint paint;

  /// Creates a labeled two-dimensional shape.
  LabeledSized2DShapeDrawable({
    required ShapeDrawable shape,
    required this.label,
    required super.size,
    required super.position,
    Paint? paint,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : shape = _requireSized2D(shape),
       paint = paint ?? shape.paint;

  ShapeDrawable get _effectiveShape {
    final positionedShape = shape.copyWith(
      position: position,
      rotation: 0,
      scale: scale,
      paint: paint,
      assists: const <ObjectDrawableAssist>{},
      locked: locked,
      hidden: hidden,
    );
    return (positionedShape as Sized2DDrawable).copyWith(size: size)
        as ShapeDrawable;
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    _effectiveShape.drawObject(canvas, size);
    label._draw(canvas, position, scale);
  }

  @override
  Size getSize({double minWidth = 0, double maxWidth = double.infinity}) {
    final shapeSize = _effectiveShape.getSize(
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
    final labelSize = label._getCenteredBoundsSize(scale);
    return Size(
      math.max(shapeSize.width, labelSize.width),
      math.max(shapeSize.height, labelSize.height),
    );
  }

  @override
  LabeledSized2DShapeDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Map<ObjectDrawableAssist, Paint>? assistPaints,
    Offset? position,
    double? rotation,
    double? scale,
    Size? size,
    Paint? paint,
    bool? locked,
    ShapeDrawable? shape,
    ShapeLabel? label,
  }) {
    return LabeledSized2DShapeDrawable(
      shape: shape ?? this.shape,
      label: label ?? this.label,
      size: size ?? this.size,
      position: position ?? this.position,
      paint: paint ?? this.paint,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      assists: assists ?? this.assists,
      assistPaints: assistPaints ?? this.assistPaints,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  LabeledSized2DShapeDrawable copyWithLabel(ShapeLabel label) {
    return copyWith(label: label);
  }

  static ShapeDrawable _requireSized2D(ShapeDrawable shape) {
    if (shape is! Sized2DDrawable) {
      throw ArgumentError.value(
        shape,
        'shape',
        'must also extend Sized2DDrawable',
      );
    }
    return shape;
  }
}
