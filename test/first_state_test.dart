import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/first_state.dart';
import 'package:supercharger_bingo/services/timezone_service.dart';

import 'support/test_sqlite3.dart';

/// Noon in Denver (UTC-6 in May) on 2026-05-[day].
DateTime denverNoon(int day) => DateTime.utc(2026, 5, day, 18);

SiteCheckin row(int id, int day, {bool first = true}) => SiteCheckin(
  id: id,
  checkinId: id,
  siteId: 1,
  odUserId: id,
  username: 'user$id',
  checkinDate: DateTime.utc(2026, 5, day),
  // A different UTC day must not shift the feed's site-local date.
  checkinTime: DateTime.utc(2026, 5, day + 1, 1),
  isFirstAtSupercharger: first,
  syncedAt: DateTime.utc(2026, 5, 20),
);

Visit visit(
  DateTime at, {
  CheckinPrecision precision = CheckinPrecision.timestamp,
}) => Visit(
  id: 1,
  siteId: 1,
  checkinDate: at,
  checkinTime: at,
  checkinPrecision: precision,
  isFirst: false,
  method: CheckinMethod.manual,
  importedAt: at,
);

void main() {
  late AppDatabase db;

  setUpAll(() async {
    registerTestSqlite3();
    await TimezoneService.instance.initialize();
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
  });
  tearDownAll(() => db.close());

  Site site({
    SiteStatus status = SiteStatus.open,
    DateTime? opened,
    DateTime? firstOpened,
    bool count = true,
  }) => Site(
    id: 1,
    siteId: 1,
    name: 'Test',
    status: status,
    latitude: 39.74,
    longitude: -104.99,
    country: 'USA',
    region: 'North America',
    timezone: 'America/Denver',
    stallsV2: 0,
    stallsV3: 8,
    stallsV4: 0,
    stallsUrban: 0,
    stallsOther: 0,
    otherEvs: false,
    dateOpened: opened,
    firstOpened: firstOpened,
    hasCheckins: count,
    visited: false,
  );

  final may2 = DateTime.utc(2026, 5, 2);

  // (description, site, history, visits, now, expected)
  final cases =
      <(String, Site, List<SiteCheckin>, List<Visit>, DateTime, FirstState?)>[
        (
          'no Check-ins: up for grabs',
          site(count: false),
          [],
          [],
          denverNoon(2),
          FirstState.upForGrabs,
        ),
        (
          'counted but history missing: First passed',
          site(opened: may2),
          [],
          [],
          denverNoon(2),
          FirstState.passed,
        ),
        (
          'unknown Opening date and missing history: First passed',
          site(),
          [],
          [],
          denverNoon(2),
          FirstState.passed,
        ),
        (
          'First today',
          site(opened: may2),
          [row(1, 2)],
          [],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'First yesterday: passed',
          site(opened: may2),
          [row(1, 2)],
          [],
          denverNoon(3),
          FirstState.passed,
        ),
        (
          'First today until site-local midnight, past UTC midnight',
          site(opened: may2),
          [row(1, 2)],
          [],
          DateTime.utc(2026, 5, 3, 5, 30),
          FirstState.today,
        ),
        (
          'earliest flagged day wins',
          site(),
          [row(2, 2), row(1, 1)],
          [],
          denverNoon(2),
          FirstState.passed,
        ),
        (
          'pre-opening First never counts',
          site(opened: may2),
          [row(1, 1)],
          [],
          denverNoon(2),
          FirstState.upForGrabs,
        ),
        (
          'pre-opening unflagged row does not trigger the count fallback',
          site(opened: may2),
          [row(1, 1, first: false)],
          [],
          denverNoon(2),
          FirstState.upForGrabs,
        ),
        (
          'invalid upstream First promotes the later unflagged rows',
          site(opened: may2),
          [row(1, 1), row(2, 2, first: false)],
          [],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'opening day itself qualifies',
          site(opened: may2),
          [row(1, 1), row(2, 2)],
          [],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'earliest opening wins over a later reopening',
          site(opened: DateTime.utc(2026, 5, 15), firstOpened: may2),
          [row(1, 1), row(2, 2)],
          [],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'repeat visitors only: First passed',
          site(),
          [row(1, 2, first: false)],
          [],
          denverNoon(2),
          FirstState.passed,
        ),
        (
          'repeat visitors without counts: up for grabs',
          site(count: false),
          [row(1, 2, first: false)],
          [],
          denverNoon(2),
          FirstState.upForGrabs,
        ),
        (
          'confirmed Visit takes an unclaimed First',
          site(count: false),
          [],
          [visit(denverNoon(2))],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'confirmed Visit counts on its site-local day',
          site(count: false),
          [],
          [visit(DateTime.utc(2026, 5, 2, 5, 30))],
          denverNoon(2),
          FirstState.passed,
        ),
        (
          'date-only Visit uses its calendar date',
          site(count: false),
          [],
          [visit(may2, precision: CheckinPrecision.dateOnly)],
          denverNoon(2),
          FirstState.today,
        ),
        (
          'Visit before the Opening date never counts',
          site(opened: DateTime.utc(2026, 5, 3), count: false),
          [],
          [visit(denverNoon(2))],
          denverNoon(3),
          FirstState.upForGrabs,
        ),
        (
          'earlier Visit beats a later community First',
          site(),
          [row(1, 3)],
          [visit(denverNoon(2))],
          denverNoon(3),
          FirstState.passed,
        ),
        for (final status in [
          SiteStatus.construction,
          SiteStatus.plan,
          SiteStatus.permit,
          SiteStatus.voting,
          SiteStatus.closedTemp,
          SiteStatus.closedPerm,
        ])
          (
            '${status.name} has no First state',
            site(status: status),
            [row(1, 2)],
            [],
            denverNoon(2),
            null,
          ),
      ];

  group('First rule', () {
    for (final (name, s, history, visits, now, expected) in cases) {
      test(name, () {
        expect(
          firstStateOf(s, history: history, visits: visits, now: now),
          expected,
        );
      });
    }
  });

  test('First-eligible is up for grabs or First today', () {
    expect(isFirstEligible(FirstState.upForGrabs), isTrue);
    expect(isFirstEligible(FirstState.today), isTrue);
    expect(isFirstEligible(FirstState.passed), isFalse);
    expect(isFirstEligible(null), isFalse);
  });

  group('database evidence', () {
    setUp(() async {
      await db.delete(db.siteCheckins).go();
      await db.delete(db.visits).go();
      await db.delete(db.outboxEntries).go();
    });

    Future<void> history(List<(int, int, String, bool)> rows) =>
        db.upsertSiteCheckins([
          for (final (id, day, name, first) in rows)
            SiteCheckinsCompanion.insert(
              checkinId: id,
              siteId: 1,
              odUserId: id,
              username: name,
              checkinDate: DateTime.utc(2026, 5, day),
              checkinTime: DateTime.utc(2026, 5, day, 15 + id),
              isFirstAtSupercharger: Value(first),
              syncedAt: DateTime.utc(2026, 5, 20),
            ),
        ]);

    test('a shared First lists everyone that day, in check-in order', () async {
      await history([
        (4, 3, 'late', true),
        (3, 2, 'theflyer', true),
        (2, 2, 'Bighorn', true),
        (1, 4, 'smithg13', false),
      ]);
      expect(await firstDayNames(site(opened: may2)), ['Bighorn', 'theflyer']);
      // Premature Firsts move the First to the next qualifying day.
      expect(await firstDayNames(site(opened: DateTime.utc(2026, 5, 3))), [
        'late',
      ]);
    });

    test('only confirmed Visits count, Pending ones do not', () async {
      final at = denverNoon(2);
      final confirmed = await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              siteId: 1,
              checkinDate: at,
              checkinTime: at,
              importedAt: at,
            ),
          );
      final pending = await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              siteId: 1,
              checkinDate: at,
              checkinTime: at,
              importedAt: at,
            ),
          );
      await db
          .into(db.outboxEntries)
          .insert(OutboxEntriesCompanion.insert(visitId: Value(pending)));
      final evidence = await db.getFirstEvidence([1]);
      expect(evidence.visits[1]!.map((v) => v.id), [confirmed]);

      await db.delete(db.visits).go();
      final now = DateTime.now();
      await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              siteId: 1,
              checkinDate: now,
              checkinTime: now,
              importedAt: now,
            ),
          );
      final states = await firstStates([
        site(count: false),
        site(status: SiteStatus.construction).copyWith(siteId: 2),
      ], now);
      expect(states, {1: FirstState.today});
    });
  });
}
