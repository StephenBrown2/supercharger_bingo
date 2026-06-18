import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Fields decoded from a VIN via NHTSA vPIC. Only these derived values are ever
/// persisted or shown (and only when the user opts in); the raw VIN is not.
class VehicleDecode {
  final String? make;
  final String? model;
  final String? year;
  final String? trim;

  const VehicleDecode({this.make, this.model, this.year, this.trim});

  bool get isEmpty =>
      make == null && model == null && year == null && trim == null;
}

/// Handles the sensitive parts of vehicles: VIN storage (encrypted at rest via
/// flutter_secure_storage, never displayed) and the one-time online vPIC
/// decode (SPEC Section 8). US-centric; manual entry remains available.
class VehicleService {
  static VehicleService? _instance;
  static VehicleService get instance => _instance ??= VehicleService._();

  VehicleService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static const String _vpicBase = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  String _vinKey(String vehicleId) => 'vehicle_vin_$vehicleId';

  Future<void> storeVin(String vehicleId, String vin) =>
      _secureStorage.write(key: _vinKey(vehicleId), value: vin);

  Future<String?> readVin(String vehicleId) =>
      _secureStorage.read(key: _vinKey(vehicleId));

  Future<void> deleteVin(String vehicleId) =>
      _secureStorage.delete(key: _vinKey(vehicleId));

  /// One-time online decode of a VIN. Returns null on network/HTTP failure so
  /// callers can fall back to manual entry.
  Future<VehicleDecode?> decodeVin(String vin) async {
    try {
      final response = await _dio.get(
        '$_vpicBase/decodevin/$vin',
        queryParameters: {'format': 'json'},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return parseVpicResults(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Swallow: offline decode is acceptable, manual entry remains.
    }
    return null;
  }

  /// Parse a vPIC `decodevin` response body into the four derived fields.
  @visibleForTesting
  static VehicleDecode parseVpicResults(Map<String, dynamic> json) {
    final results = json['Results'];
    if (results is! List) return const VehicleDecode();

    final byVariable = <String, String>{};
    for (final entry in results) {
      if (entry is Map) {
        final variable = entry['Variable']?.toString();
        final value = entry['Value']?.toString();
        if (variable != null && value != null && value.isNotEmpty) {
          byVariable[variable] = value;
        }
      }
    }

    return VehicleDecode(
      make: byVariable['Make'],
      model: byVariable['Model'],
      year: byVariable['Model Year'],
      trim: byVariable['Trim'],
    );
  }
}
