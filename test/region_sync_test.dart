import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/sync_service.dart';

import 'support/test_sqlite3.dart';

Map<String, dynamic> _siteJson(String name) {
  return {
    'id': 50,
    'locationId': 'denver',
    'name': name,
    'status': 'OPEN',
    'address': {
      'street': '1 Main',
      'city': 'Denver',
      'state': 'CO',
      'zip': '80202',
      'countryId': 1,
      'country': 'USA',
      'regionId': 100,
      'region': 'North America',
    },
    'gps': {'latitude': 39.7392, 'longitude': -104.9903},
    'dateOpened': '2024-01-15',
    'stallCount': 8,
    'counted': true,
    'elevationMeters': 1600,
    'powerKilowatt': 250,
    'solarCanopy': false,
    'battery': false,
    'otherEVs': false,
    'statusDays': 1,
    'urlDiscuss': false,
    'stalls': null,
    'plugs': null,
  };
}

Map<String, dynamic> _changeJson(int id, String name) {
  return {
    'id': id,
    'siteId': 50,
    'date': '2024-01-15',
    'changeType': 'UPDATE',
    'siteStatus': 'OPEN',
    'prevStatus': null,
    'stallCount': 8,
    'prevCount': 8,
    'powerKilowatt': 250,
    'notify': false,
    'siteName': name,
    'regionId': 100,
    'region': 'North America',
    'countryId': 1,
    'country': 'USA',
    'state': 'CO',
    'site': _siteJson(name),
    'dateFormatted': 'Jan 15, 2024',
  };
}

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

  test(
    'region sync pages sites once, then applies only newer changes',
    () async {
      final requests = <RequestOptions>[];
      var changePage = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              final path = options.uri.path;
              final length = int.tryParse(
                '${options.queryParameters['length']}',
              );
              final Map<String, dynamic> body;
              if (path.endsWith('/sites')) {
                body = {
                  'recordCount': 1,
                  'results': [_siteJson('Base')],
                };
              } else if (length == 1) {
                body = {
                  'recordCount': 3,
                  'results': [_changeJson(10, 'Base')],
                };
              } else if (changePage == 0) {
                changePage = 1;
                body = {
                  'recordCount': 3,
                  'results': [
                    _changeJson(11, 'Newer'),
                    _changeJson(10, 'Base'),
                  ],
                };
              } else {
                body = {
                  'recordCount': 4,
                  'results': [
                    _changeJson(12, 'Newest'),
                    _changeJson(11, 'Newer'),
                  ],
                };
              }
              handler.resolve(
                Response(requestOptions: options, statusCode: 200, data: body),
              );
            },
          ),
        );

      final sync = SyncService(
        apiService: ApiService(dio: dio),
        locate: () async => null,
      );

      DatabaseService.bootstrapSites = [];
      await sync.syncSites();
      expect(requests, isEmpty);
      expect(await db.getAllSites(), isEmpty);
      expect(sync.sitesVersion.value, 0);
      expect(
        await DatabaseService.getSites(status: SiteStatus.open, visited: false),
        isEmpty,
      );

      await sync.syncSites(latitude: 39.7392, longitude: -104.9903);
      expect(sync.sitesVersion.value, 1);
      final visible = await DatabaseService.getSites(
        status: SiteStatus.open,
        visited: false,
      );
      expect(visible.map((site) => site.name), ['Newer']);
      final site = (await db.getSiteBySiteId(50))!;
      expect(site.name, 'Newer');
      expect(site.city, 'Denver');
      expect(site.stallCount, 8);
      expect(site.timezone, 'America/Denver');
      expect((await db.getRegionSync(100))!.lastChangeId, 11);
      expect((await db.getUserSettings()).lastLatitude, 39.7392);
      expect(
        requests.every(
          (request) => request.queryParameters['regionId'].toString() == '100',
        ),
        isTrue,
      );
      expect(
        requests.any((request) => request.uri.path.endsWith('/allSites')),
        isFalse,
      );
      final siteCalls = requests
          .where((request) => request.uri.path.endsWith('/sites'))
          .length;
      expect(siteCalls, 1);

      final beforeSecond = requests.length;
      await sync.syncSites(latitude: 39.7392, longitude: -104.9903);
      final updated = (await db.getSiteBySiteId(50))!;
      expect(updated.name, 'Newest');
      expect((await db.getRegionSync(100))!.lastChangeId, 12);
      final second = requests.sublist(beforeSecond);
      expect(
        second.any((request) => request.uri.path.endsWith('/sites')),
        isFalse,
      );
      expect(second, isNotEmpty);
    },
  );
}
