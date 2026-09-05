import 'package:flutter/widgets.dart';

/// Abstract class to represent events that the controller can dispatch to any listeners.
@immutable
abstract class PainterEvent {
  /// Default constructor for [PainterEvent].
  const PainterEvent();
}
