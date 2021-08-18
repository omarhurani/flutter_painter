export 'free_style_settings.dart';

import 'package:flutter/material.dart';
import 'object_settings.dart';
import 'settings.dart';

/// Represents all the settings used to create and draw drawables.
@immutable
class PainterSettings{

  /// Settings for free-style drawables.
  final FreeStyleSettings freeStyle;

  /// Settings for object drawables.
  final ObjectSettings object;

  /// Settings for text drawables.
  final TextSettings text;

  /// Creates a [PainterSettings] with the given settings for [freeStyle], [object]
  /// and [text].
  const PainterSettings({
    this.freeStyle = const FreeStyleSettings(enabled: false),
    this.object = const ObjectSettings(),
    this.text = const TextSettings(),
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  PainterSettings copyWith({
    FreeStyleSettings? freeStyle,
    ObjectSettings? object,
    TextSettings? text,
  }) {
    return PainterSettings(
      text: text ?? this.text,
      object: object ?? this.object,
      freeStyle: freeStyle ?? this.freeStyle,
    );
  }
}

