import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import '../models/supercharge_info.dart';
import 'alert_rules.dart';
import 'api_service.dart';
import 'checkin_form.dart';
import 'checkin_rules.dart';
import 'checkin_writer.dart';
import 'database_service.dart';
import 'life_time.dart';
import 'location_service.dart';
import 'supercharge_region.dart';
import 'timezone_service.dart';
import 'write_result.dart';

typedef LocationFix = ({double latitude, double longitude});

/// Service for syncing data between local database and remote APIs
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService();

  /// Bumped whenever community check-in data finishes syncing, so screens can
  /// recompute First state (pin colours) once the data lands.
  final ValueNotifier<int> communityDataVersion = ValueNotifier(0);

  /// Bumped when a region site sync finishes, so a map that read the site
  /// table before those rows existed can load them.
  final ValueNotifier<int> sitesVersion = ValueNotifier(0);

  /// Bumped when a pending check-in cannot post because the session is gone.
  final ValueNotifier<int> sessionExpiredVersion = ValueNotifier(0);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncingSites = false;
  bool _isSyncingCheckinHistory = false;
  bool _isSyncingCheckinCounts = false;
  bool _isSyncingUser = false;

  final ApiService _apiService;
  final CheckinWriter? _checkinWriter;
  final Future<LocationFix?> Function() _locate;

  SyncService({
    ApiService? apiService,
    CheckinWriter? checkinWriter,
    Future<LocationFix?> Function()? locate,
  }) : _apiService = apiService ?? ApiService.instance,
       _checkinWriter = checkinWriter,
       _locate = locate ?? SyncService.deviceLocation;

  CheckinWriter get _writer =>
      _checkinWriter ?? UnofficialCheckinWriter(_apiService);

  static Future<LocationFix?> deviceLocation() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (position == null) return null;
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Initialize sync service and listen for connectivity changes
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        // We have connectivity, try to sync pending check-ins
        syncPendingCheckins();
      }
    });
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check if we have network connectivity
  Future<bool> hasConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Sync the user's region from supercharge.info.
  ///
  /// The first pull pages `/sites` and opening history for that region.
  /// Later pulls apply only newer `/changes` rows. With no fix and
  /// no stored location, this does not download the full site list.
  Future<void> syncSites({double? latitude, double? longitude}) async {
    if (_isSyncingSites) return;
    _isSyncingSites = true;
    var started = false;

    try {
      final fix = await _resolveFix(latitude, longitude);
      if (fix == null) return;
      started = true;

      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(
          lastLatitude: Value(fix.latitude),
          lastLongitude: Value(fix.longitude),
        ),
      );

      final regionId = SuperchargeRegion.forCoordinates(
        fix.latitude,
        fix.longitude,
      );
      await _syncRegion(regionId);

      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(lastSitesSyncAt: Value(DateTime.now())),
      );
    } finally {
      _isSyncingSites = false;
      if (started) sitesVersion.value++;
    }
  }

  Future<LocationFix?> _resolveFix(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      return (latitude: latitude, longitude: longitude);
    }
    final fresh = await _locate();
    if (fresh != null) return fresh;
    final settings = await DatabaseService.getUserSettings();
    final storedLat = settings.lastLatitude;
    final storedLon = settings.lastLongitude;
    if (storedLat != null && storedLon != null) {
      return (latitude: storedLat, longitude: storedLon);
    }
    return null;
  }

  Future<void> _syncRegion(int regionId) async {
    final existing = await DatabaseService.getRegionSync(regionId);
    if (existing == null) {
      await _loadRegionSites(regionId);
      final maxApplied = await _applyNewerChanges(regionId, 0);
      await DatabaseService.upsertRegionSync(regionId, maxApplied);
      return;
    }

    final maxApplied = await _applyNewerChanges(
      regionId,
      existing.lastChangeId,
    );
    await DatabaseService.upsertRegionSync(regionId, maxApplied);
  }

  Future<void> _loadRegionSites(int regionId) async {
    var start = 0;
    while (true) {
      final page = await _apiService.fetchSitesPage(
        regionId: regionId,
        start: start,
        length: ApiService.sitePageLength,
      );
      if (page.results.isEmpty) return;
      await DatabaseService.upsertSites(page.results);
      start += page.results.length;
      if (page.results.length < ApiService.sitePageLength) return;
      if (start >= page.recordCount) return;
    }
  }

  /// Apply change rows newer than [cursor], newest page first, but only the
  /// newest embedded site for each site id so an older page cannot overwrite it.
  Future<int> _applyNewerChanges(int regionId, int cursor) async {
    var start = 0;
    var maxId = cursor;
    final seenSites = <int>{};
    while (true) {
      final page = await _apiService.fetchChangesPage(
        regionId: regionId,
        start: start,
        length: ApiService.changePageLength,
      );
      if (page.results.isEmpty) return maxId;

      final batch = <SitesCompanion>[];
      final openings = <int, DateTime>{};
      var reachedCursor = false;
      for (final change in page.results) {
        if (change.id <= cursor) {
          reachedCursor = true;
          continue;
        }
        if (change.id > maxId) maxId = change.id;
        if (seenSites.add(change.siteId)) {
          batch.add(ApiService.companionFor(change.site));
        }
        if (change.siteStatus == Status.OPEN &&
            change.prevStatus != Status.OPEN) {
          final day = DateTime.utc(
            change.date.year,
            change.date.month,
            change.date.day,
          );
          final previous = openings[change.siteId];
          if (previous == null || day.isBefore(previous)) {
            openings[change.siteId] = day;
          }
        }
      }
      if (batch.isNotEmpty) {
        await DatabaseService.upsertSites(batch);
      }
      if (openings.isNotEmpty) {
        await DatabaseService.db.recordFirstOpeningDates(openings);
      }
      if (reachedCursor || page.results.length < ApiService.changePageLength) {
        return maxId;
      }
      start += page.results.length;
      if (start >= page.recordCount) return maxId;
    }
  }

  /// Sync check-in history from supercharging.life
  Future<void> syncCheckinHistory() async {
    if (_isSyncingCheckinHistory) return;
    _isSyncingCheckinHistory = true;

    try {
      final checkins = await _apiService.fetchCheckinHistory();
      await DatabaseService.upsertSiteCheckins(checkins);

      // Mark sites that have check-ins (not first eligible)
      final siteIdsWithCheckins = checkins
          .map((c) => c.siteId.value)
          .toSet()
          .toList();
      await DatabaseService.markSitesHaveCheckins(siteIdsWithCheckins);

      // Update last sync time
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(
          lastCheckinHistorySyncAt: Value(DateTime.now()),
        ),
      );
    } finally {
      _isSyncingCheckinHistory = false;
    }
  }

  /// Sync the community First data used to colour pins: the check-in history
  /// (drives first_date) and the per-site check-in counts (drives hasCheckins).
  /// Best-effort: the unofficial endpoints are fragile, so failures are logged
  /// and swallowed rather than blocking startup or the periodic sync.
  Future<void> syncCommunityData() async {
    try {
      await syncCheckinHistory();
    } catch (e) {
      debugPrint('syncCommunityData: check-in history failed: $e');
    }
    try {
      await syncSuperchargerCheckinCounts();
    } catch (e) {
      debugPrint('syncCommunityData: check-in counts failed: $e');
    }
    // Notify listeners (e.g. the map) to recompute pin colours.
    communityDataVersion.value++;
  }

  /// Sync supercharger check-in counts from supercharging.life.
  /// Sets the hasCheckins cache when the community count is above zero.
  /// First eligibility is computed from check-in dates, not from this flag.
  Future<void> syncSuperchargerCheckinCounts() async {
    if (_isSyncingCheckinCounts) {
      debugPrint('syncSuperchargerCheckinCounts: Already syncing, skipping');
      return;
    }
    _isSyncingCheckinCounts = true;
    debugPrint('syncSuperchargerCheckinCounts: Starting');

    try {
      final checkinCounts = await _apiService.fetchSuperchargerCheckinCounts();
      debugPrint(
        'syncSuperchargerCheckinCounts: Got ${checkinCounts.length} total sites from API',
      );

      // Sites with checkin_count > 0 have been visited by someone
      final siteIdsWithCheckins = checkinCounts.entries
          .where((e) => e.value > 0)
          .map((e) => e.key)
          .toList();

      debugPrint(
        'syncSuperchargerCheckinCounts: ${siteIdsWithCheckins.length} sites have check-ins',
      );
      if (siteIdsWithCheckins.isNotEmpty) {
        debugPrint(
          'syncSuperchargerCheckinCounts: First few site IDs with check-ins: ${siteIdsWithCheckins.take(10).toList()}',
        );
      }

      await DatabaseService.markSitesHaveCheckins(siteIdsWithCheckins);
      // A newly opened site's premature First can be absent from the recent
      // feed. Check it directly throughout its possible site-local First day.
      final now = DateTime.now().toUtc();
      final yesterday = DateTime.utc(now.year, now.month, now.day - 1);
      for (final site in await DatabaseService.db.getAllSites()) {
        final opened = site.firstOpeningDay?.toUtc();
        if (site.status != SiteStatus.open ||
            (checkinCounts[site.siteId] ?? 0) == 0 ||
            opened == null ||
            opened.isBefore(yesterday)) {
          continue;
        }
        try {
          await DatabaseService.upsertSiteCheckins(
            await _apiService.fetchCheckinHistory(siteId: site.siteId),
          );
        } catch (e) {
          debugPrint('Site First history failed for ${site.siteId}: $e');
        }
      }
      debugPrint('syncSuperchargerCheckinCounts: Database updated');
    } catch (e, stack) {
      debugPrint('syncSuperchargerCheckinCounts: Error: $e');
      debugPrint('syncSuperchargerCheckinCounts: Stack: $stack');
      rethrow;
    } finally {
      _isSyncingCheckinCounts = false;
      debugPrint('syncSuperchargerCheckinCounts: Completed');
    }
  }

  /// Look up user by username and sync their check-in history
  Future<bool> syncUserByUsername(String username) async {
    if (_isSyncingUser) {
      debugPrint('syncUserByUsername: Already syncing, skipping');
      return false;
    }
    _isSyncingUser = true;
    debugPrint('syncUserByUsername: Starting for $username');

    try {
      // Find user by username
      final userData = await _apiService.fetchUserByUsername(username);
      if (userData == null) {
        debugPrint('syncUserByUsername: User not found: $username');
        return false; // User not found
      }

      final userId = int.tryParse(userData['user_id']?.toString() ?? '');
      if (userId == null) {
        debugPrint('syncUserByUsername: Invalid user ID for: $username');
        return false;
      }

      debugPrint('syncUserByUsername: Found user: $username (ID: $userId)');

      // Save user info to settings - mark as authenticated since we found them
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(
          odUserId: Value(userId),
          username: Value(username),
          displayName: Value(userData['displayname'] as String?),
          isAuthenticated: const Value(true),
          lastLoginAt: Value(DateTime.now()),
        ),
      );

      // Download and parse user's XLSX to get their visits
      debugPrint('syncUserByUsername: Downloading XLSX for user $userId');
      final xlsxBytes = await _apiService.downloadUserXlsx(userId);
      debugPrint('syncUserByUsername: Got ${xlsxBytes.length} bytes');

      final visits = await _parseUserXlsx(xlsxBytes);
      debugPrint('syncUserByUsername: Parsed ${visits.length} visits');
      await DatabaseService.db.reconcileVisitIds(visits);

      // Mark sites as visited by user
      for (final visit in visits) {
        await DatabaseService.addVisit(visit);
        await DatabaseService.markSiteVisited(visit.siteId.value, true);
      }
      debugPrint(
        'syncUserByUsername: Marked ${visits.length} sites as visited',
      );

      // Update last sync time
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(lastXlsxSyncAt: Value(DateTime.now())),
      );

      debugPrint('syncUserByUsername: Completed successfully');
      return true;
    } finally {
      _isSyncingUser = false;
    }
  }

  /// Parse user XLSX export to extract visits
  Future<List<VisitsCompanion>> _parseUserXlsx(List<int> bytes) async {
    try {
      final excel = Excel.decodeBytes(Uint8List.fromList(bytes));
      final visits = <VisitsCompanion>[];

      // Assume first sheet contains the data
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];
      if (sheet == null) return visits;

      // Find column indices from header row
      final headers = <String, int>{};
      if (sheet.maxRows > 0) {
        for (var i = 0; i < sheet.maxColumns; i++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
          );
          if (cell.value != null) {
            headers[cell.value.toString().toLowerCase()] = i;
          }
        }
      }

      // Map column names (adjust based on actual XLSX format)
      final checkinIdCol = headers['checkin_id'] ?? headers['id'] ?? -1;
      final siteIdCol = headers['supercharger_id'] ?? headers['site_id'] ?? -1;
      final dateCol = headers['checkin_date'] ?? headers['date'] ?? -1;
      final timeCol = headers['checkin_time'] ?? headers['time'] ?? -1;
      final firstCol =
          headers['is_first_at_supercharger'] ??
          headers['is_first'] ??
          headers['first'] ??
          -1;
      final methodCol = headers['method'] ?? headers['checkin_method'] ?? -1;

      // Parse data rows
      for (var row = 1; row < sheet.maxRows; row++) {
        try {
          int checkinId = 0;
          int siteId = 0;
          DateTime checkinDate = DateTime.now();
          DateTime checkinTime = DateTime.now();
          var precision = CheckinPrecision.dateOnly;
          bool isFirst = false;
          CheckinMethod method = CheckinMethod.manual;

          if (checkinIdCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(
                columnIndex: checkinIdCol,
                rowIndex: row,
              ),
            );
            checkinId = int.tryParse(cell.value?.toString() ?? '') ?? 0;
          }

          if (siteIdCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: siteIdCol, rowIndex: row),
            );
            siteId = int.tryParse(cell.value?.toString() ?? '') ?? 0;
          }

          if (dateCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: dateCol, rowIndex: row),
            );
            final dateValue = cell.value;
            if (dateValue != null) {
              final dateStr = dateValue.toString();
              checkinDate = DateTime.tryParse(dateStr) ?? DateTime.now();
            }
          }

          if (timeCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: timeCol, rowIndex: row),
            );
            final timeValue = cell.value;
            final timeStr = timeValue?.toString().trim() ?? '';
            final parsed = timeStr.isEmpty ? null : parseLifeTimestamp(timeStr);
            if (parsed != null) {
              checkinTime = parsed;
              precision = CheckinPrecision.timestamp;
            } else {
              checkinTime = checkinDate;
            }
          } else {
            checkinTime = checkinDate;
          }

          if (firstCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: firstCol, rowIndex: row),
            );
            final val = cell.value?.toString().toLowerCase();
            isFirst = val == 'y' || val == 'yes' || val == 'true' || val == '1';
          }

          if (methodCol >= 0) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: methodCol, rowIndex: row),
            );
            final val = cell.value?.toString().toLowerCase();
            method = val == 'gps' ? CheckinMethod.gps : CheckinMethod.manual;
          }

          if (siteId > 0) {
            visits.add(
              VisitsCompanion(
                checkinId: checkinId > 0
                    ? Value(checkinId)
                    : const Value.absent(),
                siteId: Value(siteId),
                checkinDate: Value(checkinDate),
                checkinTime: Value(checkinTime),
                checkinPrecision: Value(precision),
                isFirst: Value(isFirst),
                method: Value(method),
                importedAt: Value(DateTime.now()),
              ),
            );
          }
        } catch (_) {
          // Skip malformed rows
        }
      }

      return visits;
    } catch (e) {
      return [];
    }
  }

  /// Submit a check-in, queueing offline if needed.
  ///
  /// A date before the site opened is rejected: nothing is posted, queued, or
  /// marked visited. Returns false both for that rejection and for a queued
  /// check-in.
  Future<bool> submitCheckin({
    required int siteId,
    required DateTime date,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
    String? notesPrivate,
    CheckinPrecision precision = CheckinPrecision.timestamp,
  }) async {
    final site = await DatabaseService.getSiteBySiteId(siteId);
    if (site != null &&
        checkinPrecedesOpening(site, date, precision: precision)) {
      return false;
    }

    final hasNetwork = await hasConnectivity();
    var queueStatus = PendingStatus.pending;
    String? queueError;
    var attempts = 0;
    DateTime? lastAttemptAt;

    if (hasNetwork) {
      // Try to submit directly
      try {
        final draft = await _draftFor(
          siteId: siteId,
          date: date,
          precision: precision,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          notes: notes,
          notesPrivate: notesPrivate,
        );
        final result = await _writer.submit(draft);

        if (result.outcome == WriteOutcome.accepted) {
          await DatabaseService.markSiteVisited(siteId, true);
          await DatabaseService.addVisit(
            VisitsCompanion(
              siteId: Value(siteId),
              checkinDate: Value(date),
              checkinTime: Value(date),
              checkinPrecision: Value(precision),
              isFirst: const Value(false),
              method: Value(
                latitude != null ? CheckinMethod.gps : CheckinMethod.manual,
              ),
              notesPublic: Value(notes),
              notesPrivate: Value(notesPrivate),
              geoDistanceAccuracy: Value(accuracy?.toInt()),
              syncStatus: const Value(VisitSyncStatus.synced),
              importedAt: Value(DateTime.now()),
            ),
          );
          return true;
        }
        if (result.outcome == WriteOutcome.needsSignIn) {
          await _markSessionExpired();
          queueError = waitingForSignInMessage;
        } else if (result.outcome == WriteOutcome.rejected) {
          queueStatus = PendingStatus.failed;
          queueError = result.message ?? WriteResult.rejected.message;
        } else if (result.outcome == WriteOutcome.retry) {
          queueError = result.message ?? WriteResult.retry.message;
          attempts = 1;
          lastAttemptAt = DateTime.now();
        }
      } catch (e) {
        queueError = WriteResult.retry.message;
        attempts = 1;
        lastAttemptAt = DateTime.now();
      }
    }

    await DatabaseService.saveQueuedCheckin(
      pending: PendingCheckinsCompanion(
        siteId: Value(siteId),
        checkinDate: Value(date),
        checkinPrecision: Value(precision),
        createdAt: Value(DateTime.now()),
        latitude: Value(latitude),
        longitude: Value(longitude),
        accuracy: Value(accuracy),
        notesPublic: Value(notes),
        notesPrivate: Value(notesPrivate),
        status: Value(queueStatus),
        lastError: Value(queueError),
        attempts: Value(attempts),
        lastAttemptAt: Value(lastAttemptAt),
      ),
      method: latitude != null ? CheckinMethod.gps : CheckinMethod.manual,
    );

    return false; // Indicates it was queued, not submitted
  }

  /// Sync pending check-ins
  Future<void> syncPendingCheckins() async {
    final hasNetwork = await hasConnectivity();
    if (!hasNetwork) return;

    final pending = await DatabaseService.getPendingCheckins();

    for (final checkin in pending) {
      final now = DateTime.now();
      if (!pendingReadyToRetry(checkin.lastAttemptAt, checkin.attempts, now)) {
        continue;
      }

      try {
        final site = await DatabaseService.getSiteBySiteId(checkin.siteId);
        if (site != null &&
            checkinPrecedesOpening(
              site,
              checkin.checkinDate,
              precision: checkin.checkinPrecision,
            )) {
          await DatabaseService.updatePendingCheckin(
            checkin.id,
            const PendingCheckinsCompanion(
              status: Value(PendingStatus.failed),
              lastError: Value('Check-in date is before the site opened'),
            ),
          );
          continue;
        }

        final session = await _apiService.getSessionCookie();
        if (session == null || session.isEmpty) {
          await DatabaseService.updatePendingCheckin(
            checkin.id,
            const PendingCheckinsCompanion(
              status: Value(PendingStatus.pending),
              lastError: Value(waitingForSignInMessage),
            ),
          );
          sessionExpiredVersion.value++;
          continue;
        }

        await DatabaseService.updatePendingCheckin(
          checkin.id,
          PendingCheckinsCompanion(
            status: const Value(PendingStatus.submitting),
            lastAttemptAt: Value(now),
            attempts: Value(checkin.attempts + 1),
          ),
        );

        final draft = await _draftFor(
          siteId: checkin.siteId,
          date: checkin.checkinDate,
          precision: checkin.checkinPrecision,
          latitude: checkin.latitude,
          longitude: checkin.longitude,
          accuracy: checkin.accuracy,
          notes: checkin.notesPublic,
          notesPrivate: checkin.notesPrivate,
        );
        final result = await _writer.submit(draft);
        await _applyWriteResult(checkin.id, result);
      } catch (e) {
        await DatabaseService.updatePendingCheckin(
          checkin.id,
          PendingCheckinsCompanion(
            status: const Value(PendingStatus.pending),
            lastError: Value(WriteResult.retry.message),
          ),
        );
      }
    }
  }

  Future<void> _applyWriteResult(int pendingId, WriteResult result) async {
    switch (result.outcome) {
      case WriteOutcome.accepted:
        await DatabaseService.updatePendingCheckin(
          pendingId,
          const PendingCheckinsCompanion(
            status: Value(PendingStatus.completed),
            lastError: Value(null),
          ),
        );
        await DatabaseService.db.markPendingVisitSynced(pendingId);
      case WriteOutcome.rejected:
        await DatabaseService.updatePendingCheckin(
          pendingId,
          PendingCheckinsCompanion(
            status: const Value(PendingStatus.failed),
            lastError: Value(result.message ?? WriteResult.rejected.message),
          ),
        );
      case WriteOutcome.retry:
        await DatabaseService.updatePendingCheckin(
          pendingId,
          PendingCheckinsCompanion(
            status: const Value(PendingStatus.pending),
            lastError: Value(result.message ?? WriteResult.retry.message),
          ),
        );
      case WriteOutcome.needsSignIn:
        await DatabaseService.updatePendingCheckin(
          pendingId,
          const PendingCheckinsCompanion(
            status: Value(PendingStatus.pending),
            lastError: Value(signInAgainMessage),
            // Do not burn a backoff slot. The next try should run as soon
            // as the user has a session again.
            attempts: Value(0),
            lastAttemptAt: Value(null),
          ),
        );
        await _markSessionExpired();
    }
  }

  Future<void> _markSessionExpired() async {
    await _apiService.clearSessionCookie();
    await DatabaseService.updateUserSettings(
      const UserSettingsTableCompanion(isAuthenticated: Value(false)),
    );
    sessionExpiredVersion.value++;
  }

  /// Recent OPEN additions in the user's region, inside [radiusKm].
  Future<List<AllChanges>> checkForNewSuperchargers(
    double userLat,
    double userLng,
    double radiusKm,
  ) async {
    final regionId = SuperchargeRegion.forCoordinates(userLat, userLng);
    final page = await _apiService.fetchChangesPage(
      regionId: regionId,
      start: 0,
      length: 100,
    );
    final newSuperchargers = <AllChanges>[];

    for (final change in page.results) {
      if (!isOpeningChange(change)) continue;
      final distance = TimezoneService.instance.calculateDistanceKm(
        userLat,
        userLng,
        change.site.gps.latitude,
        change.site.gps.longitude,
      );
      if (distance <= radiusKm) newSuperchargers.add(change);
    }

    return newSuperchargers;
  }

  /// Changes newer than [cursor]. A null cursor is the first poll: return the
  /// newest id and no rows, so alerts do not replay history.
  Future<({List<AllChanges> changes, int? nextCursor})> changesNewerThan({
    required double userLat,
    required double userLng,
    required int? cursor,
  }) async {
    final regionId = SuperchargeRegion.forCoordinates(userLat, userLng);
    if (cursor == null) {
      final newest = await _apiService.fetchNewestChangeId(regionId);
      return (changes: <AllChanges>[], nextCursor: newest);
    }

    final collected = <AllChanges>[];
    var start = 0;
    var next = cursor;
    while (true) {
      final page = await _apiService.fetchChangesPage(
        regionId: regionId,
        start: start,
        length: ApiService.changePageLength,
      );
      if (page.results.isEmpty) break;
      var reached = false;
      for (final change in page.results) {
        if (change.id > next) next = change.id;
        if (change.id <= cursor) {
          reached = true;
          continue;
        }
        collected.add(change);
      }
      if (reached || page.results.length < ApiService.changePageLength) break;
      start += page.results.length;
      if (start >= page.recordCount) break;
    }
    return (changes: collected, nextCursor: next);
  }

  Future<CheckinDraft> _draftFor({
    required int siteId,
    required DateTime date,
    required CheckinPrecision precision,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
    String? notesPrivate,
  }) async {
    final settings = await DatabaseService.getUserSettings();
    return CheckinDraft(
      siteId: siteId,
      checkinAt: date,
      precision: precision,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      notesPublic: notes,
      notesPrivate: notesPrivate,
      userId: settings.odUserId,
    );
  }
}
