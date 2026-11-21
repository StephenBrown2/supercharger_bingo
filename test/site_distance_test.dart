import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  test('distanceKm is Vincenty on WGS84', () {
    // Berlin to Dortmund, latlong2's published Vincenty result.
    expect(
      distanceKm(52.518611, 13.408056, 51.519475, 7.46694444),
      closeTo(422.591551, 1e-6),
    );
    expect(distanceKm(40, -105, 40, -105), 0);
  });

  test('distanceKm falls back to haversine for nearly antipodal points', () {
    final km = distanceKm(0, 0, 0.5, 179.7);
    expect(km.isFinite, isTrue);
    expect(km, closeTo(20000, 100));
  });

  group('database', () {
    setUpAll(registerTestSqlite3);

    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> visit(int siteId, DateTime day) => db.addVisit(
      VisitsCompanion.insert(
        siteId: siteId,
        checkinDate: day,
        checkinTime: day,
        importedAt: day,
      ),
    );

    test('addVisit marks its Site visited', () async {
      await db.upsertSite(SitesCompanion.insert(siteId: 1, name: 'One'));
      await visit(1, DateTime(2026, 6, 1));
      expect((await db.getSiteBySiteId(1))!.visited, isTrue);
    });

    test('getLastVisitDates returns the latest Visit per asked Site', () async {
      await visit(1, DateTime(2026, 6, 1));
      await visit(1, DateTime(2026, 6, 9));
      await visit(2, DateTime(2026, 5, 3));
      await visit(3, DateTime(2026, 4, 4));
      expect(await db.getLastVisitDates([1, 2, 4]), {
        1: DateTime(2026, 6, 9),
        2: DateTime(2026, 5, 3),
      });
      expect(await db.getLastVisitDates([]), isEmpty);
    });
  });

  test('nearbySites filters by radius, sorts and limits', () {
    Site site(int id, double lat) => Site(
      id: id,
      siteId: id,
      name: 'Site $id',
      latitude: lat,
      longitude: -105,
      status: SiteStatus.open,
      visited: false,
      hasCheckins: false,
      otherEvs: false,
      stallsV2: 0,
      stallsV3: 0,
      stallsV4: 0,
      stallsUrban: 0,
      stallsOther: 0,
      country: 'US',
      region: 'North America',
    );
    final near = nearbySites(
      [site(1, 40.3), site(2, 40.1), site(3, 41)],
      40,
      -105,
      radiusKm: 50,
      limit: 20,
    );
    expect(near.map((s) => s.site.siteId), [2, 1]);
  });
}
