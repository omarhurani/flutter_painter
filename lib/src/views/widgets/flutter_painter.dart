import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../controllers/drawables/object_drawable.dart';
import '../../controllers/events/events.dart';
import '../../controllers/drawables/text_drawable.dart';
import '../../controllers/drawables/free_style_drawable.dart';
import '../../controllers/settings/settings.dart';
import '../painters/painter.dart';
import '../../controllers/painter_controller.dart';

part 'free_style_widget.dart';
part 'text_widget.dart';
part 'object_widget.dart';

/// Widget that allows user to draw on it
class FlutterPainter extends StatelessWidget {

  /// The controller for this painter.
  final PainterController controller;

  /// Creates a [FlutterPainter] with the given [controller].
  const FlutterPainter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder(
          settings: settings,
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) =>
              // Listen to the [controller]
              ValueListenableBuilder<PainterControllerValue>(
                key: controller.painterKey,
                valueListenable: controller,
                builder: (context, value, child) =>
                  ClipRect(
                    child: FreeStyleWidget(
                        controller: controller,
                        child: TextWidget(
                          controller: controller,
                          child: ObjectWidget(
                            controller: controller,
                            interactionEnabled: true,
                            child: CustomPaint(
                              painter: Painter(
                                drawables: value.drawables,
                                background: value.background,
                              ),
                            ),
                          ),
                        )
                    ),
                  )
        ),
      )
    );
  }
}