import 'dart:ui';
import 'package:flutter/material.dart';

import 'drawable.dart';

import 'dart:math';

/// An abstract drawable that can be moved and rotated and scaled.
abstract class ObjectDrawable extends Drawable {
  /// Default paint used for horizontal and vertical assist lines.
  static final Paint defaultAssistPaint = Paint()
    ..strokeWidth = 1.5
    ..color = Colors.blue;

  /// Default paint used for rotational assist lines.
  static final defaultRotationAssistPaint = Paint()
    ..strokeWidth = 1.5
    ..color = Colors.pink;

  /// The smallest value for the scale of an object drawable.
  static const double minScale = 0.001;

  @Deprecated(
      "min_scale is deprecated to conform with flutter_lints, use minScale instead")
  // ignore: non_constant_identifier_names
  double get min_scale => minScale;

  /// The location of the object to be painted.
  final Offset position;

  /// The scale of the object to be painted.
  final double scale;

  /// The rotation of the object to be painted in radians.
  ///
  /// The rotation is clockwise.
  final double rotationAngle;

  /// The current assist lines the object has.
  ///
  /// These are lines drawn behind the object when it is in special positions
  /// (for example: horizontal center, vertical center, right angle).
  final Set<ObjectDrawableAssist> assists;

  /// The paint to be used for each assist type.
  ///
  /// By default, [defaultAssistPaint] will be used for
  /// [ObjectDrawableAssist.horizontal] and [ObjectDrawableAssist.vertical]
  /// and [defaultRotationAssistPaint] will be used for [ObjectDrawableAssist.rotation].
  final Map<ObjectDrawableAssist, Paint> assistPaints;

  /// Defines if the object drawable is locked or not.
  /// If it is locked, it won't be movable, scalable or re-sizable using the UI.
  final bool locked;

  /// Default constructor for [ObjectDrawable].
  const ObjectDrawable({
    required this.position,
    this.rotationAngle = 0,
    double scale = 1,
    this.assists = const <ObjectDrawableAssist>{},
    this.assistPaints = const <ObjectDrawableAssist, Paint>{},
    this.locked = false,
    bool hidden = false,
  })  : scale = scale < minScale ? minScale : scale,
        super(hidden: hidden);

  /// Draws any assist lines that the object has on [canvas] with [size].
  void drawAssists(Canvas canvas, Size size) {
    // Draw the rotation assist line
    //
    // This assist line passes through the center point of the object
    // and extends according to the object's rotation angle
    if (assists.contains(ObjectDrawableAssist.rotation)) {
      // Calculate the tangent of the angle
      final angleTan = tan(rotationAngle);
      // Calculate the points at which a line passing through the object's center
      // with an angle tangent crosses the borders of the drawing size
      final intersections =
          _calculateBoxIntersections(position, angleTan, size);

      if (intersections.length == 2) {
        // Should be redundant, added for safety
        // Draw the line between the two points on the size border
        canvas.drawLine(
          intersections[0],
          intersections[1],
          assistPaints[ObjectDrawableAssist.rotation] ??
              defaultRotationAssistPaint,
        );
      }
    }

    // Draw the horizontal assist line
    //
    // This assist line passes through the center point of the object
    // and extends horizontally (with a constant dy value)
    if (assists.contains(ObjectDrawableAssist.horizontal)) {
      canvas.drawLine(Offset(0, position.dy), Offset(size.width, position.dy),
          assistPaints[ObjectDrawableAssist.horizontal] ?? defaultAssistPaint);
    }

    // Draw the vertical assist line
    //
    // This assist line passes through the center point of the object
    // and extends vertically (with a constant dx value)
    if (assists.contains(ObjectDrawableAssist.vertical)) {
      canvas.drawLine(Offset(position.dx, 0), Offset(position.dx, size.height),
          assistPaints[ObjectDrawableAssist.horizontal] ?? defaultAssistPaint);
    }
  }

  /// Draws the object on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    // Draw the assist lines
    drawAssists(canvas, size);

    // Save the canvas before transforming it, to be restored after the object is drawn
    canvas.save();

    // Translate and rotate the canvas according to the position of the object
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-position.dx, -position.dy);

    // Draw the object
    drawObject(canvas, size);

    // Restore the canvas from the translation and rotation
    canvas.restore();
  }

  /// Abstract method to draw the object.
  ///
  /// Implementing/extending classes must implement its behavior to draw the desired object.
  void drawObject(Canvas canvas, Size size);

  /// Abstract method to get the size of the rendered object.
  ///
  /// Implementing/extending classes must implement its behavior to provide the correct size
  /// This size is used by the UI to detect movement, pinching and rotating actions.
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity});

  /// Compares two [ObjectDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is ObjectDrawable &&
  //       super == other &&
  //       other.position == position &&
  //       other.rotationAngle == rotationAngle &&
  //       other.scale == scale &&
  //       SetEquality().equals(other.assists, assists) &&
  //       MapEquality().equals(other.assistPaints, assistPaints);
  // }

  /// Creates a copy of this but with the given fields replaced with the new values.
  ///
  /// Extending classes must at least have the defined named parameters in their method
  /// implementation, but can add any extra parameters relevant to that class.
  ObjectDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    bool? locked,
  });

  // @override
  // int get hashCode => hashValues(hidden, locked, hashList(assists),
  //     hashList(assistPaints.entries), position, rotationAngle);

  /// Calculates the intersection points between a line passing through point [point]
  /// with an angle tangent [angleTan] with the rectangular box of size [size].
  List<Offset> _calculateBoxIntersections(
      Offset point, double angleTan, Size size) {
    final intersections = <Offset>[];

    // Calculate if there is an intersection with the top edge
    double coordinate = point.dx - (point.dy / angleTan);
    if (coordinate >= 0 && coordinate <= size.width) {
      intersections.add(Offset(coordinate, 0));
    }

    // Calculate if there is an intersection with the bottom edge
    coordinate = (size.height - point.dy) / angleTan + point.dx;
    if (coordinate >= 0 && coordinate <= size.width) {
      intersections.add(Offset(coordinate, size.height));
    }

    // Calculate if there is an intersection with the right edge
    coordinate = point.dy - angleTan * point.dx;
    if (coordinate >= 0 && coordinate <= size.height) {
      intersections.add(Offset(0, coordinate));
    }

    // Calculate if there is an intersection with the left edge
    coordinate = angleTan * (size.width - point.dx) + point.dy;
    if (coordinate >= 0 && coordinate <= size.height) {
      intersections.add(Offset(size.width, coordinate));
    }

    // Interactions should always have 2 results
    return intersections;
  }
}

/// Defines the different types of assist lines objects might have.
enum ObjectDrawableAssist {
  // Horizontal assist line.
  //
  // This assist line passes through the center point of the object
  // and extends horizontally (with a constant dy value).
  horizontal,

  // Vertical assist line.
  //
  // This assist line passes through the center point of the object
  // and extends vertically (with a constant dx value).
  vertical,

  // Rotation assist line.
  //
  // This assist line passes through the center point of the object
  // and extends according to the object's rotation angle.
  rotation,
}
