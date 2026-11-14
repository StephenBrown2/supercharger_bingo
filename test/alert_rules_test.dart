import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/models/supercharge_info.dart';
import 'package:supercharger_bingo/services/alert_rules.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/database_service.dart';

import 'support/test_sqlite3.dart';

Map<String, dynamic> _change({
  required int id,
  required String changeType,
  required String siteStatus,
  String? prevStatus,
}) {
  return {
    'id': id,
    'siteId': 50,
    'date': '2024-01-15',
    'changeType': changeType,
    'siteStatus': siteStatus,
    'prevStatus': prevStatus,
    'stallCount': 8,
    'prevCount': 8,
    'powerKilowatt': 250,
    'notify': true,
    'siteName': 'Denver',
    'regionId': 100,
    'region': 'North America',
    'countryId': 1,
    'country': 'USA',
    'state': 'CO',
    'dateFormatted': 'Jan 15, 2024',
    'site': {
      'id': 50,
      'name': 'Denver',
      'status': siteStatus,
      'address': {
        'street': '1 Main',
        'city': 'Denver',
        'state': 'CO',
        'zip': '80202',
        'countryId': 1,
        'country': 'USA',
        'regionId': 100,
        'region': 'North America',
      },
      'gps': {'latitude': 39.7, 'longitude': -104.9},
      'stallCount': 8,
      'counted': true,
      'elevationMeters': 1600,
      'powerKilowatt': 250,
      'solarCanopy': false,
      'battery': false,
      'otherEVs': false,
      'statusDays': 1,
      'urlDiscuss': false,
    },
  };
}

AllChanges _parsed({
  required int id,
  required String changeType,
  required String siteStatus,
  String? prevStatus,
}) {
  return ApiService.parseChangeRecord(
    _change(
      id: id,
      changeType: changeType,
      siteStatus: siteStatus,
      prevStatus: prevStatus,
    ),
  )!;
}

void main() {
  test('opening changes are ADD or UPDATE into OPEN', () {
    expect(
      isOpeningChange(_parsed(id: 1, changeType: 'ADD', siteStatus: 'OPEN')),
      isTrue,
    );
    expect(
      isOpeningChange(
        _parsed(
          id: 2,
          changeType: 'UPDATE',
          siteStatus: 'OPEN',
          prevStatus: 'CONSTRUCTION',
        ),
      ),
      isTrue,
    );
    expect(
      isOpeningChange(
        _parsed(
          id: 3,
          changeType: 'UPDATE',
          siteStatus: 'OPEN',
          prevStatus: 'OPEN',
        ),
      ),
      isFalse,
    );
    expect(
      isOpeningChange(_parsed(id: 4, changeType: 'UPDATE', siteStatus: 'OPEN')),
      isFalse,
    );
    expect(
      isOpeningChange(
        _parsed(id: 5, changeType: 'ADD', siteStatus: 'CONSTRUCTION'),
      ),
      isFalse,
    );
  });

  test('the First window is only the yellow pin', () {
    final today = DateTime(2026, 11, 10, 15);
    expect(
      isInFirstWindow(earliestCheckin: null, siteLocalNow: today),
      isFalse,
    );
    expect(
      isInFirstWindow(
        earliestCheckin: DateTime(2026, 11, 10, 1),
        siteLocalNow: today,
      ),
      isTrue,
    );
    expect(
      isInFirstWindow(
        earliestCheckin: DateTime(2026, 11, 9),
        siteLocalNow: today,
      ),
      isFalse,
    );
  });

  test('the first poll records a cursor and does not alert', () {
    final plan = planOpeningAlerts(
      changes: [_parsed(id: 9, changeType: 'ADD', siteStatus: 'OPEN')],
      lastNotifiedChangeId: null,
      notifyNewSites: true,
    );
    expect(plan.toAlert, isEmpty);
    expect(plan.nextCursor, 9);
  });

  test('later polls alert only new openings and still advance the cursor', () {
    final plan = planOpeningAlerts(
      changes: [
        _parsed(id: 6, changeType: 'ADD', siteStatus: 'OPEN'),
        _parsed(id: 7, changeType: 'UPDATE', siteStatus: 'OPEN'),
      ],
      lastNotifiedChangeId: 5,
      notifyNewSites: true,
    );
    expect(plan.toAlert.map((change) => change.id), [6]);
    expect(plan.nextCursor, 7);

    final muted = planOpeningAlerts(
      changes: [_parsed(id: 8, changeType: 'ADD', siteStatus: 'OPEN')],
      lastNotifiedChangeId: 5,
      notifyNewSites: false,
    );
    expect(muted.toAlert, isEmpty);
    expect(muted.nextCursor, 8);
  });

  test('a notification claim is once per site, channel, and key', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerTestSqlite3();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await DatabaseService.initialize(database: db);

    expect(
      await DatabaseService.claimNotification(
        siteId: 1,
        channel: 'first_eligible',
        dedupeKey: '2026-11-10',
      ),
      isTrue,
    );
    expect(
      await DatabaseService.claimNotification(
        siteId: 1,
        channel: 'first_eligible',
        dedupeKey: '2026-11-10',
      ),
      isFalse,
    );
    expect(
      await DatabaseService.claimNotification(
        siteId: 1,
        channel: 'first_eligible',
        dedupeKey: '2026-11-11',
      ),
      isTrue,
    );
  });

  test('formatTimeLeft', () {
    expect(formatTimeLeft(const Duration(seconds: 30)), 'under a minute');
    expect(formatTimeLeft(const Duration(minutes: 45, seconds: 59)), '45m');
    expect(formatTimeLeft(const Duration(hours: 5, minutes: 12)), '5h 12m');
    expect(formatTimeLeft(const Duration(hours: 23, minutes: 59)), '23h 59m');
  });
}
