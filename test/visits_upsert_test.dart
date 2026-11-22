import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  VisitsCompanion visit({required int checkinId, required bool isFirst}) {
    return VisitsCompanion(
      checkinId: Value(checkinId),
      siteId: const Value(9409),
      checkinDate: Value(DateTime(2026, 3, 16)),
      checkinTime: Value(DateTime(2026, 3, 16, 12)),
      isFirst: Value(isFirst),
      importedAt: Value(DateTime.now()),
    );
  }

  for (final batch in [false, true]) {
    test(
      'a site loaded after its imported visit stays visited (batch: $batch)',
      () async {
        await db.addVisit(visit(checkinId: 90105, isFirst: false));
        final site = SitesCompanion.insert(siteId: 9409, name: 'Imported site');
        if (batch) {
          await db.upsertSites([site]);
        } else {
          await db.upsertSite(site);
        }
        expect((await db.getSiteBySiteId(9409))!.visited, isTrue);
      },
    );
  }

  test(
    're-importing a visit upserts instead of failing on checkin_id',
    () async {
      await db.addVisit(visit(checkinId: 90105, isFirst: false));
      // Same supercharging.life check-in id imported again (XLSX re-sync).
      await db.addVisit(visit(checkinId: 90105, isFirst: true));

      final all = await db.getAllVisits();
      expect(all, hasLength(1));
      expect(all.first.isFirst, isTrue);
    },
  );

  test(
    'import reconciles a unique synced local visit without losing its row',
    () async {
      final imported = visit(checkinId: 90105, isFirst: false);
      await db.addVisit(
        imported.copyWith(
          checkinId: const Value(null),
          checkinDate: imported.checkinTime,
        ),
      );
      final localId = (await db.getAllVisits()).single.id;
      await db.reconcileVisitIds([imported]);
      await db.addVisit(imported);
      final all = await db.getAllVisits();
      expect(all, hasLength(1));
      expect(all.single.id, localId);
      expect(all.single.checkinId, 90105);
    },
  );

  test(
    'import does not guess IDs for ambiguous local or server visits',
    () async {
      final imported = visit(checkinId: 90105, isFirst: false);
      await db.addVisit(
        imported.copyWith(
          checkinId: const Value(null),
          checkinDate: imported.checkinTime,
        ),
      );
      await db.reconcileVisitIds([
        imported,
        visit(checkinId: 90106, isFirst: false),
      ]);
      expect((await db.getAllVisits()).single.checkinId, isNull);
      await db.addVisit(
        imported.copyWith(
          checkinId: const Value(null),
          checkinDate: imported.checkinTime,
        ),
      );
      await db.reconcileVisitIds([imported]);
      expect(
        (await db.getAllVisits()).every((v) => v.checkinId == null),
        isTrue,
      );
    },
  );

  test('date-only visits cannot acquire an ID by date alone', () async {
    final imported = visit(
      checkinId: 90105,
      isFirst: false,
    ).copyWith(checkinPrecision: const Value(CheckinPrecision.dateOnly));
    await db.addVisit(imported.copyWith(checkinId: const Value(null)));
    await db.reconcileVisitIds([imported]);
    expect((await db.getAllVisits()).single.checkinId, isNull);
  });

  test(
    'legacy direct visits match submitted time rather than response time',
    () async {
      final imported = visit(checkinId: 90105, isFirst: false);
      await db.addVisit(
        imported.copyWith(
          checkinId: const Value(null),
          checkinDate: imported.checkinTime,
          checkinTime: Value(
            imported.checkinTime.value.add(const Duration(seconds: 3)),
          ),
        ),
      );
      final localId = (await db.getAllVisits()).single.id;
      await db.reconcileVisitIds([imported]);
      await db.addVisit(imported);
      final all = await db.getAllVisits();
      expect(all, hasLength(1));
      expect(all.single.id, localId);
      expect(all.single.checkinId, 90105);
      await db.deleteVisit(all.single);
      expect(await db.getAllVisits(), isEmpty);
    },
  );
}
