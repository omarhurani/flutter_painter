import 'dart:ui';

import 'package:flutter/painting.dart';

/// Extension to add a copy method for [Paint].
extension PaintCopy on Paint{

  /// Creates a copy of this but with the given fields replaced with the new values.
  Paint copyWith({
    BlendMode? blendMode,
    Color? color,
    ColorFilter? colorFilter,
    FilterQuality? filterQuality,
    ImageFilter? imageFilter,
    bool? invertColors,
    bool? isAntiAlias,
    MaskFilter? maskFilter,
    Shader? shader,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? strokeWidth,
    PaintingStyle? style,
  }){
    return Paint()
      ..blendMode = blendMode ?? this.blendMode
      ..color = color ?? this.color
      ..colorFilter = colorFilter ?? this.colorFilter
      ..filterQuality = filterQuality ?? this.filterQuality
      ..imageFilter = imageFilter ?? this.imageFilter
      ..invertColors = invertColors ?? this.invertColors
      ..isAntiAlias = isAntiAlias ?? this.isAntiAlias
      ..maskFilter = maskFilter ?? this.maskFilter
      ..shader = shader ?? this.shader
      ..strokeCap = strokeCap ?? this.strokeCap
      ..strokeJoin = strokeJoin ?? this.strokeJoin
      ..strokeMiterLimit = strokeMiterLimit ?? this.strokeMiterLimit
      ..strokeWidth = strokeWidth ?? this.strokeWidth
      ..style = style ?? this.style;
  }
}

