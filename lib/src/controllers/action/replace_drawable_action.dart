import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';
import 'add_drawables_action.dart';
import 'insert_drawables_action.dart';

class ReplaceDrawableAction extends ControllerAction<bool, bool>{

  final Drawable oldDrawable, newDrawable;

  ReplaceDrawableAction(this.oldDrawable, this.newDrawable);

  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final oldDrawableIndex = value.drawables.indexOf(oldDrawable);
    if (oldDrawableIndex < 0) // not found
      return false;

    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables
        .setRange(oldDrawableIndex, oldDrawableIndex + 1, [newDrawable]);
    controller.value = value.copyWith(drawables: currentDrawables);
    return true;
  }

  @protected
  @override
  bool unperform$(PainterController controller) {
    final value = controller.value;
    final newDrawableIndex = value.drawables.indexOf(newDrawable);
    if (newDrawableIndex < 0) // not found
      return false;

    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables
        .setRange(newDrawableIndex, newDrawableIndex + 1, [oldDrawable]);
    controller.value = value.copyWith(drawables: currentDrawables);
    return true;
  }

  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction){
    if(previousAction is AddDrawablesAction && previousAction.drawables.last == oldDrawable)
      return AddDrawablesAction([...previousAction.drawables]..removeLast()..add(newDrawable));
    if(previousAction is InsertDrawablesAction && previousAction.drawables.last == oldDrawable)
      return InsertDrawablesAction(previousAction.index, [...previousAction.drawables]..removeLast()..add(newDrawable));
    if(previousAction is ReplaceDrawableAction && previousAction.newDrawable == oldDrawable)
      return ReplaceDrawableAction(previousAction.oldDrawable, newDrawable);
    return super.merge$(previousAction);
  }
}