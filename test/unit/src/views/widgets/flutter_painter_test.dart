import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../widget_test_utils.dart';

void main() {
  final testbed = WidgetTestbed();

  Widget buildPainter(
    PainterController controller, {
    ValueChanged<Drawable>? onDrawableCreated,
    ValueChanged<bool>? onIsDrawingStateChanged,
    FreeStyleDrawingCallback? onFreeStyleDrawingStarted,
    FreeStyleDrawingCallback? onFreeStyleDrawingUpdated,
    FreeStyleDrawingCallback? onFreeStyleDrawingEnded,
    FreeStyleDrawingCallback? onFreeStyleDrawingCanceled,
  }) {
    return testbed.simpleWrap(
      child: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: FlutterPainter(
            controller: controller,
            onDrawableCreated: onDrawableCreated,
            onIsDrawingStateChanged: onIsDrawingStateChanged,
            onFreeStyleDrawingStarted: onFreeStyleDrawingStarted,
            onFreeStyleDrawingUpdated: onFreeStyleDrawingUpdated,
            onFreeStyleDrawingEnded: onFreeStyleDrawingEnded,
            onFreeStyleDrawingCanceled: onFreeStyleDrawingCanceled,
          ),
        ),
      ),
    );
  }

  testWidgets('object drawables can be selected and moved', (tester) async {
    final drawable = TextDrawable(
      text: 'Move me',
      position: const Offset(150, 150),
      style: const TextStyle(fontSize: 30),
    );
    final controller = PainterController(drawables: [drawable]);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      testbed.simpleWrap(
        child: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: FlutterPainter(controller: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);

    final painterCenter = tester.getCenter(find.byType(FlutterPainter));
    await tester.tapAt(painterCenter);
    await tester.pumpAndSettle();

    expect(controller.selectedObjectDrawable, same(drawable));
    expect(find.byType(InteractiveViewer), findsNothing);

    final gesture = await tester.startGesture(painterCenter);
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(30, 20));
    await gesture.up();
    await tester.pumpAndSettle();

    final movedDrawable = controller.selectedObjectDrawable;
    expect(movedDrawable, isA<TextDrawable>());
    expect(movedDrawable!.position, const Offset(180, 170));

    controller.undo();
    expect(
      (controller.drawables.single as TextDrawable).position,
      const Offset(150, 150),
    );

    controller.redo();
    expect(
      (controller.drawables.single as TextDrawable).position,
      const Offset(180, 170),
    );

    final painterTopLeft = tester.getTopLeft(find.byType(FlutterPainter));
    await tester.tapAt(painterTopLeft + const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(controller.selectedObjectDrawable, isNull);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('free-style callbacks report the complete drawing lifecycle', (
    tester,
  ) async {
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(mode: FreeStyleMode.draw),
      ),
    );
    addTearDown(controller.dispose);
    final drawingStates = <bool>[];
    final started = <PathDrawable>[];
    final updated = <PathDrawable>[];
    final ended = <PathDrawable>[];
    final created = <Drawable>[];

    await tester.pumpWidget(
      buildPainter(
        controller,
        onDrawableCreated: created.add,
        onIsDrawingStateChanged: drawingStates.add,
        onFreeStyleDrawingStarted: started.add,
        onFreeStyleDrawingUpdated: updated.add,
        onFreeStyleDrawingEnded: ended.add,
      ),
    );
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FlutterPainter));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(20, 10));
    await gesture.moveBy(const Offset(15, 15));
    await gesture.up();
    await tester.pump();

    expect(drawingStates, [true, false]);
    expect(started, hasLength(1));
    expect(updated, hasLength(2));
    expect(ended, hasLength(1));
    expect(created, hasLength(1));
    expect(controller.drawables, hasLength(1));
    expect(ended.single, same(controller.drawables.single));
    expect(created.single, same(controller.drawables.single));
  });

  testWidgets('canceling free-style drawing removes it and its undo action', (
    tester,
  ) async {
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(mode: FreeStyleMode.draw),
      ),
    );
    addTearDown(controller.dispose);
    final drawingStates = <bool>[];
    final canceled = <PathDrawable>[];

    await tester.pumpWidget(
      buildPainter(
        controller,
        onIsDrawingStateChanged: drawingStates.add,
        onFreeStyleDrawingCanceled: canceled.add,
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(FlutterPainter)),
    );
    await gesture.moveBy(const Offset(20, 10));
    await gesture.cancel();
    await tester.pump();

    expect(drawingStates, [true, false]);
    expect(canceled, hasLength(1));
    expect(controller.drawables, isEmpty);
    expect(controller.canUndo, isFalse);
  });

  testWidgets('canceling an erase gesture restores the ungrouped drawables', (
    tester,
  ) async {
    final original = FreeStyleDrawable(
      path: const [Offset(20, 20), Offset(40, 40)],
      color: Colors.black,
      strokeWidth: 4,
    );
    final controller = PainterController(
      drawables: [original],
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(mode: FreeStyleMode.erase),
      ),
    );
    addTearDown(controller.dispose);
    final canceled = <PathDrawable>[];

    await tester.pumpWidget(
      buildPainter(controller, onFreeStyleDrawingCanceled: canceled.add),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(FlutterPainter)),
    );
    await gesture.moveBy(const Offset(20, 10));
    await gesture.cancel();
    await tester.pump();

    expect(canceled.single, isA<EraseDrawable>());
    expect(controller.drawables, [same(original)]);
    expect(controller.canUndo, isFalse);
    expect(controller.canRedo, isFalse);
  });

  testWidgets('multi-touch shape gesture does not create a null drawable', (
    tester,
  ) async {
    final factory = RectangleFactory();
    final controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(factory: factory, drawOnce: true),
      ),
    );
    addTearDown(controller.dispose);
    final created = <Drawable>[];

    await tester.pumpWidget(
      buildPainter(controller, onDrawableCreated: created.add),
    );
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FlutterPainter));
    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(center - const Offset(20, 0));
    await second.down(center + const Offset(20, 0));
    await first.moveTo(center - const Offset(30, 0));
    await second.moveTo(center + const Offset(30, 0));
    await first.up();
    await second.up();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(controller.drawables, isEmpty);
    expect(created, isEmpty);
    expect(controller.shapeFactory, same(factory));
  });

  testWidgets('completed shape callback receives normalized drawable', (
    tester,
  ) async {
    final controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(factory: RectangleFactory()),
      ),
    );
    addTearDown(controller.dispose);
    final created = <Drawable>[];

    await tester.pumpWidget(
      buildPainter(controller, onDrawableCreated: created.add),
    );
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FlutterPainter));
    await tester.dragFrom(center, const Offset(-80, -60));
    await tester.pump();

    expect(controller.drawables, hasLength(1));
    final drawable = controller.drawables.single as RectangleDrawable;
    expect(drawable.size.width, greaterThanOrEqualTo(0));
    expect(drawable.size.height, greaterThanOrEqualTo(0));
    expect(created, [same(drawable)]);
  });

  testWidgets('triangle factory draws a sized triangle gesture', (
    tester,
  ) async {
    final controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(factory: TriangleFactory()),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    final start =
        tester.getTopLeft(find.byType(FlutterPainter)) + const Offset(50, 60);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(20, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(100, 90));
    await gesture.up();
    await tester.pump();

    expect(controller.drawables, hasLength(1));
    final drawable = controller.drawables.single as TriangleDrawable;
    expect(drawable.position, const Offset(120, 115));
    expect(drawable.size, const Size(100, 90));
  });
}
