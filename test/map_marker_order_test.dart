import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supercharger_bingo/database/database.dart';
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
    testWidgets('markers and legend follow priority, clustering $clustered', (
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
              4 => SiteStatus.expanding,
              _ => SiteStatus.open,
            }),
            latitude: const Value(40),
            longitude: const Value(-100),
            hasCheckins: Value(id == 2 || id >= 5),
            visited: Value(id == 7),
            timezone: const Value('UTC'),
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
      DatabaseService.bootstrapSites = await db.getAllSites();
      DatabaseService.bootstrapUserSettings = null;
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
      final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
      expect(map.children.last, isA<MarkerLayer>());
      final top = map.children.last as MarkerLayer;
      expect(top.markers.map((marker) => marker.key), [const ValueKey(5)]);
      final layers = map.children.whereType<MarkerLayer>().toList();
      expect(layers[layers.length - 2].markers.map((marker) => marker.key), [
        const ValueKey(1),
        const ValueKey(4),
      ]);
      expect(layers[layers.length - 3].markers.map((marker) => marker.key), [
        const ValueKey(2),
        const ValueKey(6),
      ]);
      final ordinary = clustered
          ? tester
                .widget<MarkerClusterLayerWidget>(
                  find.byType(MarkerClusterLayerWidget),
                )
                .options
                .markers
          : (map.children.whereType<MarkerLayer>().first).markers;
      expect(ordinary.map((marker) => marker.key), [
        const ValueKey(3),
        const ValueKey(7),
      ]);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
