import 'package:flutter/widgets.dart';
import '../controllers/factories/free_style_factory.dart';
import '../controllers/factories/shape_factory.dart';

import '../controllers/painter_controller.dart';
import '../controllers/settings/settings.dart';
import '../controllers/drawables/drawables.dart';
import '../controllers/drawables/grouped_drawable.dart';
import 'paint_copy_extension.dart';

/// Adds extra getters and setters in [PainterController] to make it easier to use.
///
/// This was made as an extension to not clutter up the [PainterController] class even more.
extension PainterControllerHelper on PainterController {
  /// The current painter settings directly from `value`.
  PainterSettings get settings => value.settings;

  /// The current background drawable directly from `value`.
  BackgroundDrawable? get background => value.background;

  /// The unmodifiable list of drawables directly from `value`.
  List<Drawable> get drawables => value.drawables;

  /// Counts tagged image drawables by their application-defined tag.
  ///
  /// Untagged images are omitted. The returned map cannot be modified.
  Map<String, int> get imageDrawableCountsByTag {
    final counts = <String, int>{};
    for (final drawable in _imageDrawablesIn(drawables)) {
      final tag = drawable.tag;
      if (tag == null) continue;
      counts.update(tag, (count) => count + 1, ifAbsent: () => 1);
    }
    return Map.unmodifiable(counts);
  }

  /// Replaces a color-bearing [drawable] with a copy using [color].
  ///
  /// [FreeStyleDrawable], [ShapeDrawable], and [TextDrawable] are supported.
  /// Returns `false` when [drawable] does not support colors or is not owned by
  /// this controller.
  ///
  /// The replacement participates in undo and redo. Set [newAction] to `false`
  /// to merge this update with the previous controller action.
  bool setDrawableColor(
    Drawable drawable,
    Color color, {
    bool newAction = true,
  }) {
    final Drawable? coloredDrawable;
    if (drawable is FreeStyleDrawable) {
      coloredDrawable = drawable.copyWith(color: color);
    } else if (drawable is ShapeDrawable) {
      coloredDrawable = drawable.copyWith(
        paint: drawable.paint.copyWith(color: color),
      );
    } else if (drawable is TextDrawable) {
      coloredDrawable = drawable.copyWith(
        style: drawable.style.copyWith(color: color),
      );
    } else {
      coloredDrawable = null;
    }

    return coloredDrawable != null &&
        replaceDrawable(drawable, coloredDrawable, newAction: newAction);
  }

  /// Replaces the label on a labeled shape.
  ///
  /// The replacement participates in undo and redo and preserves selection.
  bool setShapeLabel(
    LabeledShapeDrawable drawable,
    ShapeLabel label, {
    bool newAction = true,
  }) {
    return replaceDrawable(
      drawable,
      drawable.copyWithLabel(label),
      newAction: newAction,
    );
  }

  /// The object settings directly from the painter settings.
  ObjectSettings get objectSettings => settings.object;

  /// The text settings directly from the painter settings.
  TextSettings get textSettings => settings.text;

  /// The free-style settings directly from the painter settings.
  FreeStyleSettings get freeStyleSettings => settings.freeStyle;

  /// The shape settings directly from the painter settings.
  ShapeSettings get shapeSettings => settings.shape;

  /// The scale settings directly from the painter settings.
  ScaleSettings get scaleSettings => settings.scale;

  /// The current painter settings directly from `value`.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set settings(PainterSettings settings) =>
      value = value.copyWith(settings: settings);

  /// The current background drawable directly from `value`.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set background(BackgroundDrawable? background) =>
      value = value.copyWith(background: background);

  /// The object settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectSettings(ObjectSettings objectSettings) => value = value.copyWith(
    settings: settings.copyWith(object: objectSettings),
  );

  /// The text settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textSettings(TextSettings textSettings) =>
      value = value.copyWith(settings: settings.copyWith(text: textSettings));

  /// The free-style settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleSettings(FreeStyleSettings freeStyleSettings) => value = value
      .copyWith(settings: settings.copyWith(freeStyle: freeStyleSettings));

  /// The shape settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapeSettings(ShapeSettings shapeSettings) =>
      value = value.copyWith(settings: settings.copyWith(shape: shapeSettings));

  /// The scale settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set scaleSettings(ScaleSettings scaleSettings) =>
      value = value.copyWith(settings: settings.copyWith(scale: scaleSettings));

  /// The function used to decide whether to enlarge the object controls or not from `value.settings.object` directly.
  ObjectEnlargeControlsResolver get enlargeObjectControlsResolver =>
      value.settings.object.enlargeControlsResolver;

  /// The layout-assist settings of the selected object drawable from `value.settings.object` directly.
  ObjectLayoutAssistSettings get objectLayoutAssist =>
      value.settings.object.layoutAssist;

  /// The function used to decide whether to show scale and rotation object controls or not from `value.settings.object` directly.
  ObjectShowScaleRotationControlsResolver
  get showObjectScaleRotationControlsResolver =>
      value.settings.object.showScaleRotationControlsResolver;

  /// The text style to be used for text drawables from `value.settings.text` directly.
  TextStyle get textStyle => value.settings.text.textStyle;

  /// The alignment used for text drawables from `value.settings.text` directly.
  TextAlign get textAlign => value.settings.text.textAlign;

  /// The focus node used to edit text drawables text from `value.settings.text` directly.
  FocusNode? get textFocusNode => value.settings.text.focusNode;

  /// The free-style painting mode from `value.settings.freeStyle` directly.
  FreeStyleMode get freeStyleMode => value.settings.freeStyle.mode;

  /// The stroke width used for free-style drawing from `value.settings.freeStyle` directly.
  double get freeStyleStrokeWidth => value.settings.freeStyle.strokeWidth;

  /// The color used for free-style drawing from `value.settings.freeStyle` directly.
  Color get freeStyleColor => value.settings.freeStyle.color;

  /// The factory used to create custom free-style drawables.
  FreeStyleFactory? get freeStyleFactory => value.settings.freeStyle.factory;

  /// The paint used to draw shapes from `value.settings.shape` directly.
  Paint? get shapePaint => value.settings.shape.paint;

  /// Whether to draw shapes once or continuously from `value.settings.shape` directly.
  bool get drawShapeOnce => value.settings.shape.drawOnce;

  /// The factory for the shape to be drawn from `value.settings.shape` directly.
  ShapeFactory? get shapeFactory => value.settings.shape.factory;

  /// The minimum scale that the user can "zoom out" to from `value.settings.scale` directly.
  double get minScale => value.settings.scale.minScale;

  /// The maximum scale that the user can "zoom in" to from `value.settings.scale` directly.
  double get maxScale => value.settings.scale.maxScale;

  /// Whether scaling is enabled or not from `value.settings.scale` directly.
  bool get scalingEnabled => value.settings.scale.enabled;

  /// The function used to decide whether to enlarge the object controls or not from `value.settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set enlargeObjectControlsResolver(
    ObjectEnlargeControlsResolver enlargeControls,
  ) => value = value.copyWith(
    settings: value.settings.copyWith(
      object: value.settings.object.copyWith(
        enlargeControlsResolver: enlargeControls,
      ),
    ),
  );

  /// The layout-assist settings of the selected object drawable from `value.settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectLayoutAssist(ObjectLayoutAssistSettings layoutAssist) =>
      value = value.copyWith(
        settings: value.settings.copyWith(
          object: value.settings.object.copyWith(layoutAssist: layoutAssist),
        ),
      );

  /// The function used to decide whether to show scale and rotation object controls or not from `value.settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set showObjectScaleRotationControlsResolver(
    ObjectShowScaleRotationControlsResolver showScaleRotationControlsResolver,
  ) => value = value.copyWith(
    settings: value.settings.copyWith(
      object: value.settings.object.copyWith(
        showScaleRotationControlsResolver: showScaleRotationControlsResolver,
      ),
    ),
  );

  /// The text style to be used for text drawables from `value.settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textStyle(TextStyle textStyle) => value = value.copyWith(
    settings: value.settings.copyWith(
      text: value.settings.text.copyWith(textStyle: textStyle),
    ),
  );

  /// The alignment used for text drawables from `value.settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update.
  set textAlign(TextAlign textAlign) => value = value.copyWith(
    settings: value.settings.copyWith(
      text: value.settings.text.copyWith(textAlign: textAlign),
    ),
  );

  /// The focus node used to edit text drawables text from `value.settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textFocusNode(FocusNode? focusNode) => value = value.copyWith(
    settings: value.settings.copyWith(
      text: value.settings.text.copyWith(focusNode: focusNode),
    ),
  );

  /// The free-style painting mode from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleMode(FreeStyleMode mode) => value = value.copyWith(
    settings: value.settings.copyWith(
      freeStyle: value.settings.freeStyle.copyWith(mode: mode),
    ),
  );

  /// The stroke width used for free-style drawing from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleStrokeWidth(double strokeWidth) => value = value.copyWith(
    settings: value.settings.copyWith(
      freeStyle: value.settings.freeStyle.copyWith(strokeWidth: strokeWidth),
    ),
  );

  /// The color used for free-style drawing from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleColor(Color color) => value = value.copyWith(
    settings: value.settings.copyWith(
      freeStyle: value.settings.freeStyle.copyWith(color: color),
    ),
  );

  /// The factory used to create custom free-style drawables.
  ///
  /// Set this to `null` to restore the built-in free-style drawable. Setting
  /// this value notifies the listeners of this [PainterController].
  set freeStyleFactory(FreeStyleFactory? factory) => value = value.copyWith(
    settings: value.settings.copyWith(
      freeStyle: value.settings.freeStyle.copyWith(factory: factory),
    ),
  );

  /// The paint used to draw shapes from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapePaint(Paint? paint) => value = value.copyWith(
    settings: value.settings.copyWith(
      shape: value.settings.shape.copyWith(paint: paint),
    ),
  );

  /// Whether to draw shapes once or continuously from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set drawShapeOnce(bool drawOnce) => value = value.copyWith(
    settings: value.settings.copyWith(
      shape: value.settings.shape.copyWith(drawOnce: drawOnce),
    ),
  );

  /// The factory for the shape to be drawn from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapeFactory(ShapeFactory? factory) => value = value.copyWith(
    settings: value.settings.copyWith(
      shape: value.settings.shape.copyWith(factory: factory),
    ),
  );

  /// The minimum scale that the user can "zoom out" to from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set minScale(double minScale) => value = value.copyWith(
    settings: value.settings.copyWith(
      scale: value.settings.scale.copyWith(minScale: minScale),
    ),
  );

  /// The maximum scale that the user can "zoom in" to from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set maxScale(double maxScale) => value = value.copyWith(
    settings: value.settings.copyWith(
      scale: value.settings.scale.copyWith(maxScale: maxScale),
    ),
  );

  /// Whether scaling is enabled or not from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set scalingEnabled(bool enabled) => value = value.copyWith(
    settings: value.settings.copyWith(
      scale: value.settings.scale.copyWith(enabled: enabled),
    ),
  );
}

Iterable<ImageDrawable> _imageDrawablesIn(Iterable<Drawable> drawables) sync* {
  for (final drawable in drawables) {
    if (drawable is ImageDrawable) {
      yield drawable;
    } else if (drawable is GroupedDrawable) {
      yield* _imageDrawablesIn(drawable.drawables);
    }
  }
}
