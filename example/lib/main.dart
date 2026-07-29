import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

import 'dart:ui' as ui;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Painter Example",
      theme: ThemeData(
        primaryColor: Colors.brown,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.amberAccent,
        ),
      ),
      home: const FlutterPainterExample(),
    );
  }
}

class DottedFreeStyleFactory extends FreeStyleFactory<DottedFreeStyleDrawable> {
  const DottedFreeStyleFactory();

  @override
  DottedFreeStyleDrawable create({
    required List<Offset> path,
    required Color color,
    required double strokeWidth,
  }) {
    return DottedFreeStyleDrawable(
      path: path,
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

class DottedFreeStyleDrawable extends PathDrawable {
  final Color color;

  DottedFreeStyleDrawable({
    required super.path,
    required this.color,
    super.strokeWidth,
    super.hidden,
  });

  @override
  DottedFreeStyleDrawable copyWith({
    bool? hidden,
    List<Offset>? path,
    double? strokeWidth,
    Color? color,
  }) {
    return DottedFreeStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hidden: hidden ?? this.hidden,
    );
  }

  @override
  Paint get paint => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas, Size size) {
    final dotPaint = paint;
    for (final point in path) {
      canvas.drawCircle(point, strokeWidth / 2, dotPaint);
    }
  }
}

enum _ImageMenuAction { onlineSticker, croppedSample }

class FlutterPainterExample extends StatefulWidget {
  const FlutterPainterExample({super.key});

  @override
  State<FlutterPainterExample> createState() => _FlutterPainterExampleState();
}

class _FlutterPainterExampleState extends State<FlutterPainterExample> {
  static const Color red = Color(0xFFFF0000);

  // Colors quantize channels to 8 bits. Values closer to 360 wrap back to
  // zero when converted to red, so stop before that rounding boundary.
  static const double maxHue = 359.8;

  bool updatingImageOpacity = false;
  bool updatingSelectedShapeColor = false;
  bool updatingSelectedAngle = false;
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static const List<String> imageLinks = [
    "https://i.imgur.com/btoI5OX.png",
    "https://i.imgur.com/EXTQFt7.png",
    "https://i.imgur.com/EDNjJYL.png",
    "https://i.imgur.com/uQKD6NL.png",
    "https://i.imgur.com/cMqVRbl.png",
    "https://i.imgur.com/1cJBAfI.png",
    "https://i.imgur.com/eNYfHKL.png",
    "https://i.imgur.com/c4Ag5yt.png",
    "https://i.imgur.com/GhpCJuf.png",
    "https://i.imgur.com/XVMeluF.png",
    "https://i.imgur.com/mt2yO6Z.png",
    "https://i.imgur.com/rw9XP1X.png",
    "https://i.imgur.com/pD7foZ8.png",
    "https://i.imgur.com/13Y3vp2.png",
    "https://i.imgur.com/ojv3yw1.png",
    "https://i.imgur.com/f8ZNJJ7.png",
    "https://i.imgur.com/BiYkHzw.png",
    "https://i.imgur.com/snJOcEz.png",
    "https://i.imgur.com/b61cnhi.png",
    "https://i.imgur.com/FkDFzYe.png",
    "https://i.imgur.com/P310x7d.png",
    "https://i.imgur.com/5AHZpua.png",
    "https://i.imgur.com/tmvJY4r.png",
    "https://i.imgur.com/PdVfGkV.png",
    "https://i.imgur.com/1PRzwBf.png",
    "https://i.imgur.com/VeeMfBS.png",
  ];

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: red,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(color: red, strokeWidth: 5),
        shape: ShapeSettings(paint: shapePaint),
        scale: const ScaleSettings(enabled: true, minScale: 1, maxScale: 5),
      ),
    );
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  /// Creates an offline background so the example starts reliably.
  Future<void> initBackground() async {
    const imageSize = Size(1280, 720);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final bounds = Offset.zero & imageSize;
    final paint = Paint()
      ..shader = ui.Gradient.linear(bounds.topLeft, bounds.bottomRight, const [
        Color(0xFFFFF3E0),
        Color(0xFFFFCC80),
      ]);
    canvas.drawRect(bounds, paint);
    final image = await recorder.endRecording().toImage(
      imageSize.width.toInt(),
      imageSize.height.toInt(),
    );

    if (!mounted) {
      image.dispose();
      return;
    }

    setState(() {
      backgroundImage = image;
      controller.background = ImageBackgroundDrawable(
        image: image,
        fit: BoxFit.contain,
        backgroundColor: Colors.white,
      );
    });
  }

  @override
  void dispose() {
    textFocusNode.removeListener(onFocus);
    textFocusNode.dispose();
    controller.dispose();
    backgroundImage?.dispose();
    super.dispose();
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  /// Rotates only the background, keeping drawable coordinates unchanged.
  void rotateBackground() {
    final background = controller.value.background;
    if (background is ImageBackgroundDrawable) {
      controller.background = background.rotated();
    }
  }

  Widget buildDefault(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        // Listen to the controller and update the UI when it updates.
        child: ValueListenableBuilder<PainterControllerValue>(
          valueListenable: controller,
          child: const Text("Flutter Painter Example"),
          builder: (context, _, child) {
            return AppBar(
              title: child,
              actions: [
                IconButton(
                  tooltip: "Rotate background",
                  icon: const Icon(Icons.rotate_90_degrees_cw),
                  onPressed:
                      controller.value.background is ImageBackgroundDrawable
                      ? rotateBackground
                      : null,
                ),
                // Edit the selected text drawable
                IconButton(
                  tooltip: "Edit selected text",
                  icon: const Icon(Icons.edit),
                  onPressed: controller.selectedObjectDrawable is TextDrawable
                      ? editSelectedTextDrawable
                      : null,
                ),
                // Delete the selected drawable
                IconButton(
                  tooltip: "Remove selected drawable",
                  icon: const Icon(Icons.delete_outline),
                  onPressed: controller.selectedObjectDrawable == null
                      ? null
                      : () => controller.removeSelectedObjectDrawable(),
                ),
                // Delete the selected drawable
                IconButton(
                  icon: const Icon(Icons.flip),
                  onPressed:
                      controller.selectedObjectDrawable != null &&
                          controller.selectedObjectDrawable is ImageDrawable
                      ? flipSelectedImageDrawable
                      : null,
                ),
                // Redo action
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: controller.canRedo ? redo : null,
                ),
                // Undo action
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: controller.canUndo ? undo : null,
                ),
              ],
            );
          },
        ),
      ),
      // Generate image
      floatingActionButton: FloatingActionButton(
        onPressed: renderAndDisplayImage,
        child: const Icon(Icons.image),
      ),
      body: Stack(
        children: [
          if (backgroundImage != null)
            // Enforces constraints
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: backgroundImage!.width / backgroundImage!.height,
                  child: FlutterPainter(controller: controller),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            // Keep the settings controls clear of the floating action button.
            right: kFloatingActionButtonMargin + 56,
            left: 0,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        color: Colors.white54,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.freeStyleMode !=
                              FreeStyleMode.none) ...[
                            const Divider(),
                            const Text("Free Style Settings"),
                            // Control free style stroke width
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("Stroke Width"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 2,
                                    max: 25,
                                    value: controller.freeStyleStrokeWidth,
                                    onChanged: setFreeStyleStrokeWidth,
                                  ),
                                ),
                              ],
                            ),
                            if (controller.freeStyleMode == FreeStyleMode.draw)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Text("Color"),
                                      ),
                                      // Control free style color hue
                                      Expanded(
                                        flex: 3,
                                        child: Slider.adaptive(
                                          min: 0,
                                          max: maxHue,
                                          value: HSVColor.fromColor(
                                            controller.freeStyleColor,
                                          ).hue,
                                          activeColor:
                                              controller.freeStyleColor,
                                          onChanged: setFreeStyleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Material(
                                    type: MaterialType.transparency,
                                    child: SwitchListTile.adaptive(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text("Dotted brush"),
                                      value:
                                          controller.freeStyleFactory
                                              is DottedFreeStyleFactory,
                                      onChanged: setDottedBrushEnabled,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          if (textFocusNode.hasFocus) ...[
                            const Divider(),
                            const Text("Text settings"),
                            // Control text font size
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("Font Size"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 8,
                                    max: 96,
                                    value: controller.textStyle.fontSize ?? 14,
                                    onChanged: setTextFontSize,
                                  ),
                                ),
                              ],
                            ),

                            // Control text color hue
                            Row(
                              children: [
                                const Expanded(flex: 1, child: Text("Color")),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 0,
                                    max: maxHue,
                                    value: HSVColor.fromColor(
                                      controller.textStyle.color ?? red,
                                    ).hue,
                                    activeColor: controller.textStyle.color,
                                    onChanged: setTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (controller.shapeFactory != null) ...[
                            const Divider(),
                            const Text("Shape Settings"),

                            // Control text color hue
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("Stroke Width"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 2,
                                    max: 25,
                                    value:
                                        controller.shapePaint?.strokeWidth ??
                                        shapePaint.strokeWidth,
                                    onChanged: (value) => setShapeFactoryPaint(
                                      (controller.shapePaint ?? shapePaint)
                                          .copyWith(strokeWidth: value),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Control shape color hue
                            Row(
                              children: [
                                const Expanded(flex: 1, child: Text("Color")),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 0,
                                    max: maxHue,
                                    value: HSVColor.fromColor(
                                      (controller.shapePaint ?? shapePaint)
                                          .color,
                                    ).hue,
                                    activeColor:
                                        (controller.shapePaint ?? shapePaint)
                                            .color,
                                    onChanged: (hue) => setShapeFactoryPaint(
                                      (controller.shapePaint ?? shapePaint)
                                          .copyWith(
                                            color: HSVColor.fromAHSV(
                                              1,
                                              hue,
                                              1,
                                              1,
                                            ).toColor(),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text("Fill shape"),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Switch(
                                      value:
                                          (controller.shapePaint ?? shapePaint)
                                              .style ==
                                          PaintingStyle.fill,
                                      onChanged: (value) =>
                                          setShapeFactoryPaint(
                                            (controller.shapePaint ??
                                                    shapePaint)
                                                .copyWith(
                                                  style: value
                                                      ? PaintingStyle.fill
                                                      : PaintingStyle.stroke,
                                                ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (controller.selectedObjectDrawable
                              case final ImageDrawable imageDrawable) ...[
                            const Divider(),
                            const Text("Image Settings"),
                            Row(
                              children: [
                                const Expanded(flex: 1, child: Text("Opacity")),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 0,
                                    max: 1,
                                    value: imageDrawable.opacity,
                                    onChangeStart: startImageOpacityUpdate,
                                    onChanged: setSelectedImageOpacity,
                                    onChangeEnd: endImageOpacityUpdate,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: toggleSelectedImageCrop,
                                child: Text(
                                  imageDrawable.isCropped
                                      ? "Reset Crop"
                                      : "Crop Center",
                                ),
                              ),
                            ),
                          ],
                          if (controller.selectedObjectDrawable
                              case final ShapeDrawable shapeDrawable) ...[
                            const Divider(),
                            const Text("Selected Shape Settings"),
                            Row(
                              children: [
                                const Expanded(flex: 1, child: Text("Color")),
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 0,
                                    max: maxHue,
                                    value: HSVColor.fromColor(
                                      shapeDrawable.paint.color,
                                    ).hue,
                                    activeColor: shapeDrawable.paint.color,
                                    onChangeStart:
                                        startSelectedShapeColorUpdate,
                                    onChanged: setSelectedShapeColor,
                                    onChangeEnd: endSelectedShapeColorUpdate,
                                  ),
                                ),
                              ],
                            ),
                            if (shapeDrawable is AngleDrawable)
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Angle")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(
                                      min: 0,
                                      max: 360,
                                      divisions: 360,
                                      label:
                                          "${shapeDrawable.sweepAngleDegrees.round()}°",
                                      value: shapeDrawable.sweepAngleDegrees,
                                      onChangeStart: startSelectedAngleUpdate,
                                      onChanged: setSelectedAngle,
                                      onChangeEnd: endSelectedAngleUpdate,
                                    ),
                                  ),
                                ],
                              ),
                            if (shapeDrawable is LabeledShapeDrawable)
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: toggleSelectedShapeLabel,
                                  child: const Text("Change Label"),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, _, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Free-style eraser
            IconButton(
              icon: Icon(
                Icons.auto_fix_off,
                color: controller.freeStyleMode == FreeStyleMode.erase
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
              onPressed: toggleFreeStyleErase,
            ),
            // Free-style drawing
            IconButton(
              icon: Icon(
                Icons.gesture,
                color: controller.freeStyleMode == FreeStyleMode.draw
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
              onPressed: toggleFreeStyleDraw,
            ),
            // Add text
            PopupMenuButton<TextAlign>(
              tooltip: "Add text",
              initialValue: controller.textAlign,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: TextAlign.start,
                  child: Text("Start aligned"),
                ),
                PopupMenuItem(
                  value: TextAlign.center,
                  child: Text("Center aligned"),
                ),
                PopupMenuItem(value: TextAlign.end, child: Text("End aligned")),
              ],
              onSelected: (alignment) {
                setTextAlign(alignment);
                addText();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.text_fields,
                  color: textFocusNode.hasFocus
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                ),
              ),
            ),
            // Add a network sticker or an offline cropped sample.
            PopupMenuButton<_ImageMenuAction>(
              tooltip: "Add image",
              icon: const Icon(Icons.emoji_emotions_outlined),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ImageMenuAction.onlineSticker,
                  child: Text("Add online sticker"),
                ),
                PopupMenuItem(
                  value: _ImageMenuAction.croppedSample,
                  child: Text("Add cropped sample"),
                ),
              ],
              onSelected: (action) {
                switch (action) {
                  case _ImageMenuAction.onlineSticker:
                    addSticker();
                  case _ImageMenuAction.croppedSample:
                    addCroppedSample();
                }
              },
            ),
            // Add shapes
            if (controller.shapeFactory == null)
              PopupMenuButton<ShapeFactory?>(
                tooltip: "Add shape",
                itemBuilder: (context) =>
                    <ShapeFactory, String>{
                          const AngleFactory(): "Angle",
                          LineFactory(): "Line",
                          ArrowFactory(): "Arrow",
                          DoubleArrowFactory(): "Double Arrow",
                          RectangleFactory(): "Rectangle",
                          OvalFactory(): "Oval",
                          TriangleFactory(): "Triangle",
                          LabeledShapeFactory(
                            factory: DoubleArrowFactory(),
                            label: const ShapeLabel(
                              text: "120 mm",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ): "Labeled Double Arrow",
                        }.entries
                        .map(
                          (e) => PopupMenuItem(
                            value: e.key,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(getShapeIcon(e.key), color: Colors.black),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    e.value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                onSelected: selectShape,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    getShapeIcon(controller.shapeFactory),
                    color: controller.shapeFactory != null
                        ? Theme.of(context).colorScheme.secondary
                        : null,
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  getShapeIcon(controller.shapeFactory),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => selectShape(null),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildDefault(context);
  }

  static IconData getShapeIcon(ShapeFactory? shapeFactory) {
    if (shapeFactory is LabeledShapeFactory) {
      return getShapeIcon(shapeFactory.factory);
    }
    if (shapeFactory is AngleFactory) return Icons.square_foot;
    if (shapeFactory is LineFactory) return Icons.horizontal_rule;
    if (shapeFactory is ArrowFactory) return Icons.arrow_outward;
    if (shapeFactory is DoubleArrowFactory) {
      return Icons.compare_arrows;
    }
    if (shapeFactory is RectangleFactory) return Icons.rectangle_outlined;
    if (shapeFactory is OvalFactory) return Icons.circle_outlined;
    if (shapeFactory is TriangleFactory) return Icons.change_history;
    return Icons.category_outlined;
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
        ? FreeStyleMode.draw
        : FreeStyleMode.none;
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
        ? FreeStyleMode.erase
        : FreeStyleMode.none;
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void addSticker() async {
    final imageLink = await showDialog<String>(
      context: context,
      builder: (context) =>
          const SelectStickerImageDialog(imagesLinks: imageLinks),
    );
    if (!mounted || imageLink == null) return;

    try {
      final image = await NetworkImage(imageLink).image;
      if (!mounted) {
        image.dispose();
        return;
      }
      controller.addTaggedImage(
        image,
        tag: imageLink,
        size: const Size(100, 100),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to download this sticker.")),
      );
    }
  }

  void addCroppedSample() {
    final image = backgroundImage;
    if (image == null) return;

    final fullRect = ImageDrawable.fullSourceRect(image);
    final cropRect = Rect.fromLTWH(
      fullRect.width * 0.2,
      fullRect.height * 0.2,
      fullRect.width * 0.6,
      fullRect.height * 0.6,
    );
    controller.addCroppedImage(image, cropRect, const Size(180, 100));
    final drawable = controller.drawables.last as ImageDrawable;
    controller.selectObjectDrawable(drawable);
  }

  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
  }

  void setDottedBrushEnabled(bool enabled) {
    controller.freeStyleFactory = enabled
        ? const DottedFreeStyleFactory()
        : null;
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
        textStyle: controller.textSettings.textStyle.copyWith(fontSize: size),
      );
    });
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void setTextColor(double hue) {
    controller.textStyle = controller.textStyle.copyWith(
      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
    );
  }

  void setTextAlign(TextAlign textAlign) {
    controller.textAlign = textAlign;
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void renderAndDisplayImage() {
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(
      backgroundImage!.width.toDouble(),
      backgroundImage!.height.toDouble(),
    );

    // Render the image
    // Returns a [ui.Image] object, convert to to byte data and then to Uint8List
    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    // From here, you can write the PNG image data a file or do whatever you want with it
    // For example:
    // ```dart
    // final file = File('${(await getTemporaryDirectory()).path}/img.png');
    // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    // ```
    // I am going to display it using Image.memory

    // Show a dialog with the image
    showDialog(
      context: context,
      builder: (context) => RenderedImageDialog(imageFuture: imageFuture),
    );
  }

  void startImageOpacityUpdate(double _) {
    updatingImageOpacity = false;
  }

  void setSelectedImageOpacity(double opacity) {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable is! ImageDrawable) return;

    final replaced = controller.replaceDrawable(
      selectedDrawable,
      selectedDrawable.copyWith(opacity: opacity),
      newAction: !updatingImageOpacity,
    );
    if (replaced) updatingImageOpacity = true;
  }

  void endImageOpacityUpdate(double _) {
    updatingImageOpacity = false;
  }

  void startSelectedShapeColorUpdate(double _) {
    updatingSelectedShapeColor = false;
  }

  void setSelectedShapeColor(double hue) {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable is! ShapeDrawable) return;

    final replaced = controller.setDrawableColor(
      selectedDrawable,
      HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      newAction: !updatingSelectedShapeColor,
    );
    if (replaced) updatingSelectedShapeColor = true;
  }

  void endSelectedShapeColorUpdate(double _) {
    updatingSelectedShapeColor = false;
  }

  void startSelectedAngleUpdate(double _) {
    updatingSelectedAngle = false;
  }

  void setSelectedAngle(double degrees) {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable is! AngleDrawable) return;

    final replaced = controller.setAngleDegrees(
      selectedDrawable,
      degrees,
      newAction: !updatingSelectedAngle,
    );
    if (replaced) updatingSelectedAngle = true;
  }

  void endSelectedAngleUpdate(double _) {
    updatingSelectedAngle = false;
  }

  void editSelectedTextDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable is TextDrawable) {
      controller.editTextDrawable(selectedDrawable);
    }
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(
      imageDrawable,
      imageDrawable.copyWith(flipped: !imageDrawable.flipped),
    );
  }

  void toggleSelectedImageCrop() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    final fullRect = ImageDrawable.fullSourceRect(imageDrawable.image);
    final sourceRect = imageDrawable.isCropped
        ? fullRect
        : Rect.fromLTWH(
            fullRect.width * 0.2,
            fullRect.height * 0.2,
            fullRect.width * 0.6,
            fullRect.height * 0.6,
          );
    controller.cropImageDrawable(imageDrawable, sourceRect);
  }

  void toggleSelectedShapeLabel() {
    final drawable = controller.selectedObjectDrawable;
    if (drawable is! LabeledShapeDrawable) return;

    final text = drawable.label.text == "120 mm" ? "240 mm" : "120 mm";
    controller.setShapeLabel(drawable, drawable.label.withText(text));
  }
}

class RenderedImageDialog extends StatelessWidget {
  final Future<Uint8List?> imageFuture;

  const RenderedImageDialog({super.key, required this.imageFuture});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rendered Image"),
      content: FutureBuilder<Uint8List?>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox();
          }
          return InteractiveViewer(
            maxScale: 10,
            child: Image.memory(snapshot.data!),
          );
        },
      ),
    );
  }
}

class SelectStickerImageDialog extends StatelessWidget {
  final List<String> imagesLinks;

  const SelectStickerImageDialog({super.key, this.imagesLinks = const []});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select sticker"),
      content: imagesLinks.isEmpty
          ? const Text("No images")
          : FractionallySizedBox(
              heightFactor: 0.5,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (final imageLink in imagesLinks)
                      InkWell(
                        onTap: () => Navigator.pop(context, imageLink),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 4,
                          child: Image.network(
                            imageLink,
                            errorBuilder: (context, error, stackTrace) =>
                                const AspectRatio(
                                  aspectRatio: 1,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
