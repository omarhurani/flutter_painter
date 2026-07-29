import 'dart:ui' hide TextStyle;

import 'package:flutter/painting.dart' show TextStyle;
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const label = ShapeLabel(text: '120 mm');

  test('factory wraps one- and two-dimensional shapes', () {
    final paint = Paint()
      ..color = const Color(0xFF1565C0)
      ..strokeWidth = 4;
    final oneDimensional = LabeledShapeFactory(
      factory: DoubleArrowFactory(),
      label: label,
    ).create(const Offset(10, 20), paint);
    final twoDimensional = LabeledShapeFactory(
      factory: RectangleFactory(),
      label: label,
    ).create(const Offset(30, 40), paint);

    expect(oneDimensional, isA<LabeledSized1DShapeDrawable>());
    expect(oneDimensional.shape, isA<DoubleArrowDrawable>());
    expect(oneDimensional.label, same(label));
    expect(oneDimensional.paint, same(paint));

    expect(twoDimensional, isA<LabeledSized2DShapeDrawable>());
    expect(twoDimensional.shape, isA<RectangleDrawable>());
    expect(twoDimensional.label, same(label));
    expect(twoDimensional.paint, same(paint));
  });

  test('copyWith preserves the wrapped shape and updates label geometry', () {
    final assistPaint = Paint()..color = const Color(0xFF00FF00);
    final drawable =
        LabeledShapeFactory(
              factory: DoubleArrowFactory(),
              label: label,
            ).create(Offset.zero)
            as LabeledSized1DShapeDrawable;
    const replacementLabel = ShapeLabel(text: '45 cm', offset: Offset(0, -20));

    final copy = drawable.copyWith(
      length: 120,
      position: const Offset(80, 60),
      rotation: 0.5,
      scale: 2,
      label: replacementLabel,
      assists: {ObjectDrawableAssist.horizontal},
      assistPaints: {ObjectDrawableAssist.horizontal: assistPaint},
    );

    expect(copy.shape, same(drawable.shape));
    expect(copy.length, 120);
    expect(copy.position, const Offset(80, 60));
    expect(copy.rotationAngle, 0.5);
    expect(copy.scale, 2);
    expect(copy.label, same(replacementLabel));
    expect(
      copy.assistPaints[ObjectDrawableAssist.horizontal],
      same(assistPaint),
    );
  });

  test('label participates in the drawable hit bounds', () {
    final drawable =
        (LabeledShapeFactory(
                  factory: LineFactory(),
                  label: const ShapeLabel(
                    text: 'A label wider than the line',
                    style: TextStyle(fontSize: 20),
                  ),
                ).create(Offset.zero)
                as LabeledSized1DShapeDrawable)
            .copyWith(length: 10);

    final size = drawable.getSize();

    expect(size.width, greaterThan(10));
    expect(size.height, greaterThan(20));
  });

  test('renders the label background over the wrapped shape', () async {
    final drawable =
        (LabeledShapeFactory(
                  factory: RectangleFactory(),
                  label: const ShapeLabel(
                    text: 'A',
                    backgroundColor: Color(0xFFFF0000),
                  ),
                ).create(
                  const Offset(50, 25),
                  Paint()..color = const Color(0xFF0000FF),
                )
                as LabeledSized2DShapeDrawable)
            .copyWith(size: const Size(80, 40));
    final recorder = PictureRecorder();
    drawable.draw(Canvas(recorder), const Size(100, 50));
    final image = await recorder.endRecording().toImage(100, 50);
    addTearDown(image.dispose);
    final bytes = await image.toByteData(format: ImageByteFormat.rawRgba);

    expect(bytes, isNotNull);
    var redPixelCount = 0;
    for (var index = 0; index < bytes!.lengthInBytes; index += 4) {
      if (bytes.getUint8(index) > 240 &&
          bytes.getUint8(index + 1) < 20 &&
          bytes.getUint8(index + 2) < 20 &&
          bytes.getUint8(index + 3) > 240) {
        redPixelCount++;
      }
    }
    expect(redPixelCount, greaterThan(20));
  });
}
