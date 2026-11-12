import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'database/database.dart';
import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/setup_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/timezone_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DatabaseService.initialize();
  await TimezoneService.instance.initialize();
  await NotificationService.instance.initialize();
  SyncService.instance.initialize();

  final settings = await DatabaseService.getUserSettings();
  runApp(SuperchargerBingoApp(initialAppearance: settings.appAppearance));
}

class SuperchargerBingoApp extends StatefulWidget {
  const SuperchargerBingoApp({super.key, required this.initialAppearance});

  final AppAppearance initialAppearance;

  @override
  State<SuperchargerBingoApp> createState() => _SuperchargerBingoAppState();
}

class _SuperchargerBingoAppState extends State<SuperchargerBingoApp> {
  bool _hasCompletedSetup = false;
  bool _needsSetup = false;
  bool _isLoading = true;
  late final AppearanceController _appearance;

  @override
  void initState() {
    super.initState();
    _appearance = AppearanceController(widget.initialAppearance);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _appearance.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final settings = await DatabaseService.getUserSettings();
    setState(() {
      // Consider setup complete if user has been through login screen
      _hasCompletedSetup = settings.lastLoginAt != null;
      _needsSetup = settings.setupCompletedAt == null;
      _isLoading = false;
    });

    // Sync sites on startup (supercharge.info has CORS enabled, works on web).
    // It asks for location, so it waits until setup has asked first.
    if (settings.setupCompletedAt != null) {
      try {
        await SyncService.instance.syncSites();
      } catch (e) {
        debugPrint('Failed to sync sites: $e');
      }
    }

    // Sync community check-in data (drives the First pin colours). Best-effort
    // and unawaited so the map renders without waiting on the fragile endpoint.
    SyncService.instance.syncCommunityData();

    // Site and First alerts come from supercharge.info, so a device-only
    // sign-in still schedules them. The check-in post itself still waits
    // for a session. Setup asks for permissions in its own order first.
    if (!kIsWeb &&
        settings.lastLoginAt != null &&
        settings.setupCompletedAt != null) {
      // Android 13+ and iOS drop alerts until the user allows them.
      await NotificationService.instance.requestPermissions();
      await NotificationService.instance.scheduleBackgroundSync(settings);
    }
  }

  void _onLoginSuccess() {
    setState(() => _hasCompletedSetup = true);
    _checkAuthStatus(); // Re-run to set up background tasks
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeBuilder(
      controller: _appearance,
      builder: (light, dark, mode) => MaterialApp(
        title: 'Supercharger Bingo',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        home: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _isLoading
              ? SplashScreen(
                  key: const ValueKey('splash'),
                  onReady: () => setState(() => _isLoading = false),
                )
              : !_hasCompletedSetup
              ? LoginScreen(
                  key: const ValueKey('login'),
                  onLoginSuccess: _onLoginSuccess,
                )
              : _needsSetup
              ? SetupScreen(
                  key: const ValueKey('setup'),
                  onDone: _checkAuthStatus,
                )
              : const AppShell(key: ValueKey('appShell')),
        ),
      ),
    );
  }
}
