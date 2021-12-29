import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

class ClearDrawablesAction extends ControllerAction<void, void>{

  List<Drawable>? _removedDrawables;

  ClearDrawablesAction();

  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    _removedDrawables = List<Drawable>.from(value.drawables);
    controller.value = value.copyWith(drawables: const <Drawable>[]);
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    final removedDrawables = _removedDrawables;
    if(removedDrawables == null)
      return;
    final value = controller.value;
    controller.value = value.copyWith(drawables: removedDrawables);
    _removedDrawables = null;
  }

  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction){
    return this;
  }
}