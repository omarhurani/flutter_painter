import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example renders the painter', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(FlutterPainter), findsOneWidget);
  });
}
