import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'haptic_feedback_settings.dart';

typedef ObjectEnlargeControlsFunction = bool Function();
typedef ObjectShowScaleRotationControlsFunction = bool Function();

/// Represents settings used to control object drawables in the UI
@immutable
class ObjectSettings {
  /// Target platforms of mobile operating systems.
  ///
  /// This is used to detect the operating system for Flutter Web applications.
  static const Set<TargetPlatform> _mobileTargetPlatforms = {
    TargetPlatform.android,
    TargetPlatform.fuchsia,
    TargetPlatform.iOS
  };

  /// The layout-assist settings of the current object.
  final ObjectLayoutAssistSettings layoutAssist;

  /// A function used to decide whether to enlarge the object controls or not.
  /// This is because on touch screens, larger controls are needed to make them easier to tap and drag.
  ///
  /// By default, it enlarges controls on mobile operating systems (see [_enlargeControls]).
  ///
  /// If you need more custom control, you can for example use the cursor state from a [MouseRegion]
  /// to determine if the user is using a mouse or not (for example, if someone is using an iPad with a mouse and keyboard).
  final ObjectEnlargeControlsFunction enlargeControls;

  /// A function used to decide whether to show scale and rotation controls or not.
  /// This is because on touch screens, scale and rotation can be controlled with pinching.
  /// (However, controlling the size for [Sized2DDrawable]s still needs the controls).
  ///
  /// By default, it hides scale and rotation controls on mobile operating systems (see [_showScaleRotationControls]).
  ///
  /// If you need more custom control, you can for example use the cursor state from a [MouseRegion]
  /// to determine if the user is using a mouse or not (for example, if someone is using an iPad with a mouse and keyboard).
  final ObjectShowScaleRotationControlsFunction showScaleRotationControls;

  /// Creates a [TextSettings] with the given [layoutAssist].
  const ObjectSettings({
    this.layoutAssist = const ObjectLayoutAssistSettings(),
    this.enlargeControls = _enlargeControls,
    this.showScaleRotationControls = _showScaleRotationControls,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ObjectSettings copyWith({
    ObjectLayoutAssistSettings? layoutAssist,
    ObjectEnlargeControlsFunction? enlargeControls,
    ObjectShowScaleRotationControlsFunction? showScaleRotationControls,
  }) {
    return ObjectSettings(
      layoutAssist: layoutAssist ?? this.layoutAssist,
      enlargeControls: enlargeControls ?? this.enlargeControls,
      showScaleRotationControls:
          showScaleRotationControls ?? this.showScaleRotationControls,
    );
  }

  /// Default value for [enlargeControls].
  ///
  /// Returns `true` on mobile devices.
  static bool _enlargeControls() {
    if (kIsWeb) return _mobileTargetPlatforms.contains(defaultTargetPlatform);
    return Platform.isAndroid || Platform.isIOS || Platform.isFuchsia;
  }

  static bool _showScaleRotationControls() {
    if (kIsWeb) return !_mobileTargetPlatforms.contains(defaultTargetPlatform);
    return Platform.isWindows || Platform.isIOS || Platform.isLinux;
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
