import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simple wrapper for testing specific widget
/// so that we don't need to write things multiple times
class WidgetTestbed {

  /// In case that we want to specify platform  for running tests
  Future<void> withPlatform(
    final TargetPlatform platform,
    final Function body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;

    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Widget simpleWrap({
    final Widget? child,
    final Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: child != null ? Material(child: child) : null,
    );
  }

  void increaseScreenSize(
    final WidgetTester tester, [
    final Size size = const Size(30000, 30000),
  ]) {
    tester.binding.window.physicalSizeTestValue = size;
  }

  void clearPhysicalSize(final WidgetTester tester) {
    tester.binding.window.clearPhysicalSizeTestValue();
  }
}
