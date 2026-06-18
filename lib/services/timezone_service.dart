import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../database/database.dart';

/// Service for timezone lookups and First-eligibility calculations
class TimezoneService {
  static TimezoneService? _instance;
  static TimezoneService get instance => _instance ??= TimezoneService._();

  bool _initialized = false;

  TimezoneService._();

  /// Initialize timezone database
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  /// Get the timezone for a given GPS coordinate
  /// Uses a simplified lookup based on longitude for now
  /// In production, you'd want a proper tz shapefile lookup
  String getTimezoneForLocation(double latitude, double longitude) {
    // Simplified timezone lookup based on longitude
    // This is a rough approximation; proper implementation would use a tz shapefile

    // Handle some common regions explicitly
    if (latitude >= 24 &&
        latitude <= 50 &&
        longitude >= -125 &&
        longitude <= -66) {
      // Continental US
      if (longitude >= -125 && longitude < -115) return 'America/Los_Angeles';
      if (longitude >= -115 && longitude < -102) return 'America/Denver';
      if (longitude >= -102 && longitude < -87) return 'America/Chicago';
      return 'America/New_York';
    }

    if (latitude >= 35 &&
        latitude <= 72 &&
        longitude >= -10 &&
        longitude <= 40) {
      // Europe
      if (longitude >= -10 && longitude < 0) return 'Europe/London';
      if (longitude >= 0 && longitude < 15) return 'Europe/Paris';
      if (longitude >= 15 && longitude < 25) return 'Europe/Berlin';
      return 'Europe/Moscow';
    }

    if (latitude >= 20 &&
        latitude <= 55 &&
        longitude >= 100 &&
        longitude <= 145) {
      // China/Japan/Korea
      if (longitude >= 100 && longitude < 120) return 'Asia/Shanghai';
      if (longitude >= 120 && longitude < 135) return 'Asia/Tokyo';
      return 'Asia/Tokyo';
    }

    if (latitude >= -45 &&
        latitude <= -10 &&
        longitude >= 110 &&
        longitude <= 155) {
      // Australia
      if (longitude < 130) return 'Australia/Perth';
      if (longitude < 145) return 'Australia/Adelaide';
      return 'Australia/Sydney';
    }

    // Fallback to UTC offset based on longitude
    final offsetHours = (longitude / 15).round();
    return 'Etc/GMT${offsetHours >= 0 ? '-' : '+'}${offsetHours.abs()}';
  }

  /// Get the local time at a site. Prefers the timezone stored at ingestion,
  /// falling back to a coordinate-based lookup for older rows.
  DateTime getLocalTimeAtSite(Site site) {
    final tzName =
        site.timezone ?? getTimezoneForLocation(site.latitude, site.longitude);
    try {
      final location = tz.getLocation(tzName);
      return tz.TZDateTime.now(location);
    } catch (_) {
      // Fallback to simple offset calculation
      final offsetHours = (site.longitude / 15).round();
      return DateTime.now().toUtc().add(Duration(hours: offsetHours));
    }
  }

  /// Get midnight (start of day) in the site's local timezone
  DateTime getMidnightAtSite(Site site, {DateTime? forDate}) {
    final tzName = getTimezoneForLocation(site.latitude, site.longitude);
    try {
      final location = tz.getLocation(tzName);
      final localNow = forDate != null
          ? tz.TZDateTime.from(forDate, location)
          : tz.TZDateTime.now(location);
      return tz.TZDateTime(
        location,
        localNow.year,
        localNow.month,
        localNow.day,
      );
    } catch (_) {
      // Fallback
      final offsetHours = (site.longitude / 15).round();
      final utcNow = forDate?.toUtc() ?? DateTime.now().toUtc();
      final localNow = utcNow.add(Duration(hours: offsetHours));
      return DateTime.utc(
        localNow.year,
        localNow.month,
        localNow.day,
      ).subtract(Duration(hours: offsetHours));
    }
  }

  /// Get the next midnight at a site (for countdown to First eligibility)
  DateTime getNextMidnightAtSite(Site site) {
    final tzName = getTimezoneForLocation(site.latitude, site.longitude);
    try {
      final location = tz.getLocation(tzName);
      final localNow = tz.TZDateTime.now(location);
      return tz.TZDateTime(
        location,
        localNow.year,
        localNow.month,
        localNow.day + 1,
      );
    } catch (_) {
      // Fallback
      final offsetHours = (site.longitude / 15).round();
      final utcNow = DateTime.now().toUtc();
      final localNow = utcNow.add(Duration(hours: offsetHours));
      return DateTime.utc(
        localNow.year,
        localNow.month,
        localNow.day + 1,
      ).subtract(Duration(hours: offsetHours));
    }
  }

  /// Get time remaining until next midnight at a site
  Duration getTimeUntilMidnight(Site site) {
    final nextMidnight = getNextMidnightAtSite(site);
    return nextMidnight.difference(DateTime.now().toUtc());
  }

  /// Format duration as countdown string (e.g., "5h 23m")
  String formatCountdown(Duration duration) {
    if (duration.isNegative) return 'Now!';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Check if a site is First-eligible (no check-ins today in local time)
  /// This requires checking the site_checkin history
  bool isSiteFirstEligibleToday(Site site, DateTime? lastCheckinAtSite) {
    if (lastCheckinAtSite == null) {
      // No check-ins ever - definitely First eligible
      return true;
    }

    // Get today's date in the site's local timezone
    final localMidnight = getMidnightAtSite(site);
    final nextMidnight = getNextMidnightAtSite(site);

    // Check if the last check-in was before today (in site's local time)
    return lastCheckinAtSite.isBefore(localMidnight) ||
        lastCheckinAtSite.isAfter(nextMidnight);
  }

  /// Calculate distance between two points using Haversine formula
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
