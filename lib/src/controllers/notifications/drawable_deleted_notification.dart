import '../drawables/drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when a drawable is deleted internally in Flutter Painter.
class DrawableDeletedNotification extends DrawableNotification<Drawable> {
  /// Creates a [DrawableDeletedNotification] with the given [drawable].
  DrawableDeletedNotification(drawable) : super(drawable);
}
