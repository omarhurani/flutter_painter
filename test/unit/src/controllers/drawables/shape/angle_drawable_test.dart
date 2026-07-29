import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  test('draws two rays and an arc for the configured sweep', () {
    final canvas = MockCanvas();
    final paint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final drawable = AngleDrawable(
      position: const Offset(50, 50),
      radius: 30,
      sweepAngle: math.pi / 2,
      arcRadius: 12,
      paint: paint,
    );

    drawable.drawObject(canvas, const Size(100, 100));

    verify(
      () => canvas.drawLine(const Offset(50, 50), const Offset(80, 50), paint),
    ).called(1);
    verify(
      () => canvas.drawLine(const Offset(50, 50), const Offset(50, 80), paint),
    ).called(1);
    verify(
      () => canvas.drawArc(
        const Rect.fromLTRB(38, 38, 62, 62),
        0,
        math.pi / 2,
        false,
        paint,
      ),
    ).called(1);
  });

  test('normalizes degree values including reflex and complete angles', () {
    final reflex = AngleDrawable(
      position: Offset.zero,
      radius: 40,
      sweepAngle: AngleDrawable.degreesToRadians(235),
    );
    final negative = reflex.copyWith(
      sweepAngle: AngleDrawable.degreesToRadians(-45),
    );
    final complete = reflex.copyWith(
      sweepAngle: AngleDrawable.degreesToRadians(360),
    );

    expect(reflex.sweepAngleDegrees, closeTo(235, 0.0001));
    expect(negative.sweepAngleDegrees, closeTo(315, 0.0001));
    expect(complete.sweepAngleDegrees, closeTo(360, 0.0001));
  });

  test('copyWith preserves geometry and applies replacements', () {
    final paint = Paint()..color = const Color(0xFFFF0000);
    final replacementPaint = Paint()..color = const Color(0xFF0000FF);
    final drawable = AngleDrawable(
      position: const Offset(10, 20),
      radius: 30,
      sweepAngle: math.pi / 4,
      arcRadius: 8,
      paint: paint,
    );

    final copy = drawable.copyWith(
      position: const Offset(50, 60),
      radius: 70,
      sweepAngle: math.pi,
      scale: 2,
      paint: replacementPaint,
    );

    expect(copy.position, const Offset(50, 60));
    expect(copy.radius, 70);
    expect(copy.sweepAngle, math.pi);
    expect(copy.arcRadius, 8);
    expect(copy.scale, 2);
    expect(copy.paint, same(replacementPaint));
    expect(copy.getSize(), const Size.square(280));
  });

  test('factory creates an empty angle with its initial geometry', () {
    final paint = Paint()..strokeWidth = 8;
    final factory = AngleFactory(
      startAngle: math.pi / 6,
      initialSweepAngle: math.pi / 3,
      arcRadius: 15,
    );

    final drawable = factory.create(const Offset(12, 34), paint);

    expect(drawable.position, const Offset(12, 34));
    expect(drawable.radius, 0);
    expect(drawable.rotationAngle, math.pi / 6);
    expect(drawable.sweepAngle, math.pi / 3);
    expect(drawable.arcRadius, 15);
    expect(drawable.paint, same(paint));
  });

  test('rejects invalid geometry', () {
    expect(
      () => AngleDrawable(position: Offset.zero, radius: -1, sweepAngle: 0),
      throwsArgumentError,
    );
    expect(
      () => AngleDrawable(
        position: Offset.zero,
        radius: 1,
        sweepAngle: double.nan,
      ),
      throwsArgumentError,
    );
    expect(
      () => AngleDrawable(
        position: Offset.zero,
        radius: 1,
        sweepAngle: 0,
        arcRadius: double.infinity,
      ),
      throwsArgumentError,
    );
  });
}
