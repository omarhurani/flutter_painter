import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Alignment, BoxFit, Colors;
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements ui.Canvas {}

class MockImage extends Mock implements ui.Image {}

void main() {
  late MockCanvas canvas;
  late MockImage image;

  setUpAll(() {
    registerFallbackValue(ui.Rect.zero);
    registerFallbackValue(ui.Paint());
    registerFallbackValue(Colors.transparent);
    registerFallbackValue(ui.BlendMode.src);
  });

  setUp(() {
    canvas = MockCanvas();
    image = MockImage();
    when(() => image.width).thenReturn(800);
    when(() => image.height).thenReturn(400);
  });

  test('preserves the original stretched image background by default', () {
    final drawable = ImageBackgroundDrawable(image: image);

    drawable.draw(canvas, const ui.Size(800, 1200));

    verify(
      () => canvas.drawImageRect(
        image,
        const ui.Rect.fromLTWH(0, 0, 800, 400),
        const ui.Rect.fromLTWH(0, 0, 800, 1200),
        any(),
      ),
    );
    verifyNever(() => canvas.drawColor(any(), any()));
    verifyNever(() => canvas.save());
    verifyNever(() => canvas.rotate(any()));
  });

  test('paints a color behind a contained and centered image', () {
    final drawable = ImageBackgroundDrawable(
      image: image,
      fit: BoxFit.contain,
      backgroundColor: Colors.white,
    );

    drawable.draw(canvas, const ui.Size(800, 1200));

    verifyInOrder([
      () => canvas.drawColor(Colors.white, ui.BlendMode.src),
      () => canvas.drawImageRect(
        image,
        const ui.Rect.fromLTWH(0, 0, 800, 400),
        const ui.Rect.fromLTWH(0, 400, 800, 400),
        any(),
      ),
    ]);
  });

  test('uses alignment when the fitted image leaves empty space', () {
    final drawable = ImageBackgroundDrawable(
      image: image,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );

    drawable.draw(canvas, const ui.Size(800, 1200));

    verify(
      () => canvas.drawImageRect(
        image,
        const ui.Rect.fromLTWH(0, 0, 800, 400),
        const ui.Rect.fromLTWH(0, 800, 800, 400),
        any(),
      ),
    );
  });

  test('rotates the background clockwise without changing canvas bounds', () {
    final drawable = ImageBackgroundDrawable(image: image, quarterTurns: 1);

    drawable.draw(canvas, const ui.Size(800, 1200));

    verifyInOrder([
      () => canvas.save(),
      () => canvas.translate(400, 600),
      () => canvas.rotate(math.pi / 2),
      () => canvas.drawImageRect(
        image,
        const ui.Rect.fromLTWH(0, 0, 800, 400),
        const ui.Rect.fromLTWH(-600, -400, 1200, 800),
        any(),
      ),
      () => canvas.restore(),
    ]);
  });

  test('keeps alignment relative to the visible canvas after rotation', () {
    final drawable = ImageBackgroundDrawable(
      image: image,
      fit: BoxFit.contain,
      alignment: Alignment.topLeft,
      quarterTurns: 1,
    );

    drawable.draw(canvas, const ui.Size(800, 1200));

    verify(
      () => canvas.drawImageRect(
        image,
        const ui.Rect.fromLTWH(0, 0, 800, 400),
        const ui.Rect.fromLTWH(-600, -200, 1200, 600),
        any(),
      ),
    );
  });

  test('normalizes positive and negative quarter turns', () {
    ImageBackgroundDrawable(
      image: image,
      quarterTurns: 5,
    ).draw(canvas, const ui.Size(800, 1200));

    verify(() => canvas.rotate(math.pi / 2));
    reset(canvas);

    ImageBackgroundDrawable(
      image: image,
      quarterTurns: -1,
    ).draw(canvas, const ui.Size(800, 1200));

    verify(() => canvas.rotate(3 * math.pi / 2));
  });

  test('rotated preserves configuration and accumulates turns', () {
    final drawable = ImageBackgroundDrawable(
      image: image,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      backgroundColor: Colors.white,
      quarterTurns: -1,
    );

    final rotated = drawable.rotated(2);

    expect(rotated.image, same(image));
    expect(rotated.fit, BoxFit.contain);
    expect(rotated.alignment, Alignment.bottomCenter);
    expect(rotated.backgroundColor, Colors.white);
    expect(rotated.quarterTurns, 1);
  });
}
