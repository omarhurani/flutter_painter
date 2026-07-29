import 'dart:ui';

import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFreeStyleFactory extends FreeStyleFactory<FreeStyleDrawable> {
  final int id;

  const TestFreeStyleFactory(this.id);

  @override
  FreeStyleDrawable create({
    required List<Offset> path,
    required Color color,
    required double strokeWidth,
  }) {
    return FreeStyleDrawable(
      path: path,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

void main() {
  test('copyWith preserves, replaces, and clears the free-style factory', () {
    const factory = TestFreeStyleFactory(1);
    const replacement = TestFreeStyleFactory(2);
    const settings = FreeStyleSettings(factory: factory);

    expect(settings.copyWith().factory, same(factory));
    expect(settings.copyWith(factory: replacement).factory, same(replacement));
    expect(settings.copyWith(factory: null).factory, isNull);
  });
}
