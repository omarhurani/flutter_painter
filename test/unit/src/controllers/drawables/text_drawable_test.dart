import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('text drawable preserves and updates text alignment', () {
    final drawable = TextDrawable(
      text: 'Aligned text',
      position: Offset.zero,
      textAlign: TextAlign.end,
    );

    expect(drawable.textAlign, TextAlign.end);
    expect(drawable.textPainter.textAlign, TextAlign.end);

    final copy = drawable.copyWith(textAlign: TextAlign.start);

    expect(copy.textAlign, TextAlign.start);
    expect(copy.textPainter.textAlign, TextAlign.start);
    expect(drawable.textAlign, TextAlign.end);
  });

  test('controller text alignment updates text settings', () {
    final controller = PainterController();
    addTearDown(controller.dispose);

    expect(controller.textAlign, TextAlign.center);

    controller.textAlign = TextAlign.end;

    expect(controller.textAlign, TextAlign.end);
    expect(controller.textSettings.textAlign, TextAlign.end);
  });
}
