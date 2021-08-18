import 'package:flutter/services.dart';

/// Represents the possible haptic feedback settings.
enum HapticFeedbackSettings {
  /// No haptic feedback.
  none,

  /// Light haptic feedback impact.
  light,

  /// Medium haptic feedback impact.
  medium,

  /// Heavy haptic feedback impact.
  heavy
}

/// An extension to add a method that performs the haptic feedback impact.
extension HapticFeedbackSettingsImpact on HapticFeedbackSettings {
  /// Performs the haptic feedback impact of the [HapticFeedbackSettings].
  Future<void> impact() async {
    switch (this) {
      case HapticFeedbackSettings.none:
        break;
      case HapticFeedbackSettings.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackSettings.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackSettings.heavy:
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}
