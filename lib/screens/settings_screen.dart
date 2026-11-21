import 'package:drift/drift.dart' hide Column;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/session.dart';
import '../services/checkin_log.dart';
import '../services/checkin_outbox.dart';
import '../services/life_time.dart' show formatCalendarDate;
import '../services/database_service.dart';
import '../services/life_auth.dart';
import '../services/location_service.dart';
import '../services/nearest_site_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'vehicles_screen.dart';

/// Mutable settings wrapper for the UI
class MutableSettings {
  int? userId;
  String? username;
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
  bool nearestSiteLiveUpdate;
  bool nearestSiteIncludeConstruction;
  AuthProvider? authProvider;
  DateTime? lastSitesSyncAt;
  DateTime? lastCheckinHistorySyncAt;
  DateTime? lastXlsxSyncAt;

  MutableSettings({
    this.userId,
    this.username,
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
    this.nearestSiteLiveUpdate = false,
    this.nearestSiteIncludeConstruction = false,
    this.authProvider,
    this.lastSitesSyncAt,
    this.lastCheckinHistorySyncAt,
    this.lastXlsxSyncAt,
  });

  factory MutableSettings.from(UserSettingsTableData data) {
    return MutableSettings(
      userId: data.odUserId,
      username: data.username,
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
      nearestSiteLiveUpdate: data.nearestSiteLiveUpdate,
      nearestSiteIncludeConstruction: data.nearestSiteIncludeConstruction,
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
      nearestSiteLiveUpdate: Value(nearestSiteLiveUpdate),
      nearestSiteIncludeConstruction: Value(nearestSiteIncludeConstruction),
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
  bool _signedIn = false;
  Map<int, PendingVisit> _pending = {};
  late final AppLifecycleListener _sessionLifecycle;

  @override
  void initState() {
    super.initState();
    Session.instance.addListener(_refreshSession);
    _sessionLifecycle = AppLifecycleListener(onResume: _refreshSession);
    _refreshSession();
    CheckinOutbox.instance.changes.addListener(_loadPending);
    _loadPending();
    _loadSettings();
    _loadSiteCount();
    _loadLocationAccess();
  }

  @override
  void dispose() {
    _sessionLifecycle.dispose();
    Session.instance.removeListener(_refreshSession);
    CheckinOutbox.instance.changes.removeListener(_loadPending);
    super.dispose();
  }

  Future<void> _loadPending() async {
    final pending = await CheckinOutbox.instance.pending();
    if (mounted) setState(() => _pending = pending);
  }

  /// Discard every Pending Visit. One being sent is discarded if its send
  /// fails; one supercharging.life accepts first stays, and is named.
  Future<void> _handleDiscardPending() async {
    final pending = await CheckinOutbox.instance.pending();
    if (pending.isEmpty || !mounted) return;
    final maybeSent = pending.values.where((p) => p.maybeSent).length;
    final count = pending.length == 1
        ? '1 check-in'
        : '${pending.length} check-ins';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Pending check-ins?'),
        content: Text(
          'This removes $count that supercharging.life has not confirmed '
          'from the app only.'
          '${maybeSent == 0 ? '' : '\n\n$maybeSent of these may already be on supercharging.life. Check there after discarding.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    void say(String text) =>
        messenger.showSnackBar(SnackBar(content: Text(text)));

    final outbox = CheckinOutbox.instance;
    bool isSending(int id) => pending[id]!.state == OutboxState.sending;
    final now = await Future.wait(
      pending.keys.where((id) => !isSending(id)).map(outbox.discard),
    );
    final later = pending.keys.where(isSending).toList();
    final discarded = now.where((r) => r == Discard.discarded).length;
    say(
      'Discarded $discarded.'
      '${later.isEmpty ? '' : ' ${later.length} being sent: discarded if the send fails.'}',
    );
    if (later.isEmpty) return;

    final results = await Future.wait(later.map(outbox.discard));
    final kept = [
      for (var i = 0; i < later.length; i++)
        if (results[i] == Discard.confirmed) later[i],
    ];
    final busy = results.where((r) => r == Discard.busy).length;
    final db = DatabaseService.db;
    final names = <String>[];
    for (final visit in await db.getAllVisits()) {
      if (!kept.contains(visit.id)) continue;
      final site = await db.getSiteBySiteId(visit.siteId);
      names.add(
        '${site?.name ?? 'Site ${visit.siteId}'} '
        '(${formatCalendarDate(visit.checkinDate.toLocal())})',
      );
    }
    if (names.isNotEmpty) {
      say(
        'Kept ${names.join(', ')}: supercharging.life accepted '
        '${names.length == 1 ? 'it' : 'them'} first. Delete from Visits if '
        'you meant to.',
      );
    }
    if (busy > 0) say('$busy still being sent were kept. Try again shortly.');
  }

  Future<void> _refreshSession() async {
    final signedIn = await Session.instance.isSignedIn();
    if (mounted && _signedIn != signedIn) {
      setState(() => _signedIn = signedIn);
    }
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

  /// The live notification needs notifications and location while in use.
  Future<void> _setNearestSiteLiveUpdate(bool value) async {
    if (value) {
      final notifications = await NotificationService.instance
          .requestPermissions();
      final location = await LocationService.instance.checkPermission();
      if (!mounted) return;
      if (!notifications || !location) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Allow notifications and location to show the nearest site',
            ),
          ),
        );
        return;
      }
    }
    setState(() => _settings?.nearestSiteLiveUpdate = value);
    await _saveSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.db.getUserSettings();
    setState(() {
      _settings = MutableSettings.from(settings);
      _isLoading = false;
    });
  }

  Future<void> _loadSiteCount() async {
    final sites = await DatabaseService.db.getSites();
    if (mounted) {
      setState(() => _siteCount = sites.length);
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await DatabaseService.db.updateUserSettings(_settings!.toCompanion());
      await NearestSiteService.instance.sync(
        await DatabaseService.db.getUserSettings(),
      );
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
                    onTap: !kIsWeb && !_signedIn ? _handleLogin : null,
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
                  ListTile(
                    leading: const Icon(Icons.straighten),
                    title: const Text('Distance Units'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.metric
                          ? 'Metric (km) for all distances'
                          : 'Imperial (miles) for all distances',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUnitSystemPicker,
                  ),
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
                  const Divider(),

                  // Notifications section
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionHeader(theme, 'Notifications'),
                      ),
                      IconButton(
                        tooltip: 'Notification grouping help',
                        icon: const Icon(Icons.info_outline),
                        onPressed: _showNotificationGroupingHelp,
                      ),
                    ],
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active),
                    title: const Text('New Superchargers'),
                    subtitle: const Text('Alert when a site opens nearby'),
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
                      'Alert when a nearby First is claimed',
                    ),
                    value: _settings?.notifyFirstEligible ?? true,
                    onChanged: (value) {
                      setState(() => _settings?.notifyFirstEligible = value);
                      _saveSettings();
                      if (value) _ensureAlertPermissions();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.radar),
                    title: const Text('Notification Radius'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.imperial
                          ? 'Alerts within ${displayFromKm(_settings!.notificationRadiusKm, UnitSystem.imperial).toStringAsFixed(0)} mi'
                          : 'Alerts within ${_settings?.notificationRadiusKm.toStringAsFixed(0)} km',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showRadiusPicker,
                  ),
                  if (_locationAccess != null)
                    ListTile(
                      leading: const Icon(Icons.my_location),
                      title: const Text('Location for alerts'),
                      subtitle: Text(
                        _locationAccess == LocationPermission.always
                            ? 'All the time, even with the app closed'
                            : 'Only while the app is open. Tap to change',
                      ),
                      onTap: _locationAccess == LocationPermission.always
                          ? null
                          : _ensureAlertPermissions,
                    ),
                  if (!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.android) ...[
                    SwitchListTile(
                      secondary: const Icon(Icons.near_me),
                      title: const Text('Nearest Unvisited Site'),
                      subtitle: const Text('Live distance while the app runs'),
                      value: _settings?.nearestSiteLiveUpdate ?? false,
                      onChanged: _setNearestSiteLiveUpdate,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.construction),
                      title: const Text('Include Sites Under Construction'),
                      subtitle: const Text('Count sites that are not open yet'),
                      value: _settings?.nearestSiteIncludeConstruction ?? false,
                      onChanged: _settings?.nearestSiteLiveUpdate == true
                          ? (value) {
                              setState(
                                () =>
                                    _settings?.nearestSiteIncludeConstruction =
                                        value,
                              );
                              _saveSettings();
                            }
                          : null,
                    ),
                  ],
                  const Divider(),

                  _buildSectionHeader(theme, 'Check-in'),
                  ListTile(
                    leading: const Icon(Icons.near_me),
                    title: const Text('Check-in Search Radius'),
                    subtitle: Text(
                      _settings?.unitSystem == UnitSystem.imperial
                          ? 'Sites within ${displayFromKm(_settings!.checkinRadiusKm, UnitSystem.imperial).toStringAsFixed(0)} mi'
                          : 'Sites within ${_settings?.checkinRadiusKm.toStringAsFixed(0)} km',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showCheckinRadiusPicker,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.history),
                    title: const Text('Include visited sites'),
                    subtitle: const Text(
                      'Show them with their last visit date',
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
                    subtitle: const Text('Year, make, model, and trim. No VIN'),
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
                    subtitle: const Text('Cars for check-ins, stored locally'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                    ),
                  ),
                  const Divider(),

                  // Advanced section
                  _buildSectionHeader(theme, 'Advanced'),
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Background Polling Interval'),
                    subtitle: Text(
                      'Check for alerts every ${pollingIntervalLabel(_settings?.pollingInterval ?? PollingInterval.hours24)}${defaultTargetPlatform == TargetPlatform.iOS ? '. iOS may limit this to daily' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showPollingIntervalPicker,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(
                      'Discard Pending check-ins (${_pending.length})',
                    ),
                    subtitle: const Text(
                      'Remove check-ins supercharging.life has not confirmed',
                    ),
                    enabled: _pending.isNotEmpty,
                    onTap: _pending.isEmpty ? null : _handleDiscardPending,
                  ),
                  const Divider(),

                  // Debug section
                  _buildSectionHeader(theme, 'Debug'),
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Copy check-in log'),
                    subtitle: const Text(
                      'Every check-in step, kept on this device',
                    ),
                    onTap: _copyCheckinLog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_remove),
                    title: const Text('Clear check-in log'),
                    subtitle: const Text(
                      'Start a fresh log before a test drive',
                    ),
                    onTap: _clearCheckinLog,
                  ),
                  ListTile(
                    leading: const Icon(Icons.notification_add_outlined),
                    title: const Text('Send test notification'),
                    subtitle: const Text('Check that alerts reach this device'),
                    onTap: _sendTestNotification,
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Force Sync Sites'),
                    subtitle: Text(
                      'Download sites again. ${_siteCount ?? 0} stored',
                    ),
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
                    subtitle: const Text('Refresh which sites anyone visited'),
                    trailing: _isSyncingSites
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    enabled: !kIsWeb,
                    onTap: kIsWeb || _isSyncingSites
                        ? null
                        : _handleSyncCheckinCounts,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_search),
                    title: const Text('Re-sync User Data'),
                    subtitle: Text(
                      _settings?.username != null
                          ? 'Download your visits again'
                          : 'Import visits by supercharging.life username',
                    ),
                    trailing: _isSyncingSites
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isSyncingSites ? null : _handleResyncUserData,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep),
                    title: const Text('Reset Database'),
                    subtitle: const Text(
                      'Delete everything, then download sites',
                    ),
                    onTap: _handleResetDatabase,
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
                    subtitle: const Text('Credits for open source code'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(context: context),
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

  String get _accountTitle {
    final username = _settings?.username;
    if (username != null && username.isNotEmpty) return username;
    if (kIsWeb) return 'Local browser storage';
    if (_settings?.authProvider != null) return 'On this device';
    return 'Not logged in';
  }

  String get _accountSubtitle {
    if (kIsWeb) {
      return 'In this browser. Check-ins stay pending until sign-in works';
    }
    final provider = _settings?.authProvider;
    final label = provider == null ? null : authProviderLabel(provider);
    if (_signedIn) {
      return label == null ? 'Signed in' : 'Signed in with $label';
    }
    if (label != null) {
      return 'Device-only. Check-ins wait here to sync';
    }
    return 'Tap to log in';
  }

  bool get _showLogout =>
      !kIsWeb && (_signedIn || _settings?.authProvider != null);

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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out? Your local data will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await Session.instance.signOut();
                _settings?.authProvider = null;
                await _saveSettings();
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not log out')),
                  );
                }
                return;
              }
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

  void _showNotificationGroupingHelp() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notification grouping on Pixel'),
        content: const SingleChildScrollView(
          child: Text(
            'On Pixel phones, Notification Organizer may group First Countdown '
            'alerts under "Suggested" and silence them.\n\n'
            'To exclude Supercharger Bingo, open your phone\'s Settings:\n\n'
            'Notifications > Notification organizer > Don\'t include these apps '
            '> Manage Apps > Uncheck Supercharger Bingo\n\n'
            'You can also long-press a countdown notification and turn off '
            'Notification Organizer for this app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Copies the field log of check-ins (see CheckinLog) to paste elsewhere.
  Future<void> _copyCheckinLog() async {
    final log = await CheckinLog.read();
    if (!mounted) return;
    final lines = log.trim().isEmpty ? 0 : log.trim().split('\n').length;
    if (lines > 0) await Clipboard.setData(ClipboardData(text: log));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lines == 0
              ? 'The check-in log is empty'
              : 'Copied $lines check-in log lines',
        ),
      ),
    );
  }

  Future<void> _clearCheckinLog() async {
    await CheckinLog.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Check-in log cleared')));
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
        title: const Text('Background Polling Interval'),
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
    final units = _settings?.unitSystem ?? UnitSystem.metric;
    final saved = await showDialog<double>(
      context: context,
      builder: (context) => _RangeValueDialog(
        title: title,
        initial: displayFromKm(currentKm, units),
        min: minDisplay,
        max: maxDisplay,
        unit: units == UnitSystem.imperial ? 'mi' : 'km',
      ),
    );
    if (saved == null || !mounted) return;
    setState(() => applyKm(kmFromDisplay(saved, units)));
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Distance Units'),
        content: RadioGroup<UnitSystem>(
          groupValue: _settings?.unitSystem,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings?.unitSystem = value);
            Navigator.pop(dialogContext);
            _saveSettings();
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<UnitSystem>(
                title: Text('Metric (kilometers)'),
                value: UnitSystem.metric,
              ),
              RadioListTile<UnitSystem>(
                title: Text('Imperial (miles)'),
                value: UnitSystem.imperial,
              ),
            ],
          ),
        ),
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
    final username = _settings?.username ?? await _askUsername();
    if (username == null || !mounted) return;

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

  Future<String?> _askUsername() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import visits'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'supercharging.life username',
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    ).then((value) => value == null || value.isEmpty ? null : value);
  }

  void _handleResetDatabase() {
    // Remember current username before reset
    final currentUsername = _settings?.username;
    final kept = _pending.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: Text(
          'This will delete ALL data including your visit history and settings, '
          'then re-sync supercharger sites.\n\n'
          '${kept == 0 ? '' : '${kept == 1 ? '1 Pending check-in is' : '$kept Pending check-ins are'} kept, since supercharging.life does not have ${kept == 1 ? 'it' : 'them'} yet.\n\n'}'
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
                // Clear everything supercharge.info or supercharging.life
                // can send again.
                await DatabaseService.db.resetKeepingPending();

                // Re-sync sites first
                await SyncService.instance.syncSites();
                await _loadSiteCount();

                // Sync check-in counts
                if (!kIsWeb) {
                  await SyncService.instance.syncSuperchargerCheckinCounts();
                }

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
