import '../database/database.dart';

// Conditional import for platform-specific database connection
import '../database/connection/connection.dart'
    if (dart.library.ffi) '../database/connection/native.dart'
    if (dart.library.js_interop) '../database/connection/web.dart';

/// The one [AppDatabase] for this engine. Each engine (app, background alerts,
/// nearest site) opens its own; the Session's write lock relies on that.
class DatabaseService {
  static AppDatabase? _db;

  static AppDatabase get db {
    if (_db == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _db!;
  }

  /// Open the database once. A [database] replaces the current one (tests).
  static Future<void> initialize({AppDatabase? database}) async {
    if (database != null) {
      _db = database;
      return;
    }
    _db ??= AppDatabase(connect());
  }
}
