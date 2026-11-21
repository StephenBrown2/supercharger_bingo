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
import 'notification_service.dart';

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
    final km = distanceKm(lat, lon, site.latitude, site.longitude);
    if (best == null || km < best.km) {
      best = (site: site, km: km, bearing: 0);
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

/// Under this distance (0.1 mi) the Live Update offers Check In.
const double checkInFromNotificationKm = 0.1 * 1.609344;

/// Eight-point compass direction for a bearing in degrees (-180 to 180).
String compassPoint(double bearing) {
  const points = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return points[((bearing % 360) / 45).round() % 8];
}

/// Where a site lies from the user, such as "Northwest of here", for a
/// [compassPoint]. Stands in for a missing street.
String directionPhrase(String point) =>
    '${const {'N': 'North', 'NE': 'Northeast', 'E': 'East', 'SE': 'Southeast', 'S': 'South', 'SW': 'Southwest', 'W': 'West', 'NW': 'Northwest'}[point]} of here';

/// Status bar chip text. Android shows about seven characters.
String chipDistance(double km, UnitSystem units) {
  final value = displayFromKm(km, units);
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

  /// Route Live Update taps to the map. Call once at startup.
  Future<void> listenForTaps() async {
    if (!_supported) return;
    void open(Object? request) {
      if (request is! Map) return;
      NotificationService.instance.openSiteRequest.value = (
        siteId: request['siteId'] as int,
        checkIn: request['checkIn'] == true,
      );
    }

    _service.setMethodCallHandler((call) async {
      if (call.method == 'openSite') open(call.arguments);
    });
    open(await _service.invokeMethod<Object?>('takeLaunchSite'));
  }

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
  static const _native = MethodChannel('supercharger_bingo/live_update');
  String? _lastShown;

  Future<void> start() async {
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
      await _show({
        'title': 'No unvisited sites',
        'body': 'Every site in the filter is visited',
      });
      return;
    }
    final site = nearest.site;
    final distance = chipDistance(nearest.km, units);
    final direction = compassPoint(nearest.bearing);
    final construction = site.status == SiteStatus.construction
        ? ' · Under construction'
        : '';
    await _show({
      'title': site.name,
      'body': '${formatDistance(nearest.km, units)} $direction$construction',
      'chip': distance,
      // Android 17 shows the distance large on the right, with this line
      // under the name, such as "1.2 mi NE".
      'metric': '$distance $direction',
      'metricLabel':
          '${_street(site) ?? directionPhrase(direction)}$construction',
      'siteId': site.siteId,
      'checkIn': nearest.km < checkInFromNotificationKm,
      'latitude': site.latitude,
      'longitude': site.longitude,
    });
  }

  static String? _street(Site site) {
    final street = site.street?.trim();
    return street == null || street.isEmpty ? null : street;
  }

  Future<void> _show(Map<String, Object?> update) async {
    // Only repost when the text changes, which is every 0.1 mi or km. The
    // body holds the direction too.
    final key = '${update['title']}|${update['body']}|${update['checkIn']}';
    if (key == _lastShown) return;
    _lastShown = key;
    await _native.invokeMethod<void>('show', update);
  }
}
