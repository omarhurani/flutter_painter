import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../controllers/drawables/drawable.dart';
import '../../controllers/notifications/notifications.dart';
import '../../controllers/events/remove_drawable_event.dart';
import '../../controllers/drawables/sized1ddrawable.dart';
import '../../controllers/drawables/shape/shape_drawable.dart';
import '../../controllers/drawables/sized2ddrawable.dart';
import '../../controllers/drawables/object_drawable.dart';
import '../../controllers/events/events.dart';
import '../../controllers/drawables/text_drawable.dart';
import '../../controllers/drawables/free_style_drawable.dart';
import '../../controllers/settings/settings.dart';
import '../painters/painter.dart';
import '../../controllers/painter_controller.dart';
import '../../controllers/helpers/border_box_shadow.dart';
import '../../controllers/helpers/painter_controller_helper.dart';

part 'free_style_widget.dart';
part 'text_widget.dart';
part 'object_widget.dart';
part 'shape_widget.dart';

typedef DrawableCreatedCallback = Function(Drawable drawable);

typedef DrawableDeletedCallback = Function(Drawable drawable);

/// Widget that allows user to draw on it
class FlutterPainter extends StatelessWidget {
  /// The controller for this painter.
  final PainterController controller;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableCreatedCallback? onDrawableCreated;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableDeleted;

  /// Callback when the selected [ObjectDrawable] changes.
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;

  /// Callback when the [PainterSettings] of [PainterController] are updated internally.
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  /// Creates a [FlutterPainter] with the given [controller] and optional callbacks.
  const FlutterPainter(
      {Key? key,
      required this.controller,
      this.onDrawableCreated,
      this.onDrawableDeleted,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : super(key: key);

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
                      builder: (context, value, child) => ClipRect(
                            child: NotificationListener<
                                FlutterPainterNotification>(
                              onNotification: onNotification,
                              child: FreeStyleWidget(
                                  controller: controller,
                                  child: TextWidget(
                                    controller: controller,
                                    child: ShapeWidget(
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
                                    ),
                                  )),
                            ),
                          )),
            ));
  }

  bool onNotification(FlutterPainterNotification notification) {
    if (notification is DrawableCreatedNotification)
      onDrawableCreated?.call(notification.drawable);
    else if (notification is DrawableDeletedNotification)
      onDrawableDeleted?.call(notification.drawable);
    else if (notification is SelectedObjectDrawableUpdatedNotification)
      onSelectedObjectDrawableChanged?.call(notification.drawable);
    else if (notification is SettingsUpdatedNotification)
      onPainterSettingsChanged?.call(notification.settings);
    return true;
  }
}
