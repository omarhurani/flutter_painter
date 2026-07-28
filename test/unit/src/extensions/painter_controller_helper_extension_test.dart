import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PainterControllerHelper.setDrawableColor', () {
    test('updates a selected shape and preserves undo and selection', () {
      const updatedColor = Color(0xFF2196F3);
      final originalPaint = Paint()..color = Colors.red;
      final shape = TriangleDrawable(
        position: Offset.zero,
        size: const Size(20, 20),
        paint: originalPaint,
      );
      final controller = PainterController(drawables: [shape]);
      addTearDown(controller.dispose);
      controller.selectObjectDrawable(shape);

      expect(controller.setDrawableColor(shape, updatedColor), isTrue);

      final updatedShape = controller.drawables.single as TriangleDrawable;
      expect(updatedShape.paint.color.toARGB32(), updatedColor.toARGB32());
      expect(updatedShape.paint.strokeWidth, originalPaint.strokeWidth);
      expect(originalPaint.color.toARGB32(), Colors.red.toARGB32());
      expect(controller.selectedObjectDrawable, same(updatedShape));

      controller.undo();

      expect(controller.drawables.single, same(shape));
      expect(controller.selectedObjectDrawable, same(shape));

      controller.redo();

      final redoneShape = controller.drawables.single as TriangleDrawable;
      expect(redoneShape.paint.color.toARGB32(), updatedColor.toARGB32());
      expect(controller.selectedObjectDrawable, same(redoneShape));
    });

    test('updates an existing free-style drawing color', () {
      final stroke = FreeStyleDrawable(
        path: const [Offset.zero, Offset(10, 10)],
        color: Colors.red,
        strokeWidth: 4,
      );
      final controller = PainterController(drawables: [stroke]);
      addTearDown(controller.dispose);

      expect(controller.setDrawableColor(stroke, Colors.green), isTrue);

      final updatedStroke = controller.drawables.single as FreeStyleDrawable;
      expect(updatedStroke.color, Colors.green);
      expect(updatedStroke.path, stroke.path);
      expect(updatedStroke.strokeWidth, stroke.strokeWidth);
    });

    test('updates text color without replacing the rest of its style', () {
      final text = TextDrawable(
        text: 'Color me',
        position: Offset.zero,
        style: const TextStyle(color: Colors.red, fontSize: 24),
      );
      final controller = PainterController(drawables: [text]);
      addTearDown(controller.dispose);

      expect(controller.setDrawableColor(text, Colors.purple), isTrue);

      final updatedText = controller.drawables.single as TextDrawable;
      expect(updatedText.style.color, Colors.purple);
      expect(updatedText.style.fontSize, 24);
    });

    test('rejects drawables without an editable color', () {
      final erase = EraseDrawable(
        path: const [Offset.zero, Offset(10, 10)],
        strokeWidth: 4,
      );
      final controller = PainterController(drawables: [erase]);
      addTearDown(controller.dispose);

      expect(controller.setDrawableColor(erase, Colors.blue), isFalse);
      expect(controller.drawables.single, same(erase));
    });
  });
}
