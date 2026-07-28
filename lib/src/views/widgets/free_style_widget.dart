part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class _FreeStyleWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates a [_FreeStyleWidget] with the given [controller], [child] widget.
  const _FreeStyleWidget({required this.child});

  @override
  _FreeStyleWidgetState createState() => _FreeStyleWidgetState();
}

/// State class
class _FreeStyleWidgetState extends State<_FreeStyleWidget> {
  /// The current drawable being drawn.
  PathDrawable? drawable;

  @override
  Widget build(BuildContext context) {
    if (settings.mode == FreeStyleMode.none || shapeSettings.factory != null) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _DragGestureDetector:
            GestureRecognizerFactoryWithHandlers<_DragGestureDetector>(
              () => _DragGestureDetector(
                shouldAcceptPointer: _shouldAcceptPointer,
                onHorizontalDragDown: _handleHorizontalDragDown,
                onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                onHorizontalDragUp: _handleHorizontalDragUp,
                onHorizontalDragCancel: _handleHorizontalDragCancel,
              ),
              (_) {},
            ),
      },
      child: widget.child,
    );
  }

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings =>
      PainterController.of(context).value.settings.freeStyle;

  /// Getter for [ShapeSettings] from `widget.controller.value` to make code more readable.
  ShapeSettings get shapeSettings =>
      PainterController.of(context).value.settings.shape;

  bool _shouldAcceptPointer(PointerDownEvent event) {
    if (settings.mode != FreeStyleMode.erase) return true;

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.globalToLocal(event.position);
    final controller = PainterController.of(context);
    final transformationScale = controller.transformationController.value
        .getMaxScaleOnAxis();
    final objectPadding = 25 / transformationScale;

    for (final drawable
        in controller.value.drawables
            .whereType<ObjectDrawable>()
            .toList()
            .reversed) {
      if (drawable.erasable || drawable.isHidden) continue;

      final offset = position - drawable.position;
      final cosine = cos(drawable.rotationAngle);
      final sine = sin(drawable.rotationAngle);
      final unrotated = Offset(
        offset.dx * cosine + offset.dy * sine,
        -offset.dx * sine + offset.dy * cosine,
      );
      final size = drawable.getSize(maxWidth: renderBox.size.width);
      final hitBounds = Rect.fromCenter(
        center: Offset.zero,
        width: size.width + objectPadding * 2,
        height: size.height + objectPadding * 2,
      );
      if (hitBounds.contains(unrotated)) return false;
    }

    return true;
  }

  /// Callback when the user holds their pointer(s) down onto the widget.
  void _handleHorizontalDragDown(Offset globalPosition) {
    // If the user is already drawing, don't create a new drawing
    if (this.drawable != null) return;

    // Create a new free-style drawable representing the current drawing
    final PathDrawable drawable;
    if (settings.mode == FreeStyleMode.draw) {
      drawable = FreeStyleDrawable(
        path: [_globalToLocal(globalPosition)],
        color: settings.color,
        strokeWidth: settings.strokeWidth,
      );

      // Add the drawable to the controller's drawables
      PainterController.of(context).addDrawables([drawable]);
    } else if (settings.mode == FreeStyleMode.erase) {
      drawable = EraseDrawable(
        path: [_globalToLocal(globalPosition)],
        strokeWidth: settings.strokeWidth,
      );
      final controller = PainterController.of(context);
      controller.groupErasableDrawables();

      // Keep protected drawables above the erase layer.
      controller.insertDrawables(1, [drawable], newAction: false);
    } else {
      return;
    }

    // Set the drawable as the current drawable
    this.drawable = drawable;
    FreeStyleDrawingNotification(
      drawable,
      FreeStyleDrawingPhase.started,
    ).dispatch(context);
  }

  /// Callback when the user moves, rotates or scales the pointer(s).
  void _handleHorizontalDragUpdate(Offset globalPosition) {
    final drawable = this.drawable;
    // If there is no current drawable, ignore user input
    if (drawable == null) return;

    // Add the new point to a copy of the current drawable
    final newDrawable = drawable.copyWith(
      path: List<Offset>.from(drawable.path)
        ..add(_globalToLocal(globalPosition)),
    );
    // Replace the current drawable with the copy with the added point
    PainterController.of(
      context,
    ).replaceDrawable(drawable, newDrawable, newAction: false);
    // Update the current drawable to be the new copy
    this.drawable = newDrawable;
    FreeStyleDrawingNotification(
      newDrawable,
      FreeStyleDrawingPhase.updated,
    ).dispatch(context);
  }

  /// Callback when the user removes all pointers from the widget.
  void _handleHorizontalDragUp() {
    final completedDrawable = drawable;
    if (completedDrawable == null) return;

    FreeStyleDrawingNotification(
      completedDrawable,
      FreeStyleDrawingPhase.ended,
    ).dispatch(context);
    DrawableCreatedNotification(completedDrawable).dispatch(context);

    // Reset the current drawable for the user to draw a new one next time.
    drawable = null;
  }

  /// Removes the incomplete drawable when the active pointer is canceled.
  void _handleHorizontalDragCancel() {
    final canceledDrawable = drawable;
    if (canceledDrawable == null) return;

    final controller = PainterController.of(context);
    // The gesture's add, erase-grouping and update actions are merged into one
    // undo entry. Undo and discard that entry so cancellation restores the
    // exact pre-gesture state without leaving a redo action behind.
    controller.undo();
    if (controller.unperformedActions.isNotEmpty) {
      controller.unperformedActions.removeLast();
    }
    drawable = null;
    FreeStyleDrawingNotification(
      canceledDrawable,
      FreeStyleDrawingPhase.canceled,
    ).dispatch(context);
  }

  Offset _globalToLocal(Offset globalPosition) {
    final getBox = context.findRenderObject() as RenderBox;

    return getBox.globalToLocal(globalPosition);
  }
}

/// A custom recognizer that recognize at most only one gesture sequence.
class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.shouldAcceptPointer,
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
    required this.onHorizontalDragCancel,
  });

  final bool Function(PointerDownEvent event) shouldAcceptPointer;
  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;
  final VoidCallback onHorizontalDragCancel;

  bool _isTrackingGesture = false;

  @override
  void addPointer(PointerEvent event) {
    if (event is PointerDownEvent && !shouldAcceptPointer(event)) return;

    if (!_isTrackingGesture) {
      resolve(GestureDisposition.accepted);
      startTrackingPointer(event.pointer);
      _isTrackingGesture = true;
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      onHorizontalDragDown(event.position);
    } else if (event is PointerMoveEvent) {
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      onHorizontalDragUp();
      _isTrackingGesture = false;
      stopTrackingPointer(event.pointer);
    } else if (event is PointerCancelEvent) {
      onHorizontalDragCancel();
      _isTrackingGesture = false;
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
