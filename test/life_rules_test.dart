import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/checkin_rules.dart';
import 'package:supercharger_bingo/services/life_time.dart';
import 'package:supercharger_bingo/services/supercharge_region.dart';
import 'package:supercharger_bingo/services/timezone_service.dart';
import 'package:supercharger_bingo/services/vehicle_service.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(() async {
    registerTestSqlite3();
    await TimezoneService.instance.initialize();
  });

  test('short supercharging.life offsets parse as a clock time', () {
    final parsed = parseLifeTimestamp('2026-11-10 00:05:53-05');
    expect(parsed, DateTime.utc(2026, 11, 10, 5, 5, 53));
    expect(
      parseLifeTimestamp('2026-11-10 00:05:53-0500'),
      DateTime.utc(2026, 11, 10, 5, 5, 53),
    );
    expect(parseLifeTimestamp(null), isNull);
    expect(parseLifeTimestamp(''), isNull);
  });

  test('history rows keep the calendar date and the parsed clock', () {
    final row = ApiService.parseSiteCheckin({
      'checkin_id': '1',
      'supercharger_id': '2',
      'user_id': '3',
      'user_username': 'driver',
      'user_displayname': 'Driver',
      'checkin_date': '2026-11-10',
      'checkin_time': '2026-11-10 00:05:53-05',
      'is_first_at_supercharger_cache': 'N',
    });
    expect(row.checkinDate.value, DateTime.parse('2026-11-10'));
    expect(row.checkinTime.value, DateTime.utc(2026, 11, 10, 5, 5, 53));
  });

  test('date-only formatting drops the clock', () {
    expect(
      formatLifeDateField(
        DateTime(2026, 5, 1, 15, 30, 45),
        precision: CheckinPrecision.dateOnly,
      ),
      '2026-05-01',
    );
    expect(
      formatLifeDateField(
        DateTime.utc(2026, 5, 1, 15, 4, 5),
        precision: CheckinPrecision.timestamp,
      ),
      startsWith('2026-05-01 15:04:05'),
    );
  });

  test('region ids match the live supercharge.info boxes', () {
    expect(SuperchargeRegion.forCoordinates(39.7, -105), 100);
    expect(SuperchargeRegion.forCoordinates(48.8, 2.3), 101);
    expect(SuperchargeRegion.forCoordinates(32.07, 34.79), 102);
    expect(SuperchargeRegion.forCoordinates(31.28, 36.05), 102);
    expect(SuperchargeRegion.forCoordinates(-33.9, 151.2), 102);
    expect(SuperchargeRegion.forCoordinates(-34.9, -56.2), 103);
  });

  test('Denver coordinates resolve to America/Denver', () {
    expect(
      TimezoneService.instance.getTimezoneForLocation(39.7392, -104.9903),
      'America/Denver',
    );
  });

  test('a check-in before the local open date is rejected', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 1,
        name: 'Denver',
        latitude: const Value(39.7392),
        longitude: const Value(-104.9903),
        timezone: const Value('America/Denver'),
        dateOpened: Value(DateTime.utc(2026, 5, 2)),
      ),
    );
    final site = (await db.getSiteBySiteId(1))!;
    expect(checkinPrecedesOpening(site, DateTime.utc(2026, 5, 2, 5)), isTrue);
    expect(checkinPrecedesOpening(site, DateTime.utc(2026, 5, 2, 7)), isFalse);
    expect(
      checkinPrecedesOpening(
        site,
        DateTime.utc(2026, 5, 1),
        precision: CheckinPrecision.dateOnly,
      ),
      isTrue,
    );
    expect(
      checkinPrecedesOpening(
        site,
        DateTime.utc(2026, 5, 2),
        precision: CheckinPrecision.dateOnly,
      ),
      isFalse,
    );

    await db.upsertSite(
      SitesCompanion.insert(
        siteId: 2,
        name: 'Undated',
        timezone: const Value('America/Denver'),
      ),
    );
    final undated = (await db.getSiteBySiteId(2))!;
    expect(undated.dateOpened, isNull);
    expect(checkinPrecedesOpening(undated, DateTime.utc(2020, 1, 1)), isFalse);
  });

  test('manual vehicle fields are kept when a decode arrives', () {
    final merged = mergeVehicleFields(
      current: const VehicleDecode(make: 'Rivian', model: ''),
      decoded: const VehicleDecode(
        make: 'Tesla',
        model: 'Model Y',
        year: '2024',
        trim: 'Long Range',
      ),
      edited: {'make'},
    );
    expect(merged.make, 'Rivian');
    expect(merged.model, 'Model Y');
    expect(merged.year, '2024');
    expect(merged.trim, 'Long Range');
  });
}
