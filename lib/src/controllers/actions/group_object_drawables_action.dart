import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';
import '../drawables/object_drawable.dart';
import '../drawables/object_group_drawable.dart';
import '../painter_controller.dart';
import 'action.dart';

/// Groups selected top-level object drawables into one transformable object.
class GroupObjectDrawablesAction
    extends ControllerAction<ObjectGroupDrawable?, void> {
  /// The object drawables to group.
  final List<ObjectDrawable> drawables;

  /// Whether the new group should become the selected object.
  final bool selectGroup;

  /// Maximum width used when measuring children such as wrapped text.
  final double maxWidth;

  List<Drawable>? _previousDrawables;
  ObjectDrawable? _previousSelection;
  ObjectGroupDrawable? _group;

  /// Creates a grouping action.
  GroupObjectDrawablesAction(
    Iterable<ObjectDrawable> drawables, {
    this.selectGroup = true,
    this.maxWidth = double.infinity,
  }) : drawables = List.unmodifiable(drawables);

  @protected
  @override
  ObjectGroupDrawable? perform$(PainterController controller) {
    final value = controller.value;
    final requested = <ObjectDrawable>[];
    for (final drawable in drawables) {
      if (!requested.any((candidate) => identical(candidate, drawable))) {
        requested.add(drawable);
      }
    }
    if (requested.length < 2) return null;

    final selectedIndexes = <int>[];
    final selectedDrawables = <ObjectDrawable>[];
    for (var index = 0; index < value.drawables.length; index++) {
      final candidate = value.drawables[index];
      if (candidate is ObjectDrawable &&
          requested.any((drawable) => identical(drawable, candidate))) {
        selectedIndexes.add(index);
        selectedDrawables.add(candidate);
      }
    }
    if (selectedDrawables.length != requested.length) return null;

    final group =
        _group ??
        ObjectGroupDrawable.fromDrawables(
          drawables: selectedDrawables,
          maxWidth: maxWidth,
        );
    _group = group;
    _previousDrawables = value.drawables;
    _previousSelection = value.selectedObjectDrawable;

    final lastSelectedIndex = selectedIndexes.last;
    final nextDrawables = <Drawable>[];
    for (var index = 0; index < value.drawables.length; index++) {
      if (index == lastSelectedIndex) {
        nextDrawables.add(group);
      } else if (!selectedIndexes.contains(index)) {
        nextDrawables.add(value.drawables[index]);
      }
    }

    final previousSelection = value.selectedObjectDrawable;
    final selectionWasGrouped =
        previousSelection != null &&
        selectedDrawables.any(
          (drawable) => identical(drawable, previousSelection),
        );
    controller.value = value.copyWith(
      drawables: nextDrawables,
      selectedObjectDrawable: selectGroup
          ? group
          : selectionWasGrouped
          ? null
          : previousSelection,
    );
    return group;
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
