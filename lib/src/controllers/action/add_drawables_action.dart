import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

class AddDrawablesAction extends ControllerAction<void, void>{

  final List<Drawable> drawables;

  AddDrawablesAction(this.drawables);

  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.addAll(drawables);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    for(final drawable in drawables.reversed){
      final index = currentDrawables.lastIndexOf(drawable);
      currentDrawables.removeAt(index);
    }
    controller.value = value.copyWith(drawables: currentDrawables);
  }
}