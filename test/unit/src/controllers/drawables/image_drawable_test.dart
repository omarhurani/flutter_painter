import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/grouped_drawable.dart';
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
    final assistPaint = Paint()..color = const Color(0xFF123456);
    final drawable = ImageDrawable(
      image: image,
      position: Offset.zero,
      tag: 'star',
      opacity: 0.75,
      assistPaints: {ObjectDrawableAssist.horizontal: assistPaint},
    );

    expect(drawable.copyWith().tag, 'star');
    expect(drawable.copyWith(tag: 'heart').tag, 'heart');
    expect(drawable.copyWith().opacity, 0.75);
    expect(drawable.copyWith(opacity: 0.25).opacity, 0.25);
    expect(
      drawable.copyWith().assistPaints[ObjectDrawableAssist.horizontal],
      same(assistPaint),
    );
  });

  test('copyWith preserves, updates, and resets the source crop', () {
    const crop = Rect.fromLTWH(20, 10, 40, 20);
    final drawable = ImageDrawable(
      image: image,
      position: Offset.zero,
      sourceRect: crop,
    );

    expect(drawable.isCropped, isTrue);
    expect(drawable.copyWith().sourceRect, crop);

    const replacement = Rect.fromLTWH(10, 5, 80, 40);
    expect(drawable.copyWith(sourceRect: replacement).sourceRect, replacement);

    final reset = drawable.copyWith(
      sourceRect: ImageDrawable.fullSourceRect(image),
    );
    expect(reset.isCropped, isFalse);
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

  test('drawObject renders only the source crop at its cropped size', () {
    final canvas = MockCanvas();
    const crop = Rect.fromLTWH(20, 10, 40, 20);
    final drawable = ImageDrawable(
      image: image,
      position: const Offset(50, 25),
      sourceRect: crop,
      scale: 2,
    );

    drawable.drawObject(canvas, const Size(100, 50));

    final captured = verify(
      () => canvas.drawImageRect(image, captureAny(), captureAny(), any()),
    ).captured;
    expect(captured[0], crop);
    expect(
      captured[1],
      Rect.fromCenter(center: const Offset(50, 25), width: 80, height: 40),
    );
    expect(drawable.getSize(), const Size(80, 40));
  });

  test('fittedToSize calculates scale from the cropped dimensions', () {
    final drawable = ImageDrawable.fittedToSize(
      image: image,
      position: Offset.zero,
      sourceRect: const Rect.fromLTWH(20, 10, 40, 20),
      size: const Size(20, 20),
    );

    expect(drawable.scale, 0.5);
    expect(drawable.getSize(), const Size(20, 10));
  });

  test('renders only pixels inside the source crop', () async {
    final sourceRecorder = PictureRecorder();
    final sourceCanvas = Canvas(sourceRecorder);
    sourceCanvas.drawRect(
      const Rect.fromLTWH(0, 0, 10, 10),
      Paint()..color = const Color(0xFFFF0000),
    );
    sourceCanvas.drawRect(
      const Rect.fromLTWH(10, 0, 10, 10),
      Paint()..color = const Color(0xFF0000FF),
    );
    final sourceImage = await sourceRecorder.endRecording().toImage(20, 10);
    addTearDown(sourceImage.dispose);
    final drawable = ImageDrawable(
      image: sourceImage,
      position: const Offset(5, 5),
      sourceRect: const Rect.fromLTWH(10, 0, 10, 10),
    );

    final outputRecorder = PictureRecorder();
    drawable.drawObject(Canvas(outputRecorder), const Size(10, 10));
    final outputImage = await outputRecorder.endRecording().toImage(10, 10);
    addTearDown(outputImage.dispose);
    final bytes = await outputImage.toByteData(format: ImageByteFormat.rawRgba);

    expect(bytes, isNotNull);
    expect(bytes!.getUint8(0), 0);
    expect(bytes.getUint8(1), 0);
    expect(bytes.getUint8(2), 255);
    expect(bytes.getUint8(3), 255);
  });

  test('rejects source crops outside the image bounds', () {
    expect(
      () => ImageDrawable(
        image: image,
        position: Offset.zero,
        sourceRect: const Rect.fromLTWH(80, 10, 40, 20),
      ),
      throwsArgumentError,
    );
    expect(
      () => ImageDrawable(
        image: image,
        position: Offset.zero,
        sourceRect: Rect.zero,
      ),
      throwsArgumentError,
    );
  });

  test('controller counts tagged image drawables by sticker type', () {
    final controller = PainterController(
      drawables: [
        ImageDrawable(image: image, position: Offset.zero, tag: 'star'),
        GroupedDrawable(
          drawables: [
            ImageDrawable(image: image, position: Offset.zero, tag: 'star'),
            GroupedDrawable(
              drawables: [
                ImageDrawable(
                  image: image,
                  position: Offset.zero,
                  tag: 'heart',
                ),
              ],
            ),
          ],
        ),
        ImageDrawable(image: image, position: Offset.zero),
      ],
    );
    addTearDown(controller.dispose);

    final counts = controller.imageDrawableCountsByTag;

    expect(counts, {'star': 2, 'heart': 1});
    expect(() => counts['star'] = 0, throwsUnsupportedError);
  });
}
