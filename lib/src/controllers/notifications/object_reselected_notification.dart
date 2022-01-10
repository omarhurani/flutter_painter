import '../drawables/object_drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when the selected [ObjectDrawable] of ObjectWidget is reselected.
///
/// This means that if the object drawable is selected and it is tapped/clicked on, this notification is dispatched.
class ObjectDrawableReselectedNotification
    extends DrawableNotification<ObjectDrawable?> {
  /// Creates a [ObjectDrawableReselectedNotification] with the given [drawable].
  ObjectDrawableReselectedNotification(ObjectDrawable? drawable)
      : super(drawable);
}
