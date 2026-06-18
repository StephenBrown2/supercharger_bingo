import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import 'api_service.dart';
import 'database_service.dart';

/// Service for syncing data between local database and remote APIs
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();

  /// Bumped whenever community check-in data finishes syncing, so screens can
  /// recompute First state (pin colours) once the data lands.
  final ValueNotifier<int> communityDataVersion = ValueNotifier(0);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncingSites = false;
  bool _isSyncingCheckinHistory = false;
  bool _isSyncingCheckinCounts = false;
  bool _isSyncingUser = false;

  SyncService._();

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

  /// Sync all sites from supercharge.info
  Future<void> syncSites() async {
    if (_isSyncingSites) return;
    _isSyncingSites = true;

    try {
      final sites = await ApiService.instance.fetchAllSites();
      await DatabaseService.upsertSites(sites);

      // Update last sync time
      await DatabaseService.updateUserSettings(
        UserSettingsTableCompanion(lastSitesSyncAt: Value(DateTime.now())),
      );
    } finally {
      _isSyncingSites = false;
    }
  }

  /// Sync check-in history from supercharging.life
  Future<void> syncCheckinHistory() async {
    if (_isSyncingCheckinHistory) return;
    _isSyncingCheckinHistory = true;

    try {
      final checkins = await ApiService.instance.fetchCheckinHistory();
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

  /// Sync supercharger check-in counts from supercharging.life
  /// This determines which sites have been visited by anyone (hasCheckins)
  Future<void> syncSuperchargerCheckinCounts() async {
    if (_isSyncingCheckinCounts) {
      debugPrint('syncSuperchargerCheckinCounts: Already syncing, skipping');
      return;
    }
    _isSyncingCheckinCounts = true;
    debugPrint('syncSuperchargerCheckinCounts: Starting');

    try {
      final checkinCounts = await ApiService.instance
          .fetchSuperchargerCheckinCounts();
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
      final userData = await ApiService.instance.fetchUserByUsername(username);
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
      final xlsxBytes = await ApiService.instance.downloadUserXlsx(userId);
      debugPrint('syncUserByUsername: Got ${xlsxBytes.length} bytes');

      final visits = await _parseUserXlsx(xlsxBytes);
      debugPrint('syncUserByUsername: Parsed ${visits.length} visits');

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
            if (timeValue != null) {
              final timeStr = timeValue.toString();
              checkinTime = DateTime.tryParse(timeStr) ?? checkinDate;
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
                checkinId: Value(checkinId),
                siteId: Value(siteId),
                checkinDate: Value(checkinDate),
                checkinTime: Value(checkinTime),
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

  /// Submit a check-in, queueing offline if needed
  Future<bool> submitCheckin({
    required int siteId,
    required DateTime date,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
  }) async {
    final hasNetwork = await hasConnectivity();

    if (hasNetwork) {
      // Try to submit directly
      try {
        final success = await ApiService.instance.submitCheckin(
          siteId: siteId,
          date: date,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          notes: notes,
        );

        if (success) {
          // Mark site as visited locally
          await DatabaseService.markSiteVisited(siteId, true);

          // Add to local visits
          final visit = VisitsCompanion(
            checkinId: const Value(0), // Will be updated on next sync
            siteId: Value(siteId),
            checkinDate: Value(date),
            checkinTime: Value(DateTime.now()),
            isFirst: const Value(false), // Will be updated on next sync
            method: Value(
              latitude != null ? CheckinMethod.gps : CheckinMethod.manual,
            ),
            notesPublic: Value(notes),
            geoDistanceAccuracy: Value(accuracy?.toInt()),
            importedAt: Value(DateTime.now()),
          );
          await DatabaseService.addVisit(visit);

          return true;
        }
      } catch (e) {
        // Fall through to queue offline
      }
    }

    // Queue for later submission
    final pending = PendingCheckinsCompanion(
      siteId: Value(siteId),
      checkinDate: Value(date),
      createdAt: Value(DateTime.now()),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracy: Value(accuracy),
      notesPublic: Value(notes),
      status: const Value(PendingStatus.pending),
    );

    await DatabaseService.addPendingCheckin(pending);

    // Mark site as visited locally (optimistic)
    await DatabaseService.markSiteVisited(siteId, true);

    return false; // Indicates it was queued, not submitted
  }

  /// Sync pending check-ins
  Future<void> syncPendingCheckins() async {
    final hasNetwork = await hasConnectivity();
    if (!hasNetwork) return;

    final pending = await DatabaseService.getPendingCheckins();

    for (final checkin in pending) {
      await DatabaseService.updatePendingCheckin(
        checkin.id,
        PendingCheckinsCompanion(
          status: const Value(PendingStatus.submitting),
          lastAttemptAt: Value(DateTime.now()),
          attempts: Value(checkin.attempts + 1),
        ),
      );

      try {
        final success = await ApiService.instance.submitCheckin(
          siteId: checkin.siteId,
          date: checkin.checkinDate,
          latitude: checkin.latitude,
          longitude: checkin.longitude,
          accuracy: checkin.accuracy,
          notes: checkin.notesPublic,
        );

        if (success) {
          await DatabaseService.updatePendingCheckin(
            checkin.id,
            const PendingCheckinsCompanion(
              status: Value(PendingStatus.completed),
            ),
          );
          // Could delete instead: await DatabaseService.deletePendingCheckin(checkin.id);
        } else {
          await DatabaseService.updatePendingCheckin(
            checkin.id,
            PendingCheckinsCompanion(
              status: const Value(PendingStatus.failed),
              lastError: const Value('Server returned failure'),
            ),
          );
        }
      } catch (e) {
        await DatabaseService.updatePendingCheckin(
          checkin.id,
          PendingCheckinsCompanion(
            status: const Value(PendingStatus.failed),
            lastError: Value(e.toString()),
          ),
        );
      }
    }
  }

  /// Check for new superchargers within radius
  Future<List<Map<String, dynamic>>> checkForNewSuperchargers(
    double userLat,
    double userLng,
    double radiusKm,
  ) async {
    final changes = await ApiService.instance.fetchAllChanges();
    final newSuperchargers = <Map<String, dynamic>>[];

    for (final change in changes) {
      if (change['changeType'] == 'ADD' && change['siteStatus'] == 'OPEN') {
        // Check if within radius (simplified great-circle distance)
        // TODO: Get actual coordinates from the change or fetch site details
        // For now, include all new opens
        newSuperchargers.add(change);
      }
    }

    return newSuperchargers;
  }
}
