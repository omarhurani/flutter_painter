import 'package:flutter/foundation.dart';

import '../drawables/grouped_drawable.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

class MergeDrawablesAction extends ControllerAction<void, void>{

  MergeDrawablesAction();

  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;

    final currentDrawables = List<Drawable>.from(value.drawables);
    final groupedDrawable = GroupedDrawable(drawables: currentDrawables);
    controller.value = value.copyWith(
      drawables: [groupedDrawable],
      selectedObjectDrawable: null,
    );
  }

  // TODO: check for compatibility with old Flutter
  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    final last = currentDrawables.last;
    if(last is! GroupedDrawable)
      return;
    final drawables = last.drawables;
    currentDrawables.removeLast();
    currentDrawables.addAll(drawables);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

}