import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../database/database.dart';
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
      initSettings,
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

  /// Show notification for new supercharger
  Future<void> showNewSuperchargerNotification(
    Site site,
    double distanceKm,
  ) async {
    await _notifications.show(
      site.siteId,
      'New Supercharger Nearby!',
      '${site.name} just opened ${distanceKm.toStringAsFixed(1)} km away',
      NotificationDetails(
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

  /// Show notification for First-eligible site
  Future<void> showFirstEligibleNotification(
    Site site,
    double distanceKm,
  ) async {
    await _notifications.show(
      site.siteId + 100000, // Offset to avoid ID collision
      'First Eligible Nearby!',
      '${site.name} (${distanceKm.toStringAsFixed(1)} km) is ready for a First!',
      NotificationDetails(
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

        final settings = await DatabaseService.getUserSettings();

        if (!settings.isAuthenticated) return true;

        // Sync sites from supercharge.info
        await SyncService.instance.syncSites();

        // Sync check-in history from supercharging.life
        await SyncService.instance.syncCheckinHistory();

        // Check for new superchargers within radius
        if (settings.lastLatitude != null && settings.lastLongitude != null) {
          final sites = await DatabaseService.getSites(status: SiteStatus.open);

          for (final site in sites) {
            final distance = TimezoneService.instance.calculateDistanceKm(
              settings.lastLatitude!,
              settings.lastLongitude!,
              site.latitude,
              site.longitude,
            );

            if (distance <= settings.notificationRadiusKm) {
              // Check if this is a newly opened site (opened in the last polling interval)
              if (site.dateOpened != null) {
                final intervalMinutes = NotificationService.instance
                    ._pollingIntervalToMinutes(settings.pollingInterval);
                final cutoff = DateTime.now().subtract(
                  Duration(minutes: intervalMinutes * 2),
                );
                if (site.dateOpened!.isAfter(cutoff)) {
                  await NotificationService.instance
                      .showNewSuperchargerNotification(site, distance);
                }
              }

              // Check for First eligibility
              if (!site.visited && site.status == SiteStatus.open) {
                // Get last check-in at this site from history
                final lastCheckin =
                    await DatabaseService.getLastPublicCheckinDate(site.siteId);

                if (TimezoneService.instance.isSiteFirstEligibleToday(
                  site,
                  lastCheckin,
                )) {
                  await NotificationService.instance
                      .showFirstEligibleNotification(site, distance);
                }
              }
            }
          }
        }

        return true;
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}
