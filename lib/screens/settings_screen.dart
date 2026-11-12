import 'package:drift/drift.dart' hide Column;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/life_auth.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'vehicles_screen.dart';

/// Mutable settings wrapper for the UI
class MutableSettings {
  int? userId;
  String? username;
  bool isAuthenticated;
  PollingInterval pollingInterval;
  double notificationRadiusKm;
  MapFilter mapFilter;
  bool showVisitedOnMap;
  bool clusterMarkers;
  double checkinRadiusKm;
  UnitSystem unitSystem;
  bool includeVisitedNearby;
  bool includeVehicleInPrivateNote;
  AppAppearance appAppearance;
  bool notifyNewSites;
  bool notifyFirstEligible;
  AuthProvider? authProvider;
  DateTime? lastSitesSyncAt;
  DateTime? lastCheckinHistorySyncAt;
  DateTime? lastXlsxSyncAt;

  MutableSettings({
    this.userId,
    this.username,
    this.isAuthenticated = false,
    this.pollingInterval = PollingInterval.hours24,
    this.notificationRadiusKm = 100.0,
    this.mapFilter = MapFilter.openUnvisited,
    this.showVisitedOnMap = false,
    this.clusterMarkers = true,
    this.checkinRadiusKm = 5000.0,
    this.unitSystem = UnitSystem.imperial,
    this.includeVisitedNearby = false,
    this.includeVehicleInPrivateNote = false,
    this.appAppearance = AppAppearance.system,
    this.notifyNewSites = true,
    this.notifyFirstEligible = true,
    this.authProvider,
    this.lastSitesSyncAt,
    this.lastCheckinHistorySyncAt,
    this.lastXlsxSyncAt,
  });

  factory MutableSettings.from(UserSettingsTableData data) {
    return MutableSettings(
      userId: data.odUserId,
      username: data.username,
      isAuthenticated: data.isAuthenticated,
      pollingInterval: data.pollingInterval,
      notificationRadiusKm: data.notificationRadiusKm,
      mapFilter: data.mapFilter,
      showVisitedOnMap: data.showVisitedOnMap,
      clusterMarkers: data.clusterMarkers,
      checkinRadiusKm: data.checkinRadiusKm,
      unitSystem: data.unitSystem,
      includeVisitedNearby: data.includeVisitedNearby,
      includeVehicleInPrivateNote: data.includeVehicleInPrivateNote,
      appAppearance: data.appAppearance,
      notifyNewSites: data.notifyNewSites,
      notifyFirstEligible: data.notifyFirstEligible,
      authProvider: data.authProvider,
      lastSitesSyncAt: data.lastSitesSyncAt,
      lastCheckinHistorySyncAt: data.lastCheckinHistorySyncAt,
      lastXlsxSyncAt: data.lastXlsxSyncAt,
    );
  }

  UserSettingsTableCompanion toCompanion() {
    return UserSettingsTableCompanion(
      odUserId: Value(userId),
      username: Value(username),
      isAuthenticated: Value(isAuthenticated),
      pollingInterval: Value(pollingInterval),
      notificationRadiusKm: Value(notificationRadiusKm),
      mapFilter: Value(mapFilter),
      showVisitedOnMap: Value(showVisitedOnMap),
      clusterMarkers: Value(clusterMarkers),
      checkinRadiusKm: Value(checkinRadiusKm),
      unitSystem: Value(unitSystem),
      includeVisitedNearby: Value(includeVisitedNearby),
      includeVehicleInPrivateNote: Value(includeVehicleInPrivateNote),
      appAppearance: Value(appAppearance),
      notifyNewSites: Value(notifyNewSites),
      notifyFirstEligible: Value(notifyFirstEligible),
      authProvider: Value(authProvider),
    );
  }
}

/// Settings screen with notification, polling, and advanced options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  MutableSettings? _settings;
  bool _isLoading = true;
  bool _isSyncingSites = false;
  int? _siteCount;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSiteCount();
    _loadLocationAccess();
  }

  /// Null hides the row. Only phones run background alerts.
  LocationPermission? _locationAccess;

  bool get _isPhone => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> _loadLocationAccess() async {
    if (!_isPhone) return;
    final access = await Geolocator.checkPermission();
    if (mounted) setState(() => _locationAccess = access);
  }

  /// Alerts need notifications, and location all the time to follow the
  /// phone while the app is closed. Without it they use the last spot the
  /// app saw.
  Future<void> _ensureAlertPermissions() async {
    if (!_isPhone) return;
    final notificationsAllowed = await NotificationService.instance
        .requestPermissions();
    if (!mounted) return;
    if (!notificationsAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications are off for Supercharger Bingo'),
        ),
      );
    }
    if (await Geolocator.checkPermission() == LocationPermission.always ||
        !mounted) {
      return;
    }
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow location all the time?'),
        content: const Text(
          'Alerts check for nearby Superchargers while the app is closed. '
          'Choose "Allow all the time" so they follow where you are. '
          'Otherwise they use the last place the app was open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed != true) return;
    final access = await LocationService.instance.requestBackgroundAccess();
    if (mounted) setState(() => _locationAccess = access);
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.getUserSettings();
    setState(() {
      _settings = MutableSettings.from(settings);
      _isLoading = false;
    });
  }

  Future<void> _loadSiteCount() async {
    final sites = await DatabaseService.getSites();
    if (mounted) {
      setState(() => _siteCount = sites.length);
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await DatabaseService.updateUserSettings(_settings!.toCompanion());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // No app bar: the tab already says Settings.
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Account section
                  _buildSectionHeader(theme, 'Account'),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_accountTitle),
                    subtitle: Text(_accountSubtitle),
                    trailing: _showLogout
                        ? TextButton(
                            onPressed: _handleLogout,
                            child: const Text('Log out'),
                          )
                        : null,
                    onTap: _settings?.isAuthenticated != true
                        ? _handleLogin
                        : null,
                  ),
                  const Divider(),

                  _buildSectionHeader(theme, 'Appearance'),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(
                      appearanceLabel(
                        _settings?.appAppearance ?? AppAppearance.system,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showThemePicker,
                  ),
                  const Divider(),

                  // Notifications section
                  _buildSectionHeader(theme, 'Notifications'),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active),
                    title: const Text('New Superchargers'),
                    subtitle: const Text(
                      'A site opening inside the notification radius',
                    ),
                    value: _settings?.notifyNewSites ?? true,
                    onChanged: (value) {
                      setState(() => _settings?.notifyNewSites = value);
                      _saveSettings();
                      if (value) _ensureAlertPermissions();
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.star),
                    title: const Text('First Countdown Started'),
                    subtitle: const Text(
                      'Someone claimed a nearby First. Check in there before local midnight to share it',
                    ),
                    value: _settings?.notifyFirstEligible ?? true,
                    onChanged: (value) {
                      setState(() => _settings?.notifyFirstEligible = value);
                      _saveSettings();
                      if (value) _ensureAlertPermissions();
                    },
                  ),
                  if (_locationAccess != null)
                    ListTile(
                      leading: const Icon(Icons.my_location),
                      title: const Text('Location for alerts'),
                      subtitle: Text(
                        _locationAccess == LocationPermission.always
                            ? 'All the time'
                            : 'Only while the app is open. Tap to allow all the time',
                      ),
                      onTap: _locationAccess == LocationPermission.always
                          ? null
                          : _ensureAlertPermissions,
                    ),
                  ListTile(
                    leading: const Icon(Icons.notification_add_outlined),
                    title: const Text('Send test notification'),
                    onTap: _sendTestNotification,
                  ),
                  const Divider(),

                  // Polling section
                  _buildSectionHeader(theme, 'Background Sync'),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Polling Interval'),
                    subtitle: Text(
                      pollingIntervalLabel(
                        _settings?.pollingInterval ?? PollingInterval.hours24,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showPollingIntervalPicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.radar),
                    title: const Text('Notification Radius'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.imperial
                          ? '${(_settings!.notificationRadiusKm * 0.621371).toStringAsFixed(0)} mi'
                          : '${_settings?.notificationRadiusKm.toStringAsFixed(0)} km',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showRadiusPicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: const Text('Distance Units'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.metric
                          ? 'Metric (km)'
                          : 'Imperial (miles)',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUnitSystemPicker,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Note: iOS may limit background refresh to once per day due to system restrictions.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const Divider(),

                  _buildSectionHeader(theme, 'Check-in'),
                  ListTile(
                    leading: const Icon(Icons.near_me),
                    title: const Text('Check-in Search Radius'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.imperial
                          ? '${(_settings!.checkinRadiusKm * 0.621371).toStringAsFixed(0)} mi'
                          : '${_settings?.checkinRadiusKm.toStringAsFixed(0)} km',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showCheckinRadiusPicker,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.history),
                    title: const Text('Include visited sites'),
                    subtitle: const Text(
                      'Show them in the nearby check-in list, with the last visit date',
                    ),
                    value: _settings?.includeVisitedNearby ?? false,
                    onChanged: (value) {
                      setState(() => _settings?.includeVisitedNearby = value);
                      _saveSettings();
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.directions_car),
                    title: const Text(
                      'Include vehicle details in the private note',
                    ),
                    subtitle: const Text(
                      'Adds year, make, model, and trim when you check in with a vehicle. The VIN is never included.',
                    ),
                    value: _settings?.includeVehicleInPrivateNote ?? false,
                    onChanged: (value) {
                      setState(
                        () => _settings?.includeVehicleInPrivateNote = value,
                      );
                      _saveSettings();
                    },
                  ),
                  const Divider(),

                  // Garage section
                  _buildSectionHeader(theme, 'Garage'),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Vehicles'),
                    subtitle: const Text('Manage your vehicles (local only)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                    ),
                  ),
                  const Divider(),

                  // Advanced section
                  _buildSectionHeader(theme, 'Advanced'),
                  SwitchListTile(
                    secondary: const Icon(Icons.bubble_chart),
                    title: const Text('Cluster map markers'),
                    subtitle: const Text('Group nearby sites when zoomed out'),
                    value: _settings?.clusterMarkers ?? true,
                    onChanged: (value) {
                      setState(() => _settings?.clusterMarkers = value);
                      _saveSettings();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Sync Visit History'),
                    subtitle: _settings?.lastXlsxSyncAt != null
                        ? Text(
                            'Last synced: ${_formatDate(_settings!.lastXlsxSyncAt!)}',
                          )
                        : const Text('Import visits from supercharging.life'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _handleSyncHistory,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever),
                    title: const Text('Clear Local Data'),
                    subtitle: const Text('Remove all cached data'),
                    onTap: _handleClearData,
                  ),
                  const Divider(),

                  // About section
                  _buildSectionHeader(theme, 'About'),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Supercharger Bingo'),
                    subtitle: const Text('Version 1.0.0'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('Open Source Licenses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(context: context),
                  ),
                  const Divider(),

                  // Debug section
                  _buildSectionHeader(theme, 'Debug'),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Force Sync Sites'),
                    subtitle: Text('${_siteCount ?? 0} sites in database'),
                    trailing: _isSyncingSites
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isSyncingSites ? null : _handleForceSyncSites,
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Sync Check-in Counts'),
                    subtitle: const Text(
                      'Update which sites have been visited',
                    ),
                    trailing: _isSyncingSites
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isSyncingSites ? null : _handleSyncCheckinCounts,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_search),
                    title: const Text('Re-sync User Data'),
                    subtitle: Text(
                      _settings?.username != null
                          ? 'Sync visits for ${_settings!.username}'
                          : 'No username set',
                    ),
                    trailing: _isSyncingSites
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: (_isSyncingSites || _settings?.username == null)
                        ? null
                        : _handleResyncUserData,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: const Text('Reset Database'),
                    subtitle: const Text('Clear all data and re-sync'),
                    onTap: _handleResetDatabase,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get _accountTitle {
    final username = _settings?.username;
    if (username != null && username.isNotEmpty) return username;
    if (_settings?.authProvider != null) return 'On this device';
    return 'Not logged in';
  }

  String get _accountSubtitle {
    final provider = _settings?.authProvider;
    final label = provider == null ? null : authProviderLabel(provider);
    if (_settings?.isAuthenticated == true) {
      return label == null ? 'Signed in' : 'Signed in with $label';
    }
    if (label != null) {
      return '$label on this device. Check-ins stay here until they sync.';
    }
    return 'Tap to log in';
  }

  bool get _showLogout =>
      _settings?.isAuthenticated == true || _settings?.authProvider != null;

  void _handleLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(onLoginSuccess: _loadSettings),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out? Your local data will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              _settings?.isAuthenticated = false;
              _settings?.authProvider = null;
              await _saveSettings();
              await ApiService.instance.clearSessionCookie();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Logged out')));
              }
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    final allowed = await NotificationService.instance.requestPermissions();
    if (allowed) await NotificationService.instance.showTestNotification();
    if (!mounted || allowed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications are off for Supercharger Bingo'),
      ),
    );
  }

  void _showPollingIntervalPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Polling Interval'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: PollingInterval.values.map((interval) {
                final label = pollingIntervalLabel(interval);
                final isSelected = _settings?.pollingInterval == interval;
                return ListTile(
                  title: Text(label),
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _settings?.pollingInterval = interval;
                    });
                    _saveSettings();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showRadiusPicker() {
    final range = alertRadiusRange(
      _settings?.unitSystem ?? UnitSystem.imperial,
    );
    _editRadius(
      title: 'Notification Radius',
      currentKm: _settings?.notificationRadiusKm ?? 100,
      minDisplay: range.min,
      maxDisplay: range.max,
      applyKm: (km) => _settings?.notificationRadiusKm = km,
    );
  }

  void _showCheckinRadiusPicker() {
    final range = checkinRadiusRange(
      _settings?.unitSystem ?? UnitSystem.imperial,
    );
    _editRadius(
      title: 'Check-in Search Radius',
      currentKm: _settings?.checkinRadiusKm ?? 5000,
      minDisplay: range.min,
      maxDisplay: range.max,
      applyKm: (km) => _settings?.checkinRadiusKm = km,
    );
  }

  /// The dialog owns the text controller. Disposing it before the route pops
  /// rebuilds the exiting field against a dead controller.
  Future<void> _editRadius({
    required String title,
    required double currentKm,
    required double minDisplay,
    required double maxDisplay,
    required void Function(double km) applyKm,
  }) async {
    final isImperial = _settings?.unitSystem == UnitSystem.imperial;
    final saved = await showDialog<double>(
      context: context,
      builder: (context) => _RangeValueDialog(
        title: title,
        initial: isImperial ? currentKm * 0.621371 : currentKm,
        min: minDisplay,
        max: maxDisplay,
        unit: isImperial ? 'mi' : 'km',
      ),
    );
    if (saved == null || !mounted) return;
    setState(() => applyKm(isImperial ? saved / 0.621371 : saved));
    await _saveSettings();
  }

  void _showThemePicker() {
    final current = _settings?.appAppearance ?? AppAppearance.system;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Theme'),
        content: RadioGroup<AppAppearance>(
          groupValue: current,
          onChanged: (value) {
            if (value == null) return;
            Navigator.pop(dialogContext);
            setState(() => _settings?.appAppearance = value);
            AppearanceScope.of(context).update(value);
            _saveSettings();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final appearance in AppAppearance.values)
                RadioListTile<AppAppearance>(
                  title: Text(appearanceLabel(appearance)),
                  subtitle: switch (appearanceDetail(appearance)) {
                    final detail? => Text(detail),
                    null => null,
                  },
                  value: appearance,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitSystemPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<UnitSystem>(
              title: const Text('Metric (kilometers)'),
              value: UnitSystem.metric,
              groupValue: _settings?.unitSystem,
              onChanged: (value) {
                setState(() {
                  _settings?.unitSystem = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
            RadioListTile<UnitSystem>(
              title: const Text('Imperial (miles)'),
              value: UnitSystem.imperial,
              groupValue: _settings?.unitSystem,
              onChanged: (value) {
                setState(() {
                  _settings?.unitSystem = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSyncHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Visit History'),
        content: const Text(
          'This will download and import your visit history from supercharging.life. '
          'This is normally done automatically on first login.\n\n'
          'Use this option only for troubleshooting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement XLSX import
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing history...')),
              );
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  void _handleClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will remove all cached supercharger data and visit history. '
          'You will need to sync again to restore the data.\n\n'
          'Your account will remain logged in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await DatabaseService.clearAll();
              await _loadSettings();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Local data cleared')),
                );
              }
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForceSyncSites() async {
    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await SyncService.instance.syncSites();
      await _loadSiteCount();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Synced $_siteCount sites')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  Future<void> _handleSyncCheckinCounts() async {
    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await SyncService.instance.syncSuperchargerCheckinCounts();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Synced check-in counts')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  Future<void> _handleResyncUserData() async {
    final username = _settings?.username;
    if (username == null) return;

    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await SyncService.instance.syncUserByUsername(username);
      await _loadSettings();
      if (mounted) {
        if (success) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Synced user data')),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  void _handleResetDatabase() {
    // Remember current username before reset
    final currentUsername = _settings?.username;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: Text(
          'This will delete ALL data including your visit history and settings, '
          'then re-sync supercharger sites.\n\n'
          '${currentUsername != null ? 'Your username ($currentUsername) will be preserved and re-synced.\n\n' : ''}'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              setState(() => _isSyncingSites = true);

              try {
                // Clear everything
                await DatabaseService.clearAll();

                // Re-sync sites first
                await SyncService.instance.syncSites();
                await _loadSiteCount();

                // Sync check-in counts
                await SyncService.instance.syncSuperchargerCheckinCounts();

                // Re-sync user data if we had a username
                if (currentUsername != null && currentUsername.isNotEmpty) {
                  await SyncService.instance.syncUserByUsername(
                    currentUsername,
                  );
                }

                await _loadSettings();

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Database reset. Synced $_siteCount sites.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Reset failed: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isSyncingSites = false);
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Owns its text controller so dispose runs after the route is gone.
class _RangeValueDialog extends StatefulWidget {
  final String title;
  final double initial;
  final double min;
  final double max;
  final String unit;

  const _RangeValueDialog({
    required this.title,
    required this.initial,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  State<_RangeValueDialog> createState() => _RangeValueDialogState();
}

class _RangeValueDialogState extends State<_RangeValueDialog> {
  late final TextEditingController _controller;
  late double _value;

  @override
  void initState() {
    super.initState();
    var initial = widget.initial;
    if (initial < widget.min) initial = widget.min;
    if (initial > widget.max) initial = widget.max;
    _value = initial;
    _controller = TextEditingController(text: _value.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            divisions: 99,
            label: '${_value.toStringAsFixed(0)} ${widget.unit}',
            onChanged: (value) {
              setState(() => _value = value);
              _controller.text = value.toStringAsFixed(0);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Exact value (${widget.unit})',
              border: const OutlineInputBorder(),
            ),
            onChanged: (text) {
              final parsed = double.tryParse(text);
              if (parsed == null ||
                  parsed < widget.min ||
                  parsed > widget.max) {
                return;
              }
              setState(() => _value = parsed);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _value),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
