import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seedSite(int id, {bool visited = false}) {
    return db.upsertSite(
      SitesCompanion.insert(
        siteId: id,
        name: 'Site $id',
        status: const Value(SiteStatus.open),
        visited: Value(visited),
      ),
    );
  }

  test('getVisitedSites returns only visited sites', () async {
    await seedSite(1, visited: true);
    await seedSite(2, visited: false);
    await seedSite(3, visited: true);

    final visited = await db.getVisitedSites();
    expect(visited.map((s) => s.siteId).toSet(), {1, 3});
  });

  test('markSiteVisited only updates visited', () async {
    await seedSite(7);
    await db.markSiteVisited(7, true);
    var site = await db.getSiteBySiteId(7);
    expect(site!.visited, isTrue);
    expect(site.hasCheckins, isFalse);

    await db.markSiteHasCheckins(7, true);
    await db.markSiteVisited(7, false);
    site = await db.getSiteBySiteId(7);
    expect(site!.visited, isFalse);
    expect(site.hasCheckins, isTrue);
  });

  test(
    'upsertSiteCheckins re-syncs the same checkin_id without failing',
    () async {
      SiteCheckinsCompanion row(bool first) => SiteCheckinsCompanion.insert(
        checkinId: 93723,
        siteId: 9928,
        odUserId: 50124,
        username: 'theflyer',
        checkinDate: DateTime.utc(2026, 6, 17),
        checkinTime: DateTime(2026, 6, 17, 12),
        isFirstAtSupercharger: Value(first),
        syncedAt: DateTime.now(),
      );

      await db.upsertSiteCheckins([row(false)]);
      // Same community check-in id arrives again on the next poll.
      await db.upsertSiteCheckins([row(true)]);

      final all = await db.getSiteCheckins(9928);
      expect(all, hasLength(1));
      expect(all.first.isFirstAtSupercharger, isTrue);
    },
  );
}
