import 'package:drift/drift.dart' show Value, Migrator;
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

    test('schemaVersion is bumped past the prototype (>= 4)', () {
      expect(db.schemaVersion, greaterThanOrEqualTo(4));
    });

    test(
      'v3 upgrade initializes new timezone without reading a missing column',
      () async {
        await db.upsertSite(
          SitesCompanion.insert(
            siteId: 42,
            name: 'Existing site',
            visited: const Value(true),
          ),
        );
        for (final statement in [
          'ALTER TABLE sites DROP COLUMN timezone',
          'ALTER TABLE visits DROP COLUMN notes_private',
          'ALTER TABLE visits DROP COLUMN vehicle_id',
          'ALTER TABLE pending_checkins DROP COLUMN notes_private',
          'ALTER TABLE pending_checkins DROP COLUMN vehicle_id',
          'DROP TABLE vehicles',
          'ALTER TABLE user_settings DROP COLUMN include_visited_nearby',
          'ALTER TABLE visits DROP COLUMN checkin_precision',
          'ALTER TABLE pending_checkins DROP COLUMN checkin_precision',
          'DROP TABLE region_syncs',
        ]) {
          await db.customStatement(statement);
        }
        await db.migration.onUpgrade(Migrator(db), 3, 7);
        final site = await db.getSiteBySiteId(42);
        expect(site!.timezone, isNull);
        expect(site.visited, isTrue);
        expect(await db.getAllVehicles(), isEmpty);
        expect((await db.getUserSettings()).includeVisitedNearby, isFalse);
        await db.upsertRegionSync(100, 5);
        expect((await db.getRegionSync(100))!.lastChangeId, 5);
      },
    );

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
