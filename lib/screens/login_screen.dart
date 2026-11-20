import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';

import '../database/database.dart';
import '../services/session.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'life_login_page.dart';
import 'login/login_webview.dart';

/// GitHub and Google, matching supercharging.life. The live site is tried
/// first. If that cannot finish, the same provider is stored on this device.
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  bool get _canUseLiveLogin => !kIsWeb && supportsInlineWebView;

  void _finish() {
    widget.onLoginSuccess();
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _signIn(AuthProvider provider) async {
    if (!_canUseLiveLogin) {
      await _signInLocally(provider);
      return;
    }

    final result = await Navigator.of(context).push<LifeLoginResult>(
      MaterialPageRoute(builder: (_) => LifeLoginPage(provider: provider)),
    );
    if (!mounted || result == null) return;
    if (result.stayLocal || result.sessionId == null) {
      await _signInLocally(provider);
      return;
    }
    await _signInWithSession(
      provider,
      result.sessionId!,
      result.displayName ?? '',
    );
  }

  Future<void> _signInWithSession(
    AuthProvider provider,
    String sessionId,
    String displayName,
  ) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Saving supercharging.life session...';
    });
    try {
      var found = false;
      if (displayName.isNotEmpty) {
        try {
          found = await SyncService.instance.syncUserByUsername(displayName);
        } catch (_) {
          found = false;
        }
      }
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(
          authProvider: Value(provider),
          lastLoginAt: Value(DateTime.now()),
          username: found ? const Value.absent() : Value(displayName),
          displayName: found ? const Value.absent() : Value(displayName),
        ),
      );
      await Session.instance.signIn(sessionId);
      _finish();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _signInLocally(AuthProvider provider) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Saving on this device...';
    });
    try {
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(
          authProvider: Value(provider),
          lastLoginAt: Value(DateTime.now()),
        ),
      );
      _finish();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _skipForNow() async {
    setState(() {
      _isLoading = true;
      _statusMessage = kIsWeb ? 'Loading...' : 'Syncing site data...';
    });

    try {
      if (!kIsWeb) {
        await SyncService.instance.syncSuperchargerCheckinCounts();
      }
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(lastLoginAt: Value(DateTime.now())),
      );
      _finish();
    } catch (e) {
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(lastLoginAt: Value(DateTime.now())),
      );
      _finish();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = _canUseLiveLogin;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.ev_station,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Supercharger Bingo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your Tesla Supercharger visits',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        kIsWeb
                            ? 'Check-ins stay in this browser and show as pending. Account sync and community history are unavailable for now. Clearing browser data removes your saved visits.'
                            : live
                            ? 'Sign in with GitHub or Google through supercharging.life. If that page cannot finish, the same choice stays on this device and check-ins show as pending.'
                            : 'GitHub and Google stay on this device. Check-ins show as pending until a supercharging.life session is available.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_statusMessage != null) ...[
                    Text(
                      _statusMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!kIsWeb) ...[
                    FilledButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _signIn(AuthProvider.github),
                      icon: const Icon(Icons.code),
                      label: const Text('Login with GitHub'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _signIn(AuthProvider.google),
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Login with Google'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextButton(
                    onPressed: _isLoading ? null : _skipForNow,
                    child: Text(kIsWeb ? 'Continue locally' : 'Skip for now'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
