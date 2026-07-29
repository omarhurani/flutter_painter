import 'dart:ui';

import 'package:flutter_painter/src/controllers/drawables/background/image_background_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/image_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/object_group_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/shape/oval_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/shape/rectangle_drawable.dart';
import 'package:flutter_painter/src/controllers/painter_controller.dart';
import 'package:flutter_painter/src/controllers/drawables/text_drawable.dart';
import 'package:flutter_painter/src/controllers/events/edit_text_painter_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImage extends Mock implements Image {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('editTextDrawable selects and dispatches the requested text', () async {
    final drawable = TextDrawable(text: 'Edit me', position: Offset.zero);
    final controller = PainterController(drawables: [drawable]);
    addTearDown(controller.dispose);
    final event = controller.events.first;

    controller.editTextDrawable(drawable);

    expect(controller.selectedObjectDrawable, same(drawable));
    expect(
      await event,
      isA<EditTextPainterEvent>().having(
        (event) => event.drawable,
        'drawable',
        same(drawable),
      ),
    );
  });

  test('editTextDrawable ignores text owned by another controller', () async {
    final controller = PainterController();
    addTearDown(controller.dispose);
    final events = <Object>[];
    final subscription = controller.events.listen(events.add);
    addTearDown(subscription.cancel);

    controller.editTextDrawable(
      TextDrawable(text: 'Foreign', position: Offset.zero),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.selectedObjectDrawable, isNull);
    expect(events, isEmpty);
  });

  test('dispose closes the controller event stream', () async {
    final controller = PainterController();
    final streamClosed = expectLater(controller.events, emitsDone);

    controller.dispose();

    await streamClosed;
  });

  test('removeSelectedObjectDrawable removes only the selected object', () {
    final first = TextDrawable(text: 'First', position: Offset.zero);
    final selected = TextDrawable(text: 'Selected', position: Offset.zero);
    final controller = PainterController(drawables: [first, selected]);
    addTearDown(controller.dispose);
    controller.selectObjectDrawable(selected);

    final removed = controller.removeSelectedObjectDrawable();

    expect(removed, isTrue);
    expect(controller.value.drawables, [first]);
    expect(controller.selectedObjectDrawable, isNull);
    expect(controller.canUndo, isTrue);

    controller.undo();
    expect(controller.value.drawables, [first, selected]);

    controller.redo();
    expect(controller.value.drawables, [first]);
  });

  test('removeSelectedObjectDrawable is a no-op without a selection', () {
    final controller = PainterController();
    addTearDown(controller.dispose);

    expect(controller.removeSelectedObjectDrawable(), isFalse);
    expect(controller.canUndo, isFalse);
  });

  test('removeDrawable does not record a failed removal', () {
    final controller = PainterController();
    addTearDown(controller.dispose);
    final foreign = TextDrawable(text: 'Foreign', position: Offset.zero);

    expect(controller.removeDrawable(foreign), isFalse);
    expect(controller.canUndo, isFalse);
  });

  test('removeLastDrawable is safe when empty and forwards newAction', () {
    final controller = PainterController();
    addTearDown(controller.dispose);

    expect(controller.removeLastDrawable, returnsNormally);
    expect(controller.canUndo, isFalse);

    final drawable = TextDrawable(text: 'Temporary', position: Offset.zero);
    controller.addDrawables([drawable]);
    controller.removeLastDrawable(newAction: false);

    expect(controller.value.drawables, isEmpty);
    expect(controller.canUndo, isFalse);
  });

  test('cropImageDrawable supports selection, undo, redo, and reset', () {
    final image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(50);
    final original = ImageDrawable(image: image, position: Offset.zero);
    final controller = PainterController(drawables: [original]);
    addTearDown(controller.dispose);
    controller.selectObjectDrawable(original);

    const crop = Rect.fromLTWH(20, 10, 40, 20);
    expect(controller.cropImageDrawable(original, crop), isTrue);

    final cropped = controller.value.drawables.single as ImageDrawable;
    expect(cropped.sourceRect, crop);
    expect(controller.selectedObjectDrawable, same(cropped));

    controller.undo();
    expect(controller.value.drawables.single, same(original));
    expect(controller.selectedObjectDrawable, same(original));

    controller.redo();
    final redone = controller.value.drawables.single as ImageDrawable;
    expect(redone.sourceRect, crop);
    expect(controller.selectedObjectDrawable, same(redone));

    expect(
      controller.cropImageDrawable(redone, ImageDrawable.fullSourceRect(image)),
      isTrue,
    );
    expect(
      (controller.value.drawables.single as ImageDrawable).isCropped,
      isFalse,
    );
  });

  test('addCroppedImage fits and stores the requested source pixels', () {
    final image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(50);
    final controller = PainterController();
    addTearDown(controller.dispose);

    const crop = Rect.fromLTWH(20, 10, 40, 20);
    controller.addCroppedImage(image, crop, const Size(20, 20));

    final drawable = controller.value.drawables.single as ImageDrawable;
    expect(drawable.sourceRect, crop);
    expect(drawable.getSize(), const Size(20, 10));
  });

  test('addBlurredImage stores its source, position, shape, and blur', () {
    final image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(50);
    final controller = PainterController();
    addTearDown(controller.dispose);

    const crop = Rect.fromLTWH(20, 10, 40, 20);
    controller.addBlurredImage(
      image,
      crop,
      position: const Offset(70, 40),
      size: const Size(80, 80),
      blurSigma: 9,
      shape: ImageDrawableShape.oval,
    );

    final drawable = controller.value.drawables.single as ImageDrawable;
    expect(drawable.sourceRect, crop);
    expect(drawable.position, const Offset(70, 40));
    expect(drawable.getSize(), const Size(80, 40));
    expect(drawable.blurSigma, 9);
    expect(drawable.shape, ImageDrawableShape.oval);
    expect(controller.canUndo, isTrue);
  });

  test('addFloodFill respects image boundaries and supports undo', () async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 20, 10),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRect(
      const Rect.fromLTWH(10, 0, 1, 10),
      Paint()..color = const Color(0xFF000000),
    );
    final image = await recorder.endRecording().toImage(20, 10);
    addTearDown(image.dispose);
    final controller = PainterController(
      background: ImageBackgroundDrawable(image: image),
    );
    addTearDown(controller.dispose);

    final fill = await controller.addFloodFill(
      const Offset(5, 5),
      color: const Color(0xFF0000FF),
      tolerance: 0,
      size: const Size(20, 10),
    );

    expect(fill, isNotNull);
    expect(fill!.spans, hasLength(10));
    expect(fill.spans.every((span) => span.endX == 9), isTrue);
    expect(controller.value.drawables.single, same(fill));
    expect(controller.canUndo, isTrue);

    final rendered = await controller.renderImage(const Size(20, 10));
    addTearDown(rendered.dispose);
    final bytes = await rendered.toByteData(format: ImageByteFormat.rawRgba);
    int channelAt(int x, int y, int channel) {
      return bytes!.getUint8((y * 20 + x) * 4 + channel);
    }

    expect(channelAt(5, 5, 2), 255);
    expect(channelAt(10, 5, 0), 0);
    expect(channelAt(15, 5, 0), 255);

    controller.undo();
    expect(controller.value.drawables, isEmpty);
  });

  test(
    'createFloodFill validates size, bounds, tolerance, and safety',
    () async {
      final controller = PainterController();
      addTearDown(controller.dispose);

      await expectLater(
        controller.createFloodFill(Offset.zero),
        throwsStateError,
      );
      await expectLater(
        controller.createFloodFill(
          const Offset(20, 20),
          size: const Size(10, 10),
        ),
        completion(isNull),
      );
      await expectLater(
        controller.createFloodFill(
          Offset.zero,
          size: const Size(10, 10),
          tolerance: 101,
        ),
        throwsRangeError,
      );
      await expectLater(
        controller.createFloodFill(
          Offset.zero,
          size: const Size(10, 10),
          maxPixels: 99,
        ),
        throwsStateError,
      );
    },
  );

  test('addTaggedImage preserves its tag, crop, and fitted size', () {
    final image = MockImage();
    when(() => image.width).thenReturn(100);
    when(() => image.height).thenReturn(50);
    final controller = PainterController();
    addTearDown(controller.dispose);

    const crop = Rect.fromLTWH(20, 10, 40, 20);
    controller.addTaggedImage(
      image,
      tag: 'sticker/star',
      size: const Size(20, 20),
      sourceRect: crop,
    );

    final drawable = controller.value.drawables.single as ImageDrawable;
    expect(drawable.tag, 'sticker/star');
    expect(drawable.sourceRect, crop);
    expect(drawable.getSize(), const Size(20, 10));
  });

  test('groups objects with exact order, selection, undo, and redo', () {
    final rectangle = RectangleDrawable(
      size: const Size(40, 30),
      position: const Offset(30, 40),
    );
    final untouched = TextDrawable(
      text: 'Untouched',
      position: const Offset(100, 100),
    );
    final oval = OvalDrawable(
      size: const Size(20, 50),
      position: const Offset(70, 60),
    );
    final controller = PainterController(
      drawables: [rectangle, untouched, oval],
    );
    addTearDown(controller.dispose);
    controller.selectObjectDrawable(rectangle);

    final group = controller.groupObjectDrawables([oval, rectangle]);

    expect(group, isNotNull);
    expect(controller.value.drawables, [untouched, same(group)]);
    expect(group!.drawables, [isA<RectangleDrawable>(), isA<OvalDrawable>()]);
    expect(controller.selectedObjectDrawable, same(group));
    expect(controller.canUndo, isTrue);

    controller.undo();
    expect(controller.value.drawables, [rectangle, untouched, oval]);
    expect(controller.selectedObjectDrawable, same(rectangle));

    controller.redo();
    expect(controller.value.drawables, [untouched, same(group)]);
    expect(controller.selectedObjectDrawable, same(group));
  });

  test('rejects invalid object groups without recording an action', () {
    final owned = TextDrawable(text: 'Owned', position: Offset.zero);
    final foreign = TextDrawable(
      text: 'Foreign',
      position: const Offset(20, 20),
    );
    final controller = PainterController(drawables: [owned]);
    addTearDown(controller.dispose);

    expect(controller.groupObjectDrawables([owned]), isNull);
    expect(controller.groupObjectDrawables([owned, foreign]), isNull);
    expect(controller.value.drawables, [owned]);
    expect(controller.canUndo, isFalse);
  });

  test('ungroups transformed objects and supports undo and redo', () async {
    final rectangle = RectangleDrawable(
      size: const Size(30, 20),
      position: const Offset(40, 50),
      rotationAngle: 0.2,
      scale: 1.1,
      paint: Paint()..color = const Color(0xFF1565C0),
    );
    final oval = OvalDrawable(
      size: const Size(25, 35),
      position: const Offset(80, 70),
      rotationAngle: 0.4,
      paint: Paint()..color = const Color(0xFFEF6C00),
    );
    final transformedGroup = ObjectGroupDrawable.fromDrawables(
      drawables: [rectangle, oval],
    ).copyWith(position: const Offset(110, 95), rotation: 0.6, scale: 1.4);
    final controller = PainterController(drawables: [transformedGroup]);
    addTearDown(controller.dispose);
    controller.selectObjectDrawable(transformedGroup);
    final groupedRender = await controller.renderImage(const Size(220, 180));
    addTearDown(groupedRender.dispose);

    final ungrouped = controller.ungroupSelectedObjectDrawable();

    expect(ungrouped, hasLength(2));
    expect(controller.value.drawables, ungrouped);
    expect(controller.selectedObjectDrawable, isNull);
    final ungroupedRender = await controller.renderImage(const Size(220, 180));
    addTearDown(ungroupedRender.dispose);
    final pixelDifference = _pixelDifference(
      await _rawPixels(groupedRender),
      await _rawPixels(ungroupedRender),
    );
    expect(pixelDifference, {
      'differentChannels': 0,
      'maximumDelta': 0,
      'totalDelta': 0,
    });

    controller.undo();
    expect(controller.value.drawables, [same(transformedGroup)]);
    expect(controller.selectedObjectDrawable, same(transformedGroup));

    controller.redo();
    expect(controller.value.drawables, ungrouped);
    expect(controller.selectedObjectDrawable, isNull);
  });
}

Future<List<int>> _rawPixels(Image image) async {
  final data = await image.toByteData(format: ImageByteFormat.rawRgba);
  if (data == null) throw StateError('Could not read rendered pixels.');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Map<String, int> _pixelDifference(List<int> first, List<int> second) {
  var differentChannels = 0;
  var maximumDelta = 0;
  var totalDelta = 0;
  for (var index = 0; index < first.length; index++) {
    final delta = (first[index] - second[index]).abs();
    if (delta == 0) continue;
    differentChannels++;
    totalDelta += delta;
    if (delta > maximumDelta) maximumDelta = delta;
  }
  return {
    'differentChannels': differentChannels,
    'maximumDelta': maximumDelta,
    'totalDelta': totalDelta,
  };
}
