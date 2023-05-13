import 'notification.dart';

/// A notification that is dispatched when the user starts or stops freehand painting
class DrawableIsDrawingStateChangedNotification
    extends FlutterPainterNotification {
  bool isDrawing;

  /// Creates a [DrawableIsDrawingStateChangedNotification]. Supplies the current Drawable and also if the user started or stopped
  DrawableIsDrawingStateChangedNotification(this.isDrawing);
}
