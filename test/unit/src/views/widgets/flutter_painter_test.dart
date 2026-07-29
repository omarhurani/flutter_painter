import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/grouped_drawable.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../widget_test_utils.dart';

class TestFreeStyleFactory extends FreeStyleFactory<TestFreeStyleDrawable> {
  const TestFreeStyleFactory();

  @override
  TestFreeStyleDrawable create({
    required List<Offset> path,
    required Color color,
    required double strokeWidth,
  }) {
    return TestFreeStyleDrawable(
      path: path,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

class TestFreeStyleDrawable extends PathDrawable {
  final Color color;

  TestFreeStyleDrawable({
    required super.path,
    required this.color,
    super.strokeWidth,
    super.hidden,
  });

  @override
  TestFreeStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
    Color? color,
  }) {
    return TestFreeStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Paint get paint => Paint()
    ..color = color
    ..style = PaintingStyle.fill;
}

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

  testWidgets('object groups can be selected, moved, and ungrouped', (
    tester,
  ) async {
    final rectangle = RectangleDrawable(
      size: const Size(50, 35),
      position: const Offset(110, 130),
    );
    final oval = OvalDrawable(
      size: const Size(40, 50),
      position: const Offset(180, 160),
    );
    final controller = PainterController(drawables: [rectangle, oval]);
    addTearDown(controller.dispose);
    final group = controller.groupObjectDrawables([rectangle, oval]);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    expect(group, isNotNull);
    expect(controller.selectedObjectDrawable, same(group));
    final painterTopLeft = tester.getTopLeft(find.byType(FlutterPainter));
    final gesture = await tester.startGesture(painterTopLeft + group!.position);
    await gesture.moveBy(const Offset(20, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(30, 20));
    await gesture.up();
    await tester.pumpAndSettle();

    final movedGroup =
        controller.selectedObjectDrawable! as ObjectGroupDrawable;
    expect(movedGroup.position, group.position + const Offset(30, 20));

    final children = controller.ungroupSelectedObjectDrawable();
    await tester.pumpAndSettle();

    expect(children, hasLength(2));
    expect(controller.drawables, children);
    expect(controller.selectedObjectDrawable, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller opens an existing text drawable for editing', (
    tester,
  ) async {
    final drawable = TextDrawable(
      text: 'Edit me',
      position: const Offset(150, 150),
    );
    final controller = PainterController(drawables: [drawable]);
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    controller.editTextDrawable(drawable);
    controller.editTextDrawable(drawable);
    await tester.pumpAndSettle();

    expect(controller.selectedObjectDrawable, same(drawable));
    expect(find.byType(TextField), findsOneWidget);
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'Edit me');
    expect(textField.focusNode?.hasFocus, isTrue);

    textField.focusNode?.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
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

  testWidgets('free-style factory creates and updates a custom drawable', (
    tester,
  ) async {
    const color = Color(0xFF7B1FA2);
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(
          mode: FreeStyleMode.draw,
          color: color,
          strokeWidth: 7,
          factory: TestFreeStyleFactory(),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    final start = tester.getCenter(find.byType(FlutterPainter));
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(20, 10));
    await gesture.moveBy(const Offset(15, 5));
    await gesture.up();
    await tester.pump();

    final drawable = controller.drawables.single as TestFreeStyleDrawable;
    expect(drawable.color, color);
    expect(drawable.strokeWidth, 7);
    expect(drawable.path, hasLength(3));
  });

  testWidgets('free-style factory does not replace the erase drawable', (
    tester,
  ) async {
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(
          mode: FreeStyleMode.erase,
          factory: TestFreeStyleFactory(),
        ),
      ),
      drawables: [
        FreeStyleDrawable(path: const [Offset(20, 20), Offset(40, 40)]),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FlutterPainter));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(20, 10));
    await gesture.up();
    await tester.pump();

    expect(controller.drawables.whereType<EraseDrawable>(), hasLength(1));
    expect(controller.drawables.whereType<TestFreeStyleDrawable>(), isEmpty);
  });

  testWidgets('scale settings allow zooming below one', (tester) async {
    final controller = PainterController(
      settings: const PainterSettings(
        scale: ScaleSettings(enabled: true, minScale: 0.5, maxScale: 4),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .boundaryMargin,
      const EdgeInsets.all(150),
    );

    final center = tester.getCenter(find.byType(FlutterPainter));
    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(center - const Offset(80, 0));
    await second.down(center + const Offset(80, 0));
    await first.moveTo(center - const Offset(20, 0));
    await second.moveTo(center + const Offset(20, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();

    expect(
      controller.transformationController.value.getMaxScaleOnAxis(),
      closeTo(0.5, 0.01),
    );
  });

  testWidgets('drawing coordinates stay local after zoom and pan', (
    tester,
  ) async {
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(mode: FreeStyleMode.draw),
        scale: ScaleSettings(enabled: true, minScale: 1, maxScale: 4),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    controller.transformationController.value = Matrix4.identity()
      ..setEntry(0, 0, 2)
      ..setEntry(1, 1, 2)
      ..setEntry(0, 3, -60)
      ..setEntry(1, 3, -40);
    await tester.pump();

    final viewportTopLeft = tester.getTopLeft(find.byType(InteractiveViewer));
    final start = viewportTopLeft + const Offset(100, 140);
    final end = viewportTopLeft + const Offset(160, 200);
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await gesture.up();
    await tester.pumpAndSettle();

    final stroke = controller.drawables.single as FreeStyleDrawable;
    expect(stroke.path.first.dx, closeTo(80, 0.01));
    expect(stroke.path.first.dy, closeTo(90, 0.01));
    expect(stroke.path.last.dx, closeTo(110, 0.01));
    expect(stroke.path.last.dy, closeTo(120, 0.01));
  });

  testWidgets(
    'drawables retain relative coordinates when the painter resizes',
    (tester) async {
      final background = RecordingBackgroundDrawable();
      final drawable = RectangleDrawable(
        position: const Offset(50, 25),
        size: const Size(20, 10),
        paint: Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill,
      );
      final controller = PainterController(
        background: background,
        drawables: [drawable],
      );
      addTearDown(controller.dispose);
      final painterSize = ValueNotifier(const Size(200, 100));
      addTearDown(painterSize.dispose);

      await tester.pumpWidget(
        testbed.simpleWrap(
          child: Center(
            child: ValueListenableBuilder<Size>(
              valueListenable: painterSize,
              builder: (context, size, _) => SizedBox.fromSize(
                key: const ValueKey('resizable-painter'),
                size: size,
                child: FlutterPainter(controller: controller),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(background.sizes.last, const Size(200, 100));
      expect(controller.painterKey.currentContext?.size, const Size(200, 100));
      expect(controller.canUndo, isFalse);

      painterSize.value = const Size(400, 100);
      await tester.pumpAndSettle();

      final painterTopLeft = tester.getTopLeft(
        find.byKey(const ValueKey('resizable-painter')),
      );
      final coordinateBox =
          controller.painterKey.currentContext!.findRenderObject() as RenderBox;
      final displayedDrawablePosition = coordinateBox.localToGlobal(
        drawable.position,
      );

      expect(background.sizes.last, const Size(400, 100));
      expect(coordinateBox.size, const Size(200, 100));
      expect(displayedDrawablePosition, painterTopLeft + const Offset(100, 25));
      expect(controller.drawables.single, same(drawable));
      expect(controller.canUndo, isFalse);

      await tester.tapAt(displayedDrawablePosition);
      await tester.pumpAndSettle();
      expect(controller.selectedObjectDrawable, same(drawable));

      final gesture = await tester.startGesture(displayedDrawablePosition);
      await gesture.moveBy(const Offset(20, 10));
      await tester.pump();
      await gesture.moveBy(const Offset(20, 10));
      await gesture.up();
      await tester.pumpAndSettle();

      final movedDrawable =
          controller.selectedObjectDrawable! as RectangleDrawable;
      expect(movedDrawable.position, const Offset(60, 35));

      final renderedImage = (await tester.runAsync(
        () => controller.renderImage(const Size(400, 200)),
      ))!;
      addTearDown(renderedImage.dispose);
      final pixels = await tester.runAsync(
        () => renderedImage.toByteData(format: ui.ImageByteFormat.rawRgba),
      );
      expect(pixels, isNotNull);
      expect(_alphaAt(pixels!, width: 400, x: 120, y: 70), 255);
      expect(_alphaAt(pixels, width: 400, x: 60, y: 70), 0);

      controller.undo();
      expect(
        (controller.drawables.single as RectangleDrawable).position,
        drawable.position,
      );
    },
  );

  testWidgets('pinch zoom cancels drawing and leaves the brush responsive', (
    tester,
  ) async {
    final controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(mode: FreeStyleMode.draw),
        scale: ScaleSettings(enabled: true, minScale: 1, maxScale: 4),
      ),
    );
    addTearDown(controller.dispose);
    final drawingStates = <bool>[];
    final canceled = <PathDrawable>[];
    final created = <Drawable>[];

    await tester.pumpWidget(
      buildPainter(
        controller,
        onDrawableCreated: created.add,
        onIsDrawingStateChanged: drawingStates.add,
        onFreeStyleDrawingCanceled: canceled.add,
      ),
    );
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.byType(FlutterPainter));
    final first = await tester.createGesture(pointer: 1);
    final second = await tester.createGesture(pointer: 2);
    await first.down(center - const Offset(30, 0));
    await first.moveBy(const Offset(-5, 0));
    await second.down(center + const Offset(30, 0));
    await first.moveTo(center - const Offset(80, 0));
    await second.moveTo(center + const Offset(80, 0));
    await tester.pump();
    await first.up();
    await second.up();
    await tester.pumpAndSettle();

    expect(controller.drawables, isEmpty);
    expect(created, isEmpty);
    expect(canceled, hasLength(1));
    expect(drawingStates, [true, false]);
    expect(
      controller.transformationController.value.getMaxScaleOnAxis(),
      greaterThan(1),
    );

    final stroke = await tester.startGesture(center, pointer: 3);
    await stroke.moveBy(const Offset(20, 10));
    await tester.pump();
    await stroke.moveBy(const Offset(20, 10));
    await stroke.up();
    await tester.pump();

    expect(controller.drawables, hasLength(1));
    expect(created, hasLength(1));
    expect(drawingStates, [true, false, true, false]);
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

  testWidgets('non-erasable images remain interactive above the erase layer', (
    tester,
  ) async {
    final image = await _createTestImage();
    addTearDown(image.dispose);
    final stroke = FreeStyleDrawable(
      path: const [Offset(20, 170), Offset(280, 170)],
      strokeWidth: 12,
    );
    final imageDrawable = ImageDrawable(
      image: image,
      position: const Offset(150, 150),
      tag: 'non-erasable-sticker',
      erasable: false,
    );
    final controller = PainterController(
      drawables: [stroke, imageDrawable],
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(
          mode: FreeStyleMode.erase,
          strokeWidth: 20,
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    final painterTopLeft = tester.getTopLeft(find.byType(FlutterPainter));
    final imageCenter = painterTopLeft + imageDrawable.position;
    await tester.tapAt(imageCenter);
    await tester.pumpAndSettle();

    expect(controller.selectedObjectDrawable, same(imageDrawable));

    final moveGesture = await tester.startGesture(imageCenter);
    await moveGesture.moveBy(const Offset(20, 20));
    await tester.pump();
    await moveGesture.moveBy(const Offset(30, 20));
    await moveGesture.up();
    await tester.pumpAndSettle();

    final movedImage = controller.selectedObjectDrawable;
    expect(movedImage, isA<ImageDrawable>());
    expect(movedImage, isNot(same(imageDrawable)));
    expect(movedImage!.position, isNot(imageDrawable.position));
    expect(movedImage.erasable, isFalse);
    expect((movedImage as ImageDrawable).tag, 'non-erasable-sticker');

    final eraseY = movedImage.position.dy;
    final eraseGesture = await tester.startGesture(
      painterTopLeft + Offset(20, eraseY),
    );
    await eraseGesture.moveTo(painterTopLeft + Offset(120, eraseY));
    await eraseGesture.moveTo(painterTopLeft + Offset(280, eraseY));
    await eraseGesture.up();
    await tester.pumpAndSettle();

    expect(controller.drawables, hasLength(3));
    final groupedDrawable = controller.drawables[0] as GroupedDrawable;
    expect(groupedDrawable.drawables, [same(stroke)]);
    expect(controller.drawables[1], isA<EraseDrawable>());
    expect(controller.drawables[2], same(movedImage));
    expect(controller.selectedObjectDrawable, isNull);

    final movedImageCenter = painterTopLeft + movedImage.position;
    await tester.tapAt(movedImageCenter);
    await tester.pumpAndSettle();
    expect(controller.selectedObjectDrawable, same(movedImage));

    final secondMoveGesture = await tester.startGesture(movedImageCenter);
    await secondMoveGesture.moveBy(const Offset(20, 20));
    await tester.pump();
    await secondMoveGesture.moveBy(const Offset(-20, 30));
    await secondMoveGesture.up();
    await tester.pumpAndSettle();
    expect(
      controller.selectedObjectDrawable!.position,
      isNot(movedImage.position),
    );

    controller.undo();
    controller.undo();

    expect(controller.drawables, [same(stroke), same(movedImage)]);
    expect(controller.selectedObjectDrawable, same(movedImage));
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

  testWidgets('labeled factory preserves a label through a line gesture', (
    tester,
  ) async {
    const label = ShapeLabel(text: '120 mm');
    final controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(
          factory: LabeledShapeFactory(
            factory: DoubleArrowFactory(),
            label: label,
          ),
        ),
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
    await gesture.moveBy(const Offset(120, 40));
    await gesture.up();
    await tester.pump();

    final drawable = controller.drawables.single as LabeledSized1DShapeDrawable;
    expect(drawable.shape, isA<DoubleArrowDrawable>());
    expect(drawable.label, same(label));
    expect(drawable.length, closeTo(126.49, 0.01));
  });

  testWidgets('labeled factory preserves a label through a box gesture', (
    tester,
  ) async {
    const label = ShapeLabel(text: 'Room A');
    final controller = PainterController(
      settings: PainterSettings(
        shape: ShapeSettings(
          factory: LabeledShapeFactory(
            factory: RectangleFactory(),
            label: label,
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildPainter(controller));
    await tester.pumpAndSettle();

    final start =
        tester.getTopLeft(find.byType(FlutterPainter)) + const Offset(160, 160);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-20, -10));
    await tester.pump();
    await gesture.moveBy(const Offset(-100, -80));
    await gesture.up();
    await tester.pump();

    final drawable = controller.drawables.single as LabeledSized2DShapeDrawable;
    expect(drawable.shape, isA<RectangleDrawable>());
    expect(drawable.label, same(label));
    expect(drawable.size, const Size(100, 80));
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

Future<ui.Image> _createTestImage() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 40, 40),
    Paint()..color = Colors.red,
  );
  return recorder.endRecording().toImage(40, 40);
}

int _alphaAt(
  ByteData pixels, {
  required int width,
  required int x,
  required int y,
}) {
  return pixels.getUint8(((y * width) + x) * 4 + 3);
}

class RecordingBackgroundDrawable extends BackgroundDrawable {
  final List<Size> sizes = [];

  @override
  void draw(Canvas canvas, Size size) {
    sizes.add(size);
  }
}
