import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart' as xlsx;
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/login_screen.dart';
import 'package:supercharger_bingo/screens/visits_screen.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/write_result.dart';
import 'package:supercharger_bingo/services/checkin_form.dart';
import 'package:supercharger_bingo/services/sync_service.dart';

import 'support/test_sqlite3.dart';

class _DeleteApi extends ApiService {
  final WriteResult result;
  int? deletedId;

  _DeleteApi(this.result) : super(sessionId: 'test');

  @override
  Future<WriteResult> submitCheckin(CheckinDraft draft) async =>
      WriteResult.accepted;

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
  });

  tearDownAll(() => db.close());

  for (final queued in [false, true]) {
    testWidgets(
      'a submitted ${queued ? 'queued' : 'direct'} visit resolves its ID before deletion',
      (tester) async {
        const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(channel, (_) async => ['wifi']);
        addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
        await DatabaseService.updateUserSettings(
          const UserSettingsTableCompanion(username: Value('test')),
        );
        await db.upsertSite(
          SitesCompanion.insert(siteId: 7, name: 'Upper Sandusky'),
        );
        final api = _DeleteApi(WriteResult.accepted);
        final sync = SyncService(apiService: api);
        final date = DateTime.utc(2026, 11, 10, 15, 0, 0, 123);
        if (queued) {
          await DatabaseService.saveQueuedCheckin(
            pending: PendingCheckinsCompanion(
              siteId: const Value(7),
              checkinDate: Value(date),
              createdAt: Value(date),
            ),
          );
          await sync.syncPendingCheckins();
        } else {
          expect(await sync.submitCheckin(siteId: 7, date: date), isTrue);
        }
        final original = (await db.getAllVisits()).single;
        expect(original.checkinId, isNull);
        expect(original.syncStatus, VisitSyncStatus.synced);
        await tester.pumpWidget(MaterialApp(home: VisitsScreen(api: api)));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Delete check-in'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(api.deletedId, 90105);
        expect(await db.getAllVisits(), isEmpty);
        expect((await db.getSiteBySiteId(7))!.visited, isFalse);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

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

  testWidgets('a pending check-in can be deleted, unmarking the site', (
    tester,
  ) async {
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
        checkinDate: Value(DateTime(2026, 11, 10, 15)),
        checkinTime: Value(DateTime(2026, 11, 10, 15)),
        syncStatus: const Value(VisitSyncStatus.pending),
        importedAt: Value(DateTime(2026, 11, 10, 15)),
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: VisitsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(await db.getAllVisits(), isEmpty);
    expect((await db.getSiteBySiteId(7))!.visited, isFalse);
    expect(find.text('No visits yet'), findsOneWidget);
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
