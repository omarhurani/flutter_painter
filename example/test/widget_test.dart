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
