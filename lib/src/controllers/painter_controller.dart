import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import './events/remove_drawable_event.dart';
import 'events/events.dart';
import 'drawables/background/background_drawable.dart';
import 'settings/settings.dart';
import '../views/painters/painter.dart';

import 'drawables/drawable.dart';

/// Controller used to control a [FlutterPainter] widget.
///
/// * IMPORTANT: *
/// Each [FlutterPainter] should have its own controller.
class PainterController extends ValueNotifier<PainterControllerValue> {
  /// A controller for an event stream which widgets will listen to.
  ///
  /// This will dispatch events that represent actions, such as adding a new text drawable.
  final StreamController<PainterEvent> _eventsSteamController;

  /// This key will be used by the [FlutterPainter] widget assigned this controller.
  ///
  /// * IMPORTANT: *
  /// DO NOT ASSIGN this key on any widget,
  /// it is automatically used inside the [FlutterPainter] controller by [this]
  ///
  /// However, you can use to to grab information about the render object, etc...
  final GlobalKey painterKey;

  /// Create a [PainterController].
  ///
  /// The behavior of a [FlutterPainter] widget is controlled by [settings].
  /// The controller can be initialized with a list of [drawables]
  /// to be painted without user interaction.
  /// It can also accept a [background] to be painted.
  /// Without it, the background will be transparent.
  PainterController({
    PainterSettings settings = const PainterSettings(),
    List<Drawable>? drawables = const [],
    BackgroundDrawable? background,
    Drawable? selectedDrawable,
  }) : this.fromValue(PainterControllerValue(
          settings: settings,
          drawables: drawables ?? const [],
          background: background,
          selectedDrawable: selectedDrawable,
        ));

  /// Create a [PainterController] from a [PainterControllerValue].
  PainterController.fromValue(PainterControllerValue value)
      : _eventsSteamController = StreamController<PainterEvent>.broadcast(),
        painterKey = GlobalKey(),
        super(value);

  /// The stream of [PainterEvent]s dispatched from this controller.
  ///
  /// This stream is for children widgets of [FlutterPainter] to listen to external events.
  /// For example, adding a new text drawable.
  Stream<PainterEvent> get events => _eventsSteamController.stream;

  /// This will let us update the selected drawable index value
  /// With this we able to use [selectedDrawable] + [drawables] to delete selected drawable
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set selectedDrawable(Drawable? selectedDrawable) =>
      value = value.copyWith(selectedDrawable: selectedDrawable);

  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set background(BackgroundDrawable? background) =>
      value = value.copyWith(background: background);

  /// Add the [drawables] to the controller value drawables.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void addDrawables(Iterable<Drawable> drawables) {
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.addAll(drawables);
    value = value.copyWith(drawables: currentDrawables);
  }

  /// Inserts the [drawables] to the controller value drawables at the provided [index].
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void insertDrawables(int index, Iterable<Drawable> drawables) {
    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables.insertAll(index, drawables);
    value = value.copyWith(drawables: currentDrawables);
  }

  /// Replace [oldDrawable] with [newDrawable] in the controller value.
  ///
  /// Returns `true` if [oldDrawable] was found and replaced, `false` otherwise.
  /// If the return value is `false`, the controller value is unaffected.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool replaceDrawable(Drawable oldDrawable, Drawable newDrawable) {
    final oldDrawableIndex = value.drawables.indexOf(oldDrawable);
    if (oldDrawableIndex < 0) // not found
      return false;

    final currentDrawables = List<Drawable>.from(value.drawables);
    currentDrawables
        .setRange(oldDrawableIndex, oldDrawableIndex + 1, [newDrawable]);
    value = value.copyWith(drawables: currentDrawables);
    return true;
  }

  /// Removes the first occurrence of [drawable] from the controller value.
  ///
  /// Returns `true` if [drawable] was in the controller value, `false` otherwise.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool removeDrawable(Drawable drawable) {
    final currentDrawables = List<Drawable>.from(value.drawables);
    final removed = currentDrawables.remove(drawable);
    if (removed) {
      value = value.copyWith(drawables: currentDrawables);
      _eventsSteamController.add(RemoveDrawableEvent(drawable));
    }
    return removed;
  }

  /// Removes the last drawable from the controller value (acts similar to an undo).
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if there are no drawables in the controller value.
  void removeLastDrawable() {
    final currentDrawables = List<Drawable>.from(value.drawables);
    if (currentDrawables.isEmpty) return;
    currentDrawables.removeAt(currentDrawables.length - 1);
    value = value.copyWith(drawables: currentDrawables);
  }

  /// Removes all drawables from the controller value.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clearDrawables() {
    value = value.copyWith(drawables: const <Drawable>[]);
  }

  /// Dispatches a [AddTextPainterEvent] on `events` stream.
  void addText() {
    _eventsSteamController.add(AddTextPainterEvent());
  }

  /// Renders the background and all other drawables to a [ui.Image] object.
  ///
  /// The size of the output image is controlled by [size].
  /// All drawables will be scaled according to that image size.
  Future<ui.Image> renderImage(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = Painter(
      drawables: value.drawables,
      scale: painterKey.currentContext?.size ?? size,
      background: value.background,
    );
    painter.paint(canvas, size);
    return await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }
}

/// The current paint mode, drawables and background values of a [FlutterPainter] widget.
@immutable
class PainterControllerValue {
  /// The current paint mode of the widget.
  final PainterSettings settings;

  /// The list of drawables currently present to be painted.
  final List<Drawable> _drawables;

  /// The current background drawable of the widget.
  final BackgroundDrawable? background;

  /// The current selected drawable index of the widget.
  final Drawable? selectedDrawable;

  /// Creates a new [PainterControllerValue] with the provided [settings] and [background].
  ///
  /// The user can pass a list of initial [drawables] which will be drawn without user interaction.
  const PainterControllerValue({
    required this.settings,
    List<Drawable> drawables = const [],
    this.background,
    this.selectedDrawable,
  }) : this._drawables = drawables;

  /// Getter for the current drawables.
  ///
  /// The returned list is unmodifiable.
  List<Drawable> get drawables => List.unmodifiable(_drawables);

  /// Creates a copy of this value but with the given fields replaced with the new values.
  PainterControllerValue copyWith({
    PainterSettings? settings,
    List<Drawable>? drawables,
    BackgroundDrawable? background,
    Drawable? selectedDrawable,
  }) {
    return PainterControllerValue(
      settings: settings ?? this.settings,
      drawables: drawables ?? this._drawables,
      background: background ?? this.background,
      selectedDrawable: selectedDrawable,
    );
  }
}
