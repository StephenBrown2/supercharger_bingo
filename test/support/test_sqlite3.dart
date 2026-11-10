/// Kept so existing tests can call it during setup.
///
/// sqlite3 3.x loads its bundled library through Dart hooks.
/// `open.overrideFor` from `package:sqlite3/open.dart` is gone, so there is
/// nothing to register here.
void registerTestSqlite3() {}
