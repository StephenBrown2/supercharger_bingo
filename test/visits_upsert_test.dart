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

  test('re-importing a visit upserts instead of failing on checkin_id', () async {
    await db.addVisit(visit(checkinId: 90105, isFirst: false));
    // Same supercharging.life check-in id imported again (XLSX re-sync).
    await db.addVisit(visit(checkinId: 90105, isFirst: true));

    final all = await db.getAllVisits();
    expect(all, hasLength(1));
    expect(all.first.isFirst, isTrue);
  });
}
