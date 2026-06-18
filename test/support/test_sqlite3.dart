import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// Loads libsqlite3 for VM-based (`flutter test`) drift databases.
///
/// `sqlite3_flutter_libs` only bundles the native library into real app
/// builds, not the Dart VM used by tests, and this environment has no
/// libsqlite3 on the default loader path. We probe a few known locations and
/// register the first that exists. Safe to call repeatedly.
bool _registered = false;

void registerTestSqlite3() {
  if (_registered) return;
  _registered = true;

  // Candidate locations, in priority order. Globs are expanded manually.
  final candidates = <String>[
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so',
    '/lib/x86_64-linux-gnu/libsqlite3.so.0',
    ..._glob('/snap/core22', 'usr/lib/x86_64-linux-gnu/libsqlite3.so.0'),
    ..._glob('/snap/core20', 'usr/lib/x86_64-linux-gnu/libsqlite3.so.0'),
    ..._glob('/snap/gnome-42-2204', 'usr/lib/x86_64-linux-gnu/libsqlite3.so'),
  ];

  final found = candidates.firstWhere(
    (p) => File(p).existsSync(),
    orElse: () => '',
  );
  if (found.isEmpty) {
    // Fall back to the default loader; the test will surface a clear error.
    return;
  }
  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open(found));
}

/// Expands `<base>/<version>/<tail>` for each version subdirectory.
List<String> _glob(String base, String tail) {
  final dir = Directory(base);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync()
      .whereType<Directory>()
      .map((d) => '${d.path}/$tail')
      .toList();
}
