import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supercharger_bingo/services/location_service.dart';

Position _at(Duration age) => Position(
  latitude: 40.06,
  longitude: -82.99,
  timestamp: DateTime.now().subtract(age),
  accuracy: 69,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a check-in reuses a fix under a minute old', () async {
    final recent = _at(const Duration(seconds: 10));
    expect(await LocationService.instance.checkinFix(recent: recent), recent);
  });

  test('a check-in never sends an hours-old fix', () async {
    // The 2026-11-19 check-ins sent a fix 6.5 hours old. With no GPS here,
    // the check-in gets no coordinates rather than stale ones.
    final stale = _at(const Duration(hours: 6));
    expect(await LocationService.instance.checkinFix(recent: stale), isNull);
  });

  test('a denied location does not retry at another accuracy', () async {
    const channel = MethodChannel('flutter.baseflow.com/geolocator');
    var requests = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getCurrentPosition') {
        requests++;
        throw PlatformException(code: 'PERMISSION_DENIED', message: 'Denied');
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    expect(await LocationService.instance.checkinFix(), isNull);
    expect(requests, 1);
  });
}
