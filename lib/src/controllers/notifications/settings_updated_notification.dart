import '../settings/painter_settings.dart';

import 'notification.dart';

/// A notification that is dispatched when the [PainterSettings] are changed internally.
class SettingsUpdatedNotification extends FlutterPainterNotification {
  /// The new settings.
  PainterSettings settings;

  /// Creates a [SettingsUpdatedNotification] with the given [settings].
  SettingsUpdatedNotification(this.settings);
}
