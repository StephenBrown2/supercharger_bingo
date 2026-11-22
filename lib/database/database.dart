import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart' show Distance, Haversine, LatLng;

part 'database.g.dart';

// ============================================================================
// Enums (stored as text in SQLite)
// ============================================================================

/// supercharge.info status (SPEC Section 2.1). EXPANDING is read as [open],
/// as supercharging.life shows it.
/// No catch-all: sites with an unrecognized status are skipped on ingestion.
enum SiteStatus {
  open,
  construction,
  permit,
  plan,
  voting,
  closedTemp,
  closedPerm,
}

/// Where a Pending Visit's Check-in stands in the Check-in outbox. A Visit
/// supercharging.life has confirmed has no outbox entry at all.
enum OutboxState { waiting, sending, waitingForSignIn }

enum CheckinMethod { gps, manual }

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

/// My Map filters. Names remain stable for stored settings.
/// Tesla EV (Open) is the default; non-Tesla support uses `otherEVs`.
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
    ? (min: 5, max: 3000, initial: 1500)
    : (min: 10, max: 4800, initial: 2400);

RadiusRange checkinRadiusRange(UnitSystem units) => units == UnitSystem.imperial
    ? (min: 1, max: 250, initial: 25)
    : (min: 2, max: 400, initial: 40);

const _milesPerKm = 0.621371;

double kmFromDisplay(double value, UnitSystem units) =>
    units == UnitSystem.imperial ? value / _milesPerKm : value;

/// [km] in the user's units, unrounded.
double displayFromKm(double km, UnitSystem units) =>
    units == UnitSystem.imperial ? km * _milesPerKm : km;

/// One decimal, in the user's units, for lists and notifications.
String formatDistance(double distanceKm, UnitSystem units) {
  if (units == UnitSystem.imperial) {
    return '${displayFromKm(distanceKm, units).toStringAsFixed(1)} mi';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}

const _vincenty = Distance(roundResult: false);
const _haversine = Distance(roundResult: false, calculator: Haversine());

/// Distance on the WGS84 ellipsoid (Vincenty). Nearly antipodal points, where
/// Vincenty cannot converge, fall back to spherical haversine.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  try {
    return _vincenty(LatLng(lat1, lon1), LatLng(lat2, lon2)) / 1000;
  } on StateError {
    return _haversine(LatLng(lat1, lon1), LatLng(lat2, lon2)) / 1000;
  }
}

typedef SiteWithDistance = ({Site site, double distanceKm});

/// [sites] within [radiusKm] of a point, nearest first, at most [limit].
List<SiteWithDistance> nearbySites(
  List<Site> sites,
  double latitude,
  double longitude, {
  required double radiusKm,
  required int limit,
}) {
  final near = <SiteWithDistance>[
    for (final site in sites)
      (
        site: site,
        distanceKm: distanceKm(
          latitude,
          longitude,
          site.latitude,
          site.longitude,
        ),
      ),
  ]..removeWhere((s) => s.distanceKm > radiusKm);
  near.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return near.take(limit).toList();
}

/// Settings > Appearance > Theme. [materialYou] uses the device wallpaper
/// colors and still follows the system light and dark setting.
enum AppAppearance { light, dark, system, materialYou }

/// How much of a check-in the supercharging.life detail actually carries.
/// DATE_ONLY is a calendar date. TIMESTAMP also has a clock time.
enum CheckinPrecision { dateOnly, timestamp }

extension SiteOpening on Site {
  /// Earliest available opening evidence, never a later reopening.
  /// Upstream dates can still need correction to the actual first local day.
  DateTime? get firstOpeningDay {
    final history = firstOpened;
    final listed = dateOpened;
    if (history == null) return listed;
    if (listed == null || history.isBefore(listed)) return history;
    return listed;
  }
}

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
  TextColumn get street => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('Unknown'))();
  TextColumn get region => text().withDefault(const Constant('Unknown'))();

  /// IANA timezone derived from coordinates at ingestion (SPEC Section 3).
  /// Drives the site-local "First" day boundary.
  TextColumn get timezone => text().nullable()();
  IntColumn get stallCount => integer().nullable()();
  IntColumn get stallsV2 => integer().withDefault(const Constant(0))();
  IntColumn get stallsV3 => integer().withDefault(const Constant(0))();
  IntColumn get stallsV4 => integer().withDefault(const Constant(0))();
  IntColumn get stallsUrban => integer().withDefault(const Constant(0))();
  IntColumn get stallsOther => integer().withDefault(const Constant(0))();

  /// Open to non-Tesla vehicles.
  BoolColumn get otherEvs => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateOpened => dateTime().nullable()();

  /// Earliest OPEN transition observed in supercharge.info change history.
  /// Unlike dateOpened, this survives a later closure and reopening.
  DateTimeColumn get firstOpened => dateTime().nullable()();

  /// Cache of "community check-in count > 0" from the counts endpoint.
  /// Only undated operational sites use it as a conservative taken fallback.
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
  DateTimeColumn get importedAt => dateTime()();
}

/// Check-in outbox: sending data for a Pending Visit. The Visit holds the
/// Check-in itself; the entry is deleted once supercharging.life confirms it.
class OutboxEntries extends Table {
  IntColumn get visitId => integer()();
  TextColumn get state =>
      textEnum<OutboxState>().withDefault(Constant(OutboxState.waiting.name))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracy => real().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {visitId};
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

  /// GitHub or Google. Set for a live session and for a device-only use.
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
  BoolColumn get clusterMarkers =>
      boolean().withDefault(const Constant(true))();
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

  /// Android: an ongoing Live Update with the distance to the nearest
  /// unvisited site while the app runs. Construction sites are opt-in.
  BoolColumn get nearestSiteLiveUpdate =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get nearestSiteIncludeConstruction =>
      boolean().withDefault(const Constant(false))();

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
    OutboxEntries,
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
  int get schemaVersion => 23;

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
          await customStatement(
            'ALTER TABLE pending_checkins ADD COLUMN checkin_precision '
            "TEXT NOT NULL DEFAULT 'timestamp'",
          );
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
          // The v9 outbox link columns are gone from the schema since v20, so
          // older databases skip them and lose any queued rows (no users yet).
          await m.alterTable(TableMigration(visits));
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
        if (from < 15 && to >= 15) {
          // The old Mark Visited button set the flag with no check-in behind
          // it. Visited now always means a visit row exists.
          await clearVisitedWithoutVisits();
        }
        if (from < 16 &&
            to >= 16 &&
            !await _columnExists('user_settings', 'cluster_markers')) {
          await m.addColumn(
            userSettingsTable,
            userSettingsTable.clusterMarkers,
          );
        }
        if (from < 17 && to >= 17) {
          if (!await _columnExists(
            'user_settings',
            'nearest_site_live_update',
          )) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.nearestSiteLiveUpdate,
            );
          }
          if (!await _columnExists(
            'user_settings',
            'nearest_site_include_construction',
          )) {
            await m.addColumn(
              userSettingsTable,
              userSettingsTable.nearestSiteIncludeConstruction,
            );
          }
        }
        if (from < 18 && to >= 18) {
          if (!await _columnExists('sites', 'first_opened')) {
            await m.addColumn(sites, sites.firstOpened);
          }
          // Backfill original openings once, using the existing regional sync.
          await customStatement('UPDATE region_syncs SET last_change_id = 0');
          // Older imports stored date-only values as device-local midnight.
          // Re-encode their calendar day, leaving all visit clocks untouched.
          for (final (table, column) in [
            ('sites', 'date_opened'),
            ('site_checkins', 'checkin_date'),
          ]) {
            final rows = await customSelect(
              'SELECT id, $column AS calendar_date FROM $table '
              'WHERE $column IS NOT NULL',
            ).get();
            for (final row in rows) {
              final date = row.read<DateTime>('calendar_date');
              if (date.hour != 0 ||
                  date.minute != 0 ||
                  date.second != 0 ||
                  date.millisecond != 0 ||
                  date.microsecond != 0) {
                continue;
              }
              await customUpdate(
                'UPDATE $table SET $column = ? WHERE id = ?',
                variables: [
                  Variable(DateTime.utc(date.year, date.month, date.day)),
                  Variable(row.read<int>('id')),
                ],
              );
            }
          }
        }
        if (from < 19 && to >= 19) {
          for (final column in [
            sites.stallsV2,
            sites.stallsV3,
            sites.stallsV4,
            sites.stallsUrban,
            sites.stallsOther,
          ]) {
            if (!await _columnExists('sites', column.name)) {
              await m.addColumn(sites, column);
            }
          }
          // Reload cached sites once to populate their stall types.
          await customStatement('DELETE FROM region_syncs');
        }
        if (from < 20 && to >= 20) {
          // The Check-in outbox replaces pending_checkins. The Visit keeps the
          // Check-in; the entry keeps only sending data. supercharging.life
          // does not refuse check-ins, so failed rows are sent again.
          if (!await _tableExists('outbox_entries')) {
            await m.createTable(outboxEntries);
          }
          if (await _tableExists('pending_checkins') &&
              await _columnExists('visits', 'pending_id')) {
            await customStatement('''
              INSERT OR IGNORE INTO outbox_entries (visit_id, state, latitude,
                longitude, accuracy, attempts, last_attempt_at, last_error)
              SELECT v.id,
                CASE
                  WHEN p.status = 'submitting' THEN 'sending'
                  WHEN p.last_error IN ('Sign in to supercharging.life again',
                    'Waiting for supercharging.life sign-in')
                    THEN 'waitingForSignIn'
                  ELSE 'waiting'
                END,
                p.latitude, p.longitude, p.accuracy,
                CASE WHEN p.status = 'failed' THEN 0 ELSE p.attempts END,
                CASE WHEN p.status = 'failed' THEN NULL
                  ELSE p.last_attempt_at END,
                CASE WHEN p.status = 'failed' THEN NULL ELSE p.last_error END
              FROM visits v JOIN pending_checkins p ON p.id = v.pending_id
              WHERE p.status != 'completed' AND v.sync_status = 'pending'
            ''');
          }
          await customStatement('DROP TABLE IF EXISTS pending_checkins');
          if (await _columnExists('visits', 'pending_id') ||
              await _columnExists('visits', 'sync_status')) {
            await m.alterTable(TableMigration(visits));
          }
        }
        if (from < 21 && to >= 21) {
          // EXPANDING is read as OPEN now, as supercharging.life shows it.
          await customStatement(
            "UPDATE sites SET status = 'open' WHERE status = 'expanding'",
          );
        }
        if (from < 22 && to >= 22) {
          // The Live Update shows the street. Site sync only fetches changed
          // sites, so forget the cursors to reload every site once.
          if (!await _columnExists('sites', 'street')) {
            await m.addColumn(sites, sites.street);
          }
          await delete(regionSyncs).go();
        }
        if (from < 23 &&
            to >= 23 &&
            await _columnExists('user_settings', 'is_authenticated')) {
          await customStatement(
            'ALTER TABLE user_settings DROP COLUMN is_authenticated',
          );
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

  /// Sites, narrowed by [status] and [visited] when given.
  Future<List<Site>> getSites({SiteStatus? status, bool? visited}) {
    final query = select(sites);
    if (status != null) query.where((t) => t.status.equals(status.name));
    if (visited != null) query.where((t) => t.visited.equals(visited));
    return query.get();
  }

  /// Unvisited OPEN sites, plus CONSTRUCTION when asked.
  Future<List<Site>> unvisitedSites({required bool includeConstruction}) {
    final statuses = [
      SiteStatus.open.name,
      if (includeConstruction) SiteStatus.construction.name,
    ];
    return (select(
      sites,
    )..where((t) => t.status.isIn(statuses) & t.visited.equals(false))).get();
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

  /// Evidence for the First rule at [siteIds]: Community history in check-in
  /// order, and the user's confirmed Visits (those without an outbox entry).
  Future<({Map<int, List<SiteCheckin>> history, Map<int, List<Visit>> visits})>
  getFirstEvidence(List<int> siteIds) async {
    final history = <int, List<SiteCheckin>>{};
    final confirmed = <int, List<Visit>>{};
    if (siteIds.isEmpty) return (history: history, visits: confirmed);
    final rows =
        await (select(siteCheckins)
              ..where((t) => t.siteId.isIn(siteIds))
              ..orderBy([
                (t) => OrderingTerm.asc(t.checkinDate),
                (t) => OrderingTerm.asc(t.checkinTime),
                (t) => OrderingTerm.asc(t.checkinId),
              ]))
            .get();
    for (final row in rows) {
      (history[row.siteId] ??= []).add(row);
    }
    final visitRows =
        await (select(visits).join([
              leftOuterJoin(
                outboxEntries,
                outboxEntries.visitId.equalsExp(visits.id),
              ),
            ])..where(
              visits.siteId.isIn(siteIds) & outboxEntries.visitId.isNull(),
            ))
            .get();
    for (final row in visitRows) {
      final visit = row.readTable(visits);
      (confirmed[visit.siteId] ??= []).add(visit);
    }
    return (history: history, visits: confirmed);
  }

  Future<void> recordFirstOpeningDates(Map<int, DateTime> dates) async {
    await transaction(() async {
      for (final entry in dates.entries) {
        await (update(sites)..where(
              (t) =>
                  t.siteId.equals(entry.key) &
                  (t.firstOpened.isNull() |
                      t.firstOpened.isBiggerThanValue(entry.value)),
            ))
            .write(SitesCompanion(firstOpened: Value(entry.value)));
      }
    });
  }

  Future<Site?> getSiteBySiteId(int siteId) {
    return (select(
      sites,
    )..where((t) => t.siteId.equals(siteId))).getSingleOrNull();
  }

  Future<void> upsertSite(SitesCompanion site) => upsertSites([site]);

  Insertable<Site> _siteUpdate(SitesCompanion site, $SitesTable old) {
    return RawValuesInsertable({
      ...site.toColumns(false),
      if (!site.firstOpened.present)
        'first_opened': CaseWhenExpression(
          cases: [
            CaseWhen(
              old.firstOpened.isNull() |
                  (old.dateOpened.isNotNull() &
                      old.dateOpened.isSmallerThan(old.firstOpened)),
              then: old.dateOpened,
            ),
          ],
          orElse: old.firstOpened,
        ),
    });
  }

  Future<void> upsertSites(List<SitesCompanion> siteList) =>
      transaction(() async {
        await batch((batch) {
          for (final site in siteList) {
            batch.insert(
              sites,
              site,
              onConflict: DoUpdate(
                ($SitesTable old) => _siteUpdate(site, old),
                target: [sites.siteId],
              ),
            );
          }
        });
        // First-run import can save Visits before their Sites are downloaded.
        await customUpdate(
          'UPDATE sites SET visited = 1 WHERE visited = 0 '
          'AND site_id IN (SELECT site_id FROM visits)',
          updates: {sites},
        );
      });

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

  Future<void> clearVisitedWithoutVisits() => customStatement(
    'UPDATE sites SET visited = 0 WHERE visited = 1 AND NOT EXISTS '
    '(SELECT 1 FROM visits v WHERE v.site_id = sites.site_id)',
  );

  /// Drop a local visit and its outbox entry after any server deletion
  /// succeeds. The site stays visited only if another visit remains.
  Future<void> deleteVisit(Visit visit) => transaction(() async {
    await (delete(visits)..where((t) => t.id.equals(visit.id))).go();
    await (delete(
      outboxEntries,
    )..where((t) => t.visitId.equals(visit.id))).go();
    if (visit.checkinId != null) {
      await (delete(
        siteCheckins,
      )..where((t) => t.checkinId.equals(visit.checkinId!))).go();
    }
    await clearVisitedWithoutVisits();
  });

  Future<List<Visit>> getVisitsBySiteId(int siteId) {
    return (select(visits)..where((t) => t.siteId.equals(siteId))).get();
  }

  Future<int> getVisitCount() async {
    final count = await (selectOnly(visits)..addColumns([visits.id.count()]))
        .map((row) => row.read(visits.id.count()))
        .getSingle();
    return count ?? 0;
  }

  /// Latest Visit at [siteId], Pending ones included.
  Future<DateTime?> getLastVisitDate(int siteId) async {
    final visit =
        await (select(visits)
              ..where((t) => t.siteId.equals(siteId))
              ..orderBy([(t) => OrderingTerm.desc(t.checkinDate)])
              ..limit(1))
            .getSingleOrNull();
    return visit?.checkinDate;
  }

  /// The user's most recent Visit date per Site, for those of [siteIds] with
  /// one. One grouped query; no IN list, so thousands of ids are fine.
  Future<Map<int, DateTime>> getLastVisitDates(List<int> siteIds) async {
    if (siteIds.isEmpty) return {};
    final wanted = siteIds.toSet();
    final last = visits.checkinDate.max();
    final rows =
        await (selectOnly(visits)
              ..addColumns([visits.siteId, last])
              ..groupBy([visits.siteId]))
            .get();
    return {
      for (final row in rows)
        if (wanted.contains(row.read(visits.siteId)))
          row.read(visits.siteId)!: row.read(last)!,
    };
  }

  /// Record the id supercharging.life gave a Visit's Check-in, unless another
  /// Visit already holds it. Returns the Visit that holds the id afterwards,
  /// or null if neither Visit exists.
  Future<int?> attachCheckinId(int visitId, int checkinId) => transaction(
    () async {
      final holder = await (select(
        visits,
      )..where((t) => t.checkinId.equals(checkinId))).getSingleOrNull();
      if (holder != null) return holder.id;
      final written = await (update(visits)..where((t) => t.id.equals(visitId)))
          .write(VisitsCompanion(checkinId: Value(checkinId)));
      return written == 0 ? null : visitId;
    },
  );

  /// Attach IDs only for unique matches in both the local and server history.
  ///
  /// A Visit still Sending that matches was confirmed by supercharging.life
  /// before its send finished (the app was killed), so its outbox entry is
  /// deleted and it is not sent again. Other Pending Visits are not on
  /// supercharging.life and never match.
  Future<void> reconcileVisitIds(List<VisitsCompanion> imported) => transaction(
    () async {
      final local = await getAllVisits();
      final entries = {
        for (final e in await select(outboxEntries).get()) e.visitId: e,
      };
      final knownIds = local.map((v) => v.checkinId).whereType<int>().toSet();
      (int, int) key(int siteId, DateTime time) =>
          (siteId, time.millisecondsSinceEpoch ~/ 1000);
      // Date-only rows cannot distinguish visits on the same day safely.
      final unmatched = local
          .where(
            (v) =>
                v.checkinId == null &&
                (entries[v.id] == null ||
                    entries[v.id]!.state == OutboxState.sending) &&
                v.checkinPrecision == CheckinPrecision.timestamp,
          )
          .toList();
      for (final row in unmatched) {
        // App-created rows preserve the submitted instant in checkinDate.
        final rowKey = key(row.siteId, row.checkinDate);
        final candidates = imported
            .where(
              (v) =>
                  v.checkinId.present &&
                  (v.checkinId.value ?? 0) > 0 &&
                  (!v.checkinPrecision.present ||
                      v.checkinPrecision.value == CheckinPrecision.timestamp) &&
                  key(v.siteId.value, v.checkinTime.value) == rowKey,
            )
            .toList();
        final localMatches = unmatched.where(
          (v) => key(v.siteId, v.checkinDate) == rowKey,
        );
        if (candidates.length == 1 &&
            localMatches.length == 1 &&
            !knownIds.contains(candidates.single.checkinId.value)) {
          await (update(visits)..where((t) => t.id.equals(row.id))).write(
            VisitsCompanion(checkinId: candidates.single.checkinId),
          );
          await (delete(
            outboxEntries,
          )..where((t) => t.visitId.equals(row.id))).go();
        }
      }
    },
  );

  /// Store a Visit and mark its Site visited, together.
  Future<void> addVisit(VisitsCompanion visit) => transaction(() async {
    // Upsert on the supercharging.life check-in id so re-importing the XLSX
    // (or rows already present) refreshes instead of violating the unique
    // constraint on visits.checkin_id.
    await into(visits).insert(
      visit,
      onConflict: DoUpdate((_) => visit, target: [visits.checkinId]),
    );
    await markSiteVisited(visit.siteId.value, true);
  });

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
      SELECT vehicle_id FROM visits WHERE vehicle_id IS NOT NULL
      ORDER BY checkin_date DESC LIMIT 1
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
    await delete(outboxEntries).go();
    await delete(siteCheckins).go();
    await delete(vehicles).go();
    await delete(regionSyncs).go();
    await delete(userSettingsTable).go();
    // Re-create default settings
    await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
  }

  /// Wipe everything that can be downloaded again. Pending Visits, their
  /// outbox entries and their Sites stay, since supercharging.life has no
  /// copy. Returns how many Pending Visits were kept.
  Future<int> resetKeepingPending() => transaction(() async {
    await customUpdate(
      'DELETE FROM visits WHERE id NOT IN (SELECT visit_id FROM outbox_entries)',
      updates: {visits},
      updateKind: UpdateKind.delete,
    );
    await customUpdate(
      'DELETE FROM sites WHERE site_id NOT IN (SELECT site_id FROM visits)',
      updates: {sites},
      updateKind: UpdateKind.delete,
    );
    await delete(siteCheckins).go();
    await delete(vehicles).go();
    await delete(regionSyncs).go();
    await delete(userSettingsTable).go();
    await into(userSettingsTable).insert(UserSettingsTableCompanion.insert());
    return (await select(outboxEntries).get()).length;
  });
}
