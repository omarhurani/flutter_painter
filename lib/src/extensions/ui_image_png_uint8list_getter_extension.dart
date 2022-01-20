import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;

/// Adds a method to convert any [ui.Image] to a [Uint8List] using
/// the `ui.ImageByteFormat.png` (png) format.
extension UiImagePngUint8ListGetter on ui.Image {
  /// Returns the image byte data from the `this` as a [Uint8List] in png format.
  Future<Uint8List?> get pngBytes async {
    // Convert this image into byte data with the png format
    final byteData = await toByteData(format: ui.ImageByteFormat.png);

    // Return the Uint8List from the byte data buffer (if not null)
    return byteData?.buffer.asUint8List();
  }
}
