import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/helpers/flood_fill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scanline worker handles a large bounded region', () {
    const width = 300;
    const height = 300;
    final pixels = Uint8List(width * height * 4);
    for (var offset = 0; offset < pixels.length; offset += 4) {
      pixels[offset] = 255;
      pixels[offset + 1] = 255;
      pixels[offset + 2] = 255;
      pixels[offset + 3] = 255;
    }
    for (var y = 0; y < height; y++) {
      final offset = (y * width + 150) * 4;
      pixels[offset] = 0;
      pixels[offset + 1] = 0;
      pixels[offset + 2] = 0;
    }

    final spans = findFloodFillSpans(
      FloodFillRequest(
        pixels: pixels,
        width: width,
        height: height,
        seedX: 75,
        seedY: 150,
        channelTolerance: 0,
      ),
    );

    expect(spans, hasLength(height * 3));
    expect(spans.take(3), [0, 0, 149]);
    expect(spans.skip((height - 1) * 3), [height - 1, 0, 149]);
  });

  test('renders compact spans in sampled painter coordinates', () async {
    final drawable = FloodFillDrawable(
      seed: const Offset(1, 1),
      color: const Color(0xFFFF0000),
      pixelWidth: 4,
      pixelHeight: 2,
      coordinateSize: const Size(4, 2),
      spans: const <FloodFillSpan>[
        FloodFillSpan(y: 0, startX: 0, endX: 1),
        FloodFillSpan(y: 1, startX: 1, endX: 2),
      ],
    );
    final recorder = PictureRecorder();
    drawable.draw(Canvas(recorder), const Size(4, 2));
    final image = await recorder.endRecording().toImage(4, 2);
    addTearDown(image.dispose);
    final bytes = await image.toByteData(format: ImageByteFormat.rawRgba);

    int alphaAt(int x, int y) => bytes!.getUint8((y * 4 + x) * 4 + 3);

    expect(alphaAt(0, 0), 255);
    expect(alphaAt(2, 0), 0);
    expect(alphaAt(0, 1), 0);
    expect(alphaAt(2, 1), 255);
  });

  test('copyWith preserves spans and validates replacements', () {
    const spans = <FloodFillSpan>[FloodFillSpan(y: 1, startX: 2, endX: 4)];
    final drawable = FloodFillDrawable(
      seed: const Offset(3, 1),
      color: const Color(0xFF0000FF),
      tolerance: 12,
      pixelWidth: 6,
      pixelHeight: 3,
      coordinateSize: const Size(60, 30),
      spans: spans,
    );

    expect(drawable.copyWith().spans, orderedEquals(spans));
    expect(drawable.copyWith().tolerance, 12);
    expect(
      drawable.copyWith(color: const Color(0xFF00FF00)).color,
      const Color(0xFF00FF00),
    );
    expect(
      () => drawable.copyWith(path: const <Offset>[]),
      throwsArgumentError,
    );
  });

  test('rejects invalid raster metadata and spans', () {
    expect(
      () => FloodFillDrawable(
        seed: Offset.zero,
        color: const Color(0xFF000000),
        tolerance: 101,
        pixelWidth: 1,
        pixelHeight: 1,
        coordinateSize: const Size(1, 1),
      ),
      throwsRangeError,
    );
    expect(
      () => FloodFillDrawable(
        seed: Offset.zero,
        color: const Color(0xFF000000),
        pixelWidth: 2,
        pixelHeight: 2,
        coordinateSize: const Size(2, 2),
        spans: const <FloodFillSpan>[FloodFillSpan(y: 0, startX: 0, endX: 2)],
      ),
      throwsArgumentError,
    );
  });
}
