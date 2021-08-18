import 'package:flutter/material.dart';
import '../../controllers/drawables/background/background_drawable.dart';
import '../../controllers/drawables/drawable.dart';

import 'package:collection/collection.dart';

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
  Painter({
    this.background,
    required this.drawables,
    this.scale,
  });

  /// Paints the drawables onto the [canvas] of size [size].
  @override
  void paint(Canvas canvas, Size size) {
    // This is to allow [_scale] to be upgraded to non-nullable after checking for null
    final _scale = scale;

    // Draw the background if it was provided
    if (background != null && !background!.hidden)
      background!.draw(canvas, size);

    // If a scale size is being used, save the canvas (with the background), scale it
    // and then proceed to drawing the drawables
    if (_scale != null) {
      canvas.save();
      canvas.transform(Matrix4.identity()
          .scaled(size.width / _scale.width, size.height / _scale.height)
          .storage);
    }

    // Draw all the drawables
    for (final drawable in drawables.where((drawable) => !drawable.hidden)) {
      drawable.draw(canvas, size);
    }
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
    return oldDelegate.background != this.background ||
        !ListEquality().equals(oldDelegate.drawables, drawables);
  }
}
