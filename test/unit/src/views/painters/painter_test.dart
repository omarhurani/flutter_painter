// ignore_for_file: prefer_const_constructors
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/background/background_drawables.dart';
import 'package:flutter_painter/src/controllers/drawables/grouped_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/object_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/erase_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/shape/rectangle_drawable.dart';
import 'package:flutter_painter/src/views/painters/painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late Canvas canvas;

  setUpAll(() {
    canvas = MockCanvas();
    _ArrangeBuilder(canvas: canvas).withFakeCallbacks();
  });

  group('painter', () {
    test(
      'verify functions which are called by default if parameters are not provided',
      () async {
        final instance = Painter(drawables: []);

        instance.paint(canvas, Size(10, 10));

        verify(
          () => canvas.saveLayer(const Rect.fromLTWH(0, 0, 10, 10), any()),
        );
        expect(verify(() => canvas.restore()).callCount, 1);
        verifyNever(() => canvas.save());
      },
    );

    test('verify calls with scale parameter provided', () async {
      const scale = Size(20, 20);
      const size = Size(10, 10);
      final instance = Painter(scale: scale, drawables: []);

      instance.paint(canvas, size);

      verify(() => canvas.save());
      final storage = Matrix4.identity()
          .scaledByDouble(
            size.width / scale.width,
            size.height / scale.height,
            1,
            1,
          )
          .storage;
      verify(() => canvas.transform(storage));
      verify(() => canvas.saveLayer(const Rect.fromLTWH(0, 0, 20, 20), any()));
      expect(verify(() => canvas.restore()).callCount, 2);
    });

    test('drawable is drawing if hidden is set to false', () async {
      const size = Size(10, 10);
      final drawable = MockBackgroundDrawable(false);
      final gDrawable = GroupedDrawable(drawables: [drawable], hidden: false);
      final instance = Painter(drawables: [gDrawable]);

      instance.paint(canvas, size);

      verify(() => drawable.draw(canvas, size));
    });

    test('drawable is not drawing if hidden is set to true', () async {
      const size = Size(10, 10);
      final drawable = MockBackgroundDrawable(false);
      final gDrawable = GroupedDrawable(drawables: [drawable], hidden: true);
      final instance = Painter(drawables: [gDrawable]);

      instance.paint(canvas, size);

      verifyNever(() => drawable.draw(canvas, size));
    });

    test('hidden drawable inside a visible group is not drawn', () async {
      const size = Size(10, 10);
      final drawable = MockBackgroundDrawable(true);
      final group = GroupedDrawable(drawables: [drawable]);
      final instance = Painter(drawables: [group]);

      instance.paint(canvas, size);

      verifyNever(() => drawable.draw(canvas, size));
    });

    test('background is drawing if it is set to false', () async {
      const size = Size(10, 10);
      final drawable = MockBackgroundDrawable(false);
      final instance = Painter(drawables: [], background: drawable);

      instance.paint(canvas, size);

      verify(() => drawable.draw(canvas, size));
    });

    test('background is not drawing if it is set to true', () async {
      const size = Size(10, 10);
      final drawable = MockBackgroundDrawable(true);
      final instance = Painter(drawables: [], background: drawable);

      instance.paint(canvas, size);

      verifyNever(() => drawable.draw(canvas, size));
    });

    test(
      'finite drawable layer preserves erasing over the background',
      () async {
        final recorder = ui.PictureRecorder();
        final realCanvas = Canvas(recorder);
        final instance = Painter(
          background: ColorBackgroundDrawable(color: Colors.white),
          drawables: [
            RectangleDrawable(
              size: const Size(80, 80),
              position: const Offset(50, 50),
              paint: Paint()
                ..color = Colors.blue
                ..style = PaintingStyle.fill,
            ),
            EraseDrawable(
              path: const [Offset(50, 25), Offset(50, 75)],
              strokeWidth: 20,
            ),
          ],
        );

        instance.paint(realCanvas, const Size(100, 100));
        final image = await recorder.endRecording().toImage(100, 100);
        addTearDown(image.dispose);
        final pixels = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );

        expect(
          _pixelColor(pixels!, width: 100, x: 20, y: 20).toARGB32(),
          Colors.blue.toARGB32(),
        );
        expect(
          _pixelColor(pixels, width: 100, x: 50, y: 50).toARGB32(),
          Colors.white.toARGB32(),
        );
      },
    );
  });

  group('repaint', () {
    test('return true if parameter is not type of painter', () async {
      final instance = Painter(drawables: []);

      final result = instance.shouldRepaint(MockCustomPainter());

      expect(result, isTrue);
    });

    test(
      'return true if there is difference in background and drawables are same',
      () async {
        final instance = Painter(drawables: []);
        final oldInstance = Painter(
          drawables: [],
          background: MockBackgroundDrawable(false),
        );

        final result = instance.shouldRepaint(oldInstance);

        expect(result, isTrue);
      },
    );

    test('return true if there is difference in drawables', () async {
      final instance = Painter(drawables: []);
      final oldInstance = Painter(
        drawables: [ColorBackgroundDrawable(color: Colors.red)],
      );

      final result = instance.shouldRepaint(oldInstance);

      expect(result, isTrue);
    });

    test('return true if there is a difference in scale', () async {
      final instance = Painter(drawables: [], scale: const Size(10, 10));
      final oldInstance = Painter(drawables: []);

      final result = instance.shouldRepaint(oldInstance);

      expect(result, isTrue);
    });

    test(
      'return false if background, scale, and drawables are the same',
      () async {
        final instance = Painter(drawables: []);
        final oldInstance = Painter(drawables: []);

        final result = instance.shouldRepaint(oldInstance);

        expect(result, isFalse);
      },
    );
  });

  group('object assists', () {
    test('vertical assist uses its configured paint', () {
      final assistCanvas = MockCanvas();
      final verticalPaint = Paint()..color = Colors.green;
      final drawable = TestObjectDrawable(
        position: const Offset(4, 5),
        assists: const {ObjectDrawableAssist.vertical},
        assistPaints: {ObjectDrawableAssist.vertical: verticalPaint},
      );

      drawable.drawAssists(assistCanvas, const Size(10, 20));

      verify(
        () => assistCanvas.drawLine(
          const Offset(4, 0),
          const Offset(4, 20),
          verticalPaint,
        ),
      );
    });
  });
}

Color _pixelColor(
  ByteData pixels, {
  required int width,
  required int x,
  required int y,
}) {
  final offset = (y * width + x) * 4;
  return Color.fromARGB(
    pixels.getUint8(offset + 3),
    pixels.getUint8(offset),
    pixels.getUint8(offset + 1),
    pixels.getUint8(offset + 2),
  );
}

class _ArrangeBuilder {
  _ArrangeBuilder({Canvas? canvas}) : _canvas = canvas ?? MockCanvas();

  // ignore: not_used
  final Canvas _canvas;

  void withCanvas() =>
      when(() => _canvas.save()).thenAnswer((final _) async => {});

  void withFakeCallbacks() {
    registerFallbackValue(Paint());
  }
}

class MockCanvas extends Mock implements Canvas {}

class MockBackgroundDrawable extends Mock implements BackgroundDrawable {
  MockBackgroundDrawable(this.isHidden);

  @override
  final bool isHidden;

  @override
  bool get hidden => isHidden;

  @override
  bool get isNotHidden => !hidden;
}

class MockCustomPainter extends Mock implements CustomPainter {}

class TestObjectDrawable extends ObjectDrawable {
  const TestObjectDrawable({
    required super.position,
    super.rotationAngle,
    super.scale,
    super.assists,
    super.assistPaints,
    super.locked,
    super.hidden,
  });

  @override
  void drawObject(Canvas canvas, Size size) {}

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size.zero;
  }

  @override
  TestObjectDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    bool? locked,
  }) {
    return TestObjectDrawable(
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      assists: assists ?? this.assists,
      assistPaints: assistPaints,
      locked: locked ?? this.locked,
      hidden: hidden ?? this.hidden,
    );
  }
}
