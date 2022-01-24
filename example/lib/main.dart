import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

import 'dart:ui' as ui;

import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Painter Example",
      theme: ThemeData(
          primaryColor: Colors.brown, accentColor: Colors.amberAccent),
      home: FlutterPainterExample(),
    );
  }
}

class FlutterPainterExample extends StatefulWidget {
  const FlutterPainterExample({Key? key}) : super(key: key);

  @override
  _FlutterPainterExampleState createState() => _FlutterPainterExampleState();
}

class _FlutterPainterExampleState extends State<FlutterPainterExample> {
  static const Color red = Color(0xFFFF0000);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: FreeStyleSettings(
              enabled: false,
              color: red,
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  /// Fetches image from an [ImageProvider] (in this example, [NetworkImage])
  /// to use it as a background
  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image = await NetworkImage('https://picsum.photos/1920/1080/').image;

    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Painter Example"),
        actions: [
          controller.value.selectedDrawable == null
              ? Container()
              : IconButton(
                  icon: const Icon(
                    PhosphorIcons.trash,
                  ),
                  color: Colors.red,
                  onPressed: () => removeDrawable(
                    controller.value.selectedDrawable!,
                  ),
                ),
          IconButton(
            icon: Icon(
              PhosphorIcons.arrowCounterClockwise,
            ),
            onPressed: removeLastDrawable,
          ),
          IconButton(
            icon: Icon(
              PhosphorIcons.scribbleLoop,
              color: controller.freeStyleSettings.enabled
                  ? Theme.of(context).accentColor
                  : null,
            ),
            onPressed: toggleFreeStyle,
          ),
          IconButton(
            icon: Icon(
              PhosphorIcons.textT,
              color:
                  textFocusNode.hasFocus ? Theme.of(context).accentColor : null,
            ),
            onPressed: addText,
          ),
          PopupMenuButton<ShapeFactory?>(
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: LineFactory(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.lineSegment,
                        color: Colors.black,
                      ),
                      Text(" Line")
                    ],
                  )),
              PopupMenuItem(
                  value: ArrowFactory(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.arrowUpRight,
                        color: Colors.black,
                      ),
                      Text(" Arrow")
                    ],
                  )),
              PopupMenuItem(
                  value: RectangleFactory(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.rectangle,
                        color: Colors.black,
                      ),
                      Text(" Rectangle")
                    ],
                  )),
              PopupMenuItem(
                  value: OvalFactory(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIcons.circle,
                        color: Colors.black,
                      ),
                      Text(" Oval")
                    ],
                  )),
            ],
            onSelected: selectShape,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                controller.shapeSettings.factory is LineFactory
                    ? PhosphorIcons.lineSegment
                    : controller.shapeSettings.factory is ArrowFactory
                        ? PhosphorIcons.arrowUpRight
                        : controller.shapeSettings.factory is RectangleFactory
                            ? PhosphorIcons.rectangle
                            : controller.shapeSettings.factory is OvalFactory
                                ? PhosphorIcons.circle
                                : PhosphorIcons.polygon,
                color: controller.shapeSettings.factory != null
                    ? Theme.of(context).accentColor
                    : null,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          PhosphorIcons.imageFill,
        ),
        onPressed: renderAndDisplayImage,
      ),
      body: Stack(
        children: [
          if (backgroundImage != null)
            // Enforces constraints
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: backgroundImage!.width / backgroundImage!.height,
                  child: FlutterPainter(
                    onPainterSettingsChanged: (_) => setState(() {}),
                    controller: controller,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 400,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      color: Colors.white54,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controller.freeStyleSettings.enabled) ...[
                          Divider(),
                          Text("Free Style Drawing Settings"),
                          // Control free style stroke width
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Stroke Width")),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 2,
                                    max: 25,
                                    value: controller
                                        .freeStyleSettings.strokeWidth,
                                    onChanged: setFreeStyleStrokeWidth),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Color")),
                              // Control free style color hue
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 0,
                                    max: 359.99,
                                    value: HSVColor.fromColor(
                                            controller.freeStyleSettings.color)
                                        .hue,
                                    activeColor:
                                        controller.freeStyleSettings.color,
                                    onChanged: setFreeStyleColor),
                              ),
                            ],
                          ),
                        ],
                        if (textFocusNode.hasFocus) ...[
                          Divider(),
                          Text("Text settings"),
                          // Control text font size
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Font Size")),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 8,
                                    max: 96,
                                    value: controller
                                            .textSettings.textStyle.fontSize ??
                                        14,
                                    onChanged: setTextFontSize),
                              ),
                            ],
                          ),

                          // Control text color hue
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Color")),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 0,
                                    max: 359.99,
                                    value: HSVColor.fromColor(controller
                                                .textSettings.textStyle.color ??
                                            red)
                                        .hue,
                                    activeColor:
                                        controller.textSettings.textStyle.color,
                                    onChanged: setTextColor),
                              ),
                            ],
                          ),
                        ],
                        if (controller.shapeSettings.factory != null) ...[
                          Divider(),
                          Text("Shape Settings"),

                          // Control text color hue
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Stroke Width")),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 2,
                                    max: 25,
                                    value: controller
                                            .shapeSettings.paint?.strokeWidth ??
                                        shapePaint.strokeWidth,
                                    onChanged: (value) => setShapeFactoryPaint(
                                            (controller.shapeSettings.paint ??
                                                    shapePaint)
                                                .copyWith(
                                          strokeWidth: value,
                                        ))),
                              ),
                            ],
                          ),

                          // Control shape color hue
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Color")),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                    min: 0,
                                    max: 359.99,
                                    value: HSVColor.fromColor(
                                            (controller.shapeSettings.paint ??
                                                    shapePaint)
                                                .color)
                                        .hue,
                                    activeColor:
                                        (controller.shapeSettings.paint ??
                                                shapePaint)
                                            .color,
                                    onChanged: (hue) => setShapeFactoryPaint(
                                            (controller.shapeSettings.paint ??
                                                    shapePaint)
                                                .copyWith(
                                          color: HSVColor.fromAHSV(1, hue, 1, 1)
                                              .toColor(),
                                        ))),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Expanded(flex: 1, child: Text("Fill shape")),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Switch(
                                      value: (controller.shapeSettings.paint ??
                                                  shapePaint)
                                              .style ==
                                          PaintingStyle.fill,
                                      onChanged: (value) =>
                                          setShapeFactoryPaint(
                                              (controller.shapeSettings.paint ??
                                                      shapePaint)
                                                  .copyWith(
                                            style: value
                                                ? PaintingStyle.fill
                                                : PaintingStyle.stroke,
                                          ))),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void removeDrawable(Drawable selectedDrawable) {
    controller.removeDrawable(selectedDrawable);
  }

  void removeLastDrawable() {
    controller.removeLastDrawable();
  }

  void toggleFreeStyle() {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings = controller.freeStyleSettings
          .copyWith(enabled: !controller.freeStyleSettings.enabled);
    });
  }

  void addText() {
    if (controller.freeStyleSettings.enabled) toggleFreeStyle();
    controller.addText();
  }

  void setFreeStyleStrokeWidth(double value) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings =
          controller.freeStyleSettings.copyWith(strokeWidth: value);
    });
  }

  void setFreeStyleColor(double hue) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.freeStyleSettings = controller.freeStyleSettings.copyWith(
        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      );
    });
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle:
              controller.textSettings.textStyle.copyWith(fontSize: size));
    });
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapeSettings =
          controller.shapeSettings.copyWith(paint: paint);
    });
  }

  void setTextColor(double hue) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle: controller.textSettings.textStyle.copyWith(
        color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
      ));
    });
  }

  void selectShape(ShapeFactory? factory) {
    setState(() {
      controller.shapeSettings = controller.shapeSettings.copyWith(
        factory:
            factory.runtimeType == controller.shapeSettings.factory.runtimeType
                ? null
                : factory,
      );
    });
  }

  void renderAndDisplayImage() {
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(
        backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());

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
        builder: (context) => RenderedImageDialog(imageFuture: imageFuture));
  }
}

class RenderedImageDialog extends StatelessWidget {
  final Future<Uint8List?> imageFuture;

  const RenderedImageDialog({Key? key, required this.imageFuture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rendered Image"),
      content: FutureBuilder<Uint8List?>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          if (!snapshot.hasData || snapshot.data == null) return SizedBox();
          return InteractiveViewer(
              maxScale: 10, child: Image.memory(snapshot.data!));
        },
      ),
    );
  }
}
