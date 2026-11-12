import 'package:flutter/material.dart';

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
  final GlobalKey<State<MapScreen>> _mapKey = GlobalKey();

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
