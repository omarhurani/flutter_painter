import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

class InsertDrawablesAction extends ControllerAction<void, void>{

  final List<Drawable> drawables;

  final int index;

  InsertDrawablesAction(this.index, this.drawables);

  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.insertAll(index, drawables);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.removeRange(index, index+drawables.length);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

}