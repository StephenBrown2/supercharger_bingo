import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../services/nearest_site_service.dart';
import '../services/notification_service.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'visits_screen.dart';

/// Main app shell with Material 3 bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showCheckinDrawer = false;
  // Bumped on each visit to the tab, so the list reloads.
  int _visitsOpens = 0;
  final GlobalKey<MapScreenState> _mapKey = GlobalKey();
  static const _app = MethodChannel('supercharger_bingo/app');

  @override
  void initState() {
    super.initState();
    final request = NotificationService.instance.openSiteRequest;
    request.addListener(_openRequestedSite);
    // A tap that launched the app is already waiting.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openRequestedSite());
  }

  @override
  void dispose() {
    NotificationService.instance.openSiteRequest.removeListener(
      _openRequestedSite,
    );
    super.dispose();
  }

  void _openRequestedSite() {
    final request = NotificationService.instance.openSiteRequest;
    final siteId = request.value;
    if (siteId == null || !mounted) return;
    request.value = null;
    setState(() {
      _selectedIndex = 0;
      _showCheckinDrawer = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _mapKey.currentState?.showSite(siteId),
    );
  }

  /// Back destroys the Dart side, which would leave the nearest site Live
  /// Update frozen. While it runs, ask whether to keep it running in the
  /// background (like Home) or stop it and close the app.
  Future<void> _onBack(bool didPop, Object? _) async {
    if (didPop) return;
    final service = NearestSiteService.instance;
    if (service.running) {
      final close = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Keep running?'),
          content: const Text(
            'Closing the app will stop the live update notification. Do you '
            'want to leave the app running in the background?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Close App'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Running'),
            ),
          ],
        ),
      );
      if (close == null) return; // Dismissed: stay in the app.
      if (!close) {
        await _app.invokeMethod<void>('moveToBack');
        return;
      }
    }
    await service.stop();
    await SystemNavigator.pop();
  }

  void _onDrawerClosed() {
    setState(() {
      _showCheckinDrawer = false;
    });
  }

  void _onDestinationSelected(int index) {
    setState(() {
      if (index == 0) {
        // Toggle checkin drawer when "Check-in" is pressed
        _showCheckinDrawer = !_showCheckinDrawer;
        _selectedIndex = 0; // Stay on map screen
      } else {
        // Map, Visits, or Settings. Check-in is the drawer, not a page.
        _selectedIndex = index - 1;
        if (index == 2) _visitsOpens++;
        _showCheckinDrawer = false; // Close drawer when switching away
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onBack,
      child: _scaffold(),
    );
  }

  Widget _scaffold() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapScreen(
            key: _mapKey,
            showCheckinDrawer: _showCheckinDrawer,
            onDrawerClosed: _onDrawerClosed,
          ),
          VisitsScreen(key: ValueKey(_visitsOpens)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _showCheckinDrawer ? 0 : _selectedIndex + 1,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Check-in',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
