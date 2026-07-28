import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

class MockImage extends Mock implements Image {}

void main() {
  late MockImage image;

  setUpAll(() {
    registerFallbackValue(Rect.zero);
    registerFallbackValue(Paint());
  });

  setUp(() {
    image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(50);
  });

  test('copyWith preserves and updates image opacity', () {
    final drawable = ImageDrawable(
      image: image,
      position: Offset.zero,
      opacity: 0.75,
    );

    expect(drawable.copyWith().opacity, 0.75);
    expect(drawable.copyWith(opacity: 0.25).opacity, 0.25);
  });

  test('drawObject applies opacity to the image paint', () {
    final canvas = MockCanvas();
    final drawable = ImageDrawable(
      image: image,
      position: const Offset(50, 25),
      opacity: 0.4,
    );

    drawable.drawObject(canvas, const Size(100, 50));

    final paint =
        verify(
              () => canvas.drawImageRect(image, any(), any(), captureAny()),
            ).captured.single
            as Paint;
    expect(paint.color.a, closeTo(0.4, 0.01));
  });
}
