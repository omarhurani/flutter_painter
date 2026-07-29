import 'dart:typed_data';

/// Inputs for the scanline flood-fill worker.
class FloodFillRequest {
  /// Raw RGBA pixels.
  final Uint8List pixels;

  /// Raster width.
  final int width;

  /// Raster height.
  final int height;

  /// Seed pixel column.
  final int seedX;

  /// Seed pixel row.
  final int seedY;

  /// Per-channel tolerance from 0 to 255.
  final int channelTolerance;

  /// Creates a flood-fill worker request.
  const FloodFillRequest({
    required this.pixels,
    required this.width,
    required this.height,
    required this.seedX,
    required this.seedY,
    required this.channelTolerance,
  });
}

/// Finds a four-connected region and returns flattened `y, startX, endX`
/// triples. This top-level function can run through Flutter's `compute`.
List<int> findFloodFillSpans(FloodFillRequest request) {
  final width = request.width;
  final height = request.height;
  final pixels = request.pixels;
  final visited = Uint8List(width * height);
  final seedOffset = (request.seedY * width + request.seedX) * 4;
  final seedRed = pixels[seedOffset];
  final seedGreen = pixels[seedOffset + 1];
  final seedBlue = pixels[seedOffset + 2];
  final seedAlpha = pixels[seedOffset + 3];
  final tolerance = request.channelTolerance;

  bool matches(int x, int y) {
    final offset = (y * width + x) * 4;
    return (pixels[offset] - seedRed).abs() <= tolerance &&
        (pixels[offset + 1] - seedGreen).abs() <= tolerance &&
        (pixels[offset + 2] - seedBlue).abs() <= tolerance &&
        (pixels[offset + 3] - seedAlpha).abs() <= tolerance;
  }

  final queue = <int>[request.seedY * width + request.seedX];
  final spans = <(int, int, int)>[];
  var queueIndex = 0;

  void enqueueMatchingSegments(int y, int startX, int endX) {
    if (y < 0 || y >= height) return;

    var x = startX;
    while (x <= endX) {
      while (x <= endX && (visited[y * width + x] != 0 || !matches(x, y))) {
        x++;
      }
      if (x > endX) return;

      queue.add(y * width + x);
      while (x <= endX && visited[y * width + x] == 0 && matches(x, y)) {
        x++;
      }
    }
  }

  while (queueIndex < queue.length) {
    final index = queue[queueIndex++];
    final y = index ~/ width;
    final x = index % width;
    if (visited[index] != 0 || !matches(x, y)) continue;

    var startX = x;
    while (startX > 0 &&
        visited[y * width + startX - 1] == 0 &&
        matches(startX - 1, y)) {
      startX--;
    }
    var endX = x;
    while (endX + 1 < width &&
        visited[y * width + endX + 1] == 0 &&
        matches(endX + 1, y)) {
      endX++;
    }

    for (var fillX = startX; fillX <= endX; fillX++) {
      visited[y * width + fillX] = 1;
    }
    spans.add((y, startX, endX));
    enqueueMatchingSegments(y - 1, startX, endX);
    enqueueMatchingSegments(y + 1, startX, endX);
  }

  spans.sort((first, second) {
    final rowComparison = first.$1.compareTo(second.$1);
    return rowComparison != 0 ? rowComparison : first.$2.compareTo(second.$2);
  });
  return <int>[
    for (final span in spans) ...<int>[span.$1, span.$2, span.$3],
  ];
}
