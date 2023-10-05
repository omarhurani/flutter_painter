import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/events/events.dart';

import '../../controllers/actions/actions.dart';
import '../../controllers/drawables/drawables.dart';
import '../../controllers/factories/node_polygon_factory.dart';
import '../../controllers/painter_controller.dart';
import '../../controllers/settings/settings.dart';
import '../painters/painter.dart';

/// Flutter widget to detect user input and request drawing
/// [FreeStyleDrawable]s as polygons.
class PolygonDrawWidget extends StatefulWidget {
  /// Parent's [PainterController].
  final PainterController controller;

  /// Creates a [PolygonDrawWidget] with the given [controller].
  const PolygonDrawWidget({required this.controller, Key? key})
      : super(key: key);

  @override
  State<PolygonDrawWidget> createState() => _PolygonDrawWidgetState();
}

/// State class
class _PolygonDrawWidgetState extends State<PolygonDrawWidget> {
  /// The current drawable being drawn.
  NodePolygonDrawable? drawable;

  /// Subscriptions for listening to undo/redo events.
  late final StreamSubscription subscription;

  /// Default [Paint] from the stored [FreeStyleSettings].
  late final paint = Paint()
    ..strokeWidth = settings.strokeWidth
    ..color = settings.color
    ..strokeCap = StrokeCap.round
    ..style =
        settings.isPolygonFilled ? PaintingStyle.fill : PaintingStyle.stroke;

  /// Helper paint [Paint] for filled polygons.
  late final outlinePaint = Paint()
    ..color = settings.color
    ..strokeCap = paint.strokeCap
    ..style = PaintingStyle.stroke
    ..strokeWidth = min(paint.strokeWidth, 1);

  bool get hasVertices => drawable?.vertices.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();

    /// Assign of the undo/redo events listening.
    subscription = controller.undoRedoEvents.listen(undoRedoListener);
  }

  @override
  void dispose() {
    /// Cancellation of the undo/redo events listening.
    subscription.cancel();
    super.dispose();
  }

  /// The listener which removes the last point from the [drawable.vertices]
  /// (in the [FreeStyleMode.polygonalDraw] mode) if it detects that an undo
  /// event has been called. On the other hand, it returns the vertex that was
  /// restored to the [drawable.vertices] list if it meets the conditions.
  void undoRedoListener(UndoRedoEvent event) {
    final vertices = [...?drawable?.vertices].whereType<Offset>().toList();
    if (vertices.isEmpty) return;
    if (event.isUndo) {
      vertices.removeLast();
      final updatedDrawable =
          vertices.isEmpty ? null : drawable?.updateWith(vertices: vertices);
      setState(() => drawable = updatedDrawable);
    } else {
      if (event.action is! ReplaceDrawableAction) return;
      final action = event.action as ReplaceDrawableAction;
      if (action.newDrawable is! NodePolygonDrawable) return;
      final restoredDrawable = action.newDrawable as NodePolygonDrawable;
      final lastVertex = restoredDrawable.vertices.last;
      if (lastVertex == vertices.last) return;
      vertices.add(lastVertex);
      final updatedDrawable = drawable?.updateWith(vertices: vertices);
      setState(() => drawable = updatedDrawable);
    }
  }

  /// Adds vertices to the [drawable.vertices] list, saves them for undo/redo.
  void onTapDown(TapDownDetails tap) => setState(() {
        if (drawable != null) {
          final newDrawable = drawable?.updateWith(vertex: tap.localPosition);
          controller.replaceDrawable(drawable!, newDrawable!, newAction: true);
          drawable = newDrawable;
        } else {
          drawable = NodePolygonFactory(settings.polygonCloseRadius)
              .create(tap.localPosition, paint);
          controller.addDrawables([drawable!], newAction: true);
        }
      });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: onTapDown,
        child: ColoredBox(
          color: settings.backgroundColor ?? Colors.transparent,
          child: hasVertices
              ? Stack(
                  children: [
                    if (radius != null &&
                        (!drawable!.isClosed || drawable!.vertices.length == 1))
                      Positioned(
                        left: drawable!.vertices.first.dx - radius!,
                        top: drawable!.vertices.first.dy - radius!,
                        child: CircleAvatar(
                          radius: radius,
                          backgroundColor: settings.color.withOpacity(0.2),
                        ),
                      ),
                    if (paint.style == PaintingStyle.fill)
                      CustomPaint(
                        painter: Painter(
                          drawables: [
                            drawable!.updateWith(paint: outlinePaint)
                          ],
                        ),
                      ),
                  ],
                )
              : null,
        ),
      );

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings => controller.value.settings.freeStyle;

  /// Getter for [PainterController] from constructor.
  PainterController get controller => widget.controller;

  /// Getter for [polygonCloseRadius] from [FreeStyleSettings].
  double? get radius => settings.polygonCloseRadius;
}
