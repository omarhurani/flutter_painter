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

  bool _fillInProgress = false;

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
                shouldYieldToMultitouch: () =>
                    PainterController.of(context).value.settings.scale.enabled,
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
    if (settings.mode == FreeStyleMode.fill && _fillInProgress) return false;
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
      final path = [_globalToLocal(globalPosition)];
      drawable =
          settings.factory?.create(
            path: path,
            color: settings.color,
            strokeWidth: settings.strokeWidth,
          ) ??
          FreeStyleDrawable(
            path: path,
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
    } else if (settings.mode == FreeStyleMode.fill) {
      final renderBox = context.findRenderObject() as RenderBox;
      drawable = FloodFillDrawable(
        seed: _globalToLocal(globalPosition),
        color: settings.color,
        tolerance: settings.fillTolerance,
        pixelWidth: renderBox.size.width.ceil(),
        pixelHeight: renderBox.size.height.ceil(),
        coordinateSize: renderBox.size,
      );
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
    if (drawable is FloodFillDrawable) return;

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

    if (completedDrawable is FloodFillDrawable) {
      drawable = null;
      _fillInProgress = true;
      unawaited(_completeFloodFill(completedDrawable));
      return;
    }

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

    if (canceledDrawable is FloodFillDrawable) {
      drawable = null;
      FreeStyleDrawingNotification(
        canceledDrawable,
        FreeStyleDrawingPhase.canceled,
      ).dispatch(context);
      return;
    }

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

  Future<void> _completeFloodFill(FloodFillDrawable pending) async {
    final controller = PainterController.of(context);
    try {
      final completed = await controller.createFloodFill(
        pending.seed,
        color: pending.color,
        tolerance: pending.tolerance,
      );
      if (!mounted || PainterController.of(context) != controller) return;

      if (completed == null) {
        FreeStyleDrawingNotification(
          pending,
          FreeStyleDrawingPhase.canceled,
        ).dispatch(context);
        return;
      }

      controller.addDrawables(<Drawable>[completed]);
      FreeStyleDrawingNotification(
        completed,
        FreeStyleDrawingPhase.ended,
      ).dispatch(context);
      DrawableCreatedNotification(completed).dispatch(context);
    } catch (error, stackTrace) {
      if (mounted) {
        FreeStyleDrawingNotification(
          pending,
          FreeStyleDrawingPhase.canceled,
        ).dispatch(context);
      }
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'flutter_painter',
          context: ErrorDescription('while creating a flood fill'),
        ),
      );
    } finally {
      _fillInProgress = false;
    }
  }

  Offset _globalToLocal(Offset globalPosition) {
    final getBox = context.findRenderObject() as RenderBox;

    return getBox.globalToLocal(globalPosition);
  }
}

/// A custom recognizer that draws with one pointer and yields to multi-touch.
class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.shouldAcceptPointer,
    required this.shouldYieldToMultitouch,
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
    required this.onHorizontalDragCancel,
  });

  final bool Function(PointerDownEvent event) shouldAcceptPointer;
  final bool Function() shouldYieldToMultitouch;
  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;
  final VoidCallback onHorizontalDragCancel;

  final Set<int> _trackedPointers = <int>{};
  int? _primaryPointer;
  Offset? _initialPosition;
  bool _drawingActive = false;
  bool _accepted = false;
  bool _multitouch = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final isFirstPointer = _trackedPointers.isEmpty;
    if (isFirstPointer && !shouldAcceptPointer(event)) {
      startTrackingPointer(event.pointer, event.transform);
      resolvePointer(event.pointer, GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
      return;
    }

    startTrackingPointer(event.pointer, event.transform);

    if (isFirstPointer) {
      _trackedPointers.add(event.pointer);
      _primaryPointer = event.pointer;
      _initialPosition = event.position;
      _drawingActive = true;
      onHorizontalDragDown(event.position);
      return;
    }

    if (!shouldYieldToMultitouch()) {
      resolvePointer(event.pointer, GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
      return;
    }

    _trackedPointers.add(event.pointer);

    // Let InteractiveViewer win both gesture arenas when a pinch starts.
    _multitouch = true;
    resolve(GestureDisposition.rejected);
    _cancelDrawing();
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent &&
        event.pointer == _primaryPointer &&
        _drawingActive &&
        !_multitouch) {
      if (!_accepted) {
        final initialPosition = _initialPosition;
        if (shouldYieldToMultitouch() &&
            initialPosition != null &&
            (event.position - initialPosition).distance <=
                computeHitSlop(event.kind, gestureSettings)) {
          return;
        }
        _accepted = true;
        resolve(GestureDisposition.accepted);
      }
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      if (event.pointer == _primaryPointer && _drawingActive && !_multitouch) {
        if (!_accepted) {
          _accepted = true;
          resolve(GestureDisposition.accepted);
        }
        onHorizontalDragUp();
        _drawingActive = false;
      }
      _stopTracking(event.pointer);
    } else if (event is PointerCancelEvent) {
      if (event.pointer == _primaryPointer) _cancelDrawing();
      if (!_accepted) resolve(GestureDisposition.rejected);
      _stopTracking(event.pointer);
    }
  }

  void _cancelDrawing() {
    if (!_drawingActive) return;
    _drawingActive = false;
    onHorizontalDragCancel();
  }

  void _stopTracking(int pointer) {
    _trackedPointers.remove(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    if (pointer == _primaryPointer && !_multitouch) _cancelDrawing();
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _trackedPointers.clear();
    _primaryPointer = null;
    _initialPosition = null;
    _drawingActive = false;
    _accepted = false;
    _multitouch = false;
  }
}
