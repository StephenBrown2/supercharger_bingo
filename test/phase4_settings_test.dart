import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  test('default user settings use imperial units (SPEC Section 7)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final settings = await db.getUserSettings();
    expect(settings.unitSystem, UnitSystem.imperial);
    expect(settings.includeVisitedNearby, isFalse);
    expect(settings.includeVehicleInPrivateNote, isFalse);
    expect(settings.notifyNewSites, isTrue);
    expect(settings.notifyFirstEligible, isTrue);
    expect(settings.appAppearance, AppAppearance.system);
  });
}
