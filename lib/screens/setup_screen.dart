import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/timezone_service.dart';
import '../theme/app_theme.dart';

/// Places that sign road distances in miles.
const _imperialCountries = {'US', 'GB', 'LR', 'MM'};
const _imperialZones = {
  'America/New_York',
  'America/Detroit',
  'America/Chicago',
  'America/Menominee',
  'America/Denver',
  'America/Boise',
  'America/Phoenix',
  'America/Los_Angeles',
  'America/Anchorage',
  'America/Juneau',
  'America/Sitka',
  'America/Metlakatla',
  'America/Yakutat',
  'America/Nome',
  'America/Adak',
  'America/Puerto_Rico',
  'Pacific/Honolulu',
  'Europe/London',
  'Africa/Monrovia',
};
const _imperialZonePrefixes = [
  'America/Indiana/',
  'America/Kentucky/',
  'America/North_Dakota/',
  'US/',
];

UnitSystem unitsForTimezone(String timezone) =>
    _imperialZones.contains(timezone) ||
        _imperialZonePrefixes.any(timezone.startsWith)
    ? UnitSystem.imperial
    : UnitSystem.metric;

UnitSystem? unitsForCountry(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) return null;
  return _imperialCountries.contains(countryCode.toUpperCase())
      ? UnitSystem.imperial
      : UnitSystem.metric;
}

/// First-run setup: location, units, distances, alerts, then theme.
/// Location comes first so it can preselect the units.
class SetupScreen extends StatefulWidget {
  final VoidCallback onDone;

  const SetupScreen({super.key, required this.onDone});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> with WidgetsBindingObserver {
  static const _stepCount = 5;
  int _step = 0;
  bool _loaded = false;
  bool _saving = false;
  bool _unitsGuessed = false;

  LocationPermission? _location;
  UnitSystem _units = UnitSystem.imperial;
  double _notificationRadiusKm = 0;
  double _checkinRadiusKm = 0;
  bool _notifyNewSites = true;
  bool _notifyFirstEligible = true;
  PollingInterval _polling = PollingInterval.hours24;
  bool? _notificationsAllowed;

  bool get _isPhone => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get _imperial => _units == UnitSystem.imperial;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final location = _isPhone || kIsWeb
        ? await LocationService.instance.locationAccess()
        : null;
    if (!mounted) return;
    setState(() {
      _location = location;
      if (kIsWeb) {
        _notificationsAllowed =
            NotificationService.instance.browserNotificationsAllowed;
      }
    });
    if (kIsWeb &&
        (location == LocationPermission.whileInUse ||
            location == LocationPermission.always)) {
      _startSiteSync();
    }
  }

  Future<void> _load() async {
    final settings = await DatabaseService.db.getUserSettings();
    final location = _isPhone || kIsWeb
        ? await LocationService.instance.locationAccess()
        : null;
    if (!mounted) return;
    setState(() {
      _location = location;
      _notificationsAllowed =
          NotificationService.instance.browserNotificationsAllowed;
      _applyUnits(settings.unitSystem);
      _notifyNewSites = settings.notifyNewSites;
      _notifyFirstEligible = settings.notifyFirstEligible;
      _polling = settings.pollingInterval;
      _loaded = true;
    });
    if (kIsWeb &&
        (location == LocationPermission.whileInUse ||
            location == LocationPermission.always)) {
      _startSiteSync();
    }
  }

  Future<void> _startSiteSync() async {
    try {
      await SyncService.instance.syncSites();
    } catch (e) {
      debugPrint('Setup site sync failed: $e');
    }
  }

  /// Foreground first. Android 11+ only grants background as a second ask.
  Future<void> _askLocation() async {
    final location = kIsWeb || _location == LocationPermission.denied
        ? await LocationService.instance.requestForegroundAccess()
        : await LocationService.instance.requestBackgroundAccess();
    if (mounted) setState(() => _location = location);
    if (kIsWeb) _startSiteSync();
  }

  /// Location if allowed, then the phone's region.
  Future<void> _guessUnits() async {
    UnitSystem? guess;
    final allowed =
        _location == LocationPermission.whileInUse ||
        _location == LocationPermission.always;
    if (allowed) {
      final position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        guess = unitsForTimezone(
          TimezoneService.instance.getTimezoneForLocation(
            position.latitude,
            position.longitude,
          ),
        );
      }
    }
    guess ??= unitsForCountry(PlatformDispatcher.instance.locale.countryCode);
    if (guess != null && mounted) _setUnits(guess);
  }

  void _setUnits(UnitSystem units) => setState(() => _applyUnits(units));

  /// New units reset both radiuses to that unit's round defaults.
  void _applyUnits(UnitSystem units) {
    _units = units;
    _notificationRadiusKm = kmFromDisplay(
      alertRadiusRange(units).initial,
      units,
    );
    _checkinRadiusKm = kmFromDisplay(checkinRadiusRange(units).initial, units);
  }

  Future<void> _askNotifications() async {
    final allowed = await NotificationService.instance.requestPermissions();
    if (mounted) setState(() => _notificationsAllowed = allowed);
  }

  Future<void> _next() async {
    setState(() => _saving = true);
    if (_step == 0 && !_unitsGuessed) {
      _unitsGuessed = true;
      await _guessUnits();
    }
    if (_step < _stepCount - 1) {
      if (mounted) {
        setState(() {
          _step++;
          _saving = false;
        });
      }
      return;
    }
    await DatabaseService.db.updateUserSettings(
      UserSettingsTableCompanion(
        unitSystem: Value(_units),
        notificationRadiusKm: Value(_notificationRadiusKm),
        checkinRadiusKm: Value(_checkinRadiusKm),
        notifyNewSites: Value(_notifyNewSites),
        notifyFirstEligible: Value(_notifyFirstEligible),
        pollingInterval: Value(_polling),
        setupCompletedAt: Value(DateTime.now()),
      ),
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: (_step + 1) / _stepCount),
                  ValueListenableBuilder<bool>(
                    valueListenable: SyncService.instance.userImporting,
                    builder: (context, importing, child) => importing
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Importing visits in the background'),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: switch (_step) {
                        0 => _locationStep(theme),
                        1 => _unitsStep(theme),
                        2 => _distanceStep(theme),
                        3 => _alertsStep(theme),
                        _ => _themeStep(theme),
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_step > 0)
                          TextButton(
                            onPressed: () => setState(() => _step--),
                            child: const Text('Back'),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _saving ? null : _next,
                          child: Text(
                            _step == _stepCount - 1 ? 'Done' : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _header(ThemeData theme, String title, String body) => [
    Text(title, style: theme.textTheme.headlineSmall),
    const SizedBox(height: 12),
    Text(body, style: theme.textTheme.bodyLarge),
    const SizedBox(height: 24),
  ];

  List<Widget> _locationStep(ThemeData theme) {
    final status = switch (_location) {
      LocationPermission.always => 'Allowed all the time',
      LocationPermission.whileInUse => 'Allowed while the app is open',
      LocationPermission.deniedForever => 'Blocked. Change it in Settings',
      LocationPermission.unableToDetermine => 'Location not available yet',
      null => 'Not needed on this device',
      _ => 'Not allowed yet',
    };
    final action = switch (_location) {
      LocationPermission.denied => ('Allow location', _askLocation),
      LocationPermission.unableToDetermine => ('Allow location', _askLocation),
      LocationPermission.whileInUse when !kIsWeb => (
        'Allow all the time',
        _askLocation,
      ),
      LocationPermission.deniedForever when kIsWeb => null,
      LocationPermission.deniedForever => (
        'Open settings',
        Geolocator.openAppSettings,
      ),
      _ => null,
    };
    return [
      ..._header(
        theme,
        'Location',
        kIsWeb
            ? 'Allow location while this page is open to find nearby Superchargers. '
                  'If it is blocked, change the location permission in your browser settings.'
            : 'Supercharger Bingo finds the sites near you for check-ins. '
                  'Allow it all the time so alerts follow you while the app is '
                  'closed. On Android, choose "Allow all the time" on the next page.',
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.my_location),
        title: Text(status),
      ),
      if (action != null)
        FilledButton.tonal(
          onPressed: () async {
            await action.$2();
          },
          child: Text(action.$1),
        ),
    ];
  }

  List<Widget> _unitsStep(ThemeData theme) => [
    ..._header(theme, 'Units', 'Used for distances and radiuses.'),
    RadioGroup<UnitSystem>(
      groupValue: _units,
      onChanged: (units) {
        if (units != null) _setUnits(units);
      },
      child: const Column(
        children: [
          RadioListTile(
            value: UnitSystem.imperial,
            title: Text('Imperial (miles)'),
          ),
          RadioListTile(
            value: UnitSystem.metric,
            title: Text('Metric (kilometers)'),
          ),
        ],
      ),
    ),
  ];

  List<Widget> _distanceStep(ThemeData theme) {
    return [
      ..._header(theme, 'Distances', 'You can change these later in Settings.'),
      _radius(
        theme,
        title: 'Alert radius',
        detail: 'Alerts cover sites this close to you.',
        km: _notificationRadiusKm,
        range: alertRadiusRange(_units),
        onChanged: (km) => setState(() => _notificationRadiusKm = km),
      ),
      const SizedBox(height: 24),
      _radius(
        theme,
        title: 'Check-in search radius',
        detail: 'Sites this close show in the check-in list.',
        km: _checkinRadiusKm,
        range: checkinRadiusRange(_units),
        onChanged: (km) => setState(() => _checkinRadiusKm = km),
      ),
    ];
  }

  Widget _radius(
    ThemeData theme, {
    required String title,
    required String detail,
    required double km,
    required RadiusRange range,
    required ValueChanged<double> onChanged,
  }) {
    final shown = displayFromKm(km, _units).clamp(range.min, range.max);
    final unit = _imperial ? 'mi' : 'km';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${shown.toStringAsFixed(0)} $unit',
          style: theme.textTheme.titleMedium,
        ),
        Text(detail, style: theme.textTheme.bodyMedium),
        Slider(
          value: shown,
          min: range.min,
          max: range.max,
          onChanged: (value) => onChanged(kmFromDisplay(value, _units)),
        ),
      ],
    );
  }

  List<Widget> _alertsStep(ThemeData theme) => [
    ..._header(
      theme,
      'Alerts',
      kIsWeb
          ? 'Alerts show only while this page is open.'
          : 'The app checks in the background for sites near you.',
    ),
    if (_isPhone || kIsWeb)
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.notifications),
        title: Text(switch (_notificationsAllowed) {
          true => 'Notifications allowed',
          false when kIsWeb =>
            'Notifications are off. On iPhone, add this page to the Home Screen first',
          false => 'Notifications are off. Change it in Settings',
          null => 'Allow notifications',
        }),
        onTap: _notificationsAllowed == true ? null : _askNotifications,
      ),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('New Superchargers'),
      subtitle: const Text('A site opening inside the alert radius'),
      value: _notifyNewSites,
      onChanged: (value) => setState(() => _notifyNewSites = value),
    ),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('First Countdown Started'),
      subtitle: const Text(
        'Someone claimed a nearby First. Check in there before local midnight to share it',
      ),
      value: _notifyFirstEligible,
      onChanged: (value) => setState(() => _notifyFirstEligible = value),
    ),
    ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Check every'),
      trailing: DropdownButton<PollingInterval>(
        value: _polling,
        onChanged: (value) {
          if (value != null) setState(() => _polling = value);
        },
        items: [
          for (final interval in PollingInterval.values)
            DropdownMenuItem(
              value: interval,
              child: Text(pollingIntervalLabel(interval)),
            ),
        ],
      ),
    ),
  ];

  List<Widget> _themeStep(ThemeData theme) {
    final appearance = AppearanceScope.of(context);
    return [
      ..._header(theme, 'Theme', 'Pick how the app looks.'),
      RadioGroup<AppAppearance>(
        groupValue: appearance.appearance,
        onChanged: (value) {
          if (value != null) appearance.update(value);
        },
        child: Column(
          children: [
            for (final option in AppAppearance.values)
              RadioListTile<AppAppearance>(
                value: option,
                title: Text(appearanceLabel(option)),
                subtitle: switch (appearanceDetail(option)) {
                  final detail? => Text(detail),
                  null => null,
                },
              ),
          ],
        ),
      ),
    ];
  }
}
