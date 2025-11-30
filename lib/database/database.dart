import 'package:drift/drift.dart';

part 'database.g.dart';

// ============================================================================
// Enums (stored as text in SQLite)
// ============================================================================

enum SiteStatus { open, construction, permit, planned, closed, unknown }

enum PendingStatus { pending, submitting, failed, completed }

enum CheckinMethod { gps, manual }

enum PollingInterval { minutes15, hour1, hours4, hours6, hours12, hours24 }

enum MapFilter { openUnvisited, openUnvisitedConstruction, all }

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
      textEnum<SiteStatus>().withDefault(Constant(SiteStatus.unknown.name))();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  TextColumn get street => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get zip => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('Unknown'))();
  TextColumn get region => text().withDefault(const Constant('Unknown'))();
  IntColumn get stallCount => integer().nullable()();
  IntColumn get powerKilowatt => integer().nullable()();
  IntColumn get stallsV2 => integer().nullable()();
  IntColumn get stallsV3 => integer().nullable()();
  IntColumn get stallsV4 => integer().nullable()();
  DateTimeColumn get dateOpened => dateTime().nullable()();

  /// Whether this site has any check-ins from any user (false = first eligible)
  BoolColumn get hasCheckins => boolean().withDefault(const Constant(false))();

  /// Whether the current user has visited this site
  BoolColumn get visited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSynced => dateTime().nullable()();
}

/// User's visits (check-ins)
class Visits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get checkinId => integer().unique()();
  IntColumn get siteId => integer()();
  DateTimeColumn get checkinDate => dateTime()();
  DateTimeColumn get checkinTime => dateTime()();
  BoolColumn get isFirst => boolean().withDefault(const Constant(false))();
  TextColumn get method => textEnum<CheckinMethod>().withDefault(
    Constant(CheckinMethod.manual.name),
  )();
  TextColumn get notesPublic => text().nullable()();
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
      textEnum<UnitSystem>().withDefault(Constant(UnitSystem.metric.name))();
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
  tables: [Sites, Visits, PendingCheckins, SiteCheckins, UserSettingsTable],
)
class AppDatabase extends _$AppDatabase {
  /// Create database with the given [executor].
  /// Use [connect] from connection/native.dart or connection/web.dart
  /// to get the appropriate executor for the current platform.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

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
      SitesCompanion(visited: Value(visited), hasCheckins: const Value(true)),
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
    return visit?.checkinDate;
  }

  Future<void> addVisit(VisitsCompanion visit) async {
    await into(visits).insert(visit);
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
          onConflict: DoUpdate((old) => checkin),
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
  // Clear All
  // -------------------------------------------------------------------------

  Future<void> clearAll() async {
    await delete(sites).go();
    await delete(visits).go();
    await delete(pendingCheckins).go();
    await delete(siteCheckins).go();
    await delete(userSettingsTable).go();
    // Re-create default settings
    await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
  }
}
