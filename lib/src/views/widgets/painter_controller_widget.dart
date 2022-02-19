import 'package:flutter/widgets.dart';
import '../../controllers/painter_controller.dart';

class PainterControllerWidget extends InheritedWidget {
  const PainterControllerWidget({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final PainterController controller;

  static PainterControllerWidget of(BuildContext context) {
    final PainterControllerWidget? result =
        context.dependOnInheritedWidgetOfExactType<PainterControllerWidget>();
    assert(result != null, 'No PainterControllerWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(PainterControllerWidget oldWidget) {
    return controller != oldWidget.controller;
  }
}
