import 'package:flutter/foundation.dart';
import 'package:flutter_painter/src/controllers/painter_controller.dart';

import 'action.dart';

class GroupedAction extends ControllerAction<void, void>{

  final List<ControllerAction> actions;

  GroupedAction(this.actions);

  @protected
  @override
  void perform$(PainterController controller) {
    for(final action in actions)
      action.perform(controller);
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    for(final action in actions.reversed)
      action.unperform(controller);
  }

  @override
  String toString() {
    return "${super.toString()}: [${actions.map((e) => e.toString()).fold('', (previousValue, element) => '$previousValue, $element')}]";
  }
}