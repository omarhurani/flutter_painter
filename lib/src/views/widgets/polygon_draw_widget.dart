import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_painter/src/controllers/events/events.dart';

import '../../controllers/actions/actions.dart';
import '../../controllers/drawables/drawables.dart';
import '../../controllers/factories/node_polygon_factory.dart';
import '../../controllers/painter_controller.dart';
import '../../controllers/settings/settings.dart';

/// Flutter widget to detect user input and request drawing
/// [FreeStyleDrawable]s as polygons.
class PolygonDrawWidget extends StatefulWidget {
  /// Child widget.
  final PainterController controller;

  /// Creates a [PolygonDrawWidget] with the given [controller], [child] widget.
  const PolygonDrawWidget({required this.controller, Key? key})
      : super(key: key);

  @override
  State<PolygonDrawWidget> createState() => _PolygonDrawWidgetState();
}

/// State class
class _PolygonDrawWidgetState extends State<PolygonDrawWidget> {
  /// The current drawable being drawn.
  NodePolygonDrawable? drawable;
  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = controller.undoRedoEvents.listen(undoRedoListener);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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

  void onTapDown(TapDownDetails tap) => setState(() {
        if (drawable != null) {
          final newDrawable = drawable?.updateWith(vertex: tap.localPosition);
          controller.replaceDrawable(drawable!, newDrawable!, newAction: true);
          drawable = newDrawable;
        } else {
          drawable = const NodePolygonFactory().create(tap.localPosition);
          controller.addDrawables([drawable!], newAction: true);
        }
      });

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: const Color.fromARGB(26, 0, 140, 255),
        child: GestureDetector(
          onTapDown: onTapDown,
          // child: CustomPaint(
          //   painter: Painter(
          //     drawables: drawable == null ? [] : [drawable!],
          //   ),
          // ),
        ),
      );

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings => controller.value.settings.freeStyle;

  /// Getter for [ShapeSettings] from `widget.controller.value` to make code more readable.
  ShapeSettings get shapeSettings => controller.value.settings.shape;

  /// Getter for [PainterController] from constructor.
  PainterController get controller => widget.controller;
}
