import 'dart:ui';

import 'package:flutter_painter/src/controllers/drawables/image_drawable.dart';
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
}
