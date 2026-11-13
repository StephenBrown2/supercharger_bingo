import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/setup_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/theme/app_theme.dart';

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
    await db.clearAll();
  });

  tearDownAll(() => db.close());

  test('units follow the timezone, then the region', () {
    expect(
      unitsForTimezone('America/Indiana/Indianapolis'),
      UnitSystem.imperial,
    );
    expect(unitsForTimezone('America/Toronto'), UnitSystem.metric);
    expect(unitsForTimezone('Europe/London'), UnitSystem.imperial);
    expect(unitsForCountry('us'), UnitSystem.imperial);
    expect(unitsForCountry('DE'), UnitSystem.metric);
    expect(unitsForCountry(null), isNull);
  });

  testWidgets('setup saves the choices and marks itself done', (tester) async {
    final appearance = AppearanceController(AppAppearance.system);
    addTearDown(appearance.dispose);
    var done = false;
    await tester.pumpWidget(
      AppearanceScope(
        controller: appearance,
        child: MaterialApp(home: SetupScreen(onDone: () => done = true)),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> next() async {
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
    }

    await next(); // Location
    await tester.tap(find.text('Metric (kilometers)'));
    await tester.pumpAndSettle();
    await next(); // Units
    expect(find.text('Check-in search radius: 40 km'), findsOneWidget);
    await next(); // Distances
    await tester.tap(find.text('First Countdown Started'));
    await tester.pumpAndSettle();
    await next(); // Alerts
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final settings = await db.getUserSettings();
    expect(done, isTrue);
    expect(settings.setupCompletedAt, isNotNull);
    expect(settings.unitSystem, UnitSystem.metric);
    expect(settings.checkinRadiusKm, 40);
    expect(settings.notificationRadiusKm, 2400);
    expect(settings.notifyFirstEligible, isFalse);
  });
}
