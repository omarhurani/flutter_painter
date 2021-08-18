part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class FreeStyleWidget extends StatefulWidget {

  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// Child widget.
  final Widget child;

  /// Creates a [FreeStyleWidget] with the given [controller], [child] widget.
  const FreeStyleWidget({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  FreeStyleWidgetState createState() => FreeStyleWidgetState();
}

/// State class
class FreeStyleWidgetState extends State<FreeStyleWidget> {

  /// The current drawable being drawn.
  FreeStyleDrawable? drawable;

  @override
  Widget build(BuildContext context) {
    if(!settings.enabled)
      return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      child: widget.child,
    );
  }

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings =>
      widget.controller.value.settings.freeStyle;

  /// Callback when the user holds their pointer(s) down onto the widget.
  void onScaleStart(ScaleStartDetails event){
    // If the user is already drawing, don't create a new drawing
    if(this.drawable != null)
      return;

    // If the user is trying to draw with multiple pointers, ignore user input
    // Drawing with two pointers causes an issue, so this is to avoid it
    if(event.pointerCount > 1)
      return;

    // Create a new free-style drawable representing the current drawing
    final drawable = FreeStyleDrawable(
      path: [event.localFocalPoint],
      color: settings.color,
      strokeWidth: settings.strokeWidth,
    );
    // Add the drawable to the controller's drawables
    widget.controller.addDrawables([drawable]);
    // Set the drawable as the current drawable
    this.drawable = drawable;
  }

  /// Callback when the user moves, rotates or scales the pointer(s).
  void onScaleUpdate(ScaleUpdateDetails event){
    final drawable = this.drawable;
    // If there is no current drawable, ignore user input
    if(drawable == null)
      return;

    // If the user is trying to draw with multiple pointers, ignore user input
    // Drawing with two pointers causes an issue, so this is to avoid it
    if(event.pointerCount > 1)
      this.drawable = null;

    // Add the new point to a copy of the current drawable
    final newDrawable = drawable.copyWith(
      path: List<Offset>.from(drawable.path)..add(event.localFocalPoint),
    );
    // Replace the current drawable with the copy with the added point
    widget.controller.replaceDrawable(drawable, newDrawable);
    // Update the current drawable to be the new copy
    this.drawable = newDrawable;
  }

  /// Callback when the user removes all pointers from the widget.
  void onScaleEnd(ScaleEndDetails event){
    /// Reset the current drawable for the user to draw a new one next time
    drawable = null;
  }
}
