part of 'flutter_painter.dart';

/// Flutter widget to draw shapes.
class ShapeWidget extends StatefulWidget {
  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// Child widget.
  final Widget child;

  /// Creates a [ShapeWidget] with the given [controller], [child] widget.
  const ShapeWidget({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  _ShapeWidgetState createState() => _ShapeWidgetState();
}

class _ShapeWidgetState extends State<ShapeWidget> {

  /// The shape that is being currently drawn.
  ShapeDrawable? currentShapeDrawable;

  /// Getter for shape settings to simplify code.
  ShapeSettings get settings => widget.controller.value.settings.shape;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      child: widget.child,
    );
  }


  void onScaleStart(ScaleStartDetails details){

    final creator = settings.creator;
    if(creator == null || details.pointerCount > 1)
      return;

    final shapeDrawable = creator.create(details.localFocalPoint);

    setState(() {
      widget.controller.addDrawables([shapeDrawable]);
      currentShapeDrawable = shapeDrawable;
    });

  }

  void onScaleUpdate(ScaleUpdateDetails details){

    final shapeDrawable = currentShapeDrawable;

    if(shapeDrawable == null)
      return;

    if(shapeDrawable is Sized1DDrawable){
      final sized1DDrawable = (shapeDrawable as Sized1DDrawable);
      final length = sized1DDrawable.length;
      final startingPosition = shapeDrawable.position - Offset.fromDirection(sized1DDrawable.rotationAngle, length/2);
      final newLine = (details.localFocalPoint - startingPosition);
      final newPosition = startingPosition + Offset.fromDirection(newLine.direction, newLine.distance/2);
      final newDrawable = sized1DDrawable.copyWith(
        position: newPosition,
        length: newLine.distance.abs(),
        rotation: newLine.direction,
      );
      currentShapeDrawable = (newDrawable as ShapeDrawable);
      updateDrawable(sized1DDrawable, newDrawable);
    }

    else if(shapeDrawable is Sized2DDrawable){
      final sized2DDrawable = (shapeDrawable as Sized2DDrawable);
      final size = sized2DDrawable.size;
      final startingPosition = shapeDrawable.position - Offset(size.width/2, size.height/2);

      final newSize = Size(
        (details.localFocalPoint.dx - startingPosition.dx),
        (details.localFocalPoint.dy - startingPosition.dy)
      );
      print([newSize, Size(
          newSize.width.abs(),
          newSize.height.abs()
      )]);
      final newPosition = startingPosition + Offset(newSize.width/2, newSize.height/2);
      final newDrawable = sized2DDrawable.copyWith(
        position: newPosition,
        size: newSize,
      );
      currentShapeDrawable = (newDrawable as ShapeDrawable);
      updateDrawable(sized2DDrawable, newDrawable);
    }
  }



  void onScaleEnd(ScaleEndDetails details){
    final shapeDrawable = currentShapeDrawable;
    if(shapeDrawable is Sized2DDrawable){
      final sized2DDrawable = (shapeDrawable as Sized2DDrawable);
      final newDrawable = sized2DDrawable.copyWith(
        size: Size(
          sized2DDrawable.size.width.abs(),
          sized2DDrawable.size.height.abs(),
        ),
      );
      updateDrawable(sized2DDrawable as ShapeDrawable, newDrawable);
    }
    setState(() {
      currentShapeDrawable = null;
    });
  }

  /// Replaces a drawable with a new one.
  void updateDrawable(ObjectDrawable oldDrawable, ObjectDrawable newDrawable) {
    setState(() {
      widget.controller.replaceDrawable(oldDrawable, newDrawable);
    });
  }

}
