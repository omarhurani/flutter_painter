import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../drawables/drawable.dart';
import '../drawables/grouped_drawable.dart';
import '../drawables/image_drawable.dart';
import '../drawables/object_drawable.dart';
import '../drawables/object_group_drawable.dart';
import '../drawables/path/erase_drawable.dart';
import '../drawables/path/free_style_drawable.dart';
import '../drawables/shape/arrow_drawable.dart';
import '../drawables/shape/double_arrow_drawable.dart';
import '../drawables/shape/labeled_shape_drawable.dart';
import '../drawables/shape/line_drawable.dart';
import '../drawables/shape/oval_drawable.dart';
import '../drawables/shape/rectangle_drawable.dart';
import '../drawables/shape/shape_drawable.dart';
import '../drawables/shape/triangle_drawable.dart';
import '../drawables/sized1ddrawable.dart';
import '../drawables/sized2ddrawable.dart';
import '../drawables/text_drawable.dart';

/// Converts an application-specific [Drawable] to and from JSON data.
///
/// Adapter type names must be unique and must not use a built-in type name.
abstract interface class DrawableJsonAdapter {
  /// The stable type name written to JSON.
  String get type;

  /// Whether this adapter can encode [drawable].
  bool canEncode(Drawable drawable);

  /// Encodes the application-specific fields of [drawable].
  FutureOr<Map<String, Object?>> encode(Drawable drawable);

  /// Decodes an application-specific drawable from [data].
  FutureOr<Drawable> decode(Map<String, Object?> data);
}

/// A versioned JSON codec for Flutter Painter drawables.
///
/// All built-in drawable types are supported. Image pixels are embedded as
/// PNG data, so encoding and decoding are asynchronous. Custom drawable types
/// require a [DrawableJsonAdapter].
class DrawableJsonCodec {
  /// The current document schema version.
  static const int schemaVersion = 1;

  static const Set<String> _builtInTypes = {
    'group',
    'objectGroup',
    'freeStyle',
    'erase',
    'text',
    'image',
    'line',
    'arrow',
    'doubleArrow',
    'rectangle',
    'oval',
    'triangle',
    'labeled1DShape',
    'labeled2DShape',
  };

  /// Application-specific drawable adapters.
  final List<DrawableJsonAdapter> adapters;

  /// Creates a codec with optional application-specific [adapters].
  DrawableJsonCodec({
    Iterable<DrawableJsonAdapter> adapters = const <DrawableJsonAdapter>[],
  }) : adapters = List.unmodifiable(adapters) {
    final types = <String>{};
    for (final adapter in this.adapters) {
      if (adapter.type.isEmpty) {
        throw ArgumentError.value(
          adapter.type,
          'adapters',
          'adapter type names cannot be empty',
        );
      }
      if (_builtInTypes.contains(adapter.type) || !types.add(adapter.type)) {
        throw ArgumentError.value(
          adapter.type,
          'adapters',
          'adapter type names must be unique and not conflict with built-ins',
        );
      }
    }
  }

  /// Encodes [drawables] into a JSON-compatible document.
  Future<Map<String, Object?>> encode(Iterable<Drawable> drawables) async {
    final encoded = <Map<String, Object?>>[];
    var index = 0;
    for (final drawable in drawables) {
      encoded.add(await _encodeDrawable(drawable, 'drawables[$index]'));
      index++;
    }
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'drawables': encoded,
    };
  }

  /// Encodes [drawables] into a JSON string.
  Future<String> encodeJson(Iterable<Drawable> drawables) async {
    return jsonEncode(await encode(drawables));
  }

  /// Decodes a document produced by [encode].
  ///
  /// The caller owns decoded image resources and should dispose their
  /// `ui.Image` objects when they are no longer used.
  Future<List<Drawable>> decode(Object? document) async {
    final root = _map(document, 'document');
    final version = _integer(root['schemaVersion'], 'schemaVersion');
    if (version != schemaVersion) {
      throw FormatException(
        'Unsupported drawable schema version $version; '
        'expected $schemaVersion.',
      );
    }
    final entries = _list(root['drawables'], 'drawables');
    final images = <ui.Image>[];
    try {
      final drawables = <Drawable>[];
      for (var index = 0; index < entries.length; index++) {
        drawables.add(
          await _decodeDrawable(
            _map(entries[index], 'drawables[$index]'),
            'drawables[$index]',
            images,
          ),
        );
      }
      return List.unmodifiable(drawables);
    } catch (_) {
      for (final image in images) {
        image.dispose();
      }
      rethrow;
    }
  }

  /// Decodes a JSON [source] produced by [encodeJson].
  Future<List<Drawable>> decodeJson(String source) {
    return decode(jsonDecode(source));
  }

  Future<Map<String, Object?>> _encodeDrawable(
    Drawable drawable,
    String path,
  ) async {
    for (final adapter in adapters) {
      if (adapter.canEncode(drawable)) {
        return _entry(adapter.type, await adapter.encode(drawable));
      }
    }

    if (drawable.runtimeType == GroupedDrawable) {
      final group = drawable as GroupedDrawable;
      final children = <Map<String, Object?>>[];
      for (var index = 0; index < group.drawables.length; index++) {
        children.add(
          await _encodeDrawable(
            group.drawables[index],
            '$path.drawables[$index]',
          ),
        );
      }
      return _entry('group', {'hidden': group.hidden, 'drawables': children});
    }
    if (drawable.runtimeType == ObjectGroupDrawable) {
      final group = drawable as ObjectGroupDrawable;
      final children = <Map<String, Object?>>[];
      for (var index = 0; index < group.drawables.length; index++) {
        children.add(
          await _encodeDrawable(
            group.drawables[index],
            '$path.drawables[$index]',
          ),
        );
      }
      return _entry('objectGroup', {
        ..._object(group, path),
        'drawables': children,
      });
    }
    if (drawable.runtimeType == FreeStyleDrawable) {
      final stroke = drawable as FreeStyleDrawable;
      return _entry('freeStyle', {
        'hidden': stroke.hidden,
        'path': _offsets(stroke.path),
        'strokeWidth': stroke.strokeWidth,
        'color': _color(stroke.color),
      });
    }
    if (drawable.runtimeType == EraseDrawable) {
      final stroke = drawable as EraseDrawable;
      return _entry('erase', {
        'hidden': stroke.hidden,
        'path': _offsets(stroke.path),
        'strokeWidth': stroke.strokeWidth,
      });
    }
    if (drawable.runtimeType == TextDrawable) {
      final text = drawable as TextDrawable;
      return _entry('text', {
        ..._object(text, path),
        'text': text.text,
        'style': _textStyle(text.style, '$path.style'),
        'direction': text.direction.name,
        'textAlign': text.textAlign.name,
      });
    }
    if (drawable.runtimeType == ImageDrawable) {
      final image = drawable as ImageDrawable;
      final bytes = await image.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (bytes == null) {
        throw StateError('Could not encode image pixels at $path.');
      }
      return _entry('image', {
        ..._object(image, path),
        'imagePng': base64Encode(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        ),
        'tag': image.tag,
        'sourceRect': _rect(image.sourceRect),
        'flipped': image.flipped,
        'opacity': image.opacity,
        'erasable': image.erasable,
      });
    }
    if (drawable.runtimeType == LineDrawable) {
      final shape = drawable as LineDrawable;
      return _entry('line', {
        ..._object(shape, path),
        'length': shape.length,
        'paint': _paint(shape.paint, '$path.paint'),
      });
    }
    if (drawable.runtimeType == ArrowDrawable) {
      final shape = drawable as ArrowDrawable;
      return _entry('arrow', {
        ..._object(shape, path),
        'length': shape.length,
        'paint': _paint(shape.paint, '$path.paint'),
        'arrowHeadSize': shape.arrowHeadSize,
      });
    }
    if (drawable.runtimeType == DoubleArrowDrawable) {
      final shape = drawable as DoubleArrowDrawable;
      return _entry('doubleArrow', {
        ..._object(shape, path),
        'length': shape.length,
        'paint': _paint(shape.paint, '$path.paint'),
        'arrowHeadSize': shape.arrowHeadSize,
      });
    }
    if (drawable.runtimeType == RectangleDrawable) {
      final shape = drawable as RectangleDrawable;
      return _entry('rectangle', {
        ..._object(shape, path),
        'size': _size(shape.size),
        'paint': _paint(shape.paint, '$path.paint'),
        'borderRadius': _borderRadius(shape.borderRadius),
      });
    }
    if (drawable.runtimeType == OvalDrawable) {
      final shape = drawable as OvalDrawable;
      return _entry('oval', {
        ..._object(shape, path),
        'size': _size(shape.size),
        'paint': _paint(shape.paint, '$path.paint'),
      });
    }
    if (drawable.runtimeType == TriangleDrawable) {
      final shape = drawable as TriangleDrawable;
      return _entry('triangle', {
        ..._object(shape, path),
        'size': _size(shape.size),
        'paint': _paint(shape.paint, '$path.paint'),
      });
    }
    if (drawable.runtimeType == LabeledSized1DShapeDrawable) {
      final shape = drawable as LabeledSized1DShapeDrawable;
      return _entry('labeled1DShape', {
        ..._object(shape, path),
        'length': shape.length,
        'paint': _paint(shape.paint, '$path.paint'),
        'shape': await _encodeDrawable(shape.shape, '$path.shape'),
        'label': _shapeLabel(shape.label, '$path.label'),
      });
    }
    if (drawable.runtimeType == LabeledSized2DShapeDrawable) {
      final shape = drawable as LabeledSized2DShapeDrawable;
      return _entry('labeled2DShape', {
        ..._object(shape, path),
        'size': _size(shape.size),
        'paint': _paint(shape.paint, '$path.paint'),
        'shape': await _encodeDrawable(shape.shape, '$path.shape'),
        'label': _shapeLabel(shape.label, '$path.label'),
      });
    }

    throw UnsupportedError(
      'No JSON adapter is registered for ${drawable.runtimeType} at $path.',
    );
  }

  Future<Drawable> _decodeDrawable(
    Map<String, Object?> entry,
    String path,
    List<ui.Image> images,
  ) async {
    final type = _string(entry['type'], '$path.type');
    final data = _map(entry['data'], '$path.data');
    switch (type) {
      case 'group':
        final entries = _list(data['drawables'], '$path.data.drawables');
        final drawables = <Drawable>[];
        for (var index = 0; index < entries.length; index++) {
          drawables.add(
            await _decodeDrawable(
              _map(entries[index], '$path.data.drawables[$index]'),
              '$path.data.drawables[$index]',
              images,
            ),
          );
        }
        return GroupedDrawable(
          drawables: drawables,
          hidden: _boolean(data['hidden'], '$path.data.hidden'),
        );
      case 'objectGroup':
        final object = _decodeObject(data, '$path.data');
        final entries = _list(data['drawables'], '$path.data.drawables');
        final localDrawables = <ObjectDrawable>[];
        for (var index = 0; index < entries.length; index++) {
          final drawable = await _decodeDrawable(
            _map(entries[index], '$path.data.drawables[$index]'),
            '$path.data.drawables[$index]',
            images,
          );
          if (drawable is! ObjectDrawable) {
            throw FormatException(
              '$path.data.drawables[$index] must decode to an object drawable.',
            );
          }
          localDrawables.add(drawable);
        }
        if (localDrawables.isEmpty) {
          throw FormatException('$path.data.drawables cannot be empty.');
        }
        return ObjectGroupDrawable.fromLocalDrawables(
          drawables: localDrawables,
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'freeStyle':
        return FreeStyleDrawable(
          path: _decodeOffsets(data['path'], '$path.data.path'),
          strokeWidth: _number(data['strokeWidth'], '$path.data.strokeWidth'),
          color: _decodeColor(data['color'], '$path.data.color'),
          hidden: _boolean(data['hidden'], '$path.data.hidden'),
        );
      case 'erase':
        return EraseDrawable(
          path: _decodeOffsets(data['path'], '$path.data.path'),
          strokeWidth: _number(data['strokeWidth'], '$path.data.strokeWidth'),
          hidden: _boolean(data['hidden'], '$path.data.hidden'),
        );
      case 'text':
        final object = _decodeObject(data, '$path.data');
        return TextDrawable(
          text: _string(data['text'], '$path.data.text'),
          position: object.position,
          rotation: object.rotation,
          scale: object.scale,
          style: _decodeTextStyle(data['style'], '$path.data.style'),
          direction: _enumValue(
            TextDirection.values,
            data['direction'],
            '$path.data.direction',
          ),
          textAlign: _enumValue(
            TextAlign.values,
            data['textAlign'],
            '$path.data.textAlign',
          ),
          locked: object.locked,
          hidden: object.hidden,
          assists: object.assists,
          assistPaints: object.assistPaints,
        );
      case 'image':
        final object = _decodeObject(data, '$path.data');
        final encoded = _string(data['imagePng'], '$path.data.imagePng');
        final bytes = base64Decode(encoded);
        final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
        final ui.FrameInfo frame;
        try {
          frame = await codec.getNextFrame();
        } finally {
          codec.dispose();
        }
        images.add(frame.image);
        return ImageDrawable(
          image: frame.image,
          tag: _optionalString(data['tag'], '$path.data.tag'),
          sourceRect: _decodeRect(data['sourceRect'], '$path.data.sourceRect'),
          flipped: _boolean(data['flipped'], '$path.data.flipped'),
          opacity: _number(data['opacity'], '$path.data.opacity'),
          erasable: _boolean(data['erasable'], '$path.data.erasable'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'line':
        final object = _decodeObject(data, '$path.data');
        return LineDrawable(
          length: _number(data['length'], '$path.data.length'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'arrow':
        final object = _decodeObject(data, '$path.data');
        return ArrowDrawable(
          length: _number(data['length'], '$path.data.length'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          arrowHeadSize: _optionalNumber(
            data['arrowHeadSize'],
            '$path.data.arrowHeadSize',
          ),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'doubleArrow':
        final object = _decodeObject(data, '$path.data');
        return DoubleArrowDrawable(
          length: _number(data['length'], '$path.data.length'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          arrowHeadSize: _optionalNumber(
            data['arrowHeadSize'],
            '$path.data.arrowHeadSize',
          ),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'rectangle':
        final object = _decodeObject(data, '$path.data');
        return RectangleDrawable(
          size: _decodeSize(data['size'], '$path.data.size'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          borderRadius: _decodeBorderRadius(
            data['borderRadius'],
            '$path.data.borderRadius',
          ),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'oval':
        final object = _decodeObject(data, '$path.data');
        return OvalDrawable(
          size: _decodeSize(data['size'], '$path.data.size'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'triangle':
        final object = _decodeObject(data, '$path.data');
        return TriangleDrawable(
          size: _decodeSize(data['size'], '$path.data.size'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'labeled1DShape':
        final object = _decodeObject(data, '$path.data');
        final shape = await _decodeDrawable(
          _map(data['shape'], '$path.data.shape'),
          '$path.data.shape',
          images,
        );
        if (shape is! ShapeDrawable || shape is! Sized1DDrawable) {
          throw FormatException(
            '$path.data.shape must decode to a one-dimensional shape.',
          );
        }
        return LabeledSized1DShapeDrawable(
          shape: shape,
          label: _decodeShapeLabel(data['label'], '$path.data.label'),
          length: _number(data['length'], '$path.data.length'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      case 'labeled2DShape':
        final object = _decodeObject(data, '$path.data');
        final shape = await _decodeDrawable(
          _map(data['shape'], '$path.data.shape'),
          '$path.data.shape',
          images,
        );
        if (shape is! ShapeDrawable || shape is! Sized2DDrawable) {
          throw FormatException(
            '$path.data.shape must decode to a two-dimensional shape.',
          );
        }
        return LabeledSized2DShapeDrawable(
          shape: shape,
          label: _decodeShapeLabel(data['label'], '$path.data.label'),
          size: _decodeSize(data['size'], '$path.data.size'),
          paint: _decodePaint(data['paint'], '$path.data.paint'),
          position: object.position,
          rotationAngle: object.rotation,
          scale: object.scale,
          assists: object.assists,
          assistPaints: object.assistPaints,
          locked: object.locked,
          hidden: object.hidden,
        );
      default:
        for (final adapter in adapters) {
          if (adapter.type == type) return await adapter.decode(data);
        }
        throw FormatException('Unknown drawable type "$type" at $path.');
    }
  }

  static Map<String, Object?> _entry(String type, Map<String, Object?> data) {
    return <String, Object?>{'type': type, 'data': data};
  }

  static Map<String, Object?> _object(ObjectDrawable drawable, String path) {
    return <String, Object?>{
      'hidden': drawable.hidden,
      'position': _offset(drawable.position),
      'rotation': drawable.rotationAngle,
      'scale': drawable.scale,
      'locked': drawable.locked,
      'assists': drawable.assists.map((assist) => assist.name).toList(),
      'assistPaints': drawable.assistPaints.map(
        (assist, paint) => MapEntry(
          assist.name,
          _paint(paint, '$path.assistPaints.${assist.name}'),
        ),
      ),
    };
  }

  static _DecodedObject _decodeObject(Map<String, Object?> data, String path) {
    final assists = _list(data['assists'], '$path.assists')
        .map(
          (value) =>
              _enumValue(ObjectDrawableAssist.values, value, '$path.assists'),
        )
        .toSet();
    final encodedPaints = _map(data['assistPaints'], '$path.assistPaints');
    final assistPaints = <ObjectDrawableAssist, Paint>{};
    for (final entry in encodedPaints.entries) {
      final assist = _enumValue(
        ObjectDrawableAssist.values,
        entry.key,
        '$path.assistPaints.${entry.key}',
      );
      assistPaints[assist] = _decodePaint(
        entry.value,
        '$path.assistPaints.${entry.key}',
      );
    }
    return _DecodedObject(
      hidden: _boolean(data['hidden'], '$path.hidden'),
      position: _decodeOffset(data['position'], '$path.position'),
      rotation: _number(data['rotation'], '$path.rotation'),
      scale: _number(data['scale'], '$path.scale'),
      locked: _boolean(data['locked'], '$path.locked'),
      assists: assists,
      assistPaints: assistPaints,
    );
  }

  static Map<String, Object?> _paint(Paint paint, String path) {
    if (paint.shader != null ||
        paint.maskFilter != null ||
        paint.colorFilter != null ||
        paint.imageFilter != null) {
      throw UnsupportedError(
        'Paint effects such as shaders and filters are not supported at $path.',
      );
    }
    return <String, Object?>{
      'color': _color(paint.color),
      'blendMode': paint.blendMode.name,
      'style': paint.style.name,
      'strokeWidth': paint.strokeWidth,
      'strokeCap': paint.strokeCap.name,
      'strokeJoin': paint.strokeJoin.name,
      'strokeMiterLimit': paint.strokeMiterLimit,
      'isAntiAlias': paint.isAntiAlias,
      'filterQuality': paint.filterQuality.name,
      'invertColors': paint.invertColors,
    };
  }

  static Paint _decodePaint(Object? value, String path) {
    final data = _map(value, path);
    return Paint()
      ..color = _decodeColor(data['color'], '$path.color')
      ..blendMode = _enumValue(
        BlendMode.values,
        data['blendMode'],
        '$path.blendMode',
      )
      ..style = _enumValue(PaintingStyle.values, data['style'], '$path.style')
      ..strokeWidth = _number(data['strokeWidth'], '$path.strokeWidth')
      ..strokeCap = _enumValue(
        StrokeCap.values,
        data['strokeCap'],
        '$path.strokeCap',
      )
      ..strokeJoin = _enumValue(
        StrokeJoin.values,
        data['strokeJoin'],
        '$path.strokeJoin',
      )
      // dart:ui exposes this value relative to its native default, while its
      // setter subtracts that default before storing it.
      ..strokeMiterLimit =
          _number(data['strokeMiterLimit'], '$path.strokeMiterLimit') + 4
      ..isAntiAlias = _boolean(data['isAntiAlias'], '$path.isAntiAlias')
      ..filterQuality = _enumValue(
        FilterQuality.values,
        data['filterQuality'],
        '$path.filterQuality',
      )
      ..invertColors = _boolean(data['invertColors'], '$path.invertColors');
  }

  static Map<String, Object?> _textStyle(TextStyle style, String path) {
    return <String, Object?>{
      'inherit': style.inherit,
      'color': style.color == null ? null : _color(style.color!),
      'backgroundColor': style.backgroundColor == null
          ? null
          : _color(style.backgroundColor!),
      'fontFamily': style.fontFamily,
      'fontFamilyFallback': style.fontFamilyFallback,
      'fontSize': style.fontSize,
      'fontWeight': style.fontWeight?.value,
      'fontStyle': style.fontStyle?.name,
      'letterSpacing': style.letterSpacing,
      'wordSpacing': style.wordSpacing,
      'textBaseline': style.textBaseline?.name,
      'height': style.height,
      'leadingDistribution': style.leadingDistribution?.name,
      'locale': style.locale == null
          ? null
          : <String, Object?>{
              'languageCode': style.locale!.languageCode,
              'scriptCode': style.locale!.scriptCode,
              'countryCode': style.locale!.countryCode,
            },
      'foreground': style.foreground == null
          ? null
          : _paint(style.foreground!, '$path.foreground'),
      'background': style.background == null
          ? null
          : _paint(style.background!, '$path.background'),
      'shadows': style.shadows
          ?.map(
            (shadow) => <String, Object?>{
              'color': _color(shadow.color),
              'offset': _offset(shadow.offset),
              'blurRadius': shadow.blurRadius,
            },
          )
          .toList(),
      'fontFeatures': style.fontFeatures
          ?.map(
            (feature) => <String, Object?>{
              'feature': feature.feature,
              'value': feature.value,
            },
          )
          .toList(),
      'fontVariations': style.fontVariations
          ?.map(
            (variation) => <String, Object?>{
              'axis': variation.axis,
              'value': variation.value,
            },
          )
          .toList(),
      'decoration': style.decoration == null
          ? null
          : <String>[
              if (style.decoration!.contains(TextDecoration.underline))
                'underline',
              if (style.decoration!.contains(TextDecoration.overline))
                'overline',
              if (style.decoration!.contains(TextDecoration.lineThrough))
                'lineThrough',
            ],
      'decorationColor': style.decorationColor == null
          ? null
          : _color(style.decorationColor!),
      'decorationStyle': style.decorationStyle?.name,
      'decorationThickness': style.decorationThickness,
      'debugLabel': style.debugLabel,
      'overflow': style.overflow?.name,
    };
  }

  static TextStyle _decodeTextStyle(Object? value, String path) {
    final data = _map(value, path);
    final fontWeightValue = _optionalInteger(
      data['fontWeight'],
      '$path.fontWeight',
    );
    FontWeight? fontWeight;
    if (fontWeightValue != null) {
      for (final candidate in FontWeight.values) {
        if (candidate.value == fontWeightValue) {
          fontWeight = candidate;
          break;
        }
      }
      if (fontWeight == null) {
        throw FormatException('$path.fontWeight is not a supported weight.');
      }
    }
    final localeData = data['locale'] == null
        ? null
        : _map(data['locale'], '$path.locale');
    final decorations = data['decoration'] == null
        ? null
        : _list(data['decoration'], '$path.decoration').map((value) {
            switch (_string(value, '$path.decoration')) {
              case 'underline':
                return TextDecoration.underline;
              case 'overline':
                return TextDecoration.overline;
              case 'lineThrough':
                return TextDecoration.lineThrough;
              default:
                throw FormatException(
                  'Unknown text decoration "$value" at $path.decoration.',
                );
            }
          }).toList();
    return TextStyle(
      inherit: _boolean(data['inherit'], '$path.inherit'),
      color: data['color'] == null
          ? null
          : _decodeColor(data['color'], '$path.color'),
      backgroundColor: data['backgroundColor'] == null
          ? null
          : _decodeColor(data['backgroundColor'], '$path.backgroundColor'),
      fontFamily: _optionalString(data['fontFamily'], '$path.fontFamily'),
      fontFamilyFallback: data['fontFamilyFallback'] == null
          ? null
          : _list(data['fontFamilyFallback'], '$path.fontFamilyFallback')
                .map((value) => _string(value, '$path.fontFamilyFallback'))
                .toList(),
      fontSize: _optionalNumber(data['fontSize'], '$path.fontSize'),
      fontWeight: fontWeight,
      fontStyle: data['fontStyle'] == null
          ? null
          : _enumValue(FontStyle.values, data['fontStyle'], '$path.fontStyle'),
      letterSpacing: _optionalNumber(
        data['letterSpacing'],
        '$path.letterSpacing',
      ),
      wordSpacing: _optionalNumber(data['wordSpacing'], '$path.wordSpacing'),
      textBaseline: data['textBaseline'] == null
          ? null
          : _enumValue(
              TextBaseline.values,
              data['textBaseline'],
              '$path.textBaseline',
            ),
      height: _optionalNumber(data['height'], '$path.height'),
      leadingDistribution: data['leadingDistribution'] == null
          ? null
          : _enumValue(
              TextLeadingDistribution.values,
              data['leadingDistribution'],
              '$path.leadingDistribution',
            ),
      locale: localeData == null
          ? null
          : Locale.fromSubtags(
              languageCode: _string(
                localeData['languageCode'],
                '$path.locale.languageCode',
              ),
              scriptCode: _optionalString(
                localeData['scriptCode'],
                '$path.locale.scriptCode',
              ),
              countryCode: _optionalString(
                localeData['countryCode'],
                '$path.locale.countryCode',
              ),
            ),
      foreground: data['foreground'] == null
          ? null
          : _decodePaint(data['foreground'], '$path.foreground'),
      background: data['background'] == null
          ? null
          : _decodePaint(data['background'], '$path.background'),
      shadows: data['shadows'] == null
          ? null
          : _list(data['shadows'], '$path.shadows').map((value) {
              final shadow = _map(value, '$path.shadows');
              return Shadow(
                color: _decodeColor(shadow['color'], '$path.shadows.color'),
                offset: _decodeOffset(shadow['offset'], '$path.shadows.offset'),
                blurRadius: _number(
                  shadow['blurRadius'],
                  '$path.shadows.blurRadius',
                ),
              );
            }).toList(),
      fontFeatures: data['fontFeatures'] == null
          ? null
          : _list(data['fontFeatures'], '$path.fontFeatures').map((value) {
              final feature = _map(value, '$path.fontFeatures');
              return ui.FontFeature(
                _string(feature['feature'], '$path.fontFeatures.feature'),
                _integer(feature['value'], '$path.fontFeatures.value'),
              );
            }).toList(),
      fontVariations: data['fontVariations'] == null
          ? null
          : _list(data['fontVariations'], '$path.fontVariations').map((value) {
              final variation = _map(value, '$path.fontVariations');
              return ui.FontVariation(
                _string(variation['axis'], '$path.fontVariations.axis'),
                _number(variation['value'], '$path.fontVariations.value'),
              );
            }).toList(),
      decoration: decorations == null
          ? null
          : TextDecoration.combine(decorations),
      decorationColor: data['decorationColor'] == null
          ? null
          : _decodeColor(data['decorationColor'], '$path.decorationColor'),
      decorationStyle: data['decorationStyle'] == null
          ? null
          : _enumValue(
              TextDecorationStyle.values,
              data['decorationStyle'],
              '$path.decorationStyle',
            ),
      decorationThickness: _optionalNumber(
        data['decorationThickness'],
        '$path.decorationThickness',
      ),
      debugLabel: _optionalString(data['debugLabel'], '$path.debugLabel'),
      overflow: data['overflow'] == null
          ? null
          : _enumValue(TextOverflow.values, data['overflow'], '$path.overflow'),
    );
  }

  static Map<String, Object?> _shapeLabel(ShapeLabel label, String path) {
    return <String, Object?>{
      'text': label.text,
      'style': _textStyle(label.style, '$path.style'),
      'direction': label.direction.name,
      'textAlign': label.textAlign.name,
      'padding': <String, Object?>{
        'left': label.padding.left,
        'top': label.padding.top,
        'right': label.padding.right,
        'bottom': label.padding.bottom,
      },
      'backgroundColor': label.backgroundColor == null
          ? null
          : _color(label.backgroundColor!),
      'borderRadius': _borderRadius(label.borderRadius),
      'offset': _offset(label.offset),
    };
  }

  static ShapeLabel _decodeShapeLabel(Object? value, String path) {
    final data = _map(value, path);
    final padding = _map(data['padding'], '$path.padding');
    return ShapeLabel(
      text: _string(data['text'], '$path.text'),
      style: _decodeTextStyle(data['style'], '$path.style'),
      direction: _enumValue(
        TextDirection.values,
        data['direction'],
        '$path.direction',
      ),
      textAlign: _enumValue(
        TextAlign.values,
        data['textAlign'],
        '$path.textAlign',
      ),
      padding: EdgeInsets.fromLTRB(
        _number(padding['left'], '$path.padding.left'),
        _number(padding['top'], '$path.padding.top'),
        _number(padding['right'], '$path.padding.right'),
        _number(padding['bottom'], '$path.padding.bottom'),
      ),
      backgroundColor: data['backgroundColor'] == null
          ? null
          : _decodeColor(data['backgroundColor'], '$path.backgroundColor'),
      borderRadius: _decodeBorderRadius(
        data['borderRadius'],
        '$path.borderRadius',
      ),
      offset: _decodeOffset(data['offset'], '$path.offset'),
    );
  }

  static Map<String, Object?> _color(Color color) {
    return <String, Object?>{
      'alpha': color.a,
      'red': color.r,
      'green': color.g,
      'blue': color.b,
      'colorSpace': color.colorSpace.name,
    };
  }

  static Color _decodeColor(Object? value, String path) {
    final data = _map(value, path);
    return Color.from(
      alpha: _number(data['alpha'], '$path.alpha'),
      red: _number(data['red'], '$path.red'),
      green: _number(data['green'], '$path.green'),
      blue: _number(data['blue'], '$path.blue'),
      colorSpace: _enumValue(
        ui.ColorSpace.values,
        data['colorSpace'],
        '$path.colorSpace',
      ),
    );
  }

  static Map<String, Object?> _offset(Offset offset) {
    return <String, Object?>{'dx': offset.dx, 'dy': offset.dy};
  }

  static List<Map<String, Object?>> _offsets(Iterable<Offset> offsets) {
    return offsets.map(_offset).toList();
  }

  static Offset _decodeOffset(Object? value, String path) {
    final data = _map(value, path);
    return Offset(
      _number(data['dx'], '$path.dx'),
      _number(data['dy'], '$path.dy'),
    );
  }

  static List<Offset> _decodeOffsets(Object? value, String path) {
    final values = _list(value, path);
    if (values.isEmpty) {
      throw FormatException('$path cannot be empty.');
    }
    return [
      for (var index = 0; index < values.length; index++)
        _decodeOffset(values[index], '$path[$index]'),
    ];
  }

  static Map<String, Object?> _size(Size size) {
    return <String, Object?>{'width': size.width, 'height': size.height};
  }

  static Size _decodeSize(Object? value, String path) {
    final data = _map(value, path);
    return Size(
      _number(data['width'], '$path.width'),
      _number(data['height'], '$path.height'),
    );
  }

  static Map<String, Object?> _rect(Rect rect) {
    return <String, Object?>{
      'left': rect.left,
      'top': rect.top,
      'width': rect.width,
      'height': rect.height,
    };
  }

  static Rect _decodeRect(Object? value, String path) {
    final data = _map(value, path);
    return Rect.fromLTWH(
      _number(data['left'], '$path.left'),
      _number(data['top'], '$path.top'),
      _number(data['width'], '$path.width'),
      _number(data['height'], '$path.height'),
    );
  }

  static Map<String, Object?> _radius(Radius radius) {
    return <String, Object?>{'x': radius.x, 'y': radius.y};
  }

  static Radius _decodeRadius(Object? value, String path) {
    final data = _map(value, path);
    return Radius.elliptical(
      _number(data['x'], '$path.x'),
      _number(data['y'], '$path.y'),
    );
  }

  static Map<String, Object?> _borderRadius(BorderRadius radius) {
    return <String, Object?>{
      'topLeft': _radius(radius.topLeft),
      'topRight': _radius(radius.topRight),
      'bottomLeft': _radius(radius.bottomLeft),
      'bottomRight': _radius(radius.bottomRight),
    };
  }

  static BorderRadius _decodeBorderRadius(Object? value, String path) {
    final data = _map(value, path);
    return BorderRadius.only(
      topLeft: _decodeRadius(data['topLeft'], '$path.topLeft'),
      topRight: _decodeRadius(data['topRight'], '$path.topRight'),
      bottomLeft: _decodeRadius(data['bottomLeft'], '$path.bottomLeft'),
      bottomRight: _decodeRadius(data['bottomRight'], '$path.bottomRight'),
    );
  }

  static Map<String, Object?> _map(Object? value, String path) {
    if (value is! Map) {
      throw FormatException('$path must be a JSON object.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('$path contains a non-string key.');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static List<Object?> _list(Object? value, String path) {
    if (value is! List) {
      throw FormatException('$path must be a JSON array.');
    }
    return value.cast<Object?>();
  }

  static String _string(Object? value, String path) {
    if (value is! String) throw FormatException('$path must be a string.');
    return value;
  }

  static String? _optionalString(Object? value, String path) {
    if (value == null) return null;
    return _string(value, path);
  }

  static bool _boolean(Object? value, String path) {
    if (value is! bool) throw FormatException('$path must be a boolean.');
    return value;
  }

  static double _number(Object? value, String path) {
    if (value is! num || !value.isFinite) {
      throw FormatException('$path must be a finite number.');
    }
    return value.toDouble();
  }

  static double? _optionalNumber(Object? value, String path) {
    if (value == null) return null;
    return _number(value, path);
  }

  static int _integer(Object? value, String path) {
    if (value is! num || !value.isFinite || value.toInt() != value) {
      throw FormatException('$path must be an integer.');
    }
    return value.toInt();
  }

  static int? _optionalInteger(Object? value, String path) {
    if (value == null) return null;
    return _integer(value, path);
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? value,
    String path,
  ) {
    final name = _string(value, path);
    for (final candidate in values) {
      if (candidate.name == name) return candidate;
    }
    throw FormatException('Unknown value "$name" at $path.');
  }
}

class _DecodedObject {
  final bool hidden;
  final Offset position;
  final double rotation;
  final double scale;
  final bool locked;
  final Set<ObjectDrawableAssist> assists;
  final Map<ObjectDrawableAssist, Paint> assistPaints;

  const _DecodedObject({
    required this.hidden,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.locked,
    required this.assists,
    required this.assistPaints,
  });
}
