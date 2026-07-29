import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockImageProvider extends Mock implements ImageProvider<Object> {}

class _TestImageStreamCompleter extends ImageStreamCompleter {
  bool get hasActiveListeners => hasListeners;

  void emitImage(ImageInfo image) => setImage(image);

  void emitError(Object error, StackTrace stackTrace) {
    reportError(exception: error, stack: stackTrace, silent: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('removes the image stream listener after the first frame', () async {
    final provider = _MockImageProvider();
    final stream = ImageStream();
    final streamCompleter = _TestImageStreamCompleter();
    stream.setCompleter(streamCompleter);
    when(() => provider.resolve(ImageConfiguration.empty)).thenReturn(stream);

    final future = provider.image;
    expect(streamCompleter.hasActiveListeners, isTrue);

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 4, 3),
      ui.Paint()..color = const ui.Color(0xFF1565C0),
    );
    streamCompleter.emitImage(
      ImageInfo(image: await recorder.endRecording().toImage(4, 3)),
    );

    final image = await future;
    addTearDown(image.dispose);
    expect(streamCompleter.hasActiveListeners, isFalse);
    expect(image.width, 4);
    expect(image.height, 3);
  });

  test('removes the image stream listener after an error', () async {
    final provider = _MockImageProvider();
    final stream = ImageStream();
    final streamCompleter = _TestImageStreamCompleter();
    stream.setCompleter(streamCompleter);
    when(() => provider.resolve(ImageConfiguration.empty)).thenReturn(stream);
    final error = StateError('image failed');

    final future = provider.image;
    expect(streamCompleter.hasActiveListeners, isTrue);
    streamCompleter.emitError(error, StackTrace.current);

    await expectLater(future, throwsA(same(error)));
    expect(streamCompleter.hasActiveListeners, isFalse);
  });
}
