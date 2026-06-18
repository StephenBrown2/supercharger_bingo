import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  group('Phase 1 schema (v4)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('schemaVersion is bumped to 4', () {
      expect(db.schemaVersion, 4);
    });

    test('site persists new enum value and derived timezone column', () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 42,
          name: 'Test Site',
          status: const Value(SiteStatus.expanding),
          latitude: const Value(40.0),
          longitude: const Value(-105.0),
          timezone: const Value('America/Denver'),
        ),
      );

      final site = await db.getSiteBySiteId(42);
      expect(site, isNotNull);
      expect(site!.status, SiteStatus.expanding);
      expect(site.timezone, 'America/Denver');
    });

    test('status filter works for the closed sub-states', () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 1,
          name: 'Temp Closed',
          status: const Value(SiteStatus.closedTemp),
        ),
      );
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 2,
          name: 'Perm Closed',
          status: const Value(SiteStatus.closedPerm),
        ),
      );

      final temp = await db.getSitesByStatus(SiteStatus.closedTemp);
      expect(temp.map((s) => s.siteId), [1]);
      final perm = await db.getSitesByStatus(SiteStatus.closedPerm);
      expect(perm.map((s) => s.siteId), [2]);
    });
  });
}
