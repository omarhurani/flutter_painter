import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../widget_test_utils.dart';

void main() {
  final testbed = WidgetTestbed();

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
}
