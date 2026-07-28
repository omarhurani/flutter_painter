# Repository Guidelines

## Project Structure & Module Organization

`lib/flutter_painter.dart` is the main public entry point; `flutter_painter_pure.dart` and `flutter_painter_extensions.dart` expose the extension-free API and helper extensions separately. Implementation code lives under `lib/src/`: controllers own painter state, actions, settings, events, and drawables, while `views/` contains widgets and custom painters. Keep barrel exports aligned when adding public APIs.

Tests live in `test/` and mirror source paths, for example `test/unit/src/views/painters/painter_test.dart`. Shared mocks and helpers belong in `test/widget_test_utils.dart`. The runnable showcase is in `example/`, with its UI in `example/lib/main.dart` and demo media beside the example project.

## Build, Test, and Development Commands

- `flutter pub get` — resolve package dependencies.
- `dart format lib test example/lib example/test` — apply standard Dart formatting.
- `flutter analyze` — run `flutter_lints` and the repository’s analyzer rules.
- `flutter test` — execute the package test suite.
- `cd example && flutter pub get && flutter run` — launch the interactive painter example.
- `cd example && flutter build web` — verify the example’s web build when UI or rendering behavior changes.

The package supports Dart 3.8+ and Flutter 3.32+. Keep those constraints and the stable-channel CI workflow aligned when adopting newer framework APIs.

## Coding Style & Naming Conventions

Use two-space indentation and let `dart format` decide wrapping. Follow Dart conventions: `UpperCamelCase` types, `lowerCamelCase` members, `snake_case.dart` files, and leading underscores for private symbols. Prefer null-safe types, `const` constructors, and `final` values. Document public APIs with `///`; keep widget, controller, and drawable responsibilities separated. Do not use `print`, as `avoid_print` is enabled.

## Testing Guidelines

Tests use `flutter_test`; mocks use `mocktail`. Name files `*_test.dart`, group related behavior with `group`, and describe observable outcomes in `test` or `testWidgets`. Add regression coverage for controller state changes, drawing calls, sizing, and visibility behavior. No coverage threshold is enforced, but changed behavior should be tested.

## Commit & Pull Request Guidelines

History favors short imperative subjects such as `Fix ...`, `Add ...`, and `Update ...`; Conventional Commit prefixes are not required. Keep commits focused. Pull requests should explain the behavior change, link relevant issues, list validation performed, and include screenshots or a GIF for visible UI changes. Ensure `flutter analyze` and `flutter test` pass, and update README/CHANGELOG when public behavior changes.
