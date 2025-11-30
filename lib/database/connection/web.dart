import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'dart:developer' as developer;

QueryExecutor connect() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'supercharger_bingo',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      developer.log(
        'Using ${result.chosenImplementation} due to missing browser '
        'features: ${result.missingFeatures}',
        name: 'drift',
      );
    }

    return result.resolvedExecutor;
  }));
}
