import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of adding a list of drawables to the [PainterController].
class AddDrawablesAction extends ControllerAction<void, void> {
  /// The list of drawables to be added to the controller.
  final List<Drawable> drawables;

  /// Creates a [AddDrawablesAction].
  ///
  /// [drawables] is the list of drawables to be added to the controller.
  AddDrawablesAction(this.drawables);

  /// Performs the action.
  ///
  /// Adds [drawables] to the end of the drawables in [controller.value].
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.addAll(drawables);
    controller.value = value.copyWith(drawables: currentDrawables);
  }

  /// Un-performs the action.
  ///
  /// Removes the added [drawables] from the end of the drawables in [controller.value].
  @protected
  @override
  void unperform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    for (final drawable in drawables.reversed) {
      final index = currentDrawables.lastIndexOf(drawable);
      currentDrawables.removeAt(index);
    }
    controller.value = value.copyWith(drawables: currentDrawables);
  }
}
