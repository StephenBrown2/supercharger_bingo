import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

/// Simple username entry screen (OAuth login temporarily disabled)
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = kIsWeb ? 'Saving...' : 'Looking up user...';
    });

    try {
      final username = _usernameController.text.trim();

      if (username.isNotEmpty) {
        if (kIsWeb) {
          // On web, CORS prevents API calls to supercharging.life
          // Just save the username locally
          setState(() => _statusMessage = 'Saving username...');
          final companion = UserSettingsTableCompanion(
            isAuthenticated: const Value(false),
            username: Value(username),
            lastLoginAt: Value(DateTime.now()),
          );
          await DatabaseService.updateUserSettings(companion);
        } else {
          // On desktop/mobile, try to sync user data from supercharging.life
          setState(() => _statusMessage = 'Syncing your check-ins...');
          final userFound = await SyncService.instance.syncUserByUsername(
            username,
          );

          if (!userFound) {
            // User not found, just save username locally
            setState(() => _statusMessage = 'User not found, continuing...');
            final companion = UserSettingsTableCompanion(
              isAuthenticated: const Value(false),
              username: Value(username),
              lastLoginAt: Value(DateTime.now()),
            );
            await DatabaseService.updateUserSettings(companion);
          }

          // Sync supercharger check-in counts to know which sites have been visited
          setState(() => _statusMessage = 'Syncing site data...');
          await SyncService.instance.syncSuperchargerCheckinCounts();
        }
      } else {
        // No username, just save settings
        final companion = UserSettingsTableCompanion(
          isAuthenticated: const Value(false),
          lastLoginAt: Value(DateTime.now()),
        );
        await DatabaseService.updateUserSettings(companion);
      }

      widget.onLoginSuccess();
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

  void _skipForNow() async {
    setState(() {
      _isLoading = true;
      _statusMessage = kIsWeb ? 'Loading...' : 'Syncing site data...';
    });

    try {
      if (!kIsWeb) {
        // On desktop/mobile, sync check-in counts
        await SyncService.instance.syncSuperchargerCheckinCounts();
      }

      final companion = UserSettingsTableCompanion(
        isAuthenticated: const Value(false),
        lastLoginAt: Value(DateTime.now()),
      );
      await DatabaseService.updateUserSettings(companion);
      widget.onLoginSuccess();
    } catch (e) {
      // Continue anyway
      final companion = UserSettingsTableCompanion(
        isAuthenticated: const Value(false),
        lastLoginAt: Value(DateTime.now()),
      );
      await DatabaseService.updateUserSettings(companion);
      widget.onLoginSuccess();
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App icon/logo
                    Icon(
                      Icons.ev_station,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),

                    // Title
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

                    // Info card about login
                    Card(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              kIsWeb ? Icons.web : Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                kIsWeb
                                    ? 'Web version has limited sync. Use the desktop app for full check-in sync from supercharging.life.'
                                    : 'Enter your supercharging.life username to sync your check-in history.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'supercharging.life Username',
                        hintText: 'Enter your username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 24),

                    // Status message
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

                    // Continue button
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _continue,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(_isLoading ? 'Syncing...' : 'Continue'),
                    ),
                    const SizedBox(height: 12),

                    // Skip button
                    TextButton(
                      onPressed: _isLoading ? null : _skipForNow,
                      child: const Text('Skip for now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
