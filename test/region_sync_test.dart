import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
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
    'new-opening history removes a premature First missing from the recent feed',
    () async {
      final today = DateTime.now().toUtc();
      final listed = _siteJson('New opening')
        ..['dateOpened'] = today.toIso8601String().substring(0, 10);
      await db.upsertSite(ApiService.parseSiteRecord(listed)!);
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              final content = options.queryParameters['content'];
              final data = content == 'supercharger_list_for_datatables'
                  ? [
                      {'supercharger_id': '50', 'checkin_qty': '1'},
                    ]
                  : content ==
                        'supercharger_checkin_history_list_for_datatables'
                  ? [
                      {
                        'checkin_id': '1',
                        'supercharger_id': '50',
                        'user_id': '1',
                        'user_username': 'early',
                        'checkin_date': '2020-01-01',
                        'is_first_at_supercharger_cache': 'Y',
                      },
                    ]
                  : [];
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'data': data},
                ),
              );
            },
          ),
        );
      await SyncService(apiService: ApiService(dio: dio)).syncCommunityData();
      expect(await db.getEarliestCheckinDates([50]), isEmpty);
      expect(await db.getSiteCheckins(50), hasLength(1));
      expect(
        requests.where((r) => r.queryParameters['id'] == 50),
        hasLength(1),
      );
    },
  );

  test(
    'opening history retains original OPEN across a reopening and resync',
    () async {
      await db.clearAll();
      final listed = _siteJson('Reopened')..['dateOpened'] = '2025-05-15';
      await db.upsertSite(ApiService.parseSiteRecord(listed)!);
      Map<String, dynamic> change(
        int id,
        String date,
        String status,
        String previous,
      ) => _changeJson(id, 'Reopened')
        ..['date'] = date
        ..['siteStatus'] = status
        ..['prevStatus'] = previous
        ..['site'] = listed;
      var history = [
        change(3, '2025-05-15', 'OPEN', 'CLOSED_TEMP'),
        change(2, '2025-04-21', 'CLOSED_TEMP', 'OPEN'),
        change(1, '2025-04-16', 'OPEN', 'CONSTRUCTION'),
      ];
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: options.path.endsWith('/sites')
                      ? {
                          'results': [listed],
                          'recordCount': 1,
                        }
                      : options.path.endsWith('/changes')
                      ? {'results': history, 'recordCount': history.length}
                      : {'data': []},
                ),
              );
            },
          ),
        );
      final sync = SyncService(apiService: ApiService(dio: dio));
      await sync.syncSites(latitude: 39.7392, longitude: -104.9903);
      var site = (await db.getSiteBySiteId(50))!;
      expect(site.firstOpeningDay!.toUtc(), DateTime.utc(2025, 4, 16));
      expect(site.dateOpened!.toUtc().month, 5);

      // A site refresh and an aged-out original change must keep the evidence.
      await db.upsertSites([ApiService.parseSiteRecord(listed)!]);
      history = [history.first];
      final restarted = SyncService(apiService: ApiService(dio: dio));
      await restarted.syncSites(latitude: 39.7392, longitude: -104.9903);
      await restarted.syncCommunityData();
      expect(requests.any((r) => r.path.endsWith('/allChanges')), isFalse);
      expect((await db.getRegionSync(100))!.lastChangeId, 3);
      site = (await db.getSiteBySiteId(50))!;
      expect(site.firstOpeningDay!.toUtc(), DateTime.utc(2025, 4, 16));
      await db.upsertSite(
        SitesCompanion(
          siteId: const Value(50),
          name: const Value('Reopened'),
          dateOpened: Value(DateTime.utc(2025, 4, 15)),
        ),
      );
      expect(
        (await db.getSiteBySiteId(50))!.firstOpeningDay!.toUtc(),
        DateTime.utc(2025, 4, 15),
      );
    },
  );

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
