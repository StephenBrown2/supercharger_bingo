import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
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

/// Android Live Update showing the nearest unvisited site while the app runs.
/// A location foreground service keeps the position stream alive when the
/// app is in the background. Swiping the app away stops it (stopWithTask).
class NearestSiteService {
  static final NearestSiteService instance = NearestSiteService._();
  NearestSiteService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<List<Site>>? _sitesSub;
  List<Site>? _sites;
  Position? _position;
  UnitSystem _units = UnitSystem.imperial;
  String? _lastShown;

  /// The running filter, or null when stopped.
  bool? _includeConstruction;

  /// Whether the Live Update is showing.
  bool get running => _includeConstruction != null;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Start, restart, or stop to match [settings]. Safe to call after any
  /// settings save. Call from the foreground: Android only lets a location
  /// service start while the app is visible.
  Future<void> sync(UserSettingsTableData settings) =>
      _queue = _queue.then((_) => _sync(settings));
  Future<void> _queue = Future.value();

  Future<void> _sync(UserSettingsTableData settings) async {
    if (!_supported) return;
    _units = settings.unitSystem;
    final want = settings.nearestSiteLiveUpdate
        ? settings.nearestSiteIncludeConstruction
        : null;
    if (want != null && want == _includeConstruction) {
      _update(); // Units may have changed.
      return;
    }
    await stop();
    if (want == null) return;
    if (!await LocationService.instance.checkPermission()) return;
    _includeConstruction = want;

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        nearestSiteChannelId,
        'Nearest Unvisited Site',
        description: 'Distance to the closest unvisited Supercharger',
        // Low keeps it silent. Live Updates only rule out minimum importance.
        importance: Importance.low,
      ),
    );
    await _show(
      title: 'Nearest unvisited site',
      body: 'Finding your location…',
    );

    _sitesSub = DatabaseService.db
        .watchUnvisitedSites(includeConstruction: want)
        .listen((sites) {
          _sites = sites;
          _update();
        });
    _positionSub = LocationService.instance.getPositionStream().listen((
      position,
    ) {
      _position = position;
      _update();
    }, onError: (Object e) => debugPrint('NearestSiteService: $e'));
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    await _sitesSub?.cancel();
    _positionSub = null;
    _sitesSub = null;
    _sites = null;
    _position = null;
    _lastShown = null;
    _includeConstruction = null;
    if (_supported) await _android?.stopForegroundService();
  }

  void _update() {
    final sites = _sites;
    final position = _position;
    if (sites == null || position == null) return;
    final nearest = findNearestSite(
      sites,
      position.latitude,
      position.longitude,
    );
    if (nearest == null) {
      _show(
        title: 'No unvisited sites',
        body: 'Every site in the filter is visited',
      );
      return;
    }
    final site = nearest.site;
    final distance = formatDistance(nearest.km, _units);
    final construction = site.status == SiteStatus.construction
        ? ' · Under construction'
        : '';
    final direction = compassPoint(nearest.bearing);
    _show(
      title: site.name,
      body: '$distance $direction$construction',
      chip: chipDistance(nearest.km, _units),
      icon: compassIcon(direction),
      siteId: site.siteId,
    );
  }

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
    await _android?.startForegroundService(
      id: _notificationId,
      title: title,
      body: body,
      payload: siteId == null ? null : 'site:$siteId',
      // Sticky would restart with no notification data after a process kill.
      startType: AndroidServiceStartType.startNotSticky,
      foregroundServiceTypes: {
        AndroidServiceForegroundType.foregroundServiceTypeLocation,
      },
      notificationDetails: AndroidNotificationDetails(
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
    );
  }
}
