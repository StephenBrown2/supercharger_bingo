import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/screens/map_site_type.dart';

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

  test(
    'types match mixed stalls and combine missing and other as Unknown',
    () async {
      for (final site in [
        SitesCompanion.insert(
          siteId: 1,
          name: 'Mixed',
          stallsV2: const Value(2),
          stallsV3: const Value(4),
        ),
        SitesCompanion.insert(siteId: 2, name: 'V4', stallsV4: const Value(8)),
        SitesCompanion.insert(
          siteId: 3,
          name: 'Urban',
          stallsUrban: const Value(4),
        ),
        SitesCompanion.insert(
          siteId: 4,
          name: 'Other',
          stallsOther: const Value(2),
          stallsV3: const Value(4),
        ),
        SitesCompanion.insert(siteId: 5, name: 'Missing'),
      ]) {
        await db.upsertSite(site);
      }
      final sites = await db.getAllSites();
      for (final entry in {
        MapSiteType.all: {1, 2, 3, 4, 5},
        MapSiteType.v2: {1},
        MapSiteType.v3: {1, 4},
        MapSiteType.v4: {2},
        MapSiteType.urban: {3},
        MapSiteType.unknown: {4, 5},
      }.entries) {
        expect(
          sites.where(entry.key.matches).map((s) => s.siteId).toSet(),
          entry.value,
        );
      }
    },
  );

  test('NACS is unvisited OPEN sites with otherEVs', () async {
    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 1,
        name: 'NACS open',
        status: const Value(SiteStatus.open),
        otherEvs: const Value(true),
      ),
    );
    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 2,
        name: 'Tesla only',
        status: const Value(SiteStatus.open),
      ),
    );
    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 3,
        name: 'Visited NACS',
        status: const Value(SiteStatus.open),
        otherEvs: const Value(true),
        visited: const Value(true),
      ),
    );
    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 4,
        name: 'NACS construction',
        status: const Value(SiteStatus.construction),
        otherEvs: const Value(true),
      ),
    );

    final nacs = await DatabaseService.getUnvisitedNacsSites();
    expect(nacs.map((site) => site.siteId), [1]);
  });
}
