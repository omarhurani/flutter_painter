import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/src/controllers/drawables/grouped_drawable.dart';
import 'package:flutter_test/flutter_test.dart';

class _CustomDrawable extends Drawable {
  final int value;

  const _CustomDrawable({required this.value, super.hidden});

  @override
  void draw(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      value.toDouble(),
      Paint()..color = Colors.purple,
    );
  }
}

class _CustomDrawableAdapter implements DrawableJsonAdapter {
  const _CustomDrawableAdapter({this.type = 'customCircle'});

  @override
  final String type;

  @override
  bool canEncode(Drawable drawable) => drawable is _CustomDrawable;

  @override
  Map<String, Object?> encode(Drawable drawable) {
    final custom = drawable as _CustomDrawable;
    return {'value': custom.value, 'hidden': custom.hidden};
  }

  @override
  Drawable decode(Map<String, Object?> data) {
    return _CustomDrawable(
      value: data['value']! as int,
      hidden: data['hidden']! as bool,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('round-trips and renders every built-in drawable type', () async {
    final sourceImage = await _createSourceImage();
    addTearDown(sourceImage.dispose);
    final shapePaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.bevel
      ..strokeMiterLimit = 7
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.high;
    final assistPaint = Paint()
      ..color = const Color(0xFF00AA00)
      ..strokeWidth = 1.5;
    final assists = {ObjectDrawableAssist.horizontal};
    final assistPaints = {ObjectDrawableAssist.horizontal: assistPaint};
    final textStyle = TextStyle(
      inherit: false,
      color: const Color(0xFF512DA8),
      backgroundColor: const Color(0x22FFCC00),
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Arial'],
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      letterSpacing: 1.2,
      wordSpacing: 2.3,
      textBaseline: TextBaseline.alphabetic,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
      locale: const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      shadows: const [
        Shadow(color: Color(0x66000000), offset: Offset(2, 3), blurRadius: 4),
      ],
      fontFeatures: const [ui.FontFeature('tnum')],
      fontVariations: const [ui.FontVariation('wght', 620)],
      decoration: TextDecoration.combine(const [
        TextDecoration.underline,
        TextDecoration.lineThrough,
      ]),
      decorationColor: const Color(0xFF00838F),
      decorationStyle: TextDecorationStyle.dashed,
      decorationThickness: 1.5,
      debugLabel: 'persisted-style',
      overflow: TextOverflow.ellipsis,
    );
    final labelStyle = TextStyle(
      fontSize: 13,
      foreground: Paint()..color = const Color(0xFFB71C1C),
      background: Paint()..color = const Color(0x11FFFFFF),
    );

    final original = <Drawable>[
      GroupedDrawable(
        drawables: [
          FreeStyleDrawable(
            path: const [Offset(10, 20), Offset(50, 60), Offset(90, 30)],
            color: const Color(0xFFEF6C00),
            strokeWidth: 5,
          ),
          EraseDrawable(
            path: const [Offset(30, 30), Offset(35, 35)],
            strokeWidth: 3,
          ),
          ImageDrawable(
            image: sourceImage,
            tag: 'sticker/star',
            sourceRect: const Rect.fromLTWH(10, 0, 10, 10),
            position: const Offset(45, 45),
            rotationAngle: 0.2,
            scale: 2,
            flipped: true,
            opacity: 0.75,
            blurSigma: 6,
            shape: ImageDrawableShape.oval,
            erasable: false,
            assists: assists,
            assistPaints: assistPaints,
          ),
        ],
      ),
      TextDrawable(
        text: 'Saved text',
        position: const Offset(120, 30),
        rotation: 0.15,
        scale: 1.2,
        style: textStyle,
        direction: TextDirection.rtl,
        textAlign: TextAlign.end,
        locked: true,
        assists: assists,
        assistPaints: assistPaints,
      ),
      LineDrawable(
        length: 70,
        position: const Offset(80, 80),
        rotationAngle: 0.1,
        scale: 1.1,
        paint: shapePaint,
        assists: assists,
        assistPaints: assistPaints,
      ),
      ArrowDrawable(
        length: 75,
        arrowHeadSize: 12,
        position: const Offset(100, 100),
        rotationAngle: 0.3,
        paint: shapePaint,
      ),
      DoubleArrowDrawable(
        length: 80,
        arrowHeadSize: 10,
        position: const Offset(120, 120),
        rotationAngle: -0.2,
        paint: shapePaint,
      ),
      RectangleDrawable(
        size: const Size(60, 40),
        position: const Offset(150, 80),
        rotationAngle: 0.25,
        scale: 0.9,
        paint: shapePaint,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.elliptical(4, 8),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.elliptical(6, 3),
        ),
      ),
      OvalDrawable(
        size: const Size(55, 35),
        position: const Offset(170, 130),
        paint: shapePaint,
      ),
      TriangleDrawable(
        size: const Size(50, 45),
        position: const Offset(60, 160),
        rotationAngle: 0.4,
        paint: shapePaint,
      ),
      LabeledSized1DShapeDrawable(
        shape: DoubleArrowDrawable(
          length: 10,
          position: Offset.zero,
          arrowHeadSize: 8,
          paint: shapePaint,
        ),
        label: ShapeLabel(
          text: '120 mm',
          style: labelStyle,
          direction: TextDirection.ltr,
          textAlign: TextAlign.center,
          padding: const EdgeInsets.fromLTRB(5, 3, 7, 4),
          backgroundColor: const Color(0xEEFFFFFF),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          offset: const Offset(0, -12),
        ),
        length: 90,
        position: const Offset(110, 185),
        rotationAngle: -0.15,
        scale: 1.05,
        paint: shapePaint,
      ),
      LabeledSized2DShapeDrawable(
        shape: RectangleDrawable(
          size: const Size(10, 10),
          position: Offset.zero,
          paint: shapePaint,
        ),
        label: const ShapeLabel(
          text: 'Room A',
          backgroundColor: Color(0xDDFFFFFF),
        ),
        size: const Size(70, 45),
        position: const Offset(175, 185),
        rotationAngle: 0.2,
        paint: shapePaint,
        hidden: true,
      ),
      ObjectGroupDrawable.fromDrawables(
        drawables: [
          RectangleDrawable(
            size: const Size(24, 18),
            position: const Offset(35, 210),
            paint: shapePaint,
          ),
          OvalDrawable(
            size: const Size(20, 28),
            position: const Offset(75, 215),
            paint: shapePaint,
          ),
        ],
        rotationAngle: 0.35,
        scale: 1.15,
        locked: true,
      ),
      AngleDrawable(
        radius: 42,
        sweepAngle: AngleDrawable.degreesToRadians(235),
        arcRadius: 14,
        position: const Offset(175, 55),
        rotationAngle: 0.3,
        scale: 0.8,
        paint: shapePaint,
      ),
    ];
    final codec = DrawableJsonCodec();

    final encodedJson = await codec.encodeJson(original);
    final restored = await codec.decodeJson(encodedJson);
    addTearDown(() => _disposeDrawableImages(restored));

    expect(restored, hasLength(original.length));
    expect(restored[0], isA<GroupedDrawable>());
    expect(restored[1], isA<TextDrawable>());
    expect(restored[2], isA<LineDrawable>());
    expect(restored[3], isA<ArrowDrawable>());
    expect(restored[4], isA<DoubleArrowDrawable>());
    expect(restored[5], isA<RectangleDrawable>());
    expect(restored[6], isA<OvalDrawable>());
    expect(restored[7], isA<TriangleDrawable>());
    expect(restored[8], isA<LabeledSized1DShapeDrawable>());
    expect(restored[9], isA<LabeledSized2DShapeDrawable>());
    expect(restored[10], isA<ObjectGroupDrawable>());
    expect(restored[11], isA<AngleDrawable>());
    expect(
      (restored[11] as AngleDrawable).sweepAngleDegrees,
      closeTo(235, 0.0001),
    );
    final movedLine = (restored[2] as LineDrawable).copyWith(
      position: const Offset(90, 90),
    );
    expect(
      movedLine.assistPaints[ObjectDrawableAssist.horizontal]?.color,
      assistPaint.color,
    );

    final reencodedJson = await codec.encodeJson(restored);
    expect(
      _withoutImageData(jsonDecode(reencodedJson)),
      _withoutImageData(jsonDecode(encodedJson)),
    );

    final originalController = PainterController(drawables: original);
    final restoredController = PainterController(drawables: restored);
    addTearDown(originalController.dispose);
    addTearDown(restoredController.dispose);
    final originalRender = await originalController.renderImage(
      const Size(240, 240),
    );
    final restoredRender = await restoredController.renderImage(
      const Size(240, 240),
    );
    addTearDown(originalRender.dispose);
    addTearDown(restoredRender.dispose);

    expect(
      await _rawPixels(restoredRender),
      orderedEquals(await _rawPixels(originalRender)),
    );
  });

  test('supports application-specific drawable adapters', () async {
    final codec = DrawableJsonCodec(adapters: const [_CustomDrawableAdapter()]);

    final json = await codec.encodeJson([
      const _CustomDrawable(value: 7, hidden: true),
    ]);
    final restored = await codec.decodeJson(json);

    expect(
      restored.single,
      isA<_CustomDrawable>()
          .having((drawable) => drawable.value, 'value', 7)
          .having((drawable) => drawable.hidden, 'hidden', isTrue),
    );
  });

  test('restores image JSON written before blur fields were added', () async {
    final sourceImage = await _createSourceImage();
    addTearDown(sourceImage.dispose);
    final codec = DrawableJsonCodec();
    final encoded = await codec.encode([
      ImageDrawable(image: sourceImage, position: const Offset(10, 10)),
    ]);
    final entries = encoded['drawables']! as List<Map<String, Object?>>;
    final data = entries.single['data']! as Map<String, Object?>;
    data
      ..remove('blurSigma')
      ..remove('shape');

    final restored = await codec.decode(encoded);
    addTearDown(() => _disposeDrawableImages(restored));
    final image = restored.single as ImageDrawable;

    expect(image.blurSigma, 0);
    expect(image.shape, ImageDrawableShape.rectangle);
  });

  test('rejects unsupported custom drawables and invalid adapters', () async {
    final codec = DrawableJsonCodec();

    await expectLater(
      codec.encodeJson([const _CustomDrawable(value: 3)]),
      throwsA(isA<UnsupportedError>()),
    );
    expect(
      () => DrawableJsonCodec(
        adapters: const [_CustomDrawableAdapter(type: 'image')],
      ),
      throwsArgumentError,
    );
    expect(
      () => DrawableJsonCodec(
        adapters: const [_CustomDrawableAdapter(), _CustomDrawableAdapter()],
      ),
      throwsArgumentError,
    );
  });

  test('rejects unsupported versions and malformed drawable types', () async {
    final codec = DrawableJsonCodec();

    await expectLater(
      codec.decode({'schemaVersion': 2, 'drawables': const []}),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      codec.decode({
        'schemaVersion': 1,
        'drawables': [
          {'type': 'futureDrawable', 'data': <String, Object?>{}},
        ],
      }),
      throwsA(isA<FormatException>()),
    );
  });
}

Future<ui.Image> _createSourceImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 10, 10),
    Paint()..color = Colors.red,
  );
  canvas.drawRect(
    const Rect.fromLTWH(10, 0, 10, 10),
    Paint()..color = Colors.blue,
  );
  return recorder.endRecording().toImage(20, 10);
}

Future<List<int>> _rawPixels(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) throw StateError('Could not read rendered pixels.');
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Object? _withoutImageData(Object? value) {
  if (value is List) return value.map(_withoutImageData).toList();
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key: entry.key == 'imagePng'
            ? '<png>'
            : _withoutImageData(entry.value),
    };
  }
  return value;
}

void _disposeDrawableImages(Iterable<Drawable> drawables) {
  final images = <ui.Image>{};

  void collect(Iterable<Drawable> values) {
    for (final drawable in values) {
      if (drawable is ImageDrawable) {
        images.add(drawable.image);
      } else if (drawable is GroupedDrawable) {
        collect(drawable.drawables);
      } else if (drawable is ObjectGroupDrawable) {
        collect(drawable.drawables);
      }
    }
  }

  collect(drawables);
  for (final image in images) {
    image.dispose();
  }
}
