import 'package:flutter_painter/src/controllers/settings/shape_settings.dart';

import '../painter_controller.dart';
import '../settings/settings.dart';
import '../drawables/drawables.dart';

/// Adds extra getters and setters in [PainterController] to make it easier to use.
///
/// This was made as an extension to not clutter up the [PainterController] class even more.
extension PainterControllerHelper on PainterController {
  /// Getter for the current painter settings directly from `value`.
  PainterSettings get settings => value.settings;

  /// Getter for the current background drawable directly from `value`.
  BackgroundDrawable? get background => value.background;

  /// Getter for the unmodifiable list of drawables directly from `value`.
  List<Drawable> get drawables => value.drawables;

  /// Getter for the object settings directly from the painter settings.
  ObjectSettings get objectSettings => settings.object;

  /// Getter for the text settings directly from the painter settings.
  TextSettings get textSettings => settings.text;

  /// Getter for the free-style settings directly from the painter settings.
  FreeStyleSettings get freeStyleSettings => settings.freeStyle;

  /// Getter for the shape settings directly from the painter settings.
  ShapeSettings get shapeSettings => settings.shape;

  /// Setter to for `settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectSettings(ObjectSettings objectSettings) => value = value.copyWith(
          settings: settings.copyWith(
        object: objectSettings,
      ));

  /// Setter to for `settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textSettings(TextSettings textSettings) => value = value.copyWith(
          settings: settings.copyWith(
        text: textSettings,
      ));

  /// Setter to for `settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleSettings(FreeStyleSettings freeStyleSettings) =>
      value = value.copyWith(
          settings: settings.copyWith(
        freeStyle: freeStyleSettings,
      ));

  /// Setter to for `settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapeSettings(ShapeSettings shapeSettings) =>
      value = value.copyWith(
          settings: settings.copyWith(
        shape: shapeSettings,
      ));


}
