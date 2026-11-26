import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/base_map_layer.dart';
import 'package:supercharger_bingo/screens/map_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/timezone_service.dart';

import 'support/test_sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  setUpAll(() async {
    registerTestSqlite3();
    await TimezoneService.instance.initialize();
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
  });
  tearDownAll(() => db.close());
  setUp(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (_) async => {
        'latitude': 40.0,
        'longitude': -100.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accuracy': 10.0,
        'altitude': 0.0,
        'heading': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
      },
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator_updates'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => '/tmp/supercharger_bingo_marker_test',
    );
  });

  for (final clustered in [false, true]) {
    testWidgets('marker priority and single site sheet, clustering $clustered', (
      tester,
    ) async {
      await db.clearAll();
      await db.updateUserSettings(
        UserSettingsTableCompanion(clusterMarkers: Value(clustered)),
      );
      for (final id in [1, 2, 3, 4, 5, 6, 7]) {
        await db.upsertSite(
          SitesCompanion.insert(
            siteId: id,
            name: 'Site $id',
            status: Value(switch (id) {
              3 => SiteStatus.construction,
              _ => SiteStatus.open,
            }),
            latitude: const Value(40),
            longitude: const Value(-100),
            hasCheckins: Value(id == 2 || id >= 5),
            visited: Value(id == 7),
            otherEvs: Value(id == 1 || id == 7),
            stallsV3: Value([1, 3, 7].contains(id) ? 4 : 0),
            // The bundled tz data has Etc/UTC but no UTC alias.
            timezone: const Value('Etc/UTC'),
            dateOpened: Value(
              id >= 5
                  ? DateTime.now().toUtc().subtract(
                      Duration(days: id == 6 ? 1 : 0),
                    )
                  : null,
            ),
          ),
        );
      }
      // First colours require dated evidence, not just a community count.
      for (final id in [5, 6, 7]) {
        final now = DateTime.now().toUtc();
        final day = DateTime.utc(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: id == 6 ? 1 : 0));
        await db.upsertSiteCheckins([
          SiteCheckinsCompanion.insert(
            checkinId: id,
            siteId: id,
            odUserId: id,
            username: 'user$id',
            checkinDate: day,
            checkinTime: day,
            isFirstAtSupercharger: const Value(true),
            syncedAt: now,
          ),
        ]);
      }
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));
      // A GPS update stops the Linux IP-location polling timer.
      tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter.baseflow.com/geolocator_updates',
        const StandardMethodCodec().encodeSuccessEnvelope({
          'latitude': 40.0,
          'longitude': -100.0,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'accuracy': 10.0,
          'altitude': 0.0,
          'heading': 0.0,
          'speed': 0.0,
          'speed_accuracy': 0.0,
        }),
        (_) {},
      );
      // Allow the database reads to finish without waiting on map tile requests.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      // Marker priority covers every kind of Site, so show them all.
      final all = find.descendant(
        of: find.byType(FilterChip),
        matching: find.text('All'),
      );
      await tester.ensureVisible(all);
      await tester.tap(all);
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      final legendLabels = [
        'First today',
        'First up for grabs',
        'Open',
        'Construction',
      ];
      for (var i = 1; i < legendLabels.length; i++) {
        expect(
          tester.getTopLeft(find.text(legendLabels[i - 1])).dy,
          lessThan(tester.getTopLeft(find.text(legendLabels[i])).dy),
        );
      }
      final map = tester.widget<BaseMapLayer>(find.byType(BaseMapLayer));
      // Bottom to top: ordinary, Open, up for grabs, First today. The first
      // two cluster when the setting is on; First-eligible sites never do.
      final layers = map.children
          .where((w) => w is MarkerLayer || w is MarkerClusterLayerWidget)
          .toList();
      expect(layers.map((w) => w is MarkerClusterLayerWidget), [
        clustered,
        clustered,
        false,
        false,
      ]);
      List<Marker> markersOf(Widget layer) => layer is MarkerLayer
          ? layer.markers
          : (layer as MarkerClusterLayerWidget).options.markers;
      expect(layers.map((l) => markersOf(l).map((m) => m.key).toList()), [
        [const ValueKey(3), const ValueKey(7)],
        [const ValueKey(2), const ValueKey(6)],
        [const ValueKey(1), const ValueKey(4)],
        [const ValueKey(5)],
      ]);
      final top = layers.last as MarkerLayer;

      // A notification must replace a sheet opened from a map marker.
      (top.markers.single.child as GestureDetector).onTap!();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Site 5'), findsOneWidget);
      final state = tester.state<MapScreenState>(find.byType(MapScreen));
      for (final siteId in [1, 1, 2]) {
        await tester.runAsync(() => state.showSite(siteId));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
        expect(find.text('Site $siteId'), findsOneWidget);
      }
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BottomSheet, skipOffstage: false), findsNothing);
      expect(Navigator.of(state.context).canPop(), isFalse);

      // Opening again after dismissal must not leave stale sheet state.
      await tester.runAsync(() => state.showSite(5));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Site 5'), findsOneWidget);
      expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
      await tester.runAsync(() async {
        await state.showSite(1);
        await state.showSite(2);
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Site 2'), findsOneWidget);
      expect(find.byType(BottomSheet, skipOffstage: false), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      tester.view.physicalSize = const Size(411, 923);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pump();

      Future<void> finishLoad() async {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump();
      }

      Future<void> selectStatus(String label) async {
        final chip = find.descendant(
          of: find.byType(FilterChip),
          matching: find.text(label),
        );
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await finishLoad();
      }

      Set<int> markerIds() {
        final map = tester.widget<BaseMapLayer>(find.byType(BaseMapLayer));
        final markers = [
          for (final layer in map.children)
            if (layer is MarkerLayer)
              ...layer.markers
            else if (layer is MarkerClusterLayerWidget)
              ...layer.options.markers,
        ];
        return markers
            .map((marker) => (marker.key as ValueKey<int>).value)
            .toSet();
      }

      await selectStatus('All');
      await tester.tap(find.text('All types'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Not specified'), findsNothing);
      await tester.tap(find.text('V3').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await finishLoad();
      expect(markerIds(), {1, 3, 7});
      await selectStatus('Visited');
      expect(markerIds(), {7});
      await selectStatus('Tesla EV (Open)');
      expect(markerIds(), {1});
      await selectStatus('Open + Construction');
      expect(markerIds(), {1, 3});
      await selectStatus('Non-Tesla EV (Open)');
      expect(markerIds(), {1});
      await selectStatus('All');
      await tester.tap(find.text('V3').first);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Unknown').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await finishLoad();
      expect(markerIds(), {2, 4, 5, 6});
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }

  testWidgets('deleting a Visit elsewhere updates the open map', (
    tester,
  ) async {
    await db.clearAll();
    for (final id in [1, 2, 3]) {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: id,
          name: 'Site $id',
          status: const Value(SiteStatus.open),
          latitude: const Value(40),
          longitude: const Value(-100),
          timezone: const Value('Etc/UTC'),
        ),
      );
    }
    final day = DateTime.utc(2026, 11, 1);
    await db.addVisit(
      VisitsCompanion.insert(
        siteId: 1,
        checkinId: const Value(9),
        checkinDate: day,
        checkinTime: day,
        importedAt: day,
      ),
    );

    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }

    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await settle();
    expect(find.text('2 sites'), findsOneWidget);

    await tester.runAsync(
      () async => db.deleteVisit((await db.getAllVisits()).single),
    );
    await settle();
    expect(find.text('3 sites'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
