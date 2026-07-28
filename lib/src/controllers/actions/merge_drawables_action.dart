import 'package:flutter/foundation.dart';

import '../drawables/grouped_drawable.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of merging drawables in the [PainterController] into a
/// [GroupedDrawable].
class MergeDrawablesAction extends ControllerAction<void, void> {
  /// Whether drawables that opt out of erasing should remain outside the group.
  final bool erasableOnly;

  List<Drawable>? _previousDrawables;

  /// Creates a [MergeDrawablesAction].
  MergeDrawablesAction({this.erasableOnly = false});

  /// Performs the action.
  ///
  /// Removes the affected drawables from [controller.value] and inserts a new
  /// [GroupedDrawable] containing them.
  ///
  /// Also deselects the selected object when it is included in the group.
  @protected
  @override
  void perform$(PainterController controller) {
    final value = controller.value;

    final currentDrawables = List<Drawable>.from(value.drawables);
    _previousDrawables = currentDrawables;

    final groupedDrawables = erasableOnly
        ? currentDrawables.where((drawable) => drawable.erasable).toList()
        : currentDrawables;
    final protectedDrawables = erasableOnly
        ? currentDrawables.where((drawable) => !drawable.erasable).toList()
        : const <Drawable>[];
    final groupedDrawable = GroupedDrawable(drawables: groupedDrawables);
    controller.value = value.copyWith(
      drawables: [groupedDrawable, ...protectedDrawables],
    );

    final selectedObject = value.selectedObjectDrawable;
    if (selectedObject != null && (!erasableOnly || selectedObject.erasable)) {
      controller.deselectObjectDrawable(isRemoved: true);
    }
  }

  /// Un-performs the action.
  ///
  /// Restores the exact drawable list from before the action.
  @protected
  @override
  void unperform$(PainterController controller) {
    final previousDrawables = _previousDrawables;
    if (previousDrawables == null) return;

    final value = controller.value;
    controller.value = value.copyWith(drawables: previousDrawables);
    _previousDrawables = null;
  }
}
