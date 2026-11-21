import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/connection/native.dart';
import 'package:supercharger_bingo/database/database.dart';

void main() {
  // Contention itself cannot be tested here: under flutter test, SQLite's
  // busy-wait sleeps return early, so it gives up after about 1% of the
  // timeout. In a plain Dart process and on Android the wait is real.
  test('every engine opens the file with a 5 s busy timeout', () async {
    final dir = await Directory.systemTemp.createTemp('bingo_db');
    addTearDown(() => dir.delete(recursive: true));
    final db = AppDatabase(
      openDatabaseFile(File('${dir.path}/supercharger_bingo.sqlite')),
    );
    addTearDown(db.close);
    final row = await db.customSelect('PRAGMA busy_timeout').getSingle();
    expect(row.data.values.single, 5000);
  });
}
