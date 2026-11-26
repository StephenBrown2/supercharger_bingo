import 'package:drift/drift.dart' show Value, Migrator;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/nearest_site_service.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  Site site(int id, double lat, double lon, [SiteStatus s = SiteStatus.open]) =>
      Site(
        id: id,
        siteId: id,
        name: 'Site $id',
        status: s,
        latitude: lat,
        longitude: lon,
        country: 'US',
        region: 'NA',
        otherEvs: false,
        stallsV2: 0,
        stallsV3: 0,
        stallsV4: 0,
        stallsUrban: 0,
        stallsOther: 0,
        hasCheckins: false,
        visited: false,
      );

  test('findNearestSite picks the closest and gives a bearing', () {
    final sites = [site(1, 35.0, -117.0), site(2, 34.1, -117.0)];
    final nearest = findNearestSite(sites, 34.0, -117.0)!;
    expect(nearest.site.siteId, 2);
    expect(nearest.km, closeTo(11.1, 0.2));
    expect(compassPoint(nearest.bearing), 'N');
    expect(findNearestSite([], 0, 0), isNull);
  });

  test('compassPoint and chipDistance', () {
    expect(compassPoint(-90), 'W');
    expect(compassPoint(-170), 'S');
    expect(compassPoint(44), 'NE');
    expect(chipDistance(5, UnitSystem.metric), '5.0 km');
    expect(directionPhrase('NW'), 'Northwest of here');
    expect(directionPhrase('S'), 'South of here');
    expect(chipDistance(200, UnitSystem.imperial), '124 mi');
  });

  test('directionTo prefers travel, then compass, then letters', () {
    // Site to the northeast.
    expect(directionTo(45), 'NE');
    expect(directionTo(45, compass: 45), '↑');
    expect(directionTo(45, compass: 135), '←');
    // Heading east while moving: northeast is ahead and to the left.
    expect(directionTo(45, travel: 90, compass: 45), '↖');
    expect(directionTo(-170, travel: 10), '↓');
    expect(directionArrow(-90), '←');
    expect(directionArrow(350), '↑');
  });

  test('v24 upgrade adds the direction setting, on', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.getUserSettings();
    await db.customStatement(
      'ALTER TABLE user_settings DROP COLUMN nearest_site_show_direction',
    );
    await db.migration.onUpgrade(Migrator(db), 24, 25);
    expect((await db.getUserSettings()).nearestSiteShowDirection, isTrue);
  });

  test('unvisitedSites filters open and optional construction', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    Future<void> add(int id, SiteStatus status, {bool visited = false}) =>
        db.upsertSite(
          SitesCompanion.insert(
            siteId: id,
            name: '$id',
            status: Value(status),
            visited: Value(visited),
          ),
        );
    await add(1, SiteStatus.open);
    await add(2, SiteStatus.construction);
    await add(3, SiteStatus.open, visited: true);
    await add(4, SiteStatus.permit);

    Future<List<int>> ids(bool construction) async => (await db.unvisitedSites(
      includeConstruction: construction,
    )).map((s) => s.siteId).toList()..sort();
    expect(await ids(false), [1]);
    expect(await ids(true), [1, 2]);
  });

  test('v16 upgrade adds the nearest site settings, off', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.getUserSettings();
    await db.customStatement(
      'ALTER TABLE user_settings DROP COLUMN nearest_site_live_update',
    );
    await db.customStatement(
      'ALTER TABLE user_settings DROP COLUMN nearest_site_include_construction',
    );
    await db.migration.onUpgrade(Migrator(db), 16, 17);
    final settings = await db.getUserSettings();
    expect(settings.nearestSiteLiveUpdate, isFalse);
    expect(settings.nearestSiteIncludeConstruction, isFalse);
  });
}
