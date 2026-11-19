import 'dart:async';
import 'dart:io' show Platform;

import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import 'database_service.dart';
import 'location_service.dart';

const String nearestSiteChannelId = 'nearest_unvisited';

/// Notification action that opens the site in a navigation app.
const String navigateActionId = 'navigate';
const int _notificationId = 7302;

typedef NearestSite = ({Site site, double km, double bearing});

/// Closest site by straight-line distance, or null when [sites] is empty.
/// ponytail: linear scan, fine for a few thousand sites per GPS fix.
NearestSite? findNearestSite(List<Site> sites, double lat, double lon) {
  NearestSite? best;
  for (final site in sites) {
    final m = Geolocator.distanceBetween(
      lat,
      lon,
      site.latitude,
      site.longitude,
    );
    if (best == null || m / 1000 < best.km) {
      best = (site: site, km: m / 1000, bearing: 0);
    }
  }
  if (best == null) return null;
  final bearing = Geolocator.bearingBetween(
    lat,
    lon,
    best.site.latitude,
    best.site.longitude,
  );
  return (site: best.site, km: best.km, bearing: bearing);
}

/// Eight-point compass direction for a bearing in degrees (-180 to 180).
String compassPoint(double bearing) {
  const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return points[((bearing % 360) / 45).round() % 8];
}

/// Drawable for the bolt-shaped compass needle pointing [direction].
String compassIcon(String direction) =>
    'ic_stat_compass_${direction.toLowerCase()}';

/// Status bar chip text. Android shows about seven characters.
String chipDistance(double km, UnitSystem units) {
  final value = units == UnitSystem.imperial ? km * 0.621371 : km;
  final unit = units == UnitSystem.imperial ? 'mi' : 'km';
  final number = value < 10
      ? value.toStringAsFixed(1)
      : value.round().toString();
  return '$number $unit';
}

/// Starts and stops the Android Live Update showing the nearest unvisited
/// site. The work runs in NearestSiteEngineService, a location foreground
/// service with its own Flutter engine running [nearestSiteMain], so it keeps
/// updating after Back closes the app. Swiping the app away stops it
/// (stopWithTask).
class NearestSiteService {
  static final NearestSiteService instance = NearestSiteService._();
  NearestSiteService._();

  static const _service = MethodChannel('supercharger_bingo/nearest_site');
  final _plugin = FlutterLocalNotificationsPlugin();

  bool get _supported => !kIsWeb && Platform.isAndroid;

  /// Start, restart, or stop to match [settings]. Safe to call after any
  /// settings save. Call from the foreground: Android only lets a location
  /// service start while the app is visible.
  Future<void> sync(UserSettingsTableData settings) =>
      _queue = _queue.then((_) => _sync(settings));
  Future<void> _queue = Future.value();

  Future<void> _sync(UserSettingsTableData settings) async {
    if (!_supported) return;
    if (!settings.nearestSiteLiveUpdate ||
        !await LocationService.instance.checkPermission()) {
      await _service.invokeMethod<void>('stop');
      return;
    }
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            nearestSiteChannelId,
            'Nearest Unvisited Site',
            description: 'Distance to the closest unvisited Supercharger',
            // Low keeps it silent. Live Updates only rule out minimum
            // importance.
            importance: Importance.low,
          ),
        );
    // The service only restarts its engine when this changes, so opening the
    // app again leaves a running update alone.
    await _service.invokeMethod<void>('start', {
      'id': _notificationId,
      'key':
          '${settings.nearestSiteIncludeConstruction}|'
          '${settings.unitSystem.name}',
    });
  }
}

/// Entry point for NearestSiteEngineService's engine. It reads the settings
/// once; a change restarts the engine.
@pragma('vm:entry-point')
Future<void> nearestSiteMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await DatabaseService.initialize();
  final settings = await DatabaseService.db.getUserSettings();
  await _LiveUpdate(settings).start();
}

class _LiveUpdate {
  _LiveUpdate(this._settings);
  final UserSettingsTableData _settings;
  final _plugin = FlutterLocalNotificationsPlugin();
  String? _lastShown;

  Future<void> start() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_bolt'),
      ),
    );
    LocationService.instance.getPositionStream().listen(
      _update,
      onError: (Object e) => debugPrint('NearestSiteService: $e'),
    );
  }

  Future<void> _update(Position position) async {
    // ponytail: re-reads sites on each fix (every 50 m) because this engine's
    // database connection doesn't see the app's writes, such as a check-in.
    // Fine for a few thousand rows.
    final sites = await DatabaseService.db.unvisitedSites(
      includeConstruction: _settings.nearestSiteIncludeConstruction,
    );
    final units = _settings.unitSystem;
    final nearest = findNearestSite(
      sites,
      position.latitude,
      position.longitude,
    );
    if (nearest == null) {
      await _show(
        title: 'No unvisited sites',
        body: 'Every site in the filter is visited',
      );
      return;
    }
    final site = nearest.site;
    final distance = formatDistance(nearest.km, units);
    final construction = site.status == SiteStatus.construction
        ? ' · Under construction'
        : '';
    final direction = compassPoint(nearest.bearing);
    await _show(
      title: site.name,
      body: '$distance $direction$construction',
      chip: chipDistance(nearest.km, units),
      icon: compassIcon(direction),
      siteId: site.siteId,
    );
  }

  /// Replaces the service's placeholder notification, which shares its id.
  Future<void> _show({
    required String title,
    required String body,
    String? chip,
    String icon = 'ic_stat_bolt',
    int? siteId,
  }) async {
    // Only repost when the text changes, which is every 0.1 mi or km. The
    // body holds the direction, so an icon change always reposts too.
    final key = '$title|$body';
    if (key == _lastShown) return;
    _lastShown = key;
    await _plugin.show(
      id: _notificationId,
      title: title,
      body: body,
      payload: siteId == null ? null : 'site:$siteId',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          nearestSiteChannelId,
          'Nearest Unvisited Site',
          icon: icon,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          silent: true,
          showWhen: false,
          category: AndroidNotificationCategory.navigation,
          requestPromotedOngoing: true,
          shortCriticalText: chip,
          actions: [
            if (siteId != null)
              const AndroidNotificationAction(
                navigateActionId,
                'Navigate',
                showsUserInterface: true,
                // The service owns this notification; leave it up.
                cancelNotification: false,
              ),
          ],
        ),
      ),
    );
  }
}
