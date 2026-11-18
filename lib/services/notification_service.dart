import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../database/database.dart';
import '../models/supercharge_info.dart';
import 'alert_rules.dart';
import 'api_service.dart';
import 'background/background_stub.dart'
    if (dart.library.io) 'background/background_native.dart'
    if (dart.library.html) 'background/background_web.dart'
    as background;
import 'database_service.dart';
import 'location_service.dart';
import 'nearest_site_service.dart' show navigateActionId;
import 'site_navigation.dart';
import 'supercharge_region.dart';
import 'checkin_outbox.dart';
import 'sync_service.dart';
import 'timezone_service.dart';

/// Background work task names
const String backgroundSyncTask = 'com.superchargerbingo.backgroundSync';

/// Notification channel IDs
const String newSuperchargersChannelId = 'new_superchargers';
const String firstEligibleChannelId = 'first_eligible';

/// Notification service for handling local notifications and background work
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Site id from a tapped notification, waiting for the map to show it.
  /// AppShell takes it and sets it back to null.
  final ValueNotifier<int?> openSiteRequest = ValueNotifier(null);

  NotificationService._();

  /// Initialize notification channels and workmanager
  Future<void> initialize() async {
    if (_initialized) return;

    background.setAfterSync(
      () => NotificationService.instance.deliverBackgroundAlerts(),
    );

    // Skip notification initialization on web
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('ic_stat_bolt');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    // A tap that launched the app arrives here, not in the callback.
    final launch = await _notifications.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final response = launch!.notificationResponse;
      if (response != null) _onNotificationTapped(response);
    }

    // Create notification channels (Android only)
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    // Initialize workmanager (only supported on Android and iOS)
    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(backgroundSyncCallback);
    }

    _initialized = true;
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // New Superchargers channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          newSuperchargersChannelId,
          'New Superchargers',
          description: 'Notifications for new Superchargers opening nearby',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // First countdown channel. The id stays first_eligible so existing
      // installs keep the user's channel settings.
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          firstEligibleChannelId,
          'First Countdown',
          description:
              'Someone claimed the First at a nearby site, so the share window is open until local midnight there',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  /// Handle notification tap
  /// Alerts carry `site:<id>` as their payload. The Navigate action sends
  /// that site to a navigation app instead of opening it on the map.
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload ?? '';
    if (!payload.startsWith('site:')) return;
    final siteId = int.tryParse(payload.substring(5));
    if (response.actionId == navigateActionId && siteId != null) {
      DatabaseService.getSiteBySiteId(siteId).then((site) {
        if (site != null) navigateToSite(site);
      });
      return;
    }
    openSiteRequest.value = siteId;
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    }

    return true;
  }

  /// Schedule background sync based on user settings
  Future<void> scheduleBackgroundSync(UserSettingsTableData settings) async {
    // Web and Desktop: Use platform-specific background service
    if (kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      await background.startBackgroundSync(settings.pollingInterval);
      return;
    }

    // Mobile (Android, iOS): Use workmanager
    if (Platform.isAndroid || Platform.isIOS) {
      // Cancel existing tasks
      await Workmanager().cancelByUniqueName(backgroundSyncTask);

      // Get interval in minutes from enum
      final intervalMinutes = _pollingIntervalToMinutes(
        settings.pollingInterval,
      );

      // Schedule periodic task
      await Workmanager().registerPeriodicTask(
        backgroundSyncTask,
        backgroundSyncTask,
        frequency: Duration(minutes: intervalMinutes),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    }
  }

  /// Convert PollingInterval enum to minutes
  int _pollingIntervalToMinutes(PollingInterval interval) {
    switch (interval) {
      case PollingInterval.minutes15:
        return 15;
      case PollingInterval.hour1:
        return 60;
      case PollingInterval.hours4:
        return 240;
      case PollingInterval.hours6:
        return 360;
      case PollingInterval.hours12:
        return 720;
      case PollingInterval.hours24:
        return 1440;
    }
  }

  /// Cancel background sync
  Future<void> cancelBackgroundSync() async {
    // Web and Desktop: Use platform-specific stop
    if (kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      background.stopBackgroundSync();
      return;
    }

    // Mobile: cancel workmanager
    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().cancelByUniqueName(backgroundSyncTask);
    }
  }

  /// New-site and First alerts for the saved location. Does not post check-ins
  /// and does not require a supercharging.life session.
  Future<void> deliverBackgroundAlerts() async {
    if (kIsWeb) return;
    final settings = await DatabaseService.getUserSettings();
    final lat = settings.lastLatitude;
    final lng = settings.lastLongitude;
    if (lat == null || lng == null) return;

    try {
      final window = await SyncService.instance.changesNewerThan(
        userLat: lat,
        userLng: lng,
        cursor: settings.lastNotifiedChangeId,
      );
      final plan = planOpeningAlerts(
        changes: window.changes,
        lastNotifiedChangeId: settings.lastNotifiedChangeId,
        notifyNewSites: settings.notifyNewSites,
      );
      // The first poll returns no rows on purpose. Its cursor is the newest
      // change id from the fetch, not from the empty plan.
      var nextCursor = window.nextCursor;
      if (kDebugMode && settings.lastNotifiedChangeId == null) {
        nextCursor =
            await _debugReplayCursor(lat, lng, settings.notificationRadiusKm) ??
            nextCursor;
      }
      if (nextCursor != null && nextCursor != settings.lastNotifiedChangeId) {
        await DatabaseService.updateUserSettings(
          UserSettingsTableCompanion(lastNotifiedChangeId: Value(nextCursor)),
        );
      }
      for (final change in plan.toAlert) {
        await _notifyOpening(
          change,
          lat,
          lng,
          settings.notificationRadiusKm,
          settings.unitSystem,
        );
      }
    } catch (_) {
      // Leave the cursor where it is so the next poll can try again.
    }

    if (!settings.notifyFirstEligible) return;
    await _notifyFirstWindow(
      lat,
      lng,
      settings.notificationRadiusKm,
      settings.unitSystem,
    );
  }

  /// Debug builds only, for testing on a device: start the cursor just
  /// below the newest opening inside the radius, so the next poll treats it
  /// as new and sends a real notification. Null when none is in the latest
  /// page of changes.
  Future<int?> _debugReplayCursor(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    final page = await ApiService.instance.fetchChangesPage(
      regionId: SuperchargeRegion.forCoordinates(lat, lng),
      start: 0,
    );
    for (final change in page.results) {
      if (!isOpeningChange(change)) continue;
      final distance = TimezoneService.instance.calculateDistanceKm(
        lat,
        lng,
        change.site.gps.latitude,
        change.site.gps.longitude,
      );
      if (distance <= radiusKm) return change.id - 1;
    }
    return null;
  }

  Future<void> _notifyOpening(
    AllChanges change,
    double lat,
    double lng,
    double radiusKm,
    UnitSystem units,
  ) async {
    final distance = TimezoneService.instance.calculateDistanceKm(
      lat,
      lng,
      change.site.gps.latitude,
      change.site.gps.longitude,
    );
    if (distance > radiusKm) return;
    final claimed = await DatabaseService.claimNotification(
      siteId: change.siteId,
      channel: newSuperchargersChannelId,
      dedupeKey: '${change.id}',
    );
    if (!claimed) return;
    var site = await DatabaseService.getSiteBySiteId(change.siteId);
    if (site == null) {
      await DatabaseService.upsertSites([ApiService.companionFor(change.site)]);
      site = await DatabaseService.getSiteBySiteId(change.siteId);
    }
    if (site == null) return;
    await showNewSuperchargerNotification(site, distance, units);
  }

  /// On app start: alert for new First windows, quietly repost open ones
  /// (Android clears notifications on an app update or a reboot, and the
  /// daily dedupe would keep them gone), and remove ones no longer open.
  Future<void> checkFirstWindowsOnStartup() async {
    if (kIsWeb) return;
    final settings = await DatabaseService.getUserSettings();
    final lat = settings.lastLatitude;
    final lng = settings.lastLongitude;
    if (lat == null || lng == null || !settings.notifyFirstEligible) return;
    await _notifyFirstWindow(
      lat,
      lng,
      settings.notificationRadiusKm,
      settings.unitSystem,
      repost: true,
    );
  }

  Future<void> _cancelClosedFirstWindows(Set<int> open) async {
    bool isFirstId(int id, String? payload) {
      if (payload == null || !payload.startsWith('site:')) return false;
      final siteId = int.tryParse(payload.substring(5));
      return siteId != null && id == siteId + 100000;
    }

    // Include scheduled follow-ups so an invalidated First cannot alert later.
    List<PendingNotificationRequest> pending = const [];
    List<ActiveNotification> active = const [];
    try {
      pending = await _notifications.pendingNotificationRequests();
    } on UnimplementedError {
      // Linux does not support listing scheduled notifications.
    }
    try {
      active = await _notifications.getActiveNotifications();
    } on UnimplementedError {
      // Linux does not support listing active notifications.
    }
    for (final n in pending) {
      if (isFirstId(n.id, n.payload) && !open.contains(n.id)) {
        await _notifications.cancel(id: n.id);
      }
    }
    for (final n in active) {
      final id = n.id;
      if (id != null &&
          (n.channelId == firstEligibleChannelId || isFirstId(id, n.payload)) &&
          !open.contains(id)) {
        await _notifications.cancel(id: id);
      }
    }
  }

  /// Alerts for open First windows and returns their notification ids.
  /// With [repost], a window already alerted today is posted again without
  /// sound, which restores it or refreshes its text.
  Future<Set<int>> _notifyFirstWindow(
    double lat,
    double lng,
    double radiusKm,
    UnitSystem units, {
    bool repost = false,
  }) async {
    final open = <int>{};
    final openSites = await DatabaseService.getSites(status: SiteStatus.open);
    final nearby = <Site>[];
    final distances = <int, double>{};
    for (final site in openSites) {
      if (site.visited) continue;
      final distance = TimezoneService.instance.calculateDistanceKm(
        lat,
        lng,
        site.latitude,
        site.longitude,
      );
      if (distance > radiusKm) continue;
      nearby.add(site);
      distances[site.siteId] = distance;
    }
    final firstDates = await DatabaseService.getEarliestCheckinDates(
      nearby.map((site) => site.siteId).toList(),
    );
    for (final site in nearby) {
      final localNow = TimezoneService.instance.getLocalTimeAtSite(site);
      if (!isInFirstWindow(
        earliestCheckin: firstDates[site.siteId],
        siteLocalNow: localNow,
      )) {
        continue;
      }
      open.add(_firstNotificationId(site));
      final day =
          '${localNow.year.toString().padLeft(4, '0')}-'
          '${localNow.month.toString().padLeft(2, '0')}-'
          '${localNow.day.toString().padLeft(2, '0')}';
      final claimed = await DatabaseService.claimNotification(
        siteId: site.siteId,
        channel: firstEligibleChannelId,
        dedupeKey: day,
      );
      final distance = distances[site.siteId]!;
      if (claimed) {
        await showFirstEligibleNotification(site, distance, units);
      } else if (repost) {
        await showFirstEligibleNotification(
          site,
          distance,
          units,
          silent: true,
        );
      }
    }
    await _cancelClosedFirstWindows(open);
    return open;
  }

  /// Show notification for new supercharger
  Future<void> showNewSuperchargerNotification(
    Site site,
    double distanceKm,
    UnitSystem units,
  ) async {
    await _notifications.show(
      id: site.siteId,
      title: 'New Supercharger Nearby!',
      body:
          '${site.name} just opened ${formatDistance(distanceKm, units)} away',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          newSuperchargersChannelId,
          'New Superchargers',
          channelDescription:
              'Notifications for new Superchargers opening nearby',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_bolt',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'site:${site.siteId}',
    );
  }

  /// Settings button: proves the permission and channel work on a device.
  Future<void> showTestNotification() async {
    await _notifications.show(
      id: 0,
      title: 'Supercharger Bingo',
      body: 'Notifications are working',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          newSuperchargersChannelId,
          'New Superchargers',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  /// Offset from the site id so it never collides with a new-site alert.
  int _firstNotificationId(Site site) => site.siteId + 100000;

  /// Someone claimed the First nearby and the share window is open
  Future<void> showFirstEligibleNotification(
    Site site,
    double distanceKm,
    UnitSystem units, {
    bool silent = false,
  }) async {
    final midnight = TimezoneService.instance.getNextMidnightAtSite(site);
    final left = midnight.difference(DateTime.now());
    if (left <= Duration.zero) return;
    // Site on the first line, since collapsed Android shows only that line.
    // Android has a live countdown in the header, so only iOS needs the
    // time left in the text.
    final names = await DatabaseService.getFirstCheckinNames(site.siteId);
    final shareWith = names.isEmpty ? '' : ' with ${joinNames(names)}';
    final body =
        '${site.name}\n'
        '${formatDistance(distanceKm, units)} away\n'
        '${Platform.isAndroid ? 'Check in' : '${formatTimeLeft(left)} left to check in'} '
        'to share the First$shareWith';
    await _notifications.show(
      id: _firstNotificationId(site),
      title: 'First Countdown Started',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          firstEligibleChannelId,
          'First Countdown',
          channelDescription:
              'Someone claimed the First at a nearby site, so the share window is open until local midnight there',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_bolt',
          silent: silent,
          // The standard style shows only two lines when expanded.
          styleInformation: BigTextStyleInformation(body),
          // A live countdown to the site's midnight, since the body text
          // goes stale. The alert removes itself when the window closes.
          when: midnight.millisecondsSinceEpoch,
          usesChronometer: true,
          chronometerCountDown: true,
          timeoutAfter: left.inMilliseconds,
          actions: [
            if (canNavigateToSite)
              const AndroidNotificationAction(
                navigateActionId,
                'Navigate',
                showsUserInterface: true,
                cancelNotification: false,
              ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: !silent,
        ),
      ),
      payload: 'site:${site.siteId}',
    );
  }
}

/// Background sync callback - must be top-level function
@pragma('vm:entry-point')
void backgroundSyncCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == backgroundSyncTask) {
      try {
        // Initialize services
        await DatabaseService.initialize();
        await TimezoneService.instance.initialize();

        // Sync sites from supercharge.info. Alerts do not need a session.
        // The check-in flush still skips the post when the cookie is missing.
        // Without background location, reuse the spot saved while the app
        // was open rather than letting syncSites fall back to IP lookup.
        // With neither, syncSites looks one up itself, IP lookup included.
        final fix = await LocationService.instance.backgroundPosition();
        final saved = await DatabaseService.getUserSettings();
        await SyncService.instance.syncSites(
          latitude: fix?.latitude ?? saved.lastLatitude,
          longitude: fix?.longitude ?? saved.lastLongitude,
        );
        await SyncService.instance.syncCommunityData();
        await CheckinOutbox.instance.sendDue();
        await NotificationService.instance.deliverBackgroundAlerts();

        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}
