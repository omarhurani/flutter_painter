import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Adds a method to get a [ui.Image] object from any [ImageProvider].
extension ImageProviderUiImageGetter on ImageProvider {
  /// Returns an [ui.Image] object containing the image data from `this` object.
  Future<ui.Image> get image async {
    // Used to convert listener callback to future
    final completer = Completer<ui.Image>();

    // Resolve the image as an [ImageStream] and listen to the stream
    resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, _) {
      // Assign the [ui.Image] from the image information streamed as the completer value
      // When the image from the stream arrives, the completer is completed
      completer.complete(info.image);
    }));

    // Wait for the image data from the completer to arrive from the callback
    return await completer.future;
  }
}
