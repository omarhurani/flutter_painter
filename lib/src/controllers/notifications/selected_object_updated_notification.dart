import '../drawables/object_drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when the selected [ObjectDrawable] of ObjectWidget changes.
///
/// Note that [drawable] will only be valid until the drawable is modified (moved, scaled, rotated, etc...),
/// so use this callback as a reference that the selected object drawable changed internally and nothing
/// more to avoid issues.
///
/// Use [PainterController.selectedObjectDrawable] if you want to do any operations on the selected object drawable.
class SelectedObjectDrawableUpdatedNotification
    extends DrawableNotification<ObjectDrawable?> {
  /// Creates a [SelectedObjectDrawableUpdatedNotification] with the given [drawable].
  SelectedObjectDrawableUpdatedNotification(ObjectDrawable? drawable)
      : super(drawable);
}
