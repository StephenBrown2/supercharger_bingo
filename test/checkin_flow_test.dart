import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/checkin_dialog.dart';
import 'package:supercharger_bingo/screens/settings_screen.dart';
import 'package:supercharger_bingo/screens/vehicles_screen.dart';
import 'package:supercharger_bingo/services/checkin_outbox.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/theme/app_theme.dart';

import 'support/outbox.dart';
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

  Future<void> openCheckin(
    WidgetTester tester, {
    String? confirmMessage,
  }) async {
    // Offline, so Check In only records and these tests never post.
    installTestOutbox(db, online: false);
    await db.upsertSite(SitesCompanion.insert(siteId: 1, name: 'Test site'));
    final site = (await db.getSiteBySiteId(1))!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCheckinDialog(
                context,
                site: site,
                distanceKm: 16.09344,
                confirmMessage: confirmMessage,
              ),
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
        ),
      );
      await db.updateUserSettings(
        UserSettingsTableCompanion(includeVehicleInPrivateNote: Value(optedIn)),
      );
      await db.upsertVehicle(
        const VehiclesCompanion(id: Value('unused'), label: Value('Zulu')),
      );
      await db.addVisit(
        VisitsCompanion.insert(
          siteId: 2,
          checkinDate: DateTime(2026, 5, 1),
          checkinTime: DateTime(2026, 5, 1),
          vehicleId: const Value('last-used'),
          importedAt: DateTime(2026, 5, 1),
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
      final visit = (await db.getAllVisits()).singleWhere((v) => v.siteId == 1);
      expect(visit.vehicleId, 'last-used');
      expect(visit.checkinPrecision, CheckinPrecision.timestamp);
      expect(visit.notesPublic, 'Public');
      expect(
        visit.notesPrivate,
        optedIn ? 'Private\nVehicle: 2024 Tesla Model Y' : 'Private',
      );
      expect(visit.checkinId, isNull);
      expect((await db.getSiteBySiteId(1))!.visited, isTrue);
      expect(await CheckinOutbox.instance.pending(), contains(visit.id));
    });
  }

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
          checkinId: const Value(9),
          siteId: 1,
          checkinDate: DateTime(2026, 4, 1),
          checkinTime: DateTime(2026, 4, 1, 8),
          importedAt: DateTime(2026, 4, 1),
        ),
      );
      // A Pending Visit counts as the latest check-in too.
      await db.addVisit(
        VisitsCompanion.insert(
          siteId: 1,
          checkinDate: DateTime(2026, 6, 2),
          checkinTime: DateTime(2026, 6, 2),
          importedAt: DateTime(2026, 6, 2),
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

  testWidgets('manual make, model, year, and trim are saved', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VehiclesScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add vehicle'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nickname (required)'),
      'Daily',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Make'), 'Rivian');
    await tester.enterText(find.widgetWithText(TextField, 'Model'), 'R1S');
    await tester.enterText(find.widgetWithText(TextField, 'Year'), '2025');
    await tester.enterText(find.widgetWithText(TextField, 'Trim'), 'Dual');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final vehicle = (await db.getAllVehicles()).single;
    expect(vehicle.make, 'Rivian');
    expect(vehicle.model, 'R1S');
    expect(vehicle.year, '2025');
    expect(vehicle.trim, 'Dual');
    expect(vehicle.hasVin, isFalse);
    expect(find.text('2025 Rivian R1S Dual'), findsOneWidget);
    expect(find.text('Show decoded make/model'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('confirming a Site needs a public note before Check In', (
    tester,
  ) async {
    await openCheckin(
      tester,
      confirmMessage: 'This Site is listed as closed. Say what you found.',
    );
    expect(
      find.text('This Site is listed as closed. Say what you found.'),
      findsOneWidget,
    );
    final checkIn = find.widgetWithText(FilledButton, 'Check In');
    expect(tester.widget<FilledButton>(checkIn).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextField, 'Public note (required)'),
      'Charging despite the closure sign',
    );
    await tester.pump();
    await tester.tap(checkIn);
    await tester.pumpAndSettle();

    final visit = (await db.getAllVisits()).single;
    expect(visit.notesPublic, 'Charging despite the closure sign');
    expect(await CheckinOutbox.instance.pending(), contains(visit.id));
  });

  testWidgets('settings can include visited sites in the nearby list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).includeVisitedNearby, isFalse);
    expect((await db.getUserSettings()).notifyNewSites, isTrue);
    expect((await db.getUserSettings()).notifyFirstEligible, isTrue);

    await tester.tap(find.text('New Superchargers'));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).notifyNewSites, isFalse);

    final tile = find.text('Include visited sites');
    await tester.scrollUntilVisible(tile, 200);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect((await db.getUserSettings()).includeVisitedNearby, isTrue);

    final note = find.text('Include vehicle details in the private note');
    await tester.scrollUntilVisible(note, 200);
    await tester.ensureVisible(note);
    await tester.pumpAndSettle();
    await tester.tap(note);
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).includeVehicleInPrivateNote, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('every settings control saves without crashing', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    final appearance = AppearanceController(AppAppearance.system);
    addTearDown(appearance.dispose);

    await tester.pumpWidget(
      AppearanceScope(
        controller: appearance,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tapTile(String label) async {
      final tile = find.text(label);
      // Start from the top so the steps need not follow page order.
      await tester.drag(find.byType(ListView), const Offset(0, 100000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(tile, 200);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    Future<void> cancelDialog() async {
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    Future<void> saveDialog() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tapTile('Theme');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).appAppearance, AppAppearance.dark);
    expect(appearance.appearance, AppAppearance.dark);
    await tapTile('Theme');
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('System'),
      ),
    );
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).appAppearance, AppAppearance.system);

    await tapTile('New Superchargers');
    expect((await db.getUserSettings()).notifyNewSites, isFalse);
    await tapTile('New Superchargers');
    expect((await db.getUserSettings()).notifyNewSites, isTrue);

    await tapTile('First Countdown Started');
    expect((await db.getUserSettings()).notifyFirstEligible, isFalse);
    await tapTile('First Countdown Started');
    expect((await db.getUserSettings()).notifyFirstEligible, isTrue);

    await tapTile('Background Polling Interval');
    await tester.tap(find.text('15 minutes'));
    await tester.pumpAndSettle();
    expect(
      (await db.getUserSettings()).pollingInterval,
      PollingInterval.minutes15,
    );
    await tapTile('Background Polling Interval');
    await tester.tap(find.text('24 hours'));
    await tester.pumpAndSettle();
    expect(
      (await db.getUserSettings()).pollingInterval,
      PollingInterval.hours24,
    );

    await tapTile('Cluster map markers');
    expect((await db.getUserSettings()).clusterMarkers, isFalse);
    await tapTile('Cluster map markers');
    expect((await db.getUserSettings()).clusterMarkers, isTrue);

    await tapTile('Distance Units');
    await tester.tap(find.text('Metric (kilometers)'));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).unitSystem, UnitSystem.metric);

    await tapTile('Notification Radius');
    await tester.enterText(find.byType(TextField), '42');
    await tester.pump();
    await saveDialog();
    expect((await db.getUserSettings()).notificationRadiusKm, 42);

    await tapTile('Notification Radius');
    await tester.enterText(find.byType(TextField), '5000');
    await tester.pump();
    await saveDialog();
    expect((await db.getUserSettings()).notificationRadiusKm, 42);

    await tapTile('Notification Radius');
    await tester.enterText(find.byType(TextField), '90');
    await tester.pump();
    await cancelDialog();
    expect((await db.getUserSettings()).notificationRadiusKm, 42);

    await tapTile('Notification Radius');
    final beforeDrag = (await db.getUserSettings()).notificationRadiusKm;
    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pump();
    await saveDialog();
    expect(
      (await db.getUserSettings()).notificationRadiusKm,
      isNot(beforeDrag),
    );

    await tapTile('Notification Radius');
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await saveDialog();
    expect((await db.getUserSettings()).notificationRadiusKm, 100);

    await tapTile('Check-in Search Radius');
    await tester.enterText(find.byType(TextField), '250');
    await tester.pump();
    await saveDialog();
    expect((await db.getUserSettings()).checkinRadiusKm, 250);

    await tapTile('Check-in Search Radius');
    await tester.enterText(find.byType(TextField), '400');
    await tester.pump();
    await cancelDialog();
    expect((await db.getUserSettings()).checkinRadiusKm, 250);

    await tapTile('Check-in Search Radius');
    await tester.enterText(find.byType(TextField), '400');
    await tester.pump();
    await saveDialog();
    expect((await db.getUserSettings()).checkinRadiusKm, 400);

    await tapTile('Distance Units');
    await tester.tap(find.text('Imperial (miles)'));
    await tester.pumpAndSettle();
    expect((await db.getUserSettings()).unitSystem, UnitSystem.imperial);

    await tapTile('Notification Radius');
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
    await saveDialog();
    expect(
      (await db.getUserSettings()).notificationRadiusKm,
      closeTo(100 / 0.621371, 0.001),
    );

    await tapTile('Check-in Search Radius');
    await tester.enterText(find.byType(TextField), '200');
    await tester.pump();
    await saveDialog();
    expect(
      (await db.getUserSettings()).checkinRadiusKm,
      closeTo(200 / 0.621371, 0.001),
    );

    await tapTile('Include visited sites');
    expect((await db.getUserSettings()).includeVisitedNearby, isTrue);
    await tapTile('Include visited sites');
    expect((await db.getUserSettings()).includeVisitedNearby, isFalse);

    await tapTile('Include vehicle details in the private note');
    expect((await db.getUserSettings()).includeVehicleInPrivateNote, isTrue);
    await tapTile('Include vehicle details in the private note');
    expect((await db.getUserSettings()).includeVehicleInPrivateNote, isFalse);

    await tapTile('Vehicles');
    expect(find.text('Manage your vehicles (local only)'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapTile('Sync Visit History');
    await cancelDialog();
    await tapTile('Clear Local Data');
    await cancelDialog();
    await tapTile('Reset Database');
    await cancelDialog();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
