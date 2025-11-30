// Web implementation using HtmlElementView with iframe
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Whether this platform supports inline webview
bool get supportsInlineWebView => true;

/// Build a webview widget for web platform using iframe
Widget buildPlatformWebView({
  Key? key,
  required String initialUrl,
  required void Function(String url) onUrlChanged,
  required void Function(String cookies) onCookiesAvailable,
  required VoidCallback onReload,
}) {
  return _WebIframeView(
    key: key,
    initialUrl: initialUrl,
    onUrlChanged: onUrlChanged,
    onCookiesAvailable: onCookiesAvailable,
    onReload: onReload,
  );
}

class _WebIframeView extends StatefulWidget {
  final String initialUrl;
  final void Function(String url) onUrlChanged;
  final void Function(String cookies) onCookiesAvailable;
  final VoidCallback onReload;

  const _WebIframeView({
    super.key,
    required this.initialUrl,
    required this.onUrlChanged,
    required this.onCookiesAvailable,
    required this.onReload,
  });

  @override
  State<_WebIframeView> createState() => _WebIframeViewState();
}

class _WebIframeViewState extends State<_WebIframeView> {
  late final String _viewType;
  html.IFrameElement? _iframe;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewType = 'login-iframe-${DateTime.now().millisecondsSinceEpoch}';
    _registerIframe();
  }

  void _registerIframe() {
    // Register the iframe factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        _iframe = html.IFrameElement()
          ..src = widget.initialUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'cross-origin-isolated';

        // Listen for load events
        _iframe!.onLoad.listen((event) {
          setState(() => _isLoading = false);
          _checkLoginStatus();
        });

        return _iframe!;
      },
    );
  }

  void _checkLoginStatus() {
    // Note: Due to cross-origin restrictions, we can't directly access
    // the iframe's document or cookies from JavaScript.
    // 
    // For web, we'll need to use a different approach:
    // 1. Use window.postMessage() if the login page supports it
    // 2. Or redirect to a callback URL that the Flutter app can intercept
    //
    // For now, we'll pass the current document cookies (not iframe cookies)
    // The user will need to configure supercharging.life to post messages
    // or use a redirect-based OAuth flow.
    
    try {
      final cookies = html.document.cookie ?? '';
      widget.onCookiesAvailable(cookies);
      
      // Try to get iframe URL (may fail due to CORS)
      try {
        final location = _iframe?.contentWindow?.location;
        if (location != null) {
          // Cast to get href property
          final href = (location as dynamic).href as String?;
          if (href != null) {
            widget.onUrlChanged(href);
          }
        }
      } catch (_) {
        // Cross-origin - cannot access iframe location
        // This is expected for external sites
      }
    } catch (_) {}
  }

  void reload() {
    if (_iframe != null) {
      _iframe!.src = widget.initialUrl;
      setState(() => _isLoading = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HtmlElementView(viewType: _viewType),
        if (_isLoading)
          const LinearProgressIndicator(),
      ],
    );
  }
}
