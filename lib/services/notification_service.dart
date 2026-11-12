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
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

      // First Eligible channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          firstEligibleChannelId,
          'First Eligible',
          description:
              'Notifications when a nearby Supercharger becomes First-eligible',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to the relevant site on the map
    // This requires passing data through the notification payload
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
      final nextCursor = window.nextCursor;
      if (nextCursor != null && nextCursor != settings.lastNotifiedChangeId) {
        await DatabaseService.updateUserSettings(
          UserSettingsTableCompanion(lastNotifiedChangeId: Value(nextCursor)),
        );
      }
      for (final change in plan.toAlert) {
        await _notifyOpening(change, lat, lng, settings.notificationRadiusKm);
      }
    } catch (_) {
      // Leave the cursor where it is so the next poll can try again.
    }

    if (!settings.notifyFirstEligible) return;
    await _notifyFirstWindow(lat, lng, settings.notificationRadiusKm);
  }

  Future<void> _notifyOpening(
    AllChanges change,
    double lat,
    double lng,
    double radiusKm,
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
    await showNewSuperchargerNotification(site, distance);
  }

  Future<void> _notifyFirstWindow(
    double lat,
    double lng,
    double radiusKm,
  ) async {
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
      final day =
          '${localNow.year.toString().padLeft(4, '0')}-'
          '${localNow.month.toString().padLeft(2, '0')}-'
          '${localNow.day.toString().padLeft(2, '0')}';
      final claimed = await DatabaseService.claimNotification(
        siteId: site.siteId,
        channel: firstEligibleChannelId,
        dedupeKey: day,
      );
      if (!claimed) continue;
      await showFirstEligibleNotification(site, distances[site.siteId]!);
    }
  }

  /// Show notification for new supercharger
  Future<void> showNewSuperchargerNotification(
    Site site,
    double distanceKm,
  ) async {
    await _notifications.show(
      id: site.siteId,
      title: 'New Supercharger Nearby!',
      body: '${site.name} just opened ${distanceKm.toStringAsFixed(1)} km away',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          newSuperchargersChannelId,
          'New Superchargers',
          channelDescription:
              'Notifications for new Superchargers opening nearby',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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

  /// Show notification for First-eligible site
  Future<void> showFirstEligibleNotification(
    Site site,
    double distanceKm,
  ) async {
    await _notifications.show(
      id: site.siteId + 100000, // Offset to avoid ID collision
      title: 'First Eligible Nearby!',
      body:
          '${site.name} (${distanceKm.toStringAsFixed(1)} km) is ready for a First!',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          firstEligibleChannelId,
          'First Eligible',
          channelDescription:
              'Notifications when a nearby Supercharger becomes First-eligible',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
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
        await SyncService.instance.syncSites();
        await SyncService.instance.syncCommunityData();
        await SyncService.instance.syncPendingCheckins();
        await NotificationService.instance.deliverBackgroundAlerts();

        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}
