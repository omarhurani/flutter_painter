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
