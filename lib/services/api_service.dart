import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database.dart';
import '../models/supercharge_info.dart';
import 'checkin_form.dart';
import 'life_auth.dart';
import 'life_time.dart';
import 'write_result.dart';
import 'timezone_service.dart';

/// API service for supercharge.info and supercharging.life
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService();

  late final Dio _dio;
  CookieJar? _cookieJar;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// When set, skips secure storage. Tests pass a fake session so a post is
  /// allowed without the plugin.
  final String? sessionId;

  static const String sessionCookieName = lifeSessionCookieName;
  static const String _sessionStorageKey = 'sclsession';

  // API endpoints
  static const String superchargeInfoBaseUrl = 'https://supercharge.info';
  static const String superchargingLifeBaseUrl = 'https://supercharging.life';

  /// Page size for the first pull of a region. North America is about 5,000
  /// sites, so a few pages cover a region without pulling the planet.
  static const int sitePageLength = 2000;

  /// Newest-first change pages. Each row embeds a full site.
  static const int changePageLength = 200;

  ApiService({Dio? dio, this.sessionId}) {
    _dio =
        dio ??
        Dio(
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

  /// Store the supercharging.life session. The live site sets SCLSESSION
  /// (not HttpOnly), which is what checkin.php expects.
  Future<void> setSessionCookie(String sessionId) async {
    try {
      await _secureStorage.write(key: _sessionStorageKey, value: sessionId);
    } catch (_) {}
    await _saveSessionCookie(sessionId);
  }

  Future<void> _saveSessionCookie(String sessionId) async {
    if (_cookieJar == null) return;
    final uri = Uri.parse(superchargingLifeBaseUrl);
    await _cookieJar!.saveFromResponse(uri, [
      Cookie(sessionCookieName, sessionId)
        ..domain = '.supercharging.life'
        ..path = '/'
        ..secure = true,
    ]);
  }

  /// Get stored session cookie. Null when the plugin is unavailable.
  Future<String?> getSessionCookie() async {
    if (sessionId != null && sessionId!.isNotEmpty) return sessionId;
    try {
      return await _secureStorage.read(key: _sessionStorageKey);
    } catch (_) {
      return null;
    }
  }

  /// Put a stored session back into the cookie jar after a process restart.
  Future<void> restoreSessionCookie() async {
    final stored = await getSessionCookie();
    if (stored == null || stored.isEmpty) return;
    await _saveSessionCookie(stored);
  }

  /// Clear session cookie (logout)
  Future<void> clearSessionCookie() async {
    try {
      await _secureStorage.delete(key: _sessionStorageKey);
      await _secureStorage.delete(key: 'sclphpsessid');
    } catch (_) {}
    await _cookieJar?.deleteAll();
  }

  /// Fetch all supercharger sites from supercharge.info
  Future<List<SitesCompanion>> fetchAllSites() async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/allSites',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      // Skip a row whose status is not one of the authoritative 8 values,
      // or that fails to parse (SPEC Section 2.1). One bad row does not
      // fail the pull.
      final sites = <SitesCompanion>[];
      for (final row in data) {
        if (row is! Map) continue;
        final parsed = _parseSite(Map<String, dynamic>.from(row));
        if (parsed != null) sites.add(parsed);
      }
      return sites;
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to fetch sites: ${response.statusCode}',
    );
  }

  /// One page of `/sites` or `/changes`. [recordCount] is the filtered total.
  Future<SuperchargePage<SitesCompanion>> fetchSitesPage({
    required int regionId,
    required int start,
    int length = sitePageLength,
  }) async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/sites',
      queryParameters: {'regionId': regionId, 'start': start, 'length': length},
    );
    return _readPage(response, parseSiteRecord);
  }

  /// One page of `/changes`, newest first.
  Future<SuperchargePage<AllChanges>> fetchChangesPage({
    required int regionId,
    required int start,
    int length = changePageLength,
  }) async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/changes',
      queryParameters: {'regionId': regionId, 'start': start, 'length': length},
    );
    return _readPage(response, parseChangeRecord);
  }

  /// Newest change id for a region, or null when the region has none.
  Future<int?> fetchNewestChangeId(int regionId) async {
    final page = await fetchChangesPage(
      regionId: regionId,
      start: 0,
      length: 1,
    );
    if (page.results.isEmpty) return null;
    return page.results.first.id;
  }

  SuperchargePage<T> _readPage<T>(
    Response<dynamic> response,
    T? Function(Map<String, dynamic> json) parse,
  ) {
    if (response.statusCode != 200 || response.data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to read supercharge.info page: ${response.statusCode}',
      );
    }
    final body = response.data as Map;
    final raw = body['results'];
    final results = <T>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is! Map) continue;
        final parsed = parse(Map<String, dynamic>.from(row));
        if (parsed != null) results.add(parsed);
      }
    }
    final recordCount =
        (body['recordCount'] as num?)?.toInt() ?? results.length;
    return SuperchargePage(results: results, recordCount: recordCount);
  }

  /// Fetch recent changes from supercharge.info
  Future<List<AllChanges>> fetchAllChanges() async {
    final response = await _dio.get(
      '$superchargeInfoBaseUrl/service/supercharge/allChanges',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      final changes = <AllChanges>[];
      for (final row in data) {
        if (row is! Map) continue;
        final parsed = parseChangeRecord(Map<String, dynamic>.from(row));
        if (parsed != null) changes.add(parsed);
      }
      return changes;
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
            .map(
              (json) =>
                  parseSiteCheckin(Map<String, dynamic>.from(json as Map)),
            )
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

  /// Submit a check-in to supercharging.life using the live multipart form.
  /// A missing or rejected session is [WriteOutcome.needsSignIn]. A transport
  /// failure is [WriteOutcome.retry]. Anything else that is not a 200 is
  /// [WriteOutcome.rejected] and should not be retried.
  Future<WriteResult> submitCheckin(CheckinDraft draft) async {
    final session = await getSessionCookie();
    if (session == null || session.isEmpty) return WriteResult.needsSignIn;
    await restoreSessionCookie();
    try {
      final response = await _dio.post(
        '$superchargingLifeBaseUrl/supercharging/checkin.php',
        data: FormData.fromMap(unofficialCheckinFields(draft)),
      );
      return writeResultFromHttp(
        statusCode: response.statusCode,
        body: response.data?.toString(),
        finalUri: response.realUri.toString(),
      );
    } on DioException catch (e) {
      return writeResultFromHttp(
        statusCode: e.response?.statusCode,
        body: '${e.response?.data ?? ''} ${e.message ?? ''}',
        finalUri:
            e.response?.realUri.toString() ?? e.requestOptions.uri.toString(),
      );
    }
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

  /// Parse a site from supercharge.info JSON into the stored companion.
  /// Returns null when the status is not one of the authoritative 8 values,
  /// or when the record cannot be parsed, so that row is skipped
  /// (SPEC Section 2.1).
  @visibleForTesting
  static SitesCompanion? parseSiteRecord(Map<String, dynamic> json) =>
      _parseSite(json);

  /// Parse one allChanges row. Returns null when the row cannot be parsed.
  @visibleForTesting
  static AllChanges? parseChangeRecord(Map<String, dynamic> json) {
    try {
      return AllChanges.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  static SitesCompanion? _parseSite(Map<String, dynamic> json) {
    try {
      final record = Map<String, dynamic>.from(json);
      final rawStatus = record['status'];
      final status = parseSiteStatus(rawStatus is String ? rawStatus : null);
      if (status == null) return null;
      // AllSites.fromJson accepts only the canonical wire spelling.
      record['status'] = _statusWireName(status);
      return companionFor(AllSites.fromJson(record));
    } catch (_) {
      return null;
    }
  }

  /// Stored row for a parsed site, including the IANA zone from its coordinates.
  static SitesCompanion companionFor(AllSites site) {
    return SitesCompanion(
      siteId: Value(site.id),
      locationId: Value(site.locationId),
      name: Value(site.name),
      status: Value(_siteStatus(site.status)),
      latitude: Value(site.gps.latitude),
      longitude: Value(site.gps.longitude),
      city: Value(site.address.city),
      state: Value(site.address.state),
      country: Value(countryValues.reverse[site.address.country] ?? 'Unknown'),
      region: Value(regionValues.reverse[site.address.region] ?? 'Unknown'),
      timezone: Value(
        TimezoneService.instance.getTimezoneForLocation(
          site.gps.latitude,
          site.gps.longitude,
        ),
      ),
      stallCount: Value(site.stallCount),
      otherEvs: Value(site.otherEVs),
      dateOpened: Value(site.dateOpened),
      lastSynced: Value(DateTime.now()),
    );
  }

  static SiteStatus _siteStatus(Status status) {
    switch (status) {
      case Status.OPEN:
        return SiteStatus.open;
      case Status.EXPANDING:
        return SiteStatus.expanding;
      case Status.CONSTRUCTION:
        return SiteStatus.construction;
      case Status.PERMIT:
        return SiteStatus.permit;
      case Status.PLAN:
        return SiteStatus.plan;
      case Status.VOTING:
        return SiteStatus.voting;
      case Status.CLOSED_TEMP:
        return SiteStatus.closedTemp;
      case Status.CLOSED_PERM:
        return SiteStatus.closedPerm;
    }
  }

  static String _statusWireName(SiteStatus status) {
    switch (status) {
      case SiteStatus.open:
        return 'OPEN';
      case SiteStatus.expanding:
        return 'EXPANDING';
      case SiteStatus.construction:
        return 'CONSTRUCTION';
      case SiteStatus.permit:
        return 'PERMIT';
      case SiteStatus.plan:
        return 'PLAN';
      case SiteStatus.voting:
        return 'VOTING';
      case SiteStatus.closedTemp:
        return 'CLOSED_TEMP';
      case SiteStatus.closedPerm:
        return 'CLOSED_PERM';
    }
  }

  /// Map a supercharge.info status string to the authoritative 8-value enum.
  /// Returns null for null/unrecognized values (caller skips the site).
  @visibleForTesting
  static SiteStatus? parseSiteStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return SiteStatus.open;
      case 'EXPANDING':
        return SiteStatus.expanding;
      case 'CONSTRUCTION':
        return SiteStatus.construction;
      case 'PERMIT':
        return SiteStatus.permit;
      case 'PLAN':
        return SiteStatus.plan;
      case 'VOTING':
        return SiteStatus.voting;
      case 'CLOSED_TEMP':
        return SiteStatus.closedTemp;
      case 'CLOSED_PERM':
        return SiteStatus.closedPerm;
      default:
        return null;
    }
  }

  /// Parse a site check-in from supercharging.life JSON.
  ///
  /// `checkin_date` is the calendar date shown on Check-in Detail.
  /// `checkin_time` is the clock when the history row has one. A short offset
  /// such as `-05` is normalized before parsing.
  @visibleForTesting
  static SiteCheckinsCompanion parseSiteCheckin(Map<String, dynamic> json) {
    DateTime checkinDate;
    try {
      checkinDate = DateTime.parse(json['checkin_date'] as String);
    } catch (_) {
      checkinDate = DateTime.now();
    }

    final checkinTime =
        parseLifeTimestamp(json['checkin_time'] as String?) ?? checkinDate;

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
      syncedAt: Value(DateTime.now()),
    );
  }
}

/// A supercharge.info datatable page. [recordCount] is the filtered total,
/// not the size of this page.
class SuperchargePage<T> {
  final List<T> results;
  final int recordCount;

  const SuperchargePage({required this.results, required this.recordCount});
}
