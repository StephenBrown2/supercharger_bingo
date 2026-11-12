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

/// A personal visit that has not been accepted by supercharging.life yet.
enum VisitSyncStatus { pending, synced }

/// GitHub and Google, the same providers supercharging.life offers.
enum AuthProvider { github, google }

enum PollingInterval { minutes15, hour1, hours4, hours6, hours12, hours24 }

String pollingIntervalLabel(PollingInterval interval) => switch (interval) {
  PollingInterval.minutes15 => '15 minutes',
  PollingInterval.hour1 => '1 hour',
  PollingInterval.hours4 => '4 hours',
  PollingInterval.hours6 => '6 hours',
  PollingInterval.hours12 => '12 hours',
  PollingInterval.hours24 => '24 hours',
};

/// My Map filters on supercharging.life, in the order that page shows them.
/// Unvisited (Open) is the default. NACS is supercharge.info `otherEVs`.
enum MapFilter {
  openUnvisited,
  all,
  visited,
  unvisitedNacs,
  openUnvisitedConstruction,
}

enum UnitSystem { metric, imperial }

/// Radius slider bounds and setup defaults, in the display unit. Alerts reach
/// far, since an opening is worth a trip. Check-ins only list sites nearby.
typedef RadiusRange = ({double min, double max, double initial});

RadiusRange alertRadiusRange(UnitSystem units) => units == UnitSystem.imperial
    ? (min: 5, max: 2000, initial: 1500)
    : (min: 10, max: 3200, initial: 2400);

RadiusRange checkinRadiusRange(UnitSystem units) => units == UnitSystem.imperial
    ? (min: 1, max: 250, initial: 25)
    : (min: 2, max: 400, initial: 40);

double kmFromDisplay(double value, UnitSystem units) =>
    units == UnitSystem.imperial ? value / 0.621371 : value;

/// One decimal, in the user's units, for lists and notifications.
String formatDistance(double distanceKm, UnitSystem units) {
  if (units == UnitSystem.imperial) {
    return '${(distanceKm * 0.621371).toStringAsFixed(1)} mi';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}

/// Settings > Appearance > Theme. [materialYou] uses the device wallpaper
/// colors and still follows the system light and dark setting.
enum AppAppearance { light, dark, system, materialYou }

/// How much of a check-in the supercharging.life detail actually carries.
/// DATE_ONLY is a calendar date. TIMESTAMP also has a clock time.
enum CheckinPrecision { dateOnly, timestamp }

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

  /// Open to non-Tesla vehicles. supercharging.life calls this NACS.
  BoolColumn get otherEvs => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateOpened => dateTime().nullable()();

  /// Cache of "community check-in count > 0" from the counts endpoint.
  /// getEarliestCheckinDates uses it when the First history has no date.
  BoolColumn get hasCheckins => boolean().withDefault(const Constant(false))();

  /// Whether the current user has visited this site
  BoolColumn get visited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSynced => dateTime().nullable()();
}

/// User's visits (check-ins)
class Visits extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Server-assigned supercharging.life check-in id, kept as that integer.
  /// Null until the site assigns one. Several local rows can be null together.
  IntColumn get checkinId => integer().unique().nullable()();
  IntColumn get siteId => integer()();
  DateTimeColumn get checkinDate => dateTime()();
  DateTimeColumn get checkinTime => dateTime()();

  /// dateOnly when the source had a calendar date and no clock time.
  /// timestamp when check-in detail includes a time, as the live form sends.
  TextColumn get checkinPrecision => textEnum<CheckinPrecision>().withDefault(
    Constant(CheckinPrecision.timestamp.name),
  )();
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

  /// Pending until the unofficial writer accepts the check-in.
  TextColumn get syncStatus => textEnum<VisitSyncStatus>().withDefault(
    Constant(VisitSyncStatus.synced.name),
  )();

  /// Matches [PendingCheckins.id] while this row is still in the outbox.
  IntColumn get pendingId => integer().nullable()();
  DateTimeColumn get importedAt => dateTime()();
}

/// Pending check-ins (offline queue)
class PendingCheckins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer()();
  DateTimeColumn get checkinDate => dateTime()();

  /// dateOnly when the queued value is a calendar date. App check-ins are
  /// timestamp, matching the live form's `date` field.
  TextColumn get checkinPrecision => textEnum<CheckinPrecision>().withDefault(
    Constant(CheckinPrecision.timestamp.name),
  )();
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
  DateTimeColumn get syncedAt => dateTime()();
}

/// Local vehicles (SPEC Section 3). Purely local; never synced. The raw VIN is
/// never stored here: it lives in flutter_secure_storage keyed by [id]. The
/// derived fields are shown on the vehicle. A check-in includes them in the
/// private note only when [UserSettingsTable.includeVehicleInPrivateNote] is on.
class Vehicles extends Table {
  TextColumn get id => text()(); // client-generated UUID
  TextColumn get label => text()(); // required nickname
  TextColumn get make => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get year => text().nullable()();
  TextColumn get trim => text().nullable()();
  BoolColumn get hasVin => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per alert already shown, so a poll does not repeat it.
class NotificationLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get siteId => integer()();
  TextColumn get channel => text()();

  /// Change id for a new site, or the site-local day for a First alert.
  TextColumn get dedupeKey => text()();
  DateTimeColumn get sentAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {siteId, channel, dedupeKey},
  ];
}

/// User settings and authentication state
class UserSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get odUserId => integer().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  BoolColumn get isAuthenticated =>
      boolean().withDefault(const Constant(false))();

  /// GitHub or Google. Set for a live session and for a device-only sign-in.
  TextColumn get authProvider => textEnum<AuthProvider>().nullable()();
  DateTimeColumn get firstLoginAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  /// Set when the first-run setup screens finish. Null shows them again.
  DateTimeColumn get setupCompletedAt => dateTime().nullable()();
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
  TextColumn get appAppearance => textEnum<AppAppearance>().withDefault(
    Constant(AppAppearance.system.name),
  )();

  /// When false, the nearby check-in list hides sites the user has already
  /// visited. Turn on to show those sites with their last visit date.
  BoolColumn get includeVisitedNearby =>
      boolean().withDefault(const Constant(false))();

  /// When true, a check-in that names a vehicle appends year, make, model,
  /// and trim to the private note. The VIN is never included.
  BoolColumn get includeVehicleInPrivateNote =>
      boolean().withDefault(const Constant(false))();

  /// New-site and First-eligible alerts. Both default on.
  BoolColumn get notifyNewSites =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notifyFirstEligible =>
      boolean().withDefault(const Constant(true))();

  /// Highest allChanges id already considered for a new-site alert.
  /// Null until the first poll, which records the cursor and does not alert.
  IntColumn get lastNotifiedChangeId => integer().nullable()();
  RealColumn get lastLatitude => real().nullable()();
  RealColumn get lastLongitude => real().nullable()();
  DateTimeColumn get lastSitesSyncAt => dateTime().nullable()();
  DateTimeColumn get lastCheckinHistorySyncAt => dateTime().nullable()();

  @override
  String get tableName => 'user_settings';
}

/// Per-region supercharge.info sync cursor. [lastChangeId] is the newest
/// change id already reflected in [Sites], so later polls only apply newer
/// allChanges rows for that region.
class RegionSyncs extends Table {
  IntColumn get regionId => integer()();
  IntColumn get lastChangeId => integer().withDefault(const Constant(0))();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {regionId};
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
    RegionSyncs,
    NotificationLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Create database with the given [executor].
  /// Use [connect] from connection/native.dart or connection/web.dart
  /// to get the appropriate executor for the current platform.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 14;

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
        if (from < 7) {
          await m.addColumn(visits, visits.checkinPrecision);
          await m.addColumn(pendingCheckins, pendingCheckins.checkinPrecision);
          await m.createTable(regionSyncs);
        }
        if (from < 8) {
          await m.addColumn(
            userSettingsTable,
            userSettingsTable.includeVehicleInPrivateNote,
          );
          // Older builds stored this choice on each vehicle. Keep it if any
          // vehicle had it on. A fresh vehicles table from an earlier step
          // never had the column.
          final legacy = await customSelect(
            "SELECT 1 AS present FROM pragma_table_info('vehicles') "
            "WHERE name = 'display_opt_in'",
          ).get();
          if (legacy.isNotEmpty) {
            await customStatement(
              'UPDATE user_settings SET include_vehicle_in_private_note = 1 '
              'WHERE EXISTS ('
              'SELECT 1 FROM vehicles WHERE display_opt_in = 1)',
            );
            await customStatement(
              'ALTER TABLE vehicles DROP COLUMN display_opt_in',
            );
          }
        }
        if (from < 9) {
          // Drop unused community columns by rebuilding those tables, and
          // allow a visit to exist before supercharging.life assigns an id.
          await m.alterTable(
            TableMigration(
              visits,
              newColumns: [visits.syncStatus, visits.pendingId],
            ),
          );
          await m.alterTable(TableMigration(siteCheckins));
          final auth = await customSelect(
            "SELECT 1 AS present FROM pragma_table_info('user_settings') "
            "WHERE name = 'auth_provider'",
          ).get();
          if (auth.isEmpty) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.authProvider,
            );
          }
        }
        if (from < 10) {
          // Guards matter when a test replays this step on a database that
          // already has the column from onCreate.
          if (!await _columnExists('sites', 'other_evs')) {
            await m.addColumn(sites, sites.otherEvs);
          }
          // Rows saved before other_evs existed keep the false default.
          // Drop the region cursor so the next sync reloads site pages
          // and fills the flag. Visited state is not part of that payload.
          if (await _tableExists('region_syncs')) {
            await customStatement('DELETE FROM region_syncs');
          }
        }
        if (from < 11) {
          // Guards matter when a test replays this step on a database that
          // already has the columns from onCreate.
          if (!await _columnExists('user_settings', 'notify_new_sites')) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.notifyNewSites,
            );
          }
          if (!await _columnExists('user_settings', 'notify_first_eligible')) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.notifyFirstEligible,
            );
          }
        }
        if (from < 12) {
          // Guards matter when a test replays this step on a database that
          // already has the column and table from onCreate.
          if (!await _columnExists(
            'user_settings',
            'last_notified_change_id',
          )) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.lastNotifiedChangeId,
            );
          }
          if (!await _tableExists('notification_log')) {
            await m.createTable(notificationLog);
          }
        }
        if (from < 13) {
          // Guards matter when a test replays this step on a database that
          // already has the column from onCreate.
          if (!await _columnExists('user_settings', 'app_appearance')) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.appAppearance,
            );
          }
        }
        if (from < 14) {
          if (!await _columnExists('user_settings', 'setup_completed_at')) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.setupCompletedAt,
            );
          }
        }
      },
    );
  }

  Future<bool> _columnExists(String table, String name) async {
    final rows = await customSelect(
      "SELECT 1 AS present FROM pragma_table_info('$table') WHERE name = '$name'",
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT 1 AS present FROM sqlite_master WHERE type = 'table' AND name = '$name'",
    ).get();
    return rows.isNotEmpty;
  }

  /// Insert a dedupe row. Returns false when this alert was already sent.
  Future<bool> claimNotification({
    required int siteId,
    required String channel,
    required String dedupeKey,
  }) async {
    try {
      await into(notificationLog).insert(
        NotificationLogCompanion.insert(
          siteId: siteId,
          channel: channel,
          dedupeKey: dedupeKey,
          sentAt: DateTime.now(),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
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

  /// Unvisited OPEN sites that supercharging.life shows as NACS.
  Future<List<Site>> getUnvisitedNacsSites() {
    return (select(sites)..where(
          (t) =>
              t.status.equals(SiteStatus.open.name) &
              t.visited.equals(false) &
              t.otherEvs.equals(true),
        ))
        .get();
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
    // The First history feed only lists recent Firsts. A site the counts feed
    // says has check-ins already has its First, so fall back to the opening
    // day: passed for an older site, today for one that opened today.
    final missing = siteIds.where((id) => !result.containsKey(id)).toList();
    if (missing.isNotEmpty) {
      final taken =
          await (select(sites)..where(
                (t) => t.siteId.isIn(missing) & t.hasCheckins.equals(true),
              ))
              .get();
      for (final site in taken) {
        result[site.siteId] = site.dateOpened ?? DateTime(2000);
      }
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

  Future<PendingCheckin?> getPendingCheckin(int id) {
    return (select(
      pendingCheckins,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<PendingCheckin>> getPendingCheckins() {
    return (select(
      pendingCheckins,
    )..where((t) => t.status.equals(PendingStatus.pending.name))).get();
  }

  Future<int> addPendingCheckin(PendingCheckinsCompanion checkin) {
    return into(pendingCheckins).insert(checkin);
  }

  Future<void> markPendingVisitSynced(int pendingId) async {
    await (update(visits)..where((t) => t.pendingId.equals(pendingId))).write(
      const VisitsCompanion(syncStatus: Value(VisitSyncStatus.synced)),
    );
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

  Future<RegionSync?> getRegionSync(int regionId) {
    return (select(
      regionSyncs,
    )..where((t) => t.regionId.equals(regionId))).getSingleOrNull();
  }

  Future<void> upsertRegionSync(int regionId, int lastChangeId) async {
    await into(regionSyncs).insert(
      RegionSyncsCompanion.insert(
        regionId: Value(regionId),
        lastChangeId: Value(lastChangeId),
        syncedAt: Value(DateTime.now()),
      ),
      onConflict: DoUpdate(
        (_) => RegionSyncsCompanion(
          lastChangeId: Value(lastChangeId),
          syncedAt: Value(DateTime.now()),
        ),
      ),
    );
  }

  Future<void> clearAll() async {
    await delete(sites).go();
    await delete(visits).go();
    await delete(pendingCheckins).go();
    await delete(siteCheckins).go();
    await delete(vehicles).go();
    await delete(regionSyncs).go();
    await delete(userSettingsTable).go();
    // Re-create default settings
    await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
  }
}
