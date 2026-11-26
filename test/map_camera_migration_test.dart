import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';

void main() {
  test('v24 adds the saved map view to a v23 database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.getUserSettings();
    for (final column in ['map_latitude', 'map_longitude', 'map_zoom']) {
      await db.customStatement('ALTER TABLE user_settings DROP COLUMN $column');
    }

    await db.migration.onUpgrade(Migrator(db), 23, 24);
    await db.updateUserSettings(
      const UserSettingsTableCompanion(
        mapLatitude: Value(39.4),
        mapLongitude: Value(-76.6),
        mapZoom: Value(11),
      ),
    );

    final settings = await db.getUserSettings();
    expect(
      [settings.mapLatitude, settings.mapLongitude, settings.mapZoom],
      [39.4, -76.6, 11],
    );
  });
}
