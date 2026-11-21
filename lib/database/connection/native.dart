import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor connect() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return openDatabaseFile(
      File(p.join(dbFolder.path, 'supercharger_bingo.sqlite')),
    );
  });
}

/// Several engines (app, background alerts, nearest site) open this file.
/// Each waits up to 5 s for another engine's write instead of failing with
/// SQLITE_BUSY.
QueryExecutor openDatabaseFile(File file) => NativeDatabase.createInBackground(
  file,
  setup: (db) => db.execute('PRAGMA busy_timeout = 5000'),
);
