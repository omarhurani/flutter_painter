import '../drawables/drawable.dart';

import 'painter_event.dart';

/// An event representing the controller requesting to add a new [TextDrawable] to the painter.
class RemoveDrawableEvent extends PainterEvent {
  final Drawable drawable;

  /// Creates an [RemoveDrawableEvent].
  const RemoveDrawableEvent(this.drawable);
}
