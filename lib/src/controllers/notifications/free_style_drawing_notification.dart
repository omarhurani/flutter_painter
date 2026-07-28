import '../drawables/path/path_drawable.dart';
import 'notification.dart';

/// The lifecycle phase of a free-style drawing gesture.
enum FreeStyleDrawingPhase {
  /// The first pointer was accepted and a drawable was created.
  started,

  /// The accepted pointer moved and the drawable was updated.
  updated,

  /// The accepted pointer was released and the drawable was completed.
  ended,

  /// The gesture was canceled and its incomplete drawable was removed.
  canceled,
}

/// A notification dispatched as a free-style drawing gesture progresses.
class FreeStyleDrawingNotification extends FlutterPainterNotification {
  /// The latest drawable produced by the gesture.
  final PathDrawable drawable;

  /// The current lifecycle phase.
  final FreeStyleDrawingPhase phase;

  /// Creates a notification for [drawable] at [phase].
  const FreeStyleDrawingNotification(this.drawable, this.phase);
}
