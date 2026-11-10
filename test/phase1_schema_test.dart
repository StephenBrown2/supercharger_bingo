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
          'ALTER TABLE user_settings DROP COLUMN include_vehicle_in_private_note',
          'ALTER TABLE visits DROP COLUMN checkin_precision',
          'ALTER TABLE pending_checkins DROP COLUMN checkin_precision',
          'DROP TABLE region_syncs',
        ]) {
          await db.customStatement(statement);
        }
        await db.migration.onUpgrade(Migrator(db), 3, 8);
        final site = await db.getSiteBySiteId(42);
        expect(site!.timezone, isNull);
        expect(site.visited, isTrue);
        expect(await db.getAllVehicles(), isEmpty);
        expect((await db.getUserSettings()).includeVisitedNearby, isFalse);
        expect(
          (await db.getUserSettings()).includeVehicleInPrivateNote,
          isFalse,
        );
        await db.upsertRegionSync(100, 5);
        expect((await db.getRegionSync(100))!.lastChangeId, 5);
      },
    );

    test('v7 per-vehicle opt-in becomes the check-in private-note setting', () async {
      await db.customStatement(
        'ALTER TABLE user_settings DROP COLUMN include_vehicle_in_private_note',
      );
      await db.customStatement(
        'ALTER TABLE vehicles ADD COLUMN display_opt_in INTEGER NOT NULL DEFAULT 0',
      );
      await db.customStatement(
        "INSERT INTO vehicles (id, label, display_opt_in) VALUES ('veh', 'Daily', 1)",
      );
      await db.migration.onUpgrade(Migrator(db), 7, 8);
      expect((await db.getUserSettings()).includeVehicleInPrivateNote, isTrue);
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('vehicles')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        isNot(contains('display_opt_in')),
      );
    });

    test(
      'v8 upgrade drops unused community columns and keeps the visit',
      () async {
        await db.customStatement(
          'ALTER TABLE visits ADD COLUMN distinct_user_super_seq INTEGER',
        );
        await db.customStatement(
          'ALTER TABLE site_checkins ADD COLUMN days_after_open INTEGER',
        );
        await db.customStatement('ALTER TABLE visits DROP COLUMN sync_status');
        await db.customStatement('ALTER TABLE visits DROP COLUMN pending_id');
        await db.customStatement(
          'ALTER TABLE user_settings DROP COLUMN auth_provider',
        );
        await db.customStatement(
          "INSERT INTO visits (checkin_id, site_id, checkin_date, checkin_time, "
          "checkin_precision, is_first, method, imported_at, distinct_user_super_seq) "
          "VALUES (55, 7, 0, 0, 'timestamp', 0, 'manual', 0, 4)",
        );
        await db.migration.onUpgrade(Migrator(db), 8, 9);

        final visit = (await db.getAllVisits()).single;
        expect(visit.checkinId, 55);
        expect(visit.syncStatus, VisitSyncStatus.synced);
        expect(visit.pendingId, isNull);
        final visitColumns = await db
            .customSelect("SELECT name FROM pragma_table_info('visits')")
            .get();
        final visitNames = visitColumns.map((row) => row.read<String>('name'));
        expect(visitNames, contains('sync_status'));
        expect(visitNames, isNot(contains('distinct_user_super_seq')));
        final community = await db
            .customSelect("SELECT name FROM pragma_table_info('site_checkins')")
            .get();
        expect(
          community.map((row) => row.read<String>('name')),
          isNot(contains('days_after_open')),
        );
        final settings = await db
            .customSelect("SELECT name FROM pragma_table_info('user_settings')")
            .get();
        expect(
          settings.map((row) => row.read<String>('name')),
          contains('auth_provider'),
        );
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
