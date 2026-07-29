import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example renders the painter', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(FlutterPainter), findsOneWidget);
  });

  testWidgets('background can rotate without replacing the painter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final controller = painter.controller;
    final originalBackground =
        controller.value.background as ImageBackgroundDrawable;

    await tester.tap(find.byTooltip('Rotate background'));
    await tester.pump();

    final rotatedBackground =
        controller.value.background as ImageBackgroundDrawable;
    expect(rotatedBackground.image, same(originalBackground.image));
    expect(rotatedBackground.quarterTurns, 1);
    expect(
      tester.widget<FlutterPainter>(find.byType(FlutterPainter)).controller,
      same(controller),
    );
  });

  testWidgets('text alignment can be selected before editing', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start aligned'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textAlign, TextAlign.start);
  });

  testWidgets('selected text can be reopened from the toolbar', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start aligned'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Edit me again');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tapAt(tester.getCenter(find.byType(FlutterPainter)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit selected text'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'Edit me again');
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('free style hue slider stays at its right boundary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.gesture));
    await tester.pumpAndSettle();

    final hueSlider = find.byWidgetPredicate(
      (widget) => widget is Slider && widget.min == 0 && widget.max == 359.8,
    );
    final slider = tester.widget<Slider>(hueSlider);

    slider.onChanged?.call(slider.max);
    await tester.pump();

    expect(tester.widget<Slider>(hueSlider).value, closeTo(slider.max, 0.05));
  });

  testWidgets('dotted brush creates a custom free-style drawable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.gesture));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dotted brush'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    expect(painter.controller.freeStyleFactory, isA<DottedFreeStyleFactory>());

    final painterCenter = tester.getCenter(find.byType(FlutterPainter));
    final gesture = await tester.startGesture(
      painterCenter - const Offset(300, 0),
    );
    await gesture.moveBy(const Offset(30, 20));
    await gesture.up();
    await tester.pump();

    expect(painter.controller.drawables.single, isA<DottedFreeStyleDrawable>());
  });

  testWidgets('cropped image sample can reset and reapply its crop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add cropped sample'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    expect(
      painter.controller.selectedObjectDrawable,
      isA<ImageDrawable>().having(
        (drawable) => drawable.isCropped,
        'isCropped',
        isTrue,
      ),
    );

    await tester.tap(find.text('Reset Crop'));
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as ImageDrawable).isCropped,
      isFalse,
    );

    await tester.tap(find.text('Crop Center'));
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as ImageDrawable).isCropped,
      isTrue,
    );
  });

  testWidgets('blurred oval sample can change blur and clipping shape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add blurred oval'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final blurred = painter.controller.selectedObjectDrawable as ImageDrawable;
    expect(blurred.isCropped, isTrue);
    expect(blurred.blurSigma, 16);
    expect(blurred.shape, ImageDrawableShape.oval);

    await tester.tap(find.text('Use Rectangle'));
    await tester.pumpAndSettle();
    expect(
      (painter.controller.selectedObjectDrawable as ImageDrawable).shape,
      ImageDrawableShape.rectangle,
    );
  });

  testWidgets('labeled shape can be drawn and its text updated', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add shape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Labeled Double Arrow'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final painterTopLeft = tester.getTopLeft(find.byType(FlutterPainter));
    await tester.dragFrom(
      painterTopLeft + const Offset(200, 120),
      const Offset(240, 0),
    );
    await tester.pumpAndSettle();

    final drawable =
        painter.controller.drawables.single as LabeledSized1DShapeDrawable;
    expect(drawable.label.text, '120 mm');

    painter.controller.selectObjectDrawable(drawable);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Label'));
    await tester.pumpAndSettle();

    expect(
      (painter.controller.selectedObjectDrawable as LabeledShapeDrawable)
          .label
          .text,
      '240 mm',
    );
  });

  testWidgets('angle can be drawn and changed to a reflex sweep', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add shape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Angle'));
    await tester.pumpAndSettle();

    final painter = tester.widget<FlutterPainter>(find.byType(FlutterPainter));
    final start =
        tester.getTopLeft(find.byType(FlutterPainter)) + const Offset(300, 250);
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
    expect(angleSlider, findsOneWidget);

    tester.widget<Slider>(angleSlider).onChanged?.call(120);
    await tester.pumpAndSettle();

    final updated = painter.controller.selectedObjectDrawable as AngleDrawable;
    expect(updated.sweepAngleDegrees, closeTo(120, 0.0001));

    painter.controller.undo();
    expect(
      (painter.controller.selectedObjectDrawable as AngleDrawable)
          .sweepAngleDegrees,
      closeTo(235, 0.1),
    );
    painter.controller.redo();
    expect(
      (painter.controller.selectedObjectDrawable as AngleDrawable)
          .sweepAngleDegrees,
      closeTo(120, 0.0001),
    );
  });

  testWidgets('font size slider stays interactive while editing text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    try {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add text'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start aligned'));
      await tester.pumpAndSettle();

      expect(tester.testTextInput.isVisible, isTrue);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();

      final fontSizeSlider = find.byWidgetPredicate(
        (widget) => widget is Slider && widget.min == 8 && widget.max == 96,
      );
      final adaptiveFontSizeSlider = find.descendant(
        of: fontSizeSlider,
        matching: find.byType(CupertinoSlider),
      );
      final initialValue = tester.widget<Slider>(fontSizeSlider).value;
      final sliderRect = tester.getRect(adaptiveFontSizeSlider);
      final initialPosition = (initialValue - 8) / (96 - 8);
      final horizontalPadding = sliderRect.height / 2;
      final thumbCenter = Offset(
        sliderRect.left +
            horizontalPadding +
            (sliderRect.width - 2 * horizontalPadding) * initialPosition,
        sliderRect.center.dy,
      );

      await tester.dragFrom(thumbCenter, const Offset(140, 0));
      await tester.pump();

      final updatedValue = tester.widget<Slider>(fontSizeSlider).value;
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedValue, greaterThan(initialValue));
      expect(textField.style?.fontSize, updatedValue);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
