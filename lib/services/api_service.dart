import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database.dart';

/// API service for supercharge.info and supercharging.life
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  late final Dio _dio;
  CookieJar? _cookieJar;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // API endpoints
  static const String superchargeInfoBaseUrl = 'https://supercharge.info';
  static const String superchargingLifeBaseUrl = 'https://supercharging.life';

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'User-Agent': 'SuperchargerBingo/1.0 (Flutter)',
          'Accept': 'application/json',
        },
      ),
    );
    // CookieManager doesn't work on web
    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }
  }

  /// Set session cookie for supercharging.life
  Future<void> setSessionCookie(String sessionId) async {
    await _secureStorage.write(key: 'sclphpsessid', value: sessionId);
    // CookieJar not available on web
    if (_cookieJar != null) {
      final uri = Uri.parse(superchargingLifeBaseUrl);
      await _cookieJar!.saveFromResponse(uri, [
        Cookie('SCLPHPSESSID', sessionId)
          ..domain = 'supercharging.life'
          ..path = '/'
          ..httpOnly = true,
      ]);
    }
  }

  /// Get stored session cookie
  Future<String?> getSessionCookie() async {
    return _secureStorage.read(key: 'sclphpsessid');
  }

  /// Clear session cookie (logout)
  Future<void> clearSessionCookie() async {
    await _secureStorage.delete(key: 'sclphpsessid');
    await _cookieJar?.deleteAll();
  }

  /// Fetch all supercharger sites from supercharge.info
  Future<List<SitesCompanion>> fetchAllSites() async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/allSites',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => _parseSite(json)).toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch sites: ${response.statusCode}',
    );
  }

  /// Fetch recent changes from supercharge.info
  Future<List<Map<String, dynamic>>> fetchAllChanges() async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/allChanges',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch changes: ${response.statusCode}',
    );
  }

  /// Fetch check-in history from supercharging.life
  Future<List<SiteCheckinsCompanion>> fetchCheckinHistory() async {
    final response = await _dio.get(
      '$superchargingLifeBaseUrl/supercharging/ajax.php',
      queryParameters: {'content': 'first_checkin_history_list_for_datatables'},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => _parseSiteCheckin(json))
            .toList();
      }
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch check-in history',
    );
  }

  /// Fetch user list from supercharging.life to find user by username
  Future<Map<String, dynamic>?> fetchUserByUsername(String username) async {
    final response = await _dio.get(
      '$superchargingLifeBaseUrl/supercharging/ajax.php',
      queryParameters: {
        'content': 'user_list_for_datatables',
        'search[value]': username, // Use server-side search to filter results
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final users = data['data'] as List;
        // Find user by display name (case-insensitive)
        for (final user in users) {
          if (user is Map &&
              (user['displayname'] as String?)?.toLowerCase() ==
                  username.toLowerCase()) {
            return Map<String, dynamic>.from(user);
          }
        }
      }
    }
    return null;
  }

  /// Fetch supercharger list with check-in counts from supercharging.life
  /// Returns a map of siteId -> total check-in count
  Future<Map<int, int>> fetchSuperchargerCheckinCounts() async {
    final response = await _dio.get(
      '$superchargingLifeBaseUrl/supercharging/ajax.php',
      queryParameters: {
        'content': 'supercharger_list_for_datatables',
        'address_region_id': '',
        'address_region': '',
        'address_country': '',
        'address_state': '',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final result = <int, int>{};
        for (final item in data['data']) {
          if (item is Map) {
            // The supercharger_id field and checkin_qty field
            final siteId = int.tryParse(
              item['supercharger_id']?.toString() ?? '',
            );
            final checkinCount =
                int.tryParse(item['checkin_qty']?.toString() ?? '0') ?? 0;
            if (siteId != null) {
              result[siteId] = checkinCount;
            }
          }
        }
        return result;
      }
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch supercharger check-in counts',
    );
  }

  /// Submit a check-in to supercharging.life
  Future<bool> submitCheckin({
    required int siteId,
    required DateTime date,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      'supercharger_id': siteId.toString(),
      'checkin_date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      if (latitude != null && longitude != null) ...{
        'method': 'gps',
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        if (accuracy != null) 'geo_accuracy': accuracy.toString(),
      } else ...{
        'method': 'manual',
      },
      if (notes != null && notes.isNotEmpty) 'notes_public': notes,
    });

    final response = await _dio.post(
      '$superchargingLifeBaseUrl/supercharging/checkin.php',
      data: formData,
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    // Check if the response indicates success
    return response.statusCode == 200;
  }

  /// Download user's XLSX export
  Future<List<int>> downloadUserXlsx(int userId) async {
    final response = await _dio.get(
      '$superchargingLifeBaseUrl/supercharging/export.php',
      queryParameters: {'action': 'user_xlsx', 'user_id': userId.toString()},
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      return response.data;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to download XLSX: ${response.statusCode}',
    );
  }

  /// Parse a site from supercharge.info JSON
  SitesCompanion _parseSite(Map<String, dynamic> json) {
    DateTime? dateOpened;
    if (json['dateOpened'] != null) {
      try {
        dateOpened = DateTime.parse(json['dateOpened'] as String);
      } catch (_) {}
    }

    int? stallsV2, stallsV3, stallsV4;
    if (json['stalls'] is Map) {
      final stalls = json['stalls'] as Map;
      stallsV2 = stalls['v2'] as int?;
      stallsV3 = stalls['v3'] as int?;
      stallsV4 = stalls['v4'] as int?;
    }

    return SitesCompanion(
      siteId: Value(json['id'] as int),
      locationId: Value(json['locationId'] as String?),
      name: Value(json['name'] as String),
      status: Value(_parseSiteStatus(json['status'] as String?)),
      latitude: Value((json['gps']?['latitude'] as num?)?.toDouble() ?? 0.0),
      longitude: Value((json['gps']?['longitude'] as num?)?.toDouble() ?? 0.0),
      street: Value(json['address']?['street'] as String?),
      city: Value(json['address']?['city'] as String?),
      state: Value(json['address']?['state'] as String?),
      zip: Value(json['address']?['zip'] as String?),
      country: Value(json['address']?['country'] as String? ?? 'Unknown'),
      region: Value(json['address']?['region'] as String? ?? 'Unknown'),
      stallCount: Value(json['stallCount'] as int?),
      powerKilowatt: Value(json['powerKilowatt'] as int?),
      stallsV2: Value(stallsV2),
      stallsV3: Value(stallsV3),
      stallsV4: Value(stallsV4),
      dateOpened: Value(dateOpened),
      lastSynced: Value(DateTime.now()),
    );
  }

  SiteStatus _parseSiteStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return SiteStatus.open;
      case 'CONSTRUCTION':
        return SiteStatus.construction;
      case 'PERMIT':
        return SiteStatus.permit;
      case 'PLANNED':
        return SiteStatus.planned;
      case 'CLOSED':
        return SiteStatus.closed;
      default:
        return SiteStatus.unknown;
    }
  }

  /// Parse a site check-in from supercharging.life JSON
  SiteCheckinsCompanion _parseSiteCheckin(Map<String, dynamic> json) {
    DateTime checkinDate;
    try {
      checkinDate = DateTime.parse(json['checkin_date'] as String);
    } catch (_) {
      checkinDate = DateTime.now();
    }

    DateTime checkinTime;
    try {
      final timeStr = json['checkin_time'] as String?;
      if (timeStr != null) {
        checkinTime = DateTime.parse(timeStr.replaceAll(' ', 'T'));
      } else {
        checkinTime = checkinDate;
      }
    } catch (_) {
      checkinTime = checkinDate;
    }

    int? daysAfterOpen;
    if (json['checkin_days_after_open'] != null) {
      daysAfterOpen = int.tryParse(json['checkin_days_after_open'] as String);
    }

    return SiteCheckinsCompanion(
      checkinId: Value(int.parse(json['checkin_id'] as String)),
      siteId: Value(int.parse(json['supercharger_id'] as String)),
      odUserId: Value(int.parse(json['user_id'] as String)),
      username: Value(json['user_username'] as String),
      displayName: Value(json['user_displayname'] as String?),
      checkinDate: Value(checkinDate),
      checkinTime: Value(checkinTime),
      isFirstAtSupercharger: Value(
        json['is_first_at_supercharger_cache'] == 'Y',
      ),
      daysAfterOpen: Value(daysAfterOpen),
      syncedAt: Value(DateTime.now()),
    );
  }
}
