import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'haptic_feedback_settings.dart';

/// Represents settings used to control object drawables in the UI
@immutable
class ObjectSettings {
  /// The layout-assist settings of the current object.
  final ObjectLayoutAssistSettings layoutAssist;

  /// Creates a [TextSettings] with the given [layoutAssist].
  const ObjectSettings({
    this.layoutAssist = const ObjectLayoutAssistSettings(),
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ObjectSettings copyWith({ObjectLayoutAssistSettings? layoutAssist}) {
    return ObjectSettings(
      layoutAssist: layoutAssist ?? this.layoutAssist,
    );
  }
}

/// Represents settings that control the behavior of layout assist for objects.
///
/// Layout assist helps in arranging objects by snapping them to common arrangements
/// (such as vertical and horizontal centers, right angle rotations, etc...).
@immutable
class ObjectLayoutAssistSettings {
  /// The default value for [positionalEnterDistance].
  static const double defaultPositionalEnterDistance = 1;

  /// The default value for [positionalExitDistance].
  static const double defaultPositionalExitDistance = 10;

  /// The default value for [rotationalEnterAngle].
  static const double defaultRotationalEnterAngle = pi / 80;

  /// The default value for [rotationalExitAngle].
  static const double defaultRotationalExitAngle = pi / 16;

  /// Have layout assist enabled or not.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// What kind of haptic feedback to trigger when the object snaps to an arrangement.
  ///
  /// Defaults to [HapticFeedbackSettings.medium].
  final HapticFeedbackSettings hapticFeedback;

  /// The distance from center to detect that the object reached the assist area.
  ///
  /// When the object is this distance close to the center, it enters layout assist.
  final double positionalEnterDistance;

  /// The distance from center to detect that the object exited the assist area.
  ///
  /// When the object is this distance far from the center, it leaves layout assist.
  final double positionalExitDistance;

  /// The angle to detect that the object entered the rotational assist range.
  ///
  /// When the object is this angle close to an assist angle, it starts layout assist.
  final double rotationalEnterAngle;

  /// The angle to detect that the object exited the rotational assist range.
  ///
  /// When the object is this angle far from an assist angle, it leaves layout assist.
  final double rotationalExitAngle;

  /// Creates an [ObjectLayoutAssistSettings].
  const ObjectLayoutAssistSettings({
    this.enabled = true,
    this.hapticFeedback = HapticFeedbackSettings.medium,
    this.positionalEnterDistance = defaultPositionalEnterDistance,
    this.positionalExitDistance = defaultPositionalExitDistance,
    this.rotationalEnterAngle = defaultRotationalEnterAngle,
    this.rotationalExitAngle = defaultRotationalExitAngle,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ObjectLayoutAssistSettings copyWith({
    bool? enabled,
    HapticFeedbackSettings? hapticFeedback,
    double? positionalEnterDistance,
    double? positionalExitDistance,
    double? rotationalEnterAngle,
    double? rotationalExitAngle,
  }) {
    return ObjectLayoutAssistSettings(
      enabled: enabled ?? this.enabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      positionalEnterDistance:
          positionalEnterDistance ?? this.positionalEnterDistance,
      positionalExitDistance:
          positionalExitDistance ?? this.positionalExitDistance,
      rotationalEnterAngle: rotationalEnterAngle ?? this.rotationalEnterAngle,
      rotationalExitAngle: rotationalExitAngle ?? this.rotationalExitAngle,
    );
  }
}
