import 'dart:math' as math;

import '../database/database.dart';

// Conditional import for platform-specific database connection
import '../database/connection/connection.dart'
    if (dart.library.ffi) '../database/connection/native.dart'
    if (dart.library.js_interop) '../database/connection/web.dart';

/// Service for managing the local Drift database
class DatabaseService {
  static AppDatabase? _db;
  // Bootstrap caches populated during splash to avoid initial in-app fetch delays
  static List<Site>? bootstrapSites; // Sites for initial default map filter
  static UserSettingsTableData? bootstrapUserSettings;
  static Future<void>? _bootstrapFuture;

  /// Get the database instance
  static AppDatabase get db {
    if (_db == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _db!;
  }

  /// Initialize the database
  static Future<void> initialize() async {
    if (_db != null) return;
    _db = AppDatabase(connect());
  }

  /// Preload user settings and default filtered sites for first screen.
  /// Safe to call multiple times; subsequent calls await the same future.
  static Future<void> preloadBootstrapData() {
    if (_bootstrapFuture != null) return _bootstrapFuture!;
    _bootstrapFuture = () async {
      try {
        // Fetch user settings
        bootstrapUserSettings = await getUserSettings();
        // Fetch default sites (Open + Unvisited)
        bootstrapSites = await getSites(
          status: SiteStatus.open,
          visited: false,
        );
      } catch (_) {
        // Leave caches null on failure; downstream code will fallback
      } finally {}
    }();
    return _bootstrapFuture!;
  }

  /// Get the current user settings
  static Future<UserSettingsTableData> getUserSettings() async {
    // Serve bootstrap cache if available
    if (bootstrapUserSettings != null) return bootstrapUserSettings!;
    return db.getUserSettings();
  }

  /// Update user settings
  static Future<void> updateUserSettings(
    UserSettingsTableCompanion settings,
  ) async {
    await db.updateUserSettings(settings);
  }

  /// Get all sites, optionally filtered
  static Future<List<Site>> getSites({
    SiteStatus? status,
    bool? visited,
  }) async {
    // If requesting the default open + unvisited set and we have bootstrap cache use it
    if (status == SiteStatus.open &&
        visited == false &&
        bootstrapSites != null) {
      return bootstrapSites!;
    }
    // Both status and visited specified
    if (status != null && visited != null) {
      return db.getSitesByStatusAndVisited(status, visited);
    }
    // Only status specified
    if (status != null) {
      return db.getSitesByStatus(status);
    }
    // Only visited specified
    if (visited == false) {
      return db.getUnvisitedSites();
    }
    return db.getAllSites();
  }

  /// Get a site by its supercharge.info ID
  static Future<Site?> getSiteBySiteId(int siteId) async {
    return db.getSiteBySiteId(siteId);
  }

  /// Upsert sites from API
  static Future<void> upsertSites(List<SitesCompanion> sites) async {
    await db.upsertSites(sites);
  }

  /// Mark a site as visited
  static Future<void> markSiteVisited(int siteId, bool visited) async {
    await db.markSiteVisited(siteId, visited);
  }

  /// Mark sites as having check-ins (not first eligible)
  static Future<void> markSitesHaveCheckins(List<int> siteIds) async {
    await db.markSitesHaveCheckins(siteIds);
  }

  /// Get user's visits
  static Future<List<Visit>> getVisits({int? siteId}) async {
    if (siteId != null) {
      return db.getVisitsBySiteId(siteId);
    }
    return db.getAllVisits();
  }

  /// Get the last visit date for a site
  static Future<DateTime?> getLastVisitDate(int siteId) async {
    return db.getLastVisitDate(siteId);
  }

  /// Get total count of visits
  static Future<int> getVisitCount() async {
    return db.getVisitCount();
  }

  /// Add a visit
  static Future<void> addVisit(VisitsCompanion visit) async {
    await db.addVisit(visit);
    // Mark site as visited
    final siteId = visit.siteId.value;
    await db.markSiteVisited(siteId, true);
  }

  /// Get pending check-ins
  static Future<List<PendingCheckin>> getPendingCheckins() async {
    return db.getPendingCheckins();
  }

  /// Add a pending check-in
  static Future<void> addPendingCheckin(
    PendingCheckinsCompanion checkin,
  ) async {
    await db.addPendingCheckin(checkin);
  }

  /// Update a pending check-in
  static Future<void> updatePendingCheckin(
    int id,
    PendingCheckinsCompanion checkin,
  ) async {
    await db.updatePendingCheckin(id, checkin);
  }

  /// Delete a pending check-in
  static Future<void> deletePendingCheckin(int id) async {
    await db.deletePendingCheckin(id);
  }

  /// Get site check-ins (others' check-ins)
  static Future<List<SiteCheckin>> getSiteCheckins(
    int siteId, {
    int limit = 10,
  }) async {
    return db.getSiteCheckins(siteId, limit: limit);
  }

  /// Get the last public check-in date for a site
  static Future<DateTime?> getLastPublicCheckinDate(int siteId) async {
    return db.getLastPublicCheckinDate(siteId);
  }

  /// Upsert site check-ins from API
  static Future<void> upsertSiteCheckins(
    List<SiteCheckinsCompanion> checkins,
  ) async {
    await db.upsertSiteCheckins(checkins);
  }

  /// Check if anyone has checked in at a site today
  static Future<bool> hasCheckinToday(int siteId, DateTime localDate) async {
    return db.hasCheckinToday(siteId, localDate);
  }

  /// Clear all data (for logout)
  static Future<void> clearAll() async {
    await db.clearAll();
  }

  /// Get nearby sites sorted by distance from a given location
  /// Returns sites within [radiusKm] kilometers, sorted by distance
  static Future<List<SiteWithDistance>> getNearbySites({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
    int limit = 20,
    bool? visited,
    SiteStatus? status,
  }) async {
    // Get all sites (or filtered by status/visited)
    final sites = await getSites(status: status, visited: visited);

    // Calculate distance for each site and filter by radius
    final sitesWithDistance = <SiteWithDistance>[];
    for (final site in sites) {
      final distance = _calculateDistanceKm(
        latitude,
        longitude,
        site.latitude,
        site.longitude,
      );
      if (distance <= radiusKm) {
        sitesWithDistance.add(
          SiteWithDistance(site: site, distanceKm: distance),
        );
      }
    }

    // Sort by distance
    sitesWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    // Return up to limit
    return sitesWithDistance.take(limit).toList();
  }

  /// Calculate distance between two points using Haversine formula
  static double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) =>
      degrees * 3.141592653589793 / 180.0;
  static double _sin(double x) => math.sin(x);
  static double _cos(double x) => math.cos(x);
  static double _sqrt(double x) => math.sqrt(x);
  static double _atan2(double y, double x) => math.atan2(y, x);
}

/// Helper class to hold a site with its calculated distance
class SiteWithDistance {
  final Site site;
  final double distanceKm;

  SiteWithDistance({required this.site, required this.distanceKm});
}
