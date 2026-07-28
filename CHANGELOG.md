## Unreleased

* Fix shape gestures under current Flutter: restore drag updates, prevent missing-drawable notifications, and keep draw-once factories active after invalid multi-touch gestures ([Issue #43](https://github.com/omarhurani/flutter_painter/issues/43)).
* Add free-style drawing state and lifecycle callbacks, including cancellation cleanup ([Issue #52](https://github.com/omarhurani/flutter_painter/issues/52)).
* Add configurable text alignment for editing and rendered `TextDrawable`s ([Issue #49](https://github.com/omarhurani/flutter_painter/issues/49)).
* Add `TriangleDrawable` and `TriangleFactory` support ([Issue #65](https://github.com/omarhurani/flutter_painter/issues/65)).
* Allow images to opt out of free-style erasing and remain interactive in erase mode ([Issue #85](https://github.com/omarhurani/flutter_painter/issues/85)).
* Allow two-pointer zooming while free-style mode is active without leaving an accidental stroke, and keep drawing responsive after zooming ([Issue #64](https://github.com/omarhurani/flutter_painter/issues/64), [Issue #72](https://github.com/omarhurani/flutter_painter/issues/72), [Issue #76](https://github.com/omarhurani/flutter_painter/issues/76)).
* Add configurable opacity to `ImageDrawable` ([Issue #30](https://github.com/omarhurani/flutter_painter/issues/30)).
* Add undo-aware color updates for existing free-style, shape, and text drawables ([Issue #42](https://github.com/omarhurani/flutter_painter/issues/42), [Issue #66](https://github.com/omarhurani/flutter_painter/issues/66)).
* Document and cover local drawing coordinates after zooming and panning the painter ([Issue #40](https://github.com/omarhurani/flutter_painter/issues/40)).

## [2.0.0] - 2026-07-28

* Resume active maintenance after four years.
* Add support for Flutter 3.44.8 and current Dart SDKs.
* **Breaking:** Require Dart 3.8+ and Flutter 3.32+.
* Restore Android, iOS, web, and desktop example runners.
* Replace removed and deprecated framework APIs.
* Fix repainting when the painter scale changes.
* Respect hidden drawables inside groups and use the correct vertical assist paint.
* Restore selecting, moving, scaling, and rotating objects when canvas zoom is enabled.

## [1.0.1]
* Fix a bug where `TextDrawable`s would incorrectly render on the final image ([Issue #19](https://github.com/omarhurani/flutter_painter/issues/19)).
* Add Flutter linting using [flutter_lints](https://pub.dev/packages/flutter_lints) ([Issue #20](https://github.com/omarhurani/flutter_painter/issues/20)).
* Add some basic tests (thanks to [d3xt3r2909](https://github.com/omarhurani/flutter_painter/pull/21)).
* Add basic GitHub actions (thanks to [d3xt3r2909](https://github.com/omarhurani/flutter_painter/pull/21)).

## [1.0.0]
* Add `ImageDrawable`; now you can add any images you want onto the painter. They can be flipped. ([Issue #8](https://github.com/omarhurani/flutter_painter/issues/8)).
* Add `DoubleArrowDrawable`, which is the same as `ArrowDrawable` but with an arrow head on both sides (thanks to [AuronChoo](https://github.com/omarhurani/flutter_painter/pull/17)).
* Add free-style eraser mode; now you can erase any drawing, free-style or not ([Issue #3](https://github.com/omarhurani/flutter_painter/issues/3)).
    * **BREAKING:** `FreeStyleSettings.enabled` is now replaced with `FreeStyleSettings.mode` which has the values `FreeStyleMode.none`, `FreeStyleMode.draw` and `FreeStyleMode.erase`.
* Add the ability to undo and redo actions, including adding, editing, moving and removing drawables.
* Add a new `FlutterPainter` constructor, `FlutterPainter.builder`.
    * It takes the `PainterController` and a builder function, and passes the context and painter itself as an argument. The builder is automatically called when an update occurs in the controller.
* Add the ability to scale (zoom in/out) the painter.
* Add the selected object drawable as a part of `PainterController` value, which automatically updates when the selected object drawable changes.
* Fix a bug where tapping in free-style mode doesn't draw dots ([Issue #5](https://github.com/omarhurani/flutter_painter/issues/5), thanks to [friebetill](https://github.com/omarhurani/flutter_painter/pull/6)).
* Fix a bug where sometimes object drawables affect other object drawables un-intentionally ([Issue #12](https://github.com/omarhurani/flutter_painter/issues/12)).
* Fix some unintended behaviors with `FlutterPainter` callbacks where they're called in the wrong time and pass the wrong drawable.
* Separate the package into two main libraries, `flutter_painter_pure` and `flutter_painter_extensions`, with the main library, `flutter_painter` to use them both.
    * `flutter_painter_pure` is the API of Flutter Painter without any extensions.
    * `flutter_painter_extensions` is all the extensions both to Flutter and to Flutter Painter itself.
    * `flutter_painter` includes both, and is what you'll use most of the time.


## [0.2.1]
* Fix a static compatibility issue with Flutter Web.

## [0.2.0]

* Add support for cursor-based controls; now objects can be scaled and rotated using cursor.
* Add shapes; now you can create rectangles, ovals, lines and arrows ([Issue #1](https://github.com/omarhurani/flutter_painter/issues/1)).

## [0.1.0]

* Shift text field while editing text if needed so that it doesn't get blocked by the keyboard.

## [0.0.1]

* Initial release.
