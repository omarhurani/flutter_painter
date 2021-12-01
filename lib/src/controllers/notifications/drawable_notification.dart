import 'notification.dart';
import '../drawables/drawable.dart';

/// Abstract class that defines any [FlutterPainterNotification] that targets a [Drawable].
abstract class DrawableNotification<T extends Drawable?>
    extends FlutterPainterNotification {
  /// The [Drawable] the notification represents.
  final T drawable;

  /// Constructor to assign the [drawable].
  const DrawableNotification(this.drawable);
}
