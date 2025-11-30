import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/timezone_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await DatabaseService.initialize();
  await TimezoneService.instance.initialize();
  await NotificationService.instance.initialize();
  SyncService.instance.initialize();

  runApp(const SuperchargerBingoApp());
}

class SuperchargerBingoApp extends StatefulWidget {
  const SuperchargerBingoApp({super.key});

  @override
  State<SuperchargerBingoApp> createState() => _SuperchargerBingoAppState();
}

class _SuperchargerBingoAppState extends State<SuperchargerBingoApp> {
  bool _hasCompletedSetup = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final settings = await DatabaseService.getUserSettings();
    setState(() {
      // Consider setup complete if user has been through login screen
      _hasCompletedSetup = settings.lastLoginAt != null;
      _isLoading = false;
    });

    // Sync sites on startup (supercharge.info has CORS enabled, works on web)
    try {
      await SyncService.instance.syncSites();
    } catch (e) {
      debugPrint('Failed to sync sites: $e');
    }

    // Background sync only on native platforms (not web)
    if (!kIsWeb && settings.isAuthenticated) {
      await NotificationService.instance.scheduleBackgroundSync(settings);
    }
  }

  void _onLoginSuccess() {
    setState(() => _hasCompletedSetup = true);
    _checkAuthStatus(); // Re-run to set up background tasks
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supercharger Bingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE82127), // Tesla red
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE82127), // Tesla red
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
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
            : (_hasCompletedSetup
                  ? const AppShell(key: ValueKey('appShell'))
                  : LoginScreen(
                      key: const ValueKey('login'),
                      onLoginSuccess: _onLoginSuccess,
                    )),
      ),
    );
  }
}
