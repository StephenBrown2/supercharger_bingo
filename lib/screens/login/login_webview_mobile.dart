// Native webview implementation for Android/iOS/Linux
// Uses webview_flutter package on mobile
// Uses webview_win_floating on Linux (registers automatically)

import 'dart:io' show Platform;

import 'package:material_ui/material_ui.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/life_auth.dart';
// Import Linux/Windows implementation - registers itself as platform implementation
// ignore: unused_import
import 'package:webview_win_floating/webview_win_floating.dart';

/// Whether this platform supports inline webview
bool get supportsInlineWebView {
  if (Platform.environment['FLUTTER_TEST'] == 'true') return false;
  return Platform.isAndroid || Platform.isIOS || Platform.isLinux;
}

/// Build a webview widget for native mobile platforms
Widget buildPlatformWebView({
  Key? key,
  required String initialUrl,
  required void Function(String url) onUrlChanged,
  required void Function(String cookies) onCookiesAvailable,
  required VoidCallback onReload,
}) {
  return _NativeWebView(
    key: key,
    initialUrl: initialUrl,
    onUrlChanged: onUrlChanged,
    onCookiesAvailable: onCookiesAvailable,
    onReload: onReload,
  );
}

class _NativeWebView extends StatefulWidget {
  final String initialUrl;
  final void Function(String url) onUrlChanged;
  final void Function(String cookies) onCookiesAvailable;
  final VoidCallback onReload;

  const _NativeWebView({
    super.key,
    required this.initialUrl,
    required this.onUrlChanged,
    required this.onCookiesAvailable,
    required this.onReload,
  });

  @override
  State<_NativeWebView> createState() => _NativeWebViewState();
}

class _NativeWebViewState extends State<_NativeWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Linux has no mobile browser to match, so it keeps a desktop Chrome agent.
  static const String _desktopUserAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            widget.onUrlChanged(url);
            await _extractCookies();
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );
    // Google refuses sign-in when it sees an embedded webview.
    var userAgent = _desktopUserAgent;
    if (Platform.isAndroid || Platform.isIOS) {
      final own = await _controller.getUserAgent();
      if (own != null && own.isNotEmpty) userAgent = browserUserAgent(own);
    }
    await _controller.setUserAgent(userAgent);
    await _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _extractCookies() async {
    try {
      final cookieResult = await _controller.runJavaScriptReturningResult(
        lifePageProbeScript,
      );
      widget.onCookiesAvailable(cookieResult.toString());
    } catch (_) {}
  }

  void reload() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const LinearProgressIndicator(),
      ],
    );
  }
}
