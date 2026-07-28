import '../drawables/text_drawable.dart';
import 'painter_event.dart';

/// An event representing the controller requesting to edit a [TextDrawable].
class EditTextPainterEvent extends PainterEvent {
  /// The text drawable to open in the editor.
  final TextDrawable drawable;

  /// Creates an [EditTextPainterEvent] for [drawable].
  const EditTextPainterEvent(this.drawable);
}
