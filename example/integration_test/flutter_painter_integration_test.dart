import 'dart:ui' as ui;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('draws, relabels, restores, and exports a labeled shape', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add shape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Labeled Double Arrow'));
    await tester.pumpAndSettle();

    final painterFinder = find.byType(FlutterPainter);
    final painter = tester.widget<FlutterPainter>(painterFinder);
    final start = tester.getTopLeft(painterFinder) + const Offset(60, 100);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(20, 5));
    await tester.pump();
    await gesture.moveBy(const Offset(180, 20));
    await gesture.up();
    await tester.pumpAndSettle();

    final original =
        painter.controller.drawables.single as LabeledSized1DShapeDrawable;
    expect(original.label.text, '120 mm');
    expect(original.length, greaterThan(150));

    painter.controller.selectObjectDrawable(original);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Label'));
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as LabeledShapeDrawable)
          .label
          .text,
      '240 mm',
    );

    painter.controller.undo();
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as LabeledShapeDrawable)
          .label
          .text,
      '120 mm',
    );

    painter.controller.redo();
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as LabeledShapeDrawable)
          .label
          .text,
      '240 mm',
    );

    await tester.tap(find.byIcon(Icons.image).last);
    await tester.pumpAndSettle();
    expect(find.text('Rendered Image'), findsOneWidget);
  });

  testWidgets('renders each of the first iOS free-style strokes', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.gesture));
    await tester.pumpAndSettle();

    final painterFinder = find.byType(FlutterPainter);
    final painter = tester.widget<FlutterPainter>(painterFinder);
    final painterTopLeft = tester.getTopLeft(painterFinder);
    var previousRedPixels = 0;

    for (var strokeIndex = 0; strokeIndex < 3; strokeIndex++) {
      final start = painterTopLeft + Offset(80, 100 + strokeIndex * 35.0);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(90, 0));
      await tester.pump();

      expect(
        painter.controller.drawables.whereType<FreeStyleDrawable>(),
        hasLength(strokeIndex + 1),
      );
      final rendered = await painter.controller.renderImage(
        const Size(320, 240),
      );
      final redPixels = await _countOpaqueRedPixels(rendered);
      rendered.dispose();
      expect(redPixels, greaterThan(previousRedPixels));
      previousRedPixels = redPixels;

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('fills, restores, renders, and undoes a coloring region', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Flood fill'));
    await tester.pumpAndSettle();

    final painterFinder = find.byType(FlutterPainter);
    final painter = tester.widget<FlutterPainter>(painterFinder);
    await tester.tapAt(tester.getCenter(painterFinder));
    for (
      var attempt = 0;
      attempt < 100 &&
          painter.controller.drawables.whereType<FloodFillDrawable>().isEmpty;
      attempt++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }

    final fill = painter.controller.drawables.single as FloodFillDrawable;
    expect(fill.color, const Color(0xFFFF0000));
    expect(fill.tolerance, 8);
    expect(fill.spans, isNotEmpty);

    final rendered = await painter.controller.renderImage(
      const Size(1280, 720),
    );
    addTearDown(rendered.dispose);
    final pixels = await rendered.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    final centerOffset = (360 * 1280 + 640) * 4;
    expect(pixels!.getUint8(centerOffset), greaterThan(240));
    expect(pixels.getUint8(centerOffset + 1), lessThan(20));
    expect(pixels.getUint8(centerOffset + 2), lessThan(20));

    final codec = DrawableJsonCodec();
    final restored = await codec.decodeJson(
      await codec.encodeJson(painter.controller.drawables),
    );
    final restoredFill = restored.single as FloodFillDrawable;
    expect(restoredFill.spans.length, fill.spans.length);
    expect(restoredFill.coordinateSize, fill.coordinateSize);

    painter.controller.undo();
    await tester.pumpAndSettle();
    expect(painter.controller.drawables, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('counts sticker tags after replacement and export', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 20, 20),
      ui.Paint()..color = Colors.orange,
    );
    final stickerImage = await recorder.endRecording().toImage(20, 20);
    addTearDown(stickerImage.dispose);

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final controller = painter.controller;
    controller.addTaggedImage(
      stickerImage,
      tag: 'star',
      size: const Size(40, 40),
    );
    controller.addTaggedImage(
      stickerImage,
      tag: 'star',
      size: const Size(40, 40),
    );
    controller.addTaggedImage(
      stickerImage,
      tag: 'heart',
      size: const Size(40, 40),
    );
    controller.addImage(stickerImage, const Size(40, 40));
    await tester.pumpAndSettle();

    expect(controller.imageDrawableCountsByTag, {'star': 2, 'heart': 1});

    final original = controller.drawables.first as ImageDrawable;
    controller.replaceDrawable(
      original,
      original.copyWith(position: const Offset(80, 80), opacity: 0.5),
    );
    await tester.pumpAndSettle();
    expect(controller.imageDrawableCountsByTag, {'star': 2, 'heart': 1});

    final rendered = await controller.renderImage(const Size(200, 200));
    addTearDown(rendered.dispose);
    expect(rendered.width, 200);
    expect(rendered.height, 200);
  });

  testWidgets('renders and restores a blurred rectangle redaction', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add blurred rectangle'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final original = painter.controller.selectedObjectDrawable as ImageDrawable;
    expect(original.isCropped, isTrue);
    expect(original.blurSigma, 16);
    expect(original.shape, ImageDrawableShape.rectangle);

    final rendered = await painter.controller.renderImage(
      const Size(1280, 720),
    );
    addTearDown(rendered.dispose);
    expect(rendered.width, 1280);
    expect(rendered.height, 720);

    final codec = DrawableJsonCodec();
    final restored = await codec.decodeJson(
      await codec.encodeJson(painter.controller.drawables),
    );
    final restoredImage = restored.single as ImageDrawable;
    addTearDown(restoredImage.image.dispose);
    expect(restoredImage.blurSigma, 16);
    expect(restoredImage.shape, ImageDrawableShape.rectangle);

    final restoredController = PainterController(drawables: restored);
    addTearDown(restoredController.dispose);
    final restoredRender = await restoredController.renderImage(
      const Size(1280, 720),
    );
    addTearDown(restoredRender.dispose);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saves, clears, restores, and exports drawable JSON', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawCircle(const Offset(10, 10), 10, ui.Paint()..color = Colors.purple);
    final stickerImage = await recorder.endRecording().toImage(20, 20);
    addTearDown(stickerImage.dispose);

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final controller = painter.controller;
    controller.addTaggedImage(
      stickerImage,
      tag: 'saved-sticker',
      size: const Size(40, 40),
    );
    controller.addDrawables([
      TextDrawable(
        text: 'Restored text',
        position: const Offset(80, 80),
        style: const TextStyle(fontSize: 18, color: Colors.blue),
      ),
      LineDrawable(
        length: 80,
        position: const Offset(120, 120),
        paint: Paint()
          ..color = Colors.red
          ..strokeWidth = 4,
      ),
    ]);
    await tester.pumpAndSettle();

    final codec = DrawableJsonCodec();
    final savedJson = await codec.encodeJson(controller.drawables);
    expect(savedJson, contains('"schemaVersion":1'));

    controller.clearDrawables();
    final restored = await codec.decodeJson(savedJson);
    final restoredImage = restored.whereType<ImageDrawable>().single.image;
    addTearDown(restoredImage.dispose);
    controller.addDrawables(restored, newAction: false);
    await tester.pumpAndSettle();

    expect(controller.drawables, hasLength(3));
    expect(controller.imageDrawableCountsByTag, {'saved-sticker': 1});
    expect(controller.drawables.whereType<TextDrawable>(), hasLength(1));
    expect(controller.drawables.whereType<LineDrawable>(), hasLength(1));

    final rendered = await controller.renderImage(const Size(200, 200));
    addTearDown(rendered.dispose);
    expect(rendered.width, 200);
    expect(rendered.height, 200);
  });

  testWidgets('groups, moves, restores, and ungroups a shape and sticker', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 20, 20),
      ui.Paint()..color = Colors.teal,
    );
    final stickerImage = await recorder.endRecording().toImage(20, 20);
    addTearDown(stickerImage.dispose);

    final painterFinder = find.byType(FlutterPainter);
    final painter = tester.widget<FlutterPainter>(painterFinder);
    final controller = painter.controller;
    final rectangle = RectangleDrawable(
      size: const Size(60, 40),
      position: const Offset(90, 120),
      paint: Paint()..color = Colors.orange,
    );
    final sticker = ImageDrawable(
      image: stickerImage,
      tag: 'grouped-sticker',
      position: const Offset(170, 140),
      scale: 2,
    );
    controller.addDrawables([rectangle, sticker]);
    final group = controller.groupObjectDrawables([rectangle, sticker]);
    await tester.pumpAndSettle();

    expect(group, isNotNull);
    expect(controller.drawables.single, same(group));
    expect(controller.selectedObjectDrawable, same(group));

    final start = tester.getTopLeft(painterFinder) + group!.position;
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(20, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(40, 20));
    await gesture.up();
    await tester.pumpAndSettle();

    final movedGroup =
        controller.selectedObjectDrawable! as ObjectGroupDrawable;
    expect(movedGroup.position, group.position + const Offset(40, 20));

    controller.undo();
    await tester.pumpAndSettle();
    expect(controller.selectedObjectDrawable, same(group));
    controller.redo();
    await tester.pumpAndSettle();
    expect(controller.selectedObjectDrawable, isA<ObjectGroupDrawable>());

    final restored = controller.ungroupSelectedObjectDrawable();
    await tester.pumpAndSettle();
    expect(restored, hasLength(2));
    expect(restored!.whereType<ImageDrawable>().single.tag, 'grouped-sticker');

    final rendered = await controller.renderImage(const Size(220, 180));
    addTearDown(rendered.dispose);
    expect(rendered.width, 220);
    expect(rendered.height, 180);
  });

  testWidgets('draws, edits, restores, and exports a reflex angle', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add shape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Angle'));
    await tester.pumpAndSettle();

    final painterFinder = find.byType(FlutterPainter);
    final painter = tester.widget<FlutterPainter>(painterFinder);
    final start = tester.getTopLeft(painterFinder) + const Offset(220, 180);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-20, -30));
    await tester.pump();
    await gesture.moveBy(const Offset(-100, -142.8));
    await gesture.up();
    await tester.pumpAndSettle();

    final original = painter.controller.drawables.single as AngleDrawable;
    expect(original.sweepAngleDegrees, closeTo(235, 0.1));

    painter.controller.selectObjectDrawable(original);
    await tester.pumpAndSettle();
    final angleSlider = find.byWidgetPredicate(
      (widget) => widget is Slider && widget.max == 360,
    );
    final slider = tester.widget<Slider>(angleSlider);
    slider.onChangeStart?.call(slider.value);
    slider.onChanged?.call(120);
    slider.onChangeEnd?.call(120);
    await tester.pumpAndSettle();

    final updated = painter.controller.selectedObjectDrawable as AngleDrawable;
    expect(updated.sweepAngleDegrees, closeTo(120, 0.0001));

    final codec = DrawableJsonCodec();
    final restored = await codec.decodeJson(
      await codec.encodeJson(painter.controller.drawables),
    );
    final restoredController = PainterController(drawables: restored);
    addTearDown(restoredController.dispose);
    final restoredAngle = restored.single as AngleDrawable;
    expect(restoredAngle.sweepAngleDegrees, closeTo(120, 0.0001));

    final rendered = await restoredController.renderImage(const Size(240, 180));
    addTearDown(rendered.dispose);
    expect(rendered.width, 240);
    expect(rendered.height, 180);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'retains independent PageView drawings without live image leaks',
    (tester) async {
      Future<ui.Image> createImage(Color color) async {
        final recorder = ui.PictureRecorder();
        ui.Canvas(recorder).drawRect(
          const Rect.fromLTWH(0, 0, 40, 30),
          ui.Paint()..color = color,
        );
        return recorder.endRecording().toImage(40, 30);
      }

      final firstImage = await createImage(Colors.indigo);
      final secondImage = await createImage(Colors.amber);
      addTearDown(firstImage.dispose);
      addTearDown(secondImage.dispose);
      final controllers = [
        PainterController(background: firstImage.backgroundDrawable),
        PainterController(background: secondImage.backgroundDrawable),
      ];
      addTearDown(() {
        for (final controller in controllers) {
          controller.dispose();
        }
      });

      final imageData = await firstImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final imageBytes = imageData!.buffer.asUint8List();
      final initialLiveImages =
          PaintingBinding.instance.imageCache.liveImageCount;
      for (var index = 0; index < 20; index++) {
        final resolvedImage = await MemoryImage(imageBytes).image;
        resolvedImage.dispose();
      }
      await tester.pump();
      expect(
        PaintingBinding.instance.imageCache.liveImageCount,
        initialLiveImages,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 180,
              child: PageView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) =>
                    FlutterPainter(controller: controllers[index]),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controllers.first.addText();
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'first page');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      controllers.last.addText();
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'second page');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(controllers.first.drawables, hasLength(1));
      expect(
        (controllers.first.drawables.single as TextDrawable).text,
        'first page',
      );
      expect(controllers.last.drawables, hasLength(1));
      expect(
        (controllers.last.drawables.single as TextDrawable).text,
        'second page',
      );

      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pumpAndSettle();
      final firstRendered = await controllers.first.renderImage(
        const Size(200, 150),
      );
      final secondRendered = await controllers.last.renderImage(
        const Size(200, 150),
      );
      addTearDown(firstRendered.dispose);
      addTearDown(secondRendered.dispose);
      expect(firstRendered.width, 200);
      expect(secondRendered.width, 200);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

Future<int> _countOpaqueRedPixels(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return 0;

  var count = 0;
  for (var index = 0; index < data.lengthInBytes; index += 4) {
    if (data.getUint8(index) > 230 &&
        data.getUint8(index + 1) < 40 &&
        data.getUint8(index + 2) < 40 &&
        data.getUint8(index + 3) > 200) {
      count++;
    }
  }
  return count;
}
