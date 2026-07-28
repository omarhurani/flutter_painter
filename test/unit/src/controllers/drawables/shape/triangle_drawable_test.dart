import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  setUpAll(() {
    registerFallbackValue(Path());
  });

  test('draws an isosceles triangle inside its declared bounds', () {
    final canvas = MockCanvas();
    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    final drawable = TriangleDrawable(
      position: const Offset(50, 50),
      size: const Size(60, 60),
      paint: paint,
    );

    drawable.drawObject(canvas, const Size(100, 100));

    final path =
        verify(() => canvas.drawPath(captureAny(), paint)).captured.single
            as Path;
    expect(path.getBounds(), const Rect.fromLTRB(20, 20, 80, 80));
    expect(path.contains(const Offset(50, 50)), isTrue);
    expect(path.contains(const Offset(10, 10)), isFalse);
  });

  test('copyWith preserves values and applies replacements', () {
    final paint = Paint()..color = const Color(0xFFFF0000);
    final replacementPaint = Paint()..color = const Color(0xFF0000FF);
    final drawable = TriangleDrawable(
      position: const Offset(10, 20),
      size: const Size(30, 40),
      paint: paint,
    );

    final copy = drawable.copyWith(
      position: const Offset(50, 60),
      scale: 2,
      paint: replacementPaint,
    );

    expect(copy.position, const Offset(50, 60));
    expect(copy.size, drawable.size);
    expect(copy.scale, 2);
    expect(copy.paint, same(replacementPaint));
  });

  test('factory creates an empty triangle with the provided paint', () {
    final paint = Paint()..strokeWidth = 8;

    final drawable = TriangleFactory().create(const Offset(12, 34), paint);

    expect(drawable.position, const Offset(12, 34));
    expect(drawable.size, Size.zero);
    expect(drawable.paint, same(paint));
  });
}
