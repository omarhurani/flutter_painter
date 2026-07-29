import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';
import '../drawables/object_drawable.dart';
import '../drawables/object_group_drawable.dart';
import '../painter_controller.dart';
import 'action.dart';

/// Replaces a transformable object group with its world-space children.
class UngroupObjectDrawableAction
    extends ControllerAction<List<ObjectDrawable>?, void> {
  /// The group to ungroup.
  final ObjectGroupDrawable group;

  List<Drawable>? _previousDrawables;
  ObjectDrawable? _previousSelection;
  List<ObjectDrawable>? _ungroupedDrawables;

  /// Creates an ungrouping action.
  UngroupObjectDrawableAction(this.group);

  @protected
  @override
  List<ObjectDrawable>? perform$(PainterController controller) {
    final value = controller.value;
    final groupIndex = value.drawables.indexWhere(
      (drawable) => identical(drawable, group),
    );
    if (groupIndex < 0) return null;

    _previousDrawables = value.drawables;
    _previousSelection = value.selectedObjectDrawable;
    final ungrouped = _ungroupedDrawables ?? group.toWorldDrawables();
    _ungroupedDrawables = ungrouped;

    final nextDrawables = List<Drawable>.from(value.drawables)
      ..removeAt(groupIndex)
      ..insertAll(groupIndex, ungrouped);
    controller.value = value.copyWith(
      drawables: nextDrawables,
      selectedObjectDrawable: identical(value.selectedObjectDrawable, group)
          ? null
          : value.selectedObjectDrawable,
    );
    return ungrouped;
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    final previousDrawables = _previousDrawables;
    if (previousDrawables == null) return;
    controller.value = controller.value.copyWith(
      drawables: previousDrawables,
      selectedObjectDrawable: _previousSelection,
    );
  }
}
