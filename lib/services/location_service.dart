import 'dart:io' show Platform;
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart' show MethodChannel;
import 'package:geolocator/geolocator.dart';

/// Service for handling device location
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Cached position
  Position? _cachedPosition;
  DateTime? _cacheTimestamp;
  static const _cacheValidDuration = Duration(minutes: 5);

  /// MainActivity asks for background location on its own. See there.
  static const _androidLocation = MethodChannel('supercharger_bingo/location');

  LocationService._();

  /// Check if we're on Linux desktop
  bool get isLinuxDesktop => !kIsWeb && Platform.isLinux;

  /// Get cached position if available and not expired
  Position? get cachedPosition {
    if (_cachedPosition != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheValidDuration) {
        return _cachedPosition;
      }
    }
    return null;
  }

  /// Clear the cached position (useful for refresh)
  void clearCache() {
    _cachedPosition = null;
    _cacheTimestamp = null;
  }

  /// Background alerts need location "all the time". Android 11+ sends the
  /// user to the system settings page for that second step.
  Future<LocationPermission> requestBackgroundAccess() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse) {
      if (Platform.isAndroid) {
        await _androidLocation.invokeMethod<bool>('requestBackgroundLocation');
        permission = await Geolocator.checkPermission();
      } else {
        permission = await Geolocator.requestPermission();
      }
    }
    return permission;
  }

  /// A GPS fix for the background task, or null. Never falls back to IP
  /// geolocation, which can be hundreds of km off on mobile data.
  Future<Position?> backgroundPosition() async {
    try {
      if (await Geolocator.checkPermission() != LocationPermission.always) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check and request location permissions
  Future<bool> checkPermission() async {
    // On Linux, skip permission checks - they don't work reliably
    if (isLinuxDesktop) return true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Current position, or the cached one if still fresh. Devices with real
  /// location never use IP geolocation, which can be hundreds of km off: a
  /// slow fix falls back to the last known GPS position. Only Linux desktop,
  /// where GeoClue is often missing, falls back to IP.
  Future<Position?> getCurrentPosition({bool forceRefresh = false}) async {
    // Return cached position if available and not forcing refresh
    if (!forceRefresh && cachedPosition != null) {
      debugPrint('LocationService: Using cached position');
      return cachedPosition;
    }

    Position? position;

    // On Linux, try GeoClue first, then fall back to IP-based
    if (isLinuxDesktop) {
      debugPrint(
        'LocationService: Linux detected, trying GeoClue with 2s timeout...',
      );
      try {
        position =
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 2),
              ),
            ).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                debugPrint(
                  'LocationService: GeoClue timed out (manual 2s timeout)',
                );
                throw Exception('GeoClue timeout');
              },
            );
        debugPrint(
          'LocationService: GeoClue succeeded: ${position.latitude}, ${position.longitude}',
        );
      } catch (e) {
        debugPrint(
          'LocationService: GeoClue failed ($e), trying IP geolocation...',
        );
        position = await _getPositionFromIP();
      }
    } else {
      // Fast fix for the UI, else the last known GPS position.
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;
      try {
        position =
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
                timeLimit: Duration(seconds: 2),
              ),
            ).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                debugPrint('LocationService: Geolocator timed out (2s)');
                throw Exception('Geolocator timeout');
              },
            );
      } catch (e) {
        debugPrint('LocationService: Geolocator failed/timeout: $e');
        try {
          position = await Geolocator.getLastKnownPosition();
          debugPrint(
            'LocationService: last known ${position?.latitude}, '
            '${position?.longitude} at ${position?.timestamp}',
          );
        } catch (_) {
          // Web and some platforms have no last known position.
        }
      }
    }

    if (position != null) _remember(position);

    return position;
  }

  void _remember(Position position) {
    _cachedPosition = position;
    // The fix's own time: a last known position hours old is not fresh.
    _cacheTimestamp = position.timestamp;
  }

  /// A fix for a check-in, taken now like the supercharging.life form's
  /// browser geolocation. Reuses one under a minute old. Never a last known
  /// or IP position: those were hours or hundreds of km off, so no fix means
  /// a manual check-in instead of wrong coordinates.
  Future<Position?> checkinFix({Position? recent}) async {
    for (final p in [recent, _cachedPosition]) {
      if (p != null &&
          p.accuracy < 5000 &&
          DateTime.now().difference(p.timestamp) < const Duration(minutes: 1)) {
        return p;
      }
    }
    // GPS first. If it can't get a fix in time, take a Wi-Fi or cell fix,
    // which is what the site's form gets without enableHighAccuracy.
    for (final (accuracy, seconds) in const [
      (LocationAccuracy.high, 15),
      (LocationAccuracy.medium, 10),
    ]) {
      try {
        final fix = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            timeLimit: Duration(seconds: seconds),
          ),
        );
        _remember(fix);
        return fix;
      } catch (_) {}
    }
    return null;
  }

  /// Get position from IP-based geolocation service
  /// Uses ip-api.com (free, no API key required, 45 requests/minute limit)
  Future<Position?> _getPositionFromIP() async {
    try {
      debugPrint('LocationService: Fetching location from ip-api.com...');
      final response = await _dio.get(
        'http://ip-api.com/json/?fields=status,lat,lon,city,regionName,country',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final lat = (response.data['lat'] as num).toDouble();
        final lon = (response.data['lon'] as num).toDouble();
        final city = response.data['city'] ?? '';
        final region = response.data['regionName'] ?? '';

        debugPrint(
          'LocationService: IP geolocation: $lat, $lon ($city, $region)',
        );

        // Create a Position object with the IP-based location
        // Note: accuracy is low for IP-based geolocation (city-level)
        return Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 5000, // ~5km accuracy for IP-based
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }

      debugPrint('LocationService: ip-api.com failed: ${response.data}');
      return null;
    } catch (e) {
      debugPrint('LocationService: IP geolocation error: $e');
      return null;
    }
  }

  /// Position updates every 50 meters, starting with a fix right away.
  /// The platform stream only reports after moving distanceFilter, so a
  /// listener standing still would otherwise never hear anything.
  Stream<Position> getPositionStream() async* {
    final now = await _gpsFix();
    if (now != null) yield now;
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    );
  }

  /// A current GPS fix, else the last known one, else null. No IP fallback.
  Future<Position?> _gpsFix() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Unified position stream:
  /// - Uses Geolocator stream when available
  /// - On Linux desktop, where geolocator may be silent, polls IP-based
  ///   location every 10 seconds (staying under 45 req/min ip-api limit)
  Stream<Position> unifiedPositionStream() {
    final controller = StreamController<Position>.broadcast();
    Position? latest;
    void emit(Position pos) {
      latest = pos;
      if (!controller.isClosed) controller.add(pos);
    }

    Timer? ipTimer;
    StreamSubscription<Position>? geoSub;

    void startIpPolling() {
      ipTimer ??= Timer.periodic(const Duration(seconds: 10), (_) async {
        final pos = await _getPositionFromIP();
        if (pos == null) return;
        _remember(pos);
        emit(pos);
      });
    }

    void stopIpPolling() {
      ipTimer?.cancel();
      ipTimer = null;
    }

    // Subscribe to geolocator stream
    geoSub = getPositionStream().listen(
      (pos) {
        // On any geolocator update, forward and stop IP fallback. Caching it
        // keeps the check-in list on the live fix, not one up to 5 min old.
        stopIpPolling();
        _remember(pos);
        emit(pos);
      },
      onError: (_) {
        // Only Linux desktop falls back to IP; real location never does.
        if (isLinuxDesktop) startIpPolling();
      },
    );

    // If on Linux desktop, proactively start IP fallback until a geolocator update arrives
    if (isLinuxDesktop) {
      startIpPolling();
    }

    controller.onCancel = () {
      geoSub?.cancel();
      stopIpPolling();
    };

    controller.onListen = () async {
      // Emit cached if present immediately
      final cached = cachedPosition;
      if (cached != null) emit(cached);
      // Also try a fresh position fast-path
      final fresh = await getCurrentPosition();
      if (fresh != null) emit(fresh);
    };

    // Each new listener starts from the latest position. A plain broadcast
    // stream would give it nothing until the next 50 m of movement, which
    // is how the map's location marker missed the first fix.
    return Stream.multi((listener) {
      // Read before listening: the first listen emits the cached fix itself.
      final last = latest;
      if (last != null) listener.addSync(last);
      final sub = controller.stream.listen(
        listener.addSync,
        onError: listener.addErrorSync,
        onDone: listener.closeSync,
      );
      listener.onCancel = sub.cancel;
    }, isBroadcast: true);
  }
}
