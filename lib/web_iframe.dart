// lib/web_iframe.dart

// This import only works on Flutter Web
// So we check if it's the web platform before using it.
import 'dart:html';
import 'dart:ui' as ui;

void registerIFrame(String viewId, String url) {
  // Registers the iframe only for Flutter Web
  // This must be guarded to avoid platform issues
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    (int viewId) => IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%',
  );
}
