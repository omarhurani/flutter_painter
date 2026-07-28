import 'package:flutter/painting.dart';

/// Custom BoxShadow that can be passed its [BlurStyle].
///
/// This is used to show an outer shadow blur for object controls.
class BorderBoxShadow extends BoxShadow {
  /// Creates a new [BorderBoxShadow] with the given `blurStyle` and other arguments matching [BoxShadow].
  const BorderBoxShadow({
    super.color,
    super.offset,
    super.blurRadius,
    super.spreadRadius,
    super.blurStyle = BlurStyle.outer,
  });
}
