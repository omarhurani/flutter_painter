import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Adds a method to get a [ui.Image] object from any [ImageProvider].
extension ImageProviderUiImageGetter on ImageProvider {
  /// Returns an owned [ui.Image] containing the first frame from this provider.
  ///
  /// The image-stream listener is removed after the first image or error. The
  /// caller must dispose the returned image when it is no longer needed.
  Future<ui.Image> get image async {
    final completer = Completer<ui.Image>();
    final stream = resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        if (completer.isCompleted) {
          info.dispose();
          return;
        }
        completer.complete(info.image);
      },
      onError: (Object error, StackTrace? stackTrace) {
        stream.removeListener(listener);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace ?? StackTrace.current);
        }
      },
    );
    stream.addListener(listener);

    return completer.future;
  }
}
