import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/login_screen.dart';
import 'package:supercharger_bingo/screens/visits_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/checkin_outbox.dart';
import 'package:supercharger_bingo/services/write_result.dart';

import 'support/outbox.dart';
import 'support/test_sqlite3.dart';

class _DeleteApi extends ApiService {
  final WriteResult result;
  int? deletedId;

  _DeleteApi(this.result) : super(sessionId: 'test');

  @override
  Future<Map<String, dynamic>?> fetchUserByUsername(String username) async => {
    'user_id': '1',
    'displayname': 'Test',
  };

  @override
  Future<List<int>> downloadUserXlsx(int userId) async {
    final book = xlsx.Excel.createExcel();
    final sheet = book[book.getDefaultSheet()!];
    sheet.appendRow(
      [
        'checkin_id',
        'supercharger_id',
        'date',
        'time',
      ].map(xlsx.TextCellValue.new).toList(),
    );
    sheet.appendRow(
      [
        '90105',
        '7',
        '2026-11-10',
        '2026-11-10T15:00:00Z',
      ].map(xlsx.TextCellValue.new).toList(),
    );
    return book.encode()!;
  }

  @override
  Future<WriteResult> deleteCheckin(int checkinId) async {
    deletedId = checkinId;
    return result;
  }
}

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
    await db.upsertSite(
      SitesCompanion.insert(siteId: 7, name: 'Upper Sandusky'),
    );
  });

  tearDownAll(() => db.close());

  testWidgets('a sent check-in resolves its ID before deletion', (
    tester,
  ) async {
    await DatabaseService.updateUserSettings(
      const UserSettingsTableCompanion(username: Value('test')),
    );
    final outbox = installTestOutbox(
      db,
      clock: FakeClock(DateTime.utc(2026, 11, 10, 15, 0, 0, 123)),
    );
    expect(await outbox.record(siteId: 7), Delivery.sent);
    final original = (await db.getAllVisits()).single;
    expect(original.checkinId, isNull);
    final api = _DeleteApi(WriteResult.accepted);
    await tester.pumpWidget(MaterialApp(home: VisitsScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsNothing);
    await tester.tap(find.byTooltip('Delete check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(api.deletedId, 90105);
    expect(await db.getAllVisits(), isEmpty);
    expect((await db.getSiteBySiteId(7))!.visited, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  for (final result in [
    WriteResult.accepted,
    WriteResult.needsSignIn,
    WriteResult.retry,
  ]) {
    testWidgets('synced deletion: ${result.outcome}', (tester) async {
      await db.upsertSite(
        SitesCompanion.insert(
          siteId: 7,
          name: 'Upper Sandusky',
          visited: const Value(true),
        ),
      );
      await db.addVisit(
        VisitsCompanion(
          siteId: const Value(7),
          checkinId: const Value(90105),
          checkinDate: Value(DateTime(2026, 11, 10)),
          checkinTime: Value(DateTime(2026, 11, 10)),
          importedAt: Value(DateTime(2026, 11, 10)),
        ),
      );
      final api = _DeleteApi(result);
      await tester.pumpWidget(MaterialApp(home: VisitsScreen(api: api)));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete check-in'));
      await tester.pumpAndSettle();
      expect(find.textContaining('This cannot be undone.'), findsOneWidget);
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(api.deletedId, isNull);
      expect(await db.getAllVisits(), hasLength(1));
      await tester.tap(find.byTooltip('Delete check-in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(api.deletedId, 90105);
      final accepted = result.outcome == WriteOutcome.accepted;
      expect(await db.getAllVisits(), hasLength(accepted ? 0 : 1));
      expect((await db.getSiteBySiteId(7))!.visited, !accepted);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('a Pending check-in shows its outbox state in visits', (
    tester,
  ) async {
    installTestOutbox(db, session: FakeSession(signedIn: false));
    await CheckinOutbox.instance.record(siteId: 7);

    await tester.pumpWidget(const MaterialApp(home: VisitsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Upper Sandusky'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(
      find.textContaining('Waiting for supercharging.life sign-in'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  for (final attempted in [false, true]) {
    testWidgets('deleting a Pending check-in '
        '${attempted ? 'that may have gone out warns' : 'stays local'}', (
      tester,
    ) async {
      installTestOutbox(
        db,
        online: attempted,
        writer: FakeWriter([WriteResult.retry]),
      );
      await CheckinOutbox.instance.record(siteId: 7);

      await tester.pumpWidget(const MaterialApp(home: VisitsScreen()));
      await tester.pumpAndSettle();
      if (attempted) {
        expect(find.textContaining('Network error'), findsOneWidget);
      }
      await tester.tap(find.byTooltip('Delete check-in'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          attempted ? 'may already be on supercharging.life' : 'not been sent',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(await db.getAllVisits(), isEmpty);
      expect((await db.getSiteBySiteId(7))!.visited, isFalse);
      expect(find.text('No visits yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('a check-in being sent is not deleted yet', (tester) async {
    final now = DateTime.now();
    final outbox = installTestOutbox(db, clock: FakeClock(now));
    final visitId = await db
        .into(db.visits)
        .insert(
          VisitsCompanion.insert(
            siteId: 7,
            checkinDate: now,
            checkinTime: now,
            importedAt: now,
          ),
        );
    await db
        .into(db.outboxEntries)
        .insert(
          OutboxEntriesCompanion.insert(
            visitId: Value(visitId),
            state: const Value(OutboxState.sending),
            attempts: const Value(1),
            lastAttemptAt: Value(now),
          ),
        );

    await tester.pumpWidget(const MaterialApp(home: VisitsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('being sent'), findsOneWidget);
    expect(await db.getAllVisits(), hasLength(1));
    expect(await outbox.pending(), contains(visitId));
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
