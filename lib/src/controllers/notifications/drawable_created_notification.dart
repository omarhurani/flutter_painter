import '../drawables/drawable.dart';
import 'drawable_notification.dart';

/// A notification that is dispatched when a drawable is created internally in Flutter Painter.
class DrawableCreatedNotification extends DrawableNotification<Drawable> {
  /// Creates a [DrawableCreatedNotification] with the given [drawable].
  DrawableCreatedNotification(drawable) : super(drawable);
}
