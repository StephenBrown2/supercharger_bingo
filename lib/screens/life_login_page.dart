import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/life_auth.dart';
import 'login/login_webview.dart';

/// Result of an attempt to sign in through supercharging.life.
class LifeLoginResult {
  final String? sessionId;
  final String? displayName;
  final bool stayLocal;

  const LifeLoginResult({
    this.sessionId,
    this.displayName,
    this.stayLocal = false,
  });
}

/// In-app browser for supercharging.life's GitHub or Google button.
class LifeLoginPage extends StatefulWidget {
  final AuthProvider provider;

  const LifeLoginPage({super.key, required this.provider});

  @override
  State<LifeLoginPage> createState() => _LifeLoginPageState();
}

class _LifeLoginPageState extends State<LifeLoginPage> {
  bool _finished = false;
  String? _blockedMessage;

  void _finish(LifeLoginResult result) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(result);
  }

  void _onProbe(String raw) {
    final probe = LifePageProbe.parse(raw);
    if (probe.signedIn) {
      _finish(
        LifeLoginResult(
          sessionId: probe.sessionId,
          displayName: probe.displayName!.trim(),
        ),
      );
      return;
    }
    if (probe.blocked && _blockedMessage == null && mounted) {
      setState(() {
        _blockedMessage =
            '${authProviderLabel(widget.provider)} blocked the in-app browser.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = authProviderLabel(widget.provider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with $label'),
        actions: [
          TextButton(
            onPressed: () => _finish(const LifeLoginResult(stayLocal: true)),
            child: const Text('On this device'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_blockedMessage != null)
            MaterialBanner(
              content: Text(
                '$_blockedMessage Check-ins can stay on this device and show as pending.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      _finish(const LifeLoginResult(stayLocal: true)),
                  child: const Text('On this device'),
                ),
              ],
            ),
          Expanded(
            child: buildPlatformWebView(
              initialUrl: lifeAuthorizeUri(widget.provider).toString(),
              onUrlChanged: (_) {},
              onCookiesAvailable: _onProbe,
              onReload: () {},
            ),
          ),
        ],
      ),
    );
  }
}
