import 'package:drift/drift.dart';

part 'database.g.dart';

// ============================================================================
// Enums (stored as text in SQLite)
// ============================================================================

/// Authoritative 8-value supercharge.info status (SPEC Section 2.1).
/// No catch-all: sites with an unrecognized status are skipped on ingestion.
enum SiteStatus {
  open,
  expanding,
  construction,
  permit,
  plan,
  voting,
  closedTemp,
  closedPerm,
}

enum PendingStatus { pending, submitting, failed, completed }

enum CheckinMethod { gps, manual }

enum PollingInterval { minutes15, hour1, hours4, hours6, hours12, hours24 }

enum MapFilter { openUnvisited, openUnvisitedConstruction, visited, all }

enum UnitSystem { metric, imperial }

// ============================================================================
// Tables
// ============================================================================

/// Supercharger sites from supercharge.info
class Sites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer().unique()();
  TextColumn get locationId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get status =>
      textEnum<SiteStatus>().withDefault(Constant(SiteStatus.plan.name))();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('Unknown'))();
  TextColumn get region => text().withDefault(const Constant('Unknown'))();

  /// IANA timezone derived from coordinates at ingestion (SPEC Section 3).
  /// Drives the site-local "First" day boundary.
  TextColumn get timezone => text().nullable()();
  IntColumn get stallCount => integer().nullable()();
  DateTimeColumn get dateOpened => dateTime().nullable()();

  /// Cache of "community check-in count > 0" from the counts endpoint.
  /// First eligibility comes from getEarliestCheckinDates (the earliest
  /// qualifying community check-in). This flag is only the counts cache.
  BoolColumn get hasCheckins => boolean().withDefault(const Constant(false))();

  /// Whether the current user has visited this site
  BoolColumn get visited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSynced => dateTime().nullable()();
}

/// User's visits (check-ins)
class Visits extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Server-assigned supercharging.life check-in id, kept as that integer.
  IntColumn get checkinId => integer().unique()();
  IntColumn get siteId => integer()();
  DateTimeColumn get checkinDate => dateTime()();
  DateTimeColumn get checkinTime => dateTime()();
  BoolColumn get isFirst => boolean().withDefault(const Constant(false))();
  TextColumn get method => textEnum<CheckinMethod>().withDefault(
    Constant(CheckinMethod.manual.name),
  )();
  TextColumn get notesPublic => text().nullable()();
  TextColumn get notesPrivate => text().nullable()();

  /// Local-only association with a Vehicle; never sent to supercharging.life.
  TextColumn get vehicleId => text().nullable()();
  IntColumn get geoDistanceAccuracy => integer().nullable()();
  IntColumn get geoDistance => integer().nullable()();
  IntColumn get distinctUserSuperSeq => integer().nullable()();
  DateTimeColumn get importedAt => dateTime()();
}

/// Pending check-ins (offline queue)
class PendingCheckins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer()();
  DateTimeColumn get checkinDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  TextColumn get notesPublic => text().nullable()();
  TextColumn get notesPrivate => text().nullable()();

  /// Local-only association with a Vehicle; never sent to supercharging.life.
  TextColumn get vehicleId => text().nullable()();
  TextColumn get status => textEnum<PendingStatus>().withDefault(
    Constant(PendingStatus.pending.name),
  )();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}

/// Others' check-ins (for First eligibility tracking)
class SiteCheckins extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Same server-assigned supercharging.life check-in id as [Visits.checkinId].
  IntColumn get checkinId => integer().unique()();
  IntColumn get siteId => integer()();
  IntColumn get odUserId => integer()();
  TextColumn get username => text()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get checkinDate => dateTime()();
  DateTimeColumn get checkinTime => dateTime()();
  BoolColumn get isFirstAtSupercharger =>
      boolean().withDefault(const Constant(false))();
  IntColumn get daysAfterOpen => integer().nullable()();
  DateTimeColumn get syncedAt => dateTime()();
}

/// Local vehicles (SPEC Section 3). Purely local; never synced. The raw VIN is
/// never stored here: it lives in flutter_secure_storage keyed by [id], and
/// only the derived fields (decoded from vPIC) are kept, shown only when the
/// user opts in.
class Vehicles extends Table {
  TextColumn get id => text()(); // client-generated UUID
  TextColumn get label => text()(); // required nickname
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get trim => text().nullable()();
  BoolColumn get displayOptIn => boolean().withDefault(const Constant(false))();
  BoolColumn get hasVin => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// User settings and authentication state
class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get odUserId => integer().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  BoolColumn get isAuthenticated =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get firstLoginAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get lastXlsxSyncAt => dateTime().nullable()();
  TextColumn get pollingInterval => textEnum<PollingInterval>().withDefault(
    Constant(PollingInterval.hours24.name),
  )();
  RealColumn get notificationRadiusKm =>
      real().withDefault(const Constant(100.0))();
  TextColumn get mapFilter => textEnum<MapFilter>().withDefault(
    Constant(MapFilter.openUnvisited.name),
  )();
  BoolColumn get showVisitedOnMap =>
      boolean().withDefault(const Constant(false))();
  RealColumn get checkinRadiusKm =>
      real().withDefault(const Constant(5000.0))();
  TextColumn get unitSystem =>
      textEnum<UnitSystem>().withDefault(Constant(UnitSystem.imperial.name))();

  /// When false, the nearby check-in list hides sites the user has already
  /// visited. Turn on to show those sites with their last visit date.
  BoolColumn get includeVisitedNearby =>
      boolean().withDefault(const Constant(false))();
  RealColumn get lastLatitude => real().nullable()();
  RealColumn get lastLongitude => real().nullable()();
  DateTimeColumn get lastSitesSyncAt => dateTime().nullable()();
  DateTimeColumn get lastCheckinHistorySyncAt => dateTime().nullable()();

  @override
  String get tableName => 'user_settings';
}

// ============================================================================
// Database
// ============================================================================

@DriftDatabase(
  tables: [
    Sites,
    Visits,
    PendingCheckins,
    SiteCheckins,
    UserSettingsTable,
    Vehicles,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Create database with the given [executor].
  /// Use [connect] from connection/native.dart or connection/web.dart
  /// to get the appropriate executor for the current platform.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create default user settings
        await into(
          userSettingsTable,
        ).insert(UserSettingsTableCompanion.insert());
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add hasCheckins column to sites table
          await customStatement(
            'ALTER TABLE sites ADD COLUMN has_checkins INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (from < 3) {
          // Add checkinRadiusKm and unitSystem columns to user_settings table
          await customStatement(
            'ALTER TABLE user_settings ADD COLUMN checkin_radius_km REAL NOT NULL DEFAULT 5000.0',
          );
          await customStatement(
            'ALTER TABLE user_settings ADD COLUMN unit_system TEXT NOT NULL DEFAULT \'metric\'',
          );
        }
        if (from < 4) {
          // SPEC Phase 1: move to the authoritative 8-value status enum, drop
          // speculative columns, and add the derived timezone column.
          // Remap legacy status strings to the new enum, then delete any rows
          // whose status has no equivalent in the strict 8-value set.
          await customStatement(
            "UPDATE sites SET status = 'plan' WHERE status = 'planned'",
          );
          await customStatement(
            "UPDATE sites SET status = 'closedPerm' WHERE status = 'closed'",
          );
          await customStatement("DELETE FROM sites WHERE status = 'unknown'");
          // Recreate the sites table from the current schema: drops the removed
          // columns (street/zip/stallsV2-4/powerKilowatt) and adds the nullable
          // timezone column (null until backfilled on next site sync).
          await m.alterTable(
            TableMigration(sites, newColumns: [sites.timezone]),
          );
        }
        if (from < 5) {
          // SPEC Phase 3: private notes + local vehicle association, plus the
          // Vehicles table.
          await customStatement(
            'ALTER TABLE visits ADD COLUMN notes_private TEXT',
          );
          await customStatement(
            'ALTER TABLE visits ADD COLUMN vehicle_id TEXT',
          );
          await customStatement(
            'ALTER TABLE pending_checkins ADD COLUMN notes_private TEXT',
          );
          await customStatement(
            'ALTER TABLE pending_checkins ADD COLUMN vehicle_id TEXT',
          );
          await m.createTable(vehicles);
        }
        if (from < 6) {
          await m.addColumn(
            userSettingsTable,
            userSettingsTable.includeVisitedNearby,
          );
        }
      },
    );
  }

  // -------------------------------------------------------------------------
  // User Settings
  // -------------------------------------------------------------------------

  Future<UserSettingsTableData> getUserSettings() async {
    final settings = await select(userSettingsTable).getSingleOrNull();
    if (settings == null) {
      await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
      return (await select(userSettingsTable).getSingle());
    }
    return settings;
  }

  Future<void> updateUserSettings(UserSettingsTableCompanion settings) async {
    final existing = await select(userSettingsTable).getSingleOrNull();
    if (existing != null) {
      await (update(
        userSettingsTable,
      )..where((t) => t.id.equals(existing.id))).write(settings);
    }
  }

  // -------------------------------------------------------------------------
  // Sites
  // -------------------------------------------------------------------------

  Future<List<Site>> getAllSites() => select(sites).get();

  Future<List<Site>> getSitesByStatus(SiteStatus status) {
    return (select(sites)..where((t) => t.status.equals(status.name))).get();
  }

  Future<List<Site>> getSitesByStatusAndVisited(
    SiteStatus status,
    bool visited,
  ) {
    return (select(sites)..where(
          (t) => t.status.equals(status.name) & t.visited.equals(visited),
        ))
        .get();
  }

  Future<List<Site>> getUnvisitedSites() {
    return (select(sites)..where((t) => t.visited.equals(false))).get();
  }

  Future<List<Site>> getVisitedSites() {
    return (select(sites)..where((t) => t.visited.equals(true))).get();
  }

  /// Earliest community check-in date per site (the site-local "first_date"
  /// that drives pin colour, SPEC Section 4/5). Derived at render time rather
  /// than stored, so it always reflects the current SiteCheckins data.
  Future<Map<int, DateTime>> getEarliestCheckinDates(List<int> siteIds) async {
    if (siteIds.isEmpty) return {};
    final minDate = siteCheckins.checkinDate.min();
    final query = selectOnly(siteCheckins)
      ..join([
        innerJoin(
          sites,
          sites.siteId.equalsExp(siteCheckins.siteId),
          useColumns: false,
        ),
      ])
      ..addColumns([siteCheckins.siteId, minDate])
      ..where(siteCheckins.siteId.isIn(siteIds))
      ..where(
        sites.dateOpened.isNull() |
            siteCheckins.checkinDate.isBiggerOrEqual(sites.dateOpened),
      )
      ..groupBy([siteCheckins.siteId]);
    final rows = await query.get();
    final result = <int, DateTime>{};
    for (final row in rows) {
      final id = row.read(siteCheckins.siteId);
      final date = row.read(minDate);
      if (id != null && date != null) result[id] = date;
    }
    return result;
  }

  Future<Site?> getSiteBySiteId(int siteId) {
    return (select(
      sites,
    )..where((t) => t.siteId.equals(siteId))).getSingleOrNull();
  }

  Future<void> upsertSite(SitesCompanion site) async {
    await into(
      sites,
    ).insert(site, onConflict: DoUpdate((old) => site, target: [sites.siteId]));
  }

  Future<void> upsertSites(List<SitesCompanion> siteList) async {
    await batch((batch) {
      for (final site in siteList) {
        batch.insert(
          sites,
          site,
          onConflict: DoUpdate((old) => site, target: [sites.siteId]),
        );
      }
    });
  }

  Future<void> markSiteVisited(int siteId, bool visited) async {
    await (update(sites)..where((t) => t.siteId.equals(siteId))).write(
      SitesCompanion(visited: Value(visited)),
    );
  }

  Future<void> markSiteHasCheckins(int siteId, bool hasCheckins) async {
    await (update(sites)..where((t) => t.siteId.equals(siteId))).write(
      SitesCompanion(hasCheckins: Value(hasCheckins)),
    );
  }

  Future<void> markSitesHaveCheckins(List<int> siteIds) async {
    if (siteIds.isEmpty) return;
    await (update(sites)..where((t) => t.siteId.isIn(siteIds))).write(
      const SitesCompanion(hasCheckins: Value(true)),
    );
  }

  // -------------------------------------------------------------------------
  // Visits
  // -------------------------------------------------------------------------

  Future<List<Visit>> getAllVisits() => select(visits).get();

  Future<List<Visit>> getVisitsBySiteId(int siteId) {
    return (select(visits)..where((t) => t.siteId.equals(siteId))).get();
  }

  Future<int> getVisitCount() async {
    final count = await (selectOnly(visits)..addColumns([visits.id.count()]))
        .map((row) => row.read(visits.id.count()))
        .getSingle();
    return count ?? 0;
  }

  Future<DateTime?> getLastVisitDate(int siteId) async {
    final visit =
        await (select(visits)
              ..where((t) => t.siteId.equals(siteId))
              ..orderBy([(t) => OrderingTerm.desc(t.checkinDate)])
              ..limit(1))
            .getSingleOrNull();
    final pending =
        await (select(pendingCheckins)
              ..where((t) => t.siteId.equals(siteId))
              ..orderBy([(t) => OrderingTerm.desc(t.checkinDate)])
              ..limit(1))
            .getSingleOrNull();
    final dates = <DateTime>[
      if (visit != null) visit.checkinDate,
      if (pending != null) pending.checkinDate,
    ];
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }

  Future<void> addVisit(VisitsCompanion visit) async {
    // Upsert on the supercharging.life check-in id so re-importing the XLSX
    // (or rows already present) refreshes instead of violating the unique
    // constraint on visits.checkin_id.
    await into(visits).insert(
      visit,
      onConflict: DoUpdate((_) => visit, target: [visits.checkinId]),
    );
  }

  // -------------------------------------------------------------------------
  // Pending Check-ins
  // -------------------------------------------------------------------------

  Future<List<PendingCheckin>> getPendingCheckins() {
    return (select(
      pendingCheckins,
    )..where((t) => t.status.equals(PendingStatus.pending.name))).get();
  }

  Future<void> addPendingCheckin(PendingCheckinsCompanion checkin) async {
    await into(pendingCheckins).insert(checkin);
  }

  Future<void> updatePendingCheckin(
    int id,
    PendingCheckinsCompanion checkin,
  ) async {
    await (update(
      pendingCheckins,
    )..where((t) => t.id.equals(id))).write(checkin);
  }

  Future<void> deletePendingCheckin(int id) async {
    await (delete(pendingCheckins)..where((t) => t.id.equals(id))).go();
  }

  // -------------------------------------------------------------------------
  // Site Check-ins (others' check-ins)
  // -------------------------------------------------------------------------

  Future<List<SiteCheckin>> getSiteCheckins(int siteId, {int limit = 10}) {
    return (select(siteCheckins)
          ..where((t) => t.siteId.equals(siteId))
          ..orderBy([(t) => OrderingTerm.desc(t.checkinTime)])
          ..limit(limit))
        .get();
  }

  Future<DateTime?> getLastPublicCheckinDate(int siteId) async {
    final checkin =
        await (select(siteCheckins)
              ..where((t) => t.siteId.equals(siteId))
              ..orderBy([(t) => OrderingTerm.desc(t.checkinDate)])
              ..limit(1))
            .getSingleOrNull();
    return checkin?.checkinDate;
  }

  Future<void> upsertSiteCheckins(List<SiteCheckinsCompanion> checkins) async {
    await batch((batch) {
      for (final checkin in checkins) {
        batch.insert(
          siteCheckins,
          checkin,
          // Conflict is on the checkin_id unique index, not the PK; without an
          // explicit target drift assumes the PK and the insert fails.
          onConflict: DoUpdate(
            (old) => checkin,
            target: [siteCheckins.checkinId],
          ),
        );
      }
    });
  }

  Future<bool> hasCheckinToday(int siteId, DateTime localDate) async {
    final startOfDay = DateTime(localDate.year, localDate.month, localDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final count =
        await (selectOnly(siteCheckins)
              ..addColumns([siteCheckins.id.count()])
              ..where(
                siteCheckins.siteId.equals(siteId) &
                    siteCheckins.checkinDate.isBiggerOrEqualValue(startOfDay) &
                    siteCheckins.checkinDate.isSmallerThanValue(endOfDay),
              ))
            .map((row) => row.read(siteCheckins.id.count()))
            .getSingle();

    return (count ?? 0) > 0;
  }

  // -------------------------------------------------------------------------
  // Vehicles
  // -------------------------------------------------------------------------

  Future<List<Vehicle>> getAllVehicles() {
    return (select(
      vehicles,
    )..orderBy([(t) => OrderingTerm(expression: t.label)])).get();
  }

  Future<String?> getLastUsedVehicleId() async {
    final row = await customSelect('''
      SELECT vehicle_id FROM (
        SELECT vehicle_id, created_at AS used_at FROM pending_checkins
        UNION ALL
        SELECT vehicle_id, checkin_date AS used_at FROM visits
      ) WHERE vehicle_id IS NOT NULL
      ORDER BY used_at DESC LIMIT 1
    ''').getSingleOrNull();
    return row?.read<String>('vehicle_id');
  }

  Future<Vehicle?> getVehicle(String id) {
    return (select(vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertVehicle(VehiclesCompanion vehicle) async {
    await into(vehicles).insertOnConflictUpdate(vehicle);
  }

  Future<void> deleteVehicle(String id) async {
    await (delete(vehicles)..where((t) => t.id.equals(id))).go();
  }

  // -------------------------------------------------------------------------
  // Clear All
  // -------------------------------------------------------------------------

  Future<void> clearAll() async {
    await delete(sites).go();
    await delete(visits).go();
    await delete(pendingCheckins).go();
    await delete(siteCheckins).go();
    await delete(vehicles).go();
    await delete(userSettingsTable).go();
    // Re-create default settings
    await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
  }
}
