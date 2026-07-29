import 'dart:ui';

import 'path_drawable.dart';

/// One inclusive horizontal pixel span produced by a flood fill.
class FloodFillSpan {
  /// The pixel row containing this span.
  final int y;

  /// The first included pixel column.
  final int startX;

  /// The last included pixel column.
  final int endX;

  /// Creates an inclusive horizontal pixel span.
  const FloodFillSpan({
    required this.y,
    required this.startX,
    required this.endX,
  });
}

/// A compact raster-derived flood fill rendered in painter coordinates.
///
/// The original composed painter is sampled only while the fill is created.
/// The drawable stores horizontal spans rather than a full-canvas bitmap.
class FloodFillDrawable extends PathDrawable {
  /// The fill color.
  final Color color;

  /// The tolerance percentage used to create this fill.
  final int tolerance;

  /// Width of the sampled raster in pixels.
  final int pixelWidth;

  /// Height of the sampled raster in pixels.
  final int pixelHeight;

  /// Painter coordinate size represented by the sampled raster.
  final Size coordinateSize;

  /// Horizontal spans belonging to the connected filled region.
  final List<FloodFillSpan> spans;

  late final Path _fillPath = _createFillPath();

  /// The position from which the fill started.
  Offset get seed => path.single;

  /// Creates a flood-fill drawable.
  FloodFillDrawable({
    required Offset seed,
    required this.color,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.coordinateSize,
    Iterable<FloodFillSpan> spans = const <FloodFillSpan>[],
    this.tolerance = 8,
    super.strokeWidth = 1,
    super.hidden,
  }) : spans = List.unmodifiable(spans),
       super(path: <Offset>[seed]) {
    _validate();
  }

  /// Creates a copy with selected fields replaced.
  @override
  FloodFillDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
    Color? color,
    int? tolerance,
    int? pixelWidth,
    int? pixelHeight,
    Size? coordinateSize,
    Iterable<FloodFillSpan>? spans,
  }) {
    final nextPath = path ?? this.path;
    if (nextPath.length != 1) {
      throw ArgumentError.value(
        nextPath,
        'path',
        'a flood fill must contain exactly one seed position',
      );
    }
    return FloodFillDrawable(
      seed: nextPath.single,
      color: color ?? this.color,
      tolerance: tolerance ?? this.tolerance,
      pixelWidth: pixelWidth ?? this.pixelWidth,
      pixelHeight: pixelHeight ?? this.pixelHeight,
      coordinateSize: coordinateSize ?? this.coordinateSize,
      spans: spans ?? this.spans,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Paint get paint => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;

  /// Draws all filled spans in the coordinate space that was sampled.
  @override
  void draw(Canvas canvas, Size size) {
    if (spans.isEmpty) return;

    canvas.drawPath(_fillPath, paint);
  }

  Path _createFillPath() {
    final pixelScaleX = coordinateSize.width / pixelWidth;
    final pixelScaleY = coordinateSize.height / pixelHeight;
    final fillPath = Path();
    for (final span in spans) {
      fillPath.addRect(
        Rect.fromLTRB(
          span.startX * pixelScaleX,
          span.y * pixelScaleY,
          (span.endX + 1) * pixelScaleX,
          (span.y + 1) * pixelScaleY,
        ),
      );
    }
    return fillPath;
  }

  void _validate() {
    if (!seed.dx.isFinite || !seed.dy.isFinite) {
      throw ArgumentError.value(seed, 'seed', 'must be finite');
    }
    if (!coordinateSize.isFinite || coordinateSize.isEmpty) {
      throw ArgumentError.value(
        coordinateSize,
        'coordinateSize',
        'must be finite and non-empty',
      );
    }
    if (pixelWidth <= 0 || pixelHeight <= 0) {
      throw ArgumentError(
        'pixelWidth and pixelHeight must both be greater than zero',
      );
    }
    if (tolerance < 0 || tolerance > 100) {
      throw RangeError.range(tolerance, 0, 100, 'tolerance');
    }
    for (final span in spans) {
      if (span.y < 0 ||
          span.y >= pixelHeight ||
          span.startX < 0 ||
          span.endX < span.startX ||
          span.endX >= pixelWidth) {
        throw ArgumentError.value(
          span,
          'spans',
          'must stay inside the sampled pixel bounds',
        );
      }
    }
  }
}
