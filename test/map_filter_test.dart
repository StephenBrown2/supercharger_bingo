import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/database_service.dart';

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
        name: 'NACS expanding',
        status: const Value(SiteStatus.expanding),
        otherEvs: const Value(true),
      ),
    );

    final nacs = await DatabaseService.getUnvisitedNacsSites();
    expect(nacs.map((site) => site.siteId), [1]);
  });
}
