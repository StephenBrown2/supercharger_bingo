import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/notification_service.dart';
import 'package:supercharger_bingo/services/timezone_service.dart';

class _UnsupportedNotificationListings
    extends FlutterLocalNotificationsPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });
  setUp(() => db.clearAll());
  tearDownAll(() => db.close());

  test(
    'unsupported notification listings do not fail First window checks',
    () async {
      await db.updateUserSettings(
        const UserSettingsTableCompanion(
          lastLatitude: Value(0),
          lastLongitude: Value(0),
          notifyFirstEligible: Value(true),
        ),
      );
      final previous = FlutterLocalNotificationsPlatform.instance;
      addTearDown(() => FlutterLocalNotificationsPlatform.instance = previous);
      FlutterLocalNotificationsPlatform.instance =
          _UnsupportedNotificationListings();
      await expectLater(
        NotificationService.instance.checkFirstWindowsOnStartup(),
        completes,
      );
    },
  );

  test(
    'startup removes active and scheduled invalid First alerts only',
    () async {
      await TimezoneService.instance.initialize();
      await db.updateUserSettings(
        const UserSettingsTableCompanion(
          lastLatitude: Value(0),
          lastLongitude: Value(0),
          notifyFirstEligible: Value(true),
        ),
      );
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 1,
          name: 'Invalid First',
          status: const Value(SiteStatus.open),
          dateOpened: Value(today),
          hasCheckins: const Value(true),
          timezone: const Value('Etc/UTC'),
        ),
      );
      await db.upsertSiteCheckins([
        SiteCheckinsCompanion.insert(
          checkinId: 1,
          siteId: 1,
          odUserId: 1,
          username: 'early',
          checkinDate: today.subtract(const Duration(days: 1)),
          checkinTime: today.subtract(const Duration(days: 1)),
          isFirstAtSupercharger: const Value(true),
          syncedAt: now,
        ),
      ]);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      AndroidFlutterLocalNotificationsPlugin.registerWith();
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      final cancelled = <int>[];
      final shown = <Object?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'getActiveNotifications':
                return [
                  {'id': 100001, 'channelId': firstEligibleChannelId},
                  {'id': 1, 'channelId': newSuperchargersChannelId},
                ];
              case 'pendingNotificationRequests':
                return [
                  {'id': 100001, 'payload': 'site:1'},
                  {'id': 1, 'payload': 'site:1'},
                ];
              case 'cancel':
                cancelled.add((call.arguments as Map)['id'] as int);
                return null;
              case 'show':
                shown.add(call.arguments);
                return null;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      await NotificationService.instance.checkFirstWindowsOnStartup();
      expect(shown, isEmpty);
      expect(cancelled, contains(100001));
      expect(cancelled, isNot(contains(1)));
      // Pending follow-ups must be inspected even when the active alert is gone.
      cancelled.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getActiveNotifications') return [];
            if (call.method == 'pendingNotificationRequests') {
              return [
                {'id': 100001, 'payload': 'site:1'},
              ];
            }
            if (call.method == 'cancel') {
              cancelled.add((call.arguments as Map)['id'] as int);
            }
            return null;
          });
      await NotificationService.instance.checkFirstWindowsOnStartup();
      expect(cancelled, [100001]);
    },
  );
}
