import 'dart:math' as math;
import 'dart:ui';

import 'object_drawable.dart';

/// A transformable group of object drawables.
///
/// The child [drawables] use coordinates local to the center of the group.
/// Create groups from painter-coordinate drawables with
/// [ObjectGroupDrawable.fromDrawables].
class ObjectGroupDrawable extends ObjectDrawable {
  /// The objects contained by this group, in paint order.
  final List<ObjectDrawable> drawables;

  late final List<ObjectDrawable> _worldDrawables = _createWorldDrawables();

  @override
  bool get erasable => drawables.every((drawable) => drawable.erasable);

  ObjectGroupDrawable._({
    required List<ObjectDrawable> drawables,
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  }) : drawables = List.unmodifiable(drawables);

  /// Creates a group from [drawables] positioned in painter coordinates.
  ///
  /// The group is centered on the combined visual bounds of its children.
  /// Child layout assists are cleared because assists apply to the group while
  /// it is being transformed.
  factory ObjectGroupDrawable.fromDrawables({
    required Iterable<ObjectDrawable> drawables,
    double maxWidth = double.infinity,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  }) {
    final values = List<ObjectDrawable>.from(drawables);
    if (values.isEmpty) {
      throw ArgumentError.value(
        drawables,
        'drawables',
        'must contain at least one object drawable',
      );
    }

    final position = _boundsOf(values, maxWidth: maxWidth).center;
    final localDrawables = values
        .map(
          (drawable) => drawable.copyWith(
            position: drawable.position - position,
            assists: const <ObjectDrawableAssist>{},
          ),
        )
        .toList();

    return ObjectGroupDrawable._(
      drawables: localDrawables,
      position: position,
      rotationAngle: rotationAngle,
      scale: scale,
      assists: assists,
      assistPaints: assistPaints,
      locked: locked,
      hidden: hidden,
    );
  }

  /// Creates a group from children already expressed in group-local space.
  ///
  /// This constructor is useful for restoring previously normalized group
  /// data. Use [ObjectGroupDrawable.fromDrawables] for objects positioned in
  /// painter coordinates.
  factory ObjectGroupDrawable.fromLocalDrawables({
    required Iterable<ObjectDrawable> drawables,
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
  }) {
    final values = List<ObjectDrawable>.from(drawables);
    if (values.isEmpty) {
      throw ArgumentError.value(
        drawables,
        'drawables',
        'must contain at least one object drawable',
      );
    }
    return ObjectGroupDrawable._(
      drawables: values,
      position: position,
      rotationAngle: rotationAngle,
      scale: scale,
      assists: assists,
      assistPaints: assistPaints,
      locked: locked,
      hidden: hidden,
    );
  }

  /// Returns the children transformed back into painter coordinates.
  List<ObjectDrawable> toWorldDrawables() => _worldDrawables;

  List<ObjectDrawable> _createWorldDrawables() {
    final cosine = math.cos(rotationAngle);
    final sine = math.sin(rotationAngle);
    return List.unmodifiable(
      drawables.map((drawable) {
        final local = drawable.position * scale;
        final rotated = Offset(
          local.dx * cosine - local.dy * sine,
          local.dx * sine + local.dy * cosine,
        );
        return drawable.copyWith(
          position: position + rotated,
          rotation: _normalizedAngle(drawable.rotationAngle + rotationAngle),
          scale: drawable.scale * scale,
          assists: const <ObjectDrawableAssist>{},
        );
      }),
    );
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    for (final drawable in toWorldDrawables().where(
      (drawable) => drawable.isNotHidden,
    )) {
      drawable.draw(canvas, size);
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    drawAssists(canvas, size);
    drawObject(canvas, size);
  }

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final size = _boundsOf(drawables, maxWidth: maxWidth).size * scale;
    return Size(
      size.width.clamp(minWidth, double.infinity),
      size.height.clamp(0, double.infinity),
    );
  }

  @override
  ObjectGroupDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Map<ObjectDrawableAssist, Paint>? assistPaints,
    Offset? position,
    double? rotation,
    double? scale,
    bool? locked,
  }) {
    return ObjectGroupDrawable._(
      drawables: drawables,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      assists: assists ?? this.assists,
      assistPaints: assistPaints ?? this.assistPaints,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
    );
  }

  static Rect _boundsOf(
    Iterable<ObjectDrawable> drawables, {
    double maxWidth = double.infinity,
  }) {
    Rect? bounds;
    for (final drawable in drawables) {
      final size = drawable.getSize(maxWidth: maxWidth);
      final cosine = math.cos(drawable.rotationAngle).abs();
      final sine = math.sin(drawable.rotationAngle).abs();
      final rotatedSize = Size(
        size.width * cosine + size.height * sine,
        size.width * sine + size.height * cosine,
      );
      final drawableBounds = Rect.fromCenter(
        center: drawable.position,
        width: rotatedSize.width,
        height: rotatedSize.height,
      );
      bounds = bounds?.expandToInclude(drawableBounds) ?? drawableBounds;
    }
    return bounds ?? Rect.zero;
  }

  static double _normalizedAngle(double angle) {
    var result = angle.remainder(math.pi * 2);
    if (result < 0) result += math.pi * 2;
    return result;
  }
}
