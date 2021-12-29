import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';
import 'add_drawables_action.dart';
import 'insert_drawables_action.dart';

class RemoveDrawableAction extends ControllerAction<bool, bool>{

  final Drawable drawable;

  int? _removedIndex;

  RemoveDrawableAction(this.drawable);

  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    final index = currentDrawables.indexOf(drawable);
    if (index < 0)
      return false;
    currentDrawables.removeAt(index);
    _removedIndex = index;
    controller.value = value.copyWith(drawables: currentDrawables);
    return true;
  }

  @protected
  @override
  bool unperform$(PainterController controller) {
    final removedIndex = _removedIndex;
    if(removedIndex == null)
      return false;
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.insert(removedIndex, drawable);
    controller.value = value.copyWith(drawables: currentDrawables);
    _removedIndex = null;
    return true;
  }

  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction){
    if(previousAction is AddDrawablesAction && previousAction.drawables.length == 1 && previousAction.drawables.first == drawable)
      return null;
    if(previousAction is InsertDrawablesAction && previousAction.drawables.length == 1 && previousAction.drawables.first == drawable)
      return null;
    return super.merge$(previousAction);
  }
}