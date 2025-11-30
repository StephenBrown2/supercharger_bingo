// Stub file - this shouldn't be imported directly
// Used for conditional imports

import 'package:flutter/material.dart';

/// Stub widget builder - should never be called directly
Widget buildPlatformWebView({
  Key? key,
  required String initialUrl,
  required void Function(String url) onUrlChanged,
  required void Function(String cookies) onCookiesAvailable,
  required VoidCallback onReload,
}) {
  throw UnsupportedError('Platform not supported for webview');
}

/// Check if this platform supports inline webview
bool get supportsInlineWebView => false;
