import 'package:flutter_painter/src/controllers/painter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispose closes the controller event stream', () async {
    final controller = PainterController();
    final streamClosed = expectLater(controller.events, emitsDone);

    controller.dispose();

    await streamClosed;
  });
}
