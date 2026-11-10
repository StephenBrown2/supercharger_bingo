import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/checkin_dialog.dart';
import 'package:supercharger_bingo/screens/settings_screen.dart';
import 'package:supercharger_bingo/screens/vehicles_screen.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/sync_service.dart';

import 'support/test_sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUpAll(() async {
    registerTestSqlite3();
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
  });
  setUp(() async {
    DatabaseService.bootstrapUserSettings = null;
    DatabaseService.bootstrapSites = null;
    await db.clearAll();
  });
  tearDownAll(() => db.close());

  Future<void> openCheckin(WidgetTester tester) async {
    await db.upsertSite(SitesCompanion.insert(siteId: 1, name: 'Test site'));
    final site = (await db.getSiteBySiteId(1))!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showCheckinDialog(context, site: site, distanceKm: 16.09344),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('typing a nickname enables vehicle Save', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VehiclesScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add vehicle'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nickname (required)'),
      'Daily',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((await db.getAllVehicles()).single.label, 'Daily');
    await tester.pumpWidget(const SizedBox());
  });

  for (final units in UnitSystem.values) {
    testWidgets('check-in distance respects ${units.name} units', (
      tester,
    ) async {
      await db.updateUserSettings(
        UserSettingsTableCompanion(unitSystem: Value(units)),
      );
      await openCheckin(tester);
      expect(
        find.text(
          units == UnitSystem.imperial ? '10.0 mi away' : '16.1 km away',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  }

  for (final optedIn in [false, true]) {
    testWidgets('last-used vehicle and private note respect opt-in=$optedIn', (
      tester,
    ) async {
      await db.upsertVehicle(
        VehiclesCompanion(
          id: const Value('last-used'),
          label: const Value('Alpha'),
          make: const Value('Tesla'),
          model: const Value('Model Y'),
          year: const Value('2024'),
          displayOptIn: Value(optedIn),
        ),
      );
      await db.upsertVehicle(
        const VehiclesCompanion(id: Value('unused'), label: Value('Zulu')),
      );
      await db.addPendingCheckin(
        PendingCheckinsCompanion(
          siteId: const Value(2),
          checkinDate: Value(DateTime(2026, 5, 1)),
          createdAt: Value(DateTime(2026, 5, 1)),
          vehicleId: const Value('last-used'),
          status: const Value(PendingStatus.completed),
        ),
      );
      await openCheckin(tester);
      final dropdown = tester.widget<DropdownButtonFormField<String?>>(
        find.byType(DropdownButtonFormField<String?>),
      );
      expect(dropdown.initialValue, 'last-used');
      await tester.enterText(
        find.widgetWithText(TextField, 'Public note (optional)'),
        'Public',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Private note (optional)'),
        'Private',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Check In'));
      await tester.pumpAndSettle();
      final pending = (await db.getPendingCheckins()).single;
      expect(pending.vehicleId, 'last-used');
      expect(pending.notesPublic, 'Public');
      expect(
        pending.notesPrivate,
        optedIn ? 'Private\nVehicle: 2024 Tesla Model Y' : 'Private',
      );
      expect((await db.getSiteBySiteId(1))!.visited, isTrue);
    });
  }

  test(
    'queued private notes reach the submitted form without sending vehicle ids',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              requests.add(request);
              handler.resolve(
                Response(requestOptions: request, statusCode: 200),
              );
            },
          ),
        );
      const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (_) async => ['wifi']);
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await db.addPendingCheckin(
        PendingCheckinsCompanion(
          siteId: const Value(1),
          checkinDate: Value(DateTime(2026, 5, 1)),
          createdAt: Value(DateTime.now()),
          notesPublic: const Value('Public'),
          notesPrivate: const Value('Private\nVehicle: 2024 Tesla Model Y'),
          vehicleId: const Value('local-id'),
        ),
      );
      await SyncService(apiService: ApiService(dio: dio)).syncPendingCheckins();
      expect(requests, hasLength(1));
      final data = requests.single.data;
      final form = data is FormData
          ? Map.fromEntries(data.fields)
          : data as Map;
      expect(form['notes_public'], 'Public');
      expect(form['notes_private'], 'Private\nVehicle: 2024 Tesla Model Y');
      expect(form.containsKey('vehicle_id'), isFalse);
      expect(await db.getPendingCheckins(), isEmpty);
    },
  );

  test(
    'nearby list includes a visited site and its last visit when asked',
    () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 1,
          name: 'Already been',
          status: const Value(SiteStatus.open),
          latitude: const Value(40.0),
          longitude: const Value(-105.0),
          visited: const Value(true),
        ),
      );
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 2,
          name: 'First time',
          status: const Value(SiteStatus.open),
          latitude: const Value(40.01),
          longitude: const Value(-105.0),
        ),
      );
      await db.addVisit(
        VisitsCompanion.insert(
          checkinId: 9,
          siteId: 1,
          checkinDate: DateTime(2026, 4, 1),
          checkinTime: DateTime(2026, 4, 1, 8),
          importedAt: DateTime(2026, 4, 1),
        ),
      );
      await db.addPendingCheckin(
        PendingCheckinsCompanion(
          siteId: const Value(1),
          checkinDate: Value(DateTime(2026, 6, 2)),
          createdAt: Value(DateTime(2026, 6, 2)),
        ),
      );

      final hidden = await DatabaseService.getNearbySites(
        latitude: 40,
        longitude: -105,
        radiusKm: 50,
        status: SiteStatus.open,
        visited: false,
      );
      expect(hidden.map((s) => s.site.siteId), [2]);

      final shown = await DatabaseService.getNearbySites(
        latitude: 40,
        longitude: -105,
        radiusKm: 50,
        status: SiteStatus.open,
      );
      expect(shown.map((s) => s.site.siteId), containsAll([1, 2]));
      expect(await db.getLastVisitDate(1), DateTime(2026, 6, 2));
    },
  );

  testWidgets('settings can include visited sites in the nearby list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).includeVisitedNearby, isFalse);

    final tile = find.text('Include visited sites');
    await tester.scrollUntilVisible(tile, 200);
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect((await db.getUserSettings()).includeVisitedNearby, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
