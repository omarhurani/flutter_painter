import '../../flutter_painter.dart';
import '../controllers/drawables/sized1ddrawable.dart';
import '../controllers/drawables/sized2ddrawable.dart';

extension ObjectDrawableExtension on ObjectDrawable {
  T? whenOrNull<T extends Object?>({
    T Function()? arrowDrawable,
    T Function()? doubleArrowDrawable,
    T Function()? imageDrawable,
    T Function()? lineDrawable,
    T Function()? nodePolygonDrawable,
    T Function()? ovalDrawable,
    T Function()? rectangleDrawable,
    T Function()? shapeDrawable,
    T Function()? sized1DDrawable,
    T Function()? sized2DDrawable,
    T Function()? textDrawable,
  }) {
    if (this is ArrowDrawable) return arrowDrawable?.call();
    if (this is DoubleArrowDrawable) return doubleArrowDrawable?.call();
    if (this is ImageDrawable) return imageDrawable?.call();
    if (this is ImageDrawable) return imageDrawable?.call();
    if (this is LineDrawable) return lineDrawable?.call();
    if (this is NodePolygonDrawable) return nodePolygonDrawable?.call();
    if (this is OvalDrawable) return ovalDrawable?.call();
    if (this is RectangleDrawable) return rectangleDrawable?.call();
    if (this is ShapeDrawable) return shapeDrawable?.call();
    if (this is Sized1DDrawable) return sized1DDrawable?.call();
    if (this is Sized2DDrawable) return sized2DDrawable?.call();
    if (this is TextDrawable) return textDrawable?.call();

    return null;
  }
}
