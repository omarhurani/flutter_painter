import 'package:flutter_painter/src/controllers/painter_controller.dart';
import 'package:flutter_painter/src/controllers/drawables/text_drawable.dart';
import 'package:flutter_painter/src/controllers/events/edit_text_painter_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
