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

    test(
      'v19 upgrade retains sites and reloads regions for stall types',
      () async {
        await db.upsertSite(
          SitesCompanion.insert(
            siteId: 42,
            name: 'Existing',
            visited: const Value(true),
          ),
        );
        await db.upsertRegionSync(100, 123);
        final names =
            (await db
                    .customSelect("SELECT name FROM pragma_table_info('sites')")
                    .get())
                .map((row) => row.read<String>('name'))
                .toSet();
        for (final name in [
          'stalls_v2',
          'stalls_v3',
          'stalls_v4',
          'stalls_urban',
          'stalls_other',
        ]) {
          if (names.contains(name)) {
            await db.customStatement('ALTER TABLE sites DROP COLUMN $name');
          }
        }
        await db.migration.onUpgrade(Migrator(db), 18, 19);
        final columns =
            (await db
                    .customSelect("SELECT name FROM pragma_table_info('sites')")
                    .get())
                .map((row) => row.read<String>('name'));
        expect(
          columns,
          containsAll([
            'stalls_v2',
            'stalls_v3',
            'stalls_v4',
            'stalls_urban',
            'stalls_other',
          ]),
        );
        expect((await db.getSiteBySiteId(42))!.visited, isTrue);
        expect(await db.getRegionSync(100), isNull);
        await db.migration.onUpgrade(Migrator(db), 18, 19);
      },
    );

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
          // The v3 outbox table, removed from the schema in v20.
          'CREATE TABLE pending_checkins (id INTEGER PRIMARY KEY, '
              'site_id INTEGER NOT NULL, checkin_date INTEGER NOT NULL, '
              'created_at INTEGER NOT NULL, latitude REAL, longitude REAL, '
              'accuracy REAL, notes_public TEXT, status TEXT, '
              'attempts INTEGER, last_attempt_at INTEGER, last_error TEXT)',
          'DROP TABLE vehicles',
          'ALTER TABLE user_settings DROP COLUMN include_visited_nearby',
          'ALTER TABLE user_settings DROP COLUMN include_vehicle_in_private_note',
          'ALTER TABLE visits DROP COLUMN checkin_precision',
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
        final visitColumns = await db
            .customSelect("SELECT name FROM pragma_table_info('visits')")
            .get();
        final visitNames = visitColumns.map((row) => row.read<String>('name'));
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

    test(
      'v10 upgrade clears the region cursor so otherEvs can reload',
      () async {
        await db.upsertRegionSync(100, 27726);
        await db.migration.onUpgrade(Migrator(db), 9, 10);
        expect(await db.getRegionSync(100), isNull);
      },
    );

    test('v12 upgrade adds the alert cursor and dedupe log once', () async {
      await db.customStatement(
        'ALTER TABLE user_settings DROP COLUMN last_notified_change_id',
      );
      await db.customStatement('DROP TABLE notification_log');
      await db.migration.onUpgrade(Migrator(db), 11, 12);
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('user_settings')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('last_notified_change_id'),
      );
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'notification_log'",
          )
          .get();
      expect(tables, isNotEmpty);
      await db.migration.onUpgrade(Migrator(db), 11, 12);
    });

    test('v13 upgrade adds the appearance theme once', () async {
      await db.customStatement(
        'ALTER TABLE user_settings DROP COLUMN app_appearance',
      );
      await db.migration.onUpgrade(Migrator(db), 12, 13);
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('user_settings')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('app_appearance'),
      );
      expect((await db.getUserSettings()).appAppearance, AppAppearance.system);
      await db.migration.onUpgrade(Migrator(db), 12, 13);
    });

    test(
      'v15 upgrade clears visited flags with no visit behind them',
      () async {
        for (final id in [1, 2]) {
          await db.upsertSite(
            SitesCompanion.insert(
              siteId: id,
              name: 'Site $id',
              visited: const Value(true),
            ),
          );
        }
        await db.addVisit(
          VisitsCompanion.insert(
            siteId: 2,
            checkinDate: DateTime(2026, 11, 1),
            checkinTime: DateTime(2026, 11, 1, 12),
            importedAt: DateTime(2026, 11, 1),
          ),
        );
        await db.migration.onUpgrade(Migrator(db), 14, 15);
        expect((await db.getSiteBySiteId(1))!.visited, isFalse);
        expect((await db.getSiteBySiteId(2))!.visited, isTrue);
      },
    );

    test('v14 upgrade adds the setup marker once', () async {
      await db.customStatement(
        'ALTER TABLE user_settings DROP COLUMN setup_completed_at',
      );
      await db.migration.onUpgrade(Migrator(db), 13, 14);
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('user_settings')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('setup_completed_at'),
      );
      expect((await db.getUserSettings()).setupCompletedAt, isNull);
      await db.migration.onUpgrade(Migrator(db), 13, 14);
    });

    test('v21 reads a stored EXPANDING Site as OPEN', () async {
      await db.customStatement(
        "INSERT INTO sites (site_id, name, status) VALUES (7, 'Grow', 'expanding')",
      );
      await db.migration.onUpgrade(Migrator(db), 20, 21);
      expect((await db.getSiteBySiteId(7))!.status, SiteStatus.open);
    });

    test('v22 adds the street once and reloads every site', () async {
      await db.customStatement('ALTER TABLE sites DROP COLUMN street');
      await db.upsertRegionSync(100, 5000);
      await db.migration.onUpgrade(Migrator(db), 21, 22);
      final columns = await db
          .customSelect("SELECT name FROM pragma_table_info('sites')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')),
        contains('street'),
      );
      expect(await db.getRegionSync(100), isNull);
      await db.migration.onUpgrade(Migrator(db), 21, 22);
    });

    test('site persists closed status and derived timezone column', () async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 42,
          name: 'Test Site',
          status: const Value(SiteStatus.closedTemp),
          latitude: const Value(40.0),
          longitude: const Value(-105.0),
          timezone: const Value('America/Denver'),
        ),
      );

      final site = await db.getSiteBySiteId(42);
      expect(site, isNotNull);
      expect(site!.status, SiteStatus.closedTemp);
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

      final temp = await db.getSites(status: SiteStatus.closedTemp);
      expect(temp.map((s) => s.siteId), [1]);
      final perm = await db.getSites(status: SiteStatus.closedPerm);
      expect(perm.map((s) => s.siteId), [2]);
    });
  });
}
