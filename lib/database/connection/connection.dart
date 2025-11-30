import 'package:drift/drift.dart';

/// Stub that will be replaced by conditional imports
QueryExecutor connect() {
  throw UnsupportedError(
    'No suitable database implementation found for this platform.',
  );
}
