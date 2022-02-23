import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_painter/flutter_painter.dart';

/// Painter that paints the drawables.
class Painter extends CustomPainter {
  /// The background drawable to be used as a background.
  ///
  /// If it is `null`, the painter will have a transparent background.
  final BackgroundDrawable? background;

  /// List of drawables to be painted.
  final List<Drawable> drawables;

  /// Size that the drawables will be scaled to.
  /// If it is null, the drawables will be drawn without scaling.
  final Size? scale;

  /// Creates a [Painter] that paints the [drawables] onto a background [background].
  const Painter({
    required this.drawables,
    this.background,
    this.scale,
  });

  /// Paints the drawables onto the [canvas] of size [size].
  @override
  void paint(Canvas canvas, Size size) {
    // This is to allow [_scale] to be upgraded to non-nullable after checking for null
    final _scale = scale;

    // Draw the background if it was provided
    if (background != null && background!.isNotHidden) {
      background!.draw(canvas, size);
    }

    // If a scale size is being used, save the canvas (with the background), scale it
    // and then proceed to drawing the drawables
    if (_scale != null) {
      canvas.save();
      canvas.transform(Matrix4.identity()
          .scaled(size.width / _scale.width, size.height / _scale.height)
          .storage);
    }

    canvas.saveLayer(Rect.largest, Paint());

    // Draw all the drawables
    for (final drawable
        in drawables.where((drawable) => drawable.isNotHidden)) {
      drawable.draw(canvas, _scale ?? size);
    }

    canvas.restore();

    // If a scale size is being used, restore the saved canvas, which will scale all the drawn drawables
    if (_scale != null) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Unnecessary check to enforce the [Painter] type
    if (oldDelegate is! Painter) return true;

    // If the background changed, or any of the drawables changed, a repaint is needed
    return oldDelegate.background != background ||
        !const ListEquality().equals(oldDelegate.drawables, drawables);
  }
}
