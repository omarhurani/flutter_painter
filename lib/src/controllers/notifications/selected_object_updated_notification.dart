import '../drawables/object_drawable.dart';
import '../../views/widgets/flutter_painter.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when the selected [ObjectDrawable] of [ObjectWidget] changes.
class SelectedObjectDrawableUpdatedNotification
    extends DrawableNotification<ObjectDrawable?> {
  /// Creates a [SelectedObjectDrawableUpdatedNotification] with the given [drawable].
  SelectedObjectDrawableUpdatedNotification(ObjectDrawable? drawable)
      : super(drawable);
}
