import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of inserting a list of drawables to the [PainterController] at
/// a specific index.
class InsertDrawablesAction extends ControllerAction<void, void> {
  /// The list of drawables to be inserted into the controller.
  final List<Drawable> drawables;

  /// The index at which the drawables are be inserted.
  final int index;

  /// Creates an [InsertDrawablesAction] with the [index] to insert the [drawables] at.
  InsertDrawablesAction(this.index, this.drawables);

  /// Performs the action.
  ///
  /// Inserts [drawables] into the list of drawables in [controller.value] at [index].
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.insertAll(index, drawables);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

  /// Un-performs the action.
  ///
  /// Removes drawables from the list of drawables in [controller.value]
  /// starting from [index] and at the length of [drawables].
  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.removeRange(index, index + drawables.length);
    controller.value = value.copyWith(drawables: currentDrawables);
  }
}
