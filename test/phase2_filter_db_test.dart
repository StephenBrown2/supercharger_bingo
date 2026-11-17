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

  test(
    'getEarliestCheckinDates returns the min check-in date per site',
    () async {
      await seedSite(10);
      await db.upsertSiteCheckins([
        SiteCheckinsCompanion.insert(
          checkinId: 1,
          siteId: 10,
          odUserId: 100,
          username: 'a',
          checkinDate: DateTime.utc(2026, 5, 2),
          checkinTime: DateTime(2026, 5, 2, 12),
          isFirstAtSupercharger: const Value(true),
          syncedAt: DateTime.now(),
        ),
        SiteCheckinsCompanion.insert(
          checkinId: 2,
          siteId: 10,
          odUserId: 101,
          username: 'b',
          checkinDate: DateTime.utc(2026, 5, 1),
          checkinTime: DateTime(2026, 5, 1, 9),
          isFirstAtSupercharger: const Value(true),
          syncedAt: DateTime.now(),
        ),
      ]);

      final dates = await db.getEarliestCheckinDates([10]);
      expect(dates[10], DateTime(2026, 5, 1));
    },
  );

  test(
    'counts keep older sites claimed without inventing a First day',
    () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 11,
          name: 'Older site',
          status: const Value(SiteStatus.open),
          dateOpened: Value(DateTime.utc(2026, 10, 26)),
        ),
      );
      await seedSite(12);
      expect(await db.getEarliestCheckinDates([11, 12]), isEmpty);

      await db.markSitesHaveCheckins([11]);
      expect(await db.getEarliestCheckinDates([11, 12]), {11: DateTime(2000)});
    },
  );

  test('getEarliestCheckinDates is empty when no ids given', () async {
    expect(await db.getEarliestCheckinDates([]), isEmpty);
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
    'First dates ignore check-ins before opening but include opening day',
    () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 10,
          name: 'New site',
          status: const Value(SiteStatus.open),
          dateOpened: Value(DateTime.utc(2026, 5, 2)),
        ),
      );
      for (var day = 1; day <= 3; day++) {
        await db.upsertSiteCheckins([
          SiteCheckinsCompanion.insert(
            checkinId: day,
            siteId: 10,
            odUserId: 100,
            username: 'a',
            checkinDate: DateTime.utc(2026, 5, day),
            checkinTime: DateTime(2026, 5, day, 12),
            isFirstAtSupercharger: const Value(true),
            syncedAt: DateTime.now(),
          ),
        ]);
      }
      expect(
        (await db.getEarliestCheckinDates([10]))[10],
        DateTime(2026, 5, 2),
      );

      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 10,
          name: 'New site',
          status: const Value(SiteStatus.open),
          dateOpened: Value(DateTime.utc(2026, 5, 4)),
        ),
      );
      // A later listed opening can be a reopening, not a reason to revoke First.
      expect(await db.getEarliestCheckinDates([10]), {
        10: DateTime(2026, 5, 2),
      });
    },
  );

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

  test(
    'a repeat visitor is not the First, and a shared First lists everyone',
    () async {
      SiteCheckinsCompanion row(int id, String name, int day, bool first) =>
          SiteCheckinsCompanion.insert(
            checkinId: id,
            siteId: 20,
            odUserId: id,
            username: name,
            checkinDate: DateTime.utc(2026, 11, day),
            checkinTime: DateTime(2026, 11, day, 9 + id),
            isFirstAtSupercharger: Value(first),
            syncedAt: DateTime.now(),
          );
      await seedSite(20);
      // Someone's first visit today, at a site whose First was earlier.
      await db.upsertSiteCheckins([row(1, 'smithg13', 14, false)]);
      expect(await db.getEarliestCheckinDates([20]), isEmpty);
      expect(await db.getFirstCheckinNames(20), isEmpty);

      await db.upsertSiteCheckins([
        row(2, 'Bighorn', 11, true),
        row(3, 'theflyer', 11, true),
        row(4, 'late', 12, true),
      ]);
      expect(await db.getEarliestCheckinDates([20]), {
        20: DateTime(2026, 11, 11),
      });
      expect(await db.getFirstCheckinNames(20), ['Bighorn', 'theflyer']);
    },
  );
}
