import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'settings_screen.dart';

/// Main app shell with Material 3 bottom navigation
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showCheckinDrawer = false;
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
        _selectedIndex =
            index - 1; // Map or Settings (offset by 1 since checkin is removed)
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
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
