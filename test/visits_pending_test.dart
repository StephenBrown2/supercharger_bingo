import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/login_screen.dart';
import 'package:supercharger_bingo/screens/visits_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';

import 'support/test_sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUpAll(() async {
    registerTestSqlite3();
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
  });

  setUp(() async {
    DatabaseService.bootstrapUserSettings = null;
    DatabaseService.bootstrapSites = null;
    await db.clearAll();
  });

  tearDownAll(() => db.close());

  testWidgets('a local check-in shows as pending in visits', (tester) async {
    await db.upsertSite(
      SitesCompanion.insert(siteId: 7, name: 'Upper Sandusky'),
    );
    await db.addVisit(
      VisitsCompanion(
        siteId: const Value(7),
        checkinDate: Value(DateTime(2026, 11, 10, 15)),
        checkinTime: Value(DateTime(2026, 11, 10, 15)),
        syncStatus: const Value(VisitSyncStatus.pending),
        importedAt: Value(DateTime(2026, 11, 10, 15)),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: VisitsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Upper Sandusky'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'GitHub sign-in stays on this device when the webview is unavailable',
    (tester) async {
      var finished = false;
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(onLoginSuccess: () => finished = true)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Login with GitHub'), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);

      await tester.tap(find.text('Login with GitHub'));
      await tester.pumpAndSettle();

      final settings = await db.getUserSettings();
      expect(settings.authProvider, AuthProvider.github);
      expect(settings.isAuthenticated, isFalse);
      expect(settings.lastLoginAt, isNotNull);
      expect(finished, isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
