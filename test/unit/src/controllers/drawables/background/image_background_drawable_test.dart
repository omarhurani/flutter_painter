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
}
