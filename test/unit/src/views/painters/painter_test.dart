// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/drawables/background/background_drawables.dart';
import 'package:flutter_painter/src/controllers/drawables/grouped_drawable.dart';
import 'package:flutter_painter/src/views/painters/painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late Canvas canvas;

  setUpAll(() {
    canvas = MockCanvas();
    _ArrangeBuilder(
      canvas: canvas,
    ).withFakeCallbacks();
  });

  group('painter', () {
    test(
      'verify functions which are called by default if parameters are not provided',
      () async {
        final instance = Painter(
          drawables: [],
        );

        instance.paint(canvas, Size(10, 10));

        verify(() => canvas.saveLayer(any(), any()));
        expect(verify(() => canvas.restore()).callCount, 1);
        verifyNever(() => canvas.save());
      },
    );

    test(
      'verify calls with scale parameter provided',
      () async {
        const scale = Size(20, 20);
        const size = Size(10, 10);
        final instance = Painter(
          scale: scale,
          drawables: [],
        );

        instance.paint(canvas, size);

        verify(() => canvas.save());
        final storage = Matrix4.identity()
            .scaled(size.width / scale.width, size.height / scale.height)
            .storage;
        verify(() => canvas.transform(storage));
        verify(() => canvas.saveLayer(any(), any()));
        expect(verify(() => canvas.restore()).callCount, 2);
      },
    );

    test(
      'drawable is drawing if hidden is set to false',
      () async {
        const size = Size(10, 10);
        final drawable = ColorBackgroundDrawable(color: Colors.red);
        final gDrawable = GroupedDrawable(
          drawables: [drawable],
          hidden: false,
        );
        final instance = Painter(
          drawables: [gDrawable],
        );

        instance.paint(canvas, size);

        verify(() => drawable.draw(canvas, size));
      },
    );

    test(
      'drawable is not drawing if hidden is set to true',
      () async {
        const size = Size(10, 10);
        final drawable = ColorBackgroundDrawable(color: Colors.red);
        final gDrawable = GroupedDrawable(
          drawables: [drawable],
          hidden: false,
        );
        final instance = Painter(
          drawables: [gDrawable],
        );

        instance.paint(canvas, size);

        verify(() => drawable.draw(canvas, size));
      },
    );

    test(
      'background is drawing if it is set to false',
      () async {
        const size = Size(10, 10);
        final drawable = MockBackgroundDrawable(false);
        final instance = Painter(
          drawables: [],
          background: drawable,
        );

        instance.paint(canvas, size);

        verify(() => drawable.draw(canvas, size));
      },
    );

    test(
      'background is not drawing if it is set to true',
      () async {
        const size = Size(10, 10);
        final drawable = MockBackgroundDrawable(true);
        final instance = Painter(
          drawables: [],
          background: drawable,
        );

        instance.paint(canvas, size);

        verifyNever(() => drawable.draw(canvas, size));
      },
    );
  });

  group('repaint', () {
    test(
      'return true if parameter is not type of painter',
      () async {
        final instance = Painter(drawables: []);

        final result = instance.shouldRepaint(MockCustomPainter());

        expect(result, isTrue);
      },
    );

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

    test(
      'return true if there is difference in drawables',
      () async {
        final instance = Painter(drawables: []);
        final oldInstance = Painter(drawables: [
          ColorBackgroundDrawable(color: Colors.red),
        ]);

        final result = instance.shouldRepaint(oldInstance);

        expect(result, isTrue);
      },
    );

    test(
      'return false if background and drawables are the same',
      () async {
        final instance = Painter(drawables: []);
        final oldInstance = Painter(drawables: []);

        final result = instance.shouldRepaint(oldInstance);

        expect(result, isFalse);
      },
    );
  });
}

class _ArrangeBuilder {
  _ArrangeBuilder({Canvas? canvas}) : _canvas = canvas ?? MockCanvas();

  // ignore: not_used
  final Canvas _canvas;

  void withCanvas() =>
      when(() => _canvas.save()).thenAnswer((final _) async => {});

  void withFakeCallbacks() {
    registerFallbackValue(FakePaint());
  }
}

class FakePaint extends Fake implements Paint {}

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
