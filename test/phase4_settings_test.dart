import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show Value, Migrator;
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
    expect(settings.clusterMarkers, isTrue);
  });

  test('v15 upgrade preserves settings and adds clustering defaults', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.getUserSettings();
    await db.updateUserSettings(
      const UserSettingsTableCompanion(username: Value('existing')),
    );
    await db.customStatement(
      'ALTER TABLE user_settings DROP COLUMN cluster_markers',
    );
    await db.migration.onUpgrade(Migrator(db), 15, 16);
    final settings = await db.getUserSettings();
    expect(settings.username, 'existing');
    expect(settings.clusterMarkers, isTrue);
  });
}
