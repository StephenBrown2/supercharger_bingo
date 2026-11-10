import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';

import 'support/test_sqlite3.dart';

void main() {
  setUpAll(registerTestSqlite3);

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('Phase 3 schema (v5)', () {
    test('schemaVersion is bumped to at least 5', () {
      expect(db.schemaVersion, greaterThanOrEqualTo(5));
    });

    test('Vehicles CRUD round-trips, raw VIN is not a column', () async {
      await db.upsertVehicle(
        VehiclesCompanion(
          id: const Value('veh-1'),
          label: const Value('Daily'),
          make: const Value('TESLA'),
          model: const Value('Model Y'),
          hasVin: const Value(true),
        ),
      );

      final vehicles = await db.getAllVehicles();
      expect(vehicles, hasLength(1));
      expect(vehicles.first.label, 'Daily');
      expect(vehicles.first.make, 'TESLA');
      expect(vehicles.first.hasVin, isTrue);

      await db.deleteVehicle('veh-1');
      expect(await db.getAllVehicles(), isEmpty);
    });

    test(
      'pending check-in persists private note and vehicle association',
      () async {
        await db.addPendingCheckin(
          PendingCheckinsCompanion(
            siteId: const Value(7),
            checkinDate: Value(DateTime(2026, 6, 18)),
            createdAt: Value(DateTime(2026, 6, 18)),
            notesPublic: const Value('great spot'),
            notesPrivate: const Value('charged to 80%'),
            vehicleId: const Value('veh-1'),
          ),
        );

        final pending = await db.getPendingCheckins();
        expect(pending, hasLength(1));
        expect(pending.first.notesPublic, 'great spot');
        expect(pending.first.notesPrivate, 'charged to 80%');
        expect(pending.first.vehicleId, 'veh-1');
      },
    );
  });
}
