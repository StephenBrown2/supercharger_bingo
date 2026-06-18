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

  test('getEarliestCheckinDates returns the min check-in date per site', () async {
    await seedSite(10);
    await db.upsertSiteCheckins([
      SiteCheckinsCompanion.insert(
        checkinId: 1,
        siteId: 10,
        odUserId: 100,
        username: 'a',
        checkinDate: DateTime(2026, 5, 2),
        checkinTime: DateTime(2026, 5, 2, 12),
        syncedAt: DateTime.now(),
      ),
      SiteCheckinsCompanion.insert(
        checkinId: 2,
        siteId: 10,
        odUserId: 101,
        username: 'b',
        checkinDate: DateTime(2026, 5, 1),
        checkinTime: DateTime(2026, 5, 1, 9),
        syncedAt: DateTime.now(),
      ),
    ]);

    final dates = await db.getEarliestCheckinDates([10]);
    expect(dates[10], DateTime(2026, 5, 1));
  });

  test('getEarliestCheckinDates is empty when no ids given', () async {
    expect(await db.getEarliestCheckinDates([]), isEmpty);
  });
}
