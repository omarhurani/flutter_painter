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
}
