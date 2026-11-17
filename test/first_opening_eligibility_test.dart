import 'package:drift/drift.dart' show Value, Migrator;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/alert_rules.dart';
import 'package:supercharger_bingo/services/checkin_rules.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> site({
    SiteStatus status = SiteStatus.open,
    DateTime? opened,
    bool count = true,
  }) => db.upsertSite(
    SitesCompanion.insert(
      siteId: 1,
      name: 'Test',
      status: Value(status),
      timezone: const Value('America/Denver'),
      dateOpened: Value(opened),
      hasCheckins: Value(count),
    ),
  );

  Future<void> visit(int id, int day, {bool first = true}) =>
      db.upsertSiteCheckins([
        SiteCheckinsCompanion.insert(
          checkinId: id,
          siteId: 1,
          odUserId: id,
          username: 'user$id',
          checkinDate: DateTime.utc(2026, 5, day),
          // A different UTC day must not shift the feed's site-local date.
          checkinTime: DateTime.utc(2026, 5, day + 1, 1),
          isFirstAtSupercharger: Value(first),
          syncedAt: DateTime.utc(2026, 5, 5),
        ),
      ]);

  test(
    'original opening preserves First and check-in acceptance before reopening',
    () async {
      await site(opened: DateTime.utc(2026, 5, 15));
      await db.recordFirstOpeningDates({1: DateTime.utc(2026, 5, 2)});
      await visit(1, 1);
      await visit(2, 2);
      expect(await db.getEarliestCheckinDates([1]), {1: DateTime(2026, 5, 2)});
      expect(await db.getFirstCheckinNames(1), ['user2']);
      final reopened = (await db.getSiteBySiteId(1))!;
      expect(
        checkinPrecedesOpening(
          reopened,
          DateTime.utc(2026, 5, 2),
          precision: CheckinPrecision.dateOnly,
        ),
        isFalse,
      );
    },
  );

  test('refresh preserves an earlier listed opening across a reopen', () async {
    await site(opened: DateTime.utc(2026, 5, 2));
    await site(opened: DateTime.utc(2026, 5, 15));
    await db.recordFirstOpeningDates({1: DateTime.utc(2026, 5, 3)});
    expect(
      (await db.getSiteBySiteId(1))!.firstOpeningDay!.toUtc(),
      DateTime.utc(2026, 5, 2),
    );
  });

  test(
    'v18 migration adds opening evidence without removing history',
    () async {
      await site(opened: DateTime.utc(2026, 5, 2));
      await visit(1, 1);
      await db.upsertRegionSync(100, 900);
      await db.customStatement('ALTER TABLE sites DROP COLUMN first_opened');
      await db.migration.onUpgrade(Migrator(db), 17, 18);
      expect((await db.getSiteBySiteId(1))!.firstOpened, isNull);
      expect(await db.getSiteCheckins(1), hasLength(1));
      expect((await db.getRegionSync(100))!.lastChangeId, 0);
      await db.recordFirstOpeningDates({1: DateTime.utc(2026, 5, 2)});
      expect(
        (await db.getSiteBySiteId(1))!.firstOpened!.toUtc(),
        DateTime.utc(2026, 5, 2),
      );
    },
  );

  test(
    'v18 upgrade preserves legacy local calendar days before a resync',
    () async {
      await site(opened: DateTime(2026, 5, 2));
      final clock = DateTime.utc(2026, 5, 1, 12, 34);
      await db.upsertSiteCheckins([
        SiteCheckinsCompanion.insert(
          checkinId: 1,
          siteId: 1,
          odUserId: 1,
          username: 'early',
          checkinDate: DateTime(2026, 5, 1),
          checkinTime: clock,
          isFirstAtSupercharger: const Value(true),
          syncedAt: clock,
        ),
      ]);
      await db.migration.onUpgrade(Migrator(db), 17, 18);
      expect(
        (await db.getSiteBySiteId(1))!.dateOpened!.toUtc(),
        DateTime.utc(2026, 5, 2),
      );
      final history = (await db.getSiteCheckins(1)).single;
      expect(history.checkinDate.toUtc(), DateTime.utc(2026, 5, 1));
      expect(history.checkinTime.toUtc(), clock);
      // Refreshing the row must not cache the previous UTC day as firstOpened.
      await site(opened: DateTime.utc(2026, 5, 2));
      await visit(1, 1);
      expect(await db.getEarliestCheckinDates([1]), isEmpty);
    },
  );

  test(
    'pre-opening First plus positive counts leaves no award or countdown',
    () async {
      await site(opened: DateTime.utc(2026, 5, 2));
      await visit(1, 1);
      final dates = await db.getEarliestCheckinDates([1]);
      expect(dates, isEmpty);
      expect(await db.getFirstCheckinNames(1), isEmpty);
      expect(
        isInFirstWindow(
          earliestCheckin: dates[1],
          siteLocalNow: DateTime(2026, 5, 2, 12),
        ),
        isFalse,
      );
      final history = await db.getSiteCheckins(1);
      expect(history, hasLength(1));
      expect(history.single.isFirstAtSupercharger, isTrue);
    },
  );

  test(
    'invalid upstream First does not hide later unflagged shared Firsts',
    () async {
      await site(opened: DateTime.utc(2026, 5, 2));
      await visit(1, 1);
      await visit(2, 2, first: false);
      await visit(3, 2, first: false);
      await visit(4, 3, first: false);
      expect(await db.getEarliestCheckinDates([1]), {1: DateTime(2026, 5, 2)});
      expect(await db.getFirstCheckinNames(1), ['user2', 'user3']);
      expect(await db.getSiteCheckins(1), hasLength(4));
    },
  );

  test(
    'unflagged premature visits cannot activate the count fallback',
    () async {
      await site(opened: DateTime.utc(2026, 5, 2));
      await visit(1, 1, first: false);
      expect(await db.getEarliestCheckinDates([1]), isEmpty);
      expect(await db.getSiteCheckins(1), hasLength(1));
    },
  );

  for (final status in [
    SiteStatus.plan,
    SiteStatus.permit,
    SiteStatus.construction,
    SiteStatus.voting,
  ]) {
    test(
      '${status.name} cannot consume First with or without an opening date',
      () async {
        await visit(1, 2);
        for (final opened in [null, DateTime.utc(2026, 5, 2)]) {
          await site(status: status, opened: opened);
          expect(await db.getEarliestCheckinDates([1]), isEmpty);
          expect(await db.getFirstCheckinNames(1), isEmpty);
        }
      },
    );
  }

  test('closed sites keep legitimate opening-day Firsts', () async {
    await site(status: SiteStatus.closedPerm, opened: DateTime.utc(2026, 5, 2));
    await visit(1, 1);
    await visit(2, 2);
    expect(await db.getEarliestCheckinDates([1]), {1: DateTime(2026, 5, 2)});
    expect(await db.getFirstCheckinNames(1), ['user2']);
  });

  test(
    'older counted sites stay claimed without inventing a countdown',
    () async {
      await site(opened: DateTime.utc(2026, 5, 2));
      final dates = await db.getEarliestCheckinDates([1]);
      expect(dates, {1: DateTime(2000)});
      expect(
        isInFirstWindow(
          earliestCheckin: dates[1],
          siteLocalNow: DateTime(2026, 5, 2, 12),
        ),
        isFalse,
      );
    },
  );

  test(
    'unknown operational opening keeps conservative claimed fallback',
    () async {
      await site();
      expect(await db.getEarliestCheckinDates([1]), {1: DateTime(2000)});
      expect(await db.getFirstCheckinNames(1), isEmpty);
      await visit(1, 2, first: false);
      expect(await db.getFirstCheckinNames(1), isEmpty);
      await visit(2, 3);
      expect(await db.getFirstCheckinNames(1), ['user2']);
    },
  );
}
