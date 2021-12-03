import 'dart:js' as js;

/// Check Javascript for the renderer.
bool get usingHtmlRenderer => js.context['flutterCanvasKit'] == null;