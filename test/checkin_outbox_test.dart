import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Migrator, Value;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/api_service.dart';
import 'package:supercharger_bingo/services/checkin_outbox.dart';
import 'package:supercharger_bingo/services/checkin_writer.dart';
import 'package:supercharger_bingo/services/checkin_form.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/session.dart';
import 'package:supercharger_bingo/services/write_result.dart';

import 'support/outbox.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  final start = DateTime.utc(2026, 11, 18, 15);

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DatabaseService.initialize(database: db);
  });
  setUp(() async {
    await db.clearAll();
    await db.upsertSite(
      SitesCompanion.insert(siteId: 7, name: 'Upper Sandusky'),
    );
  });
  tearDownAll(() => db.close());

  Future<List<OutboxEntry>> entries() => db.select(db.outboxEntries).get();

  test('an accepted check-in is Sent: a Visit with no outbox entry', () async {
    final writer = FakeWriter();
    final outbox = installTestOutbox(
      db,
      writer: writer,
      clock: FakeClock(start),
    );

    final delivery = await outbox.record(
      siteId: 7,
      latitude: 40,
      longitude: -83,
      accuracy: 12,
      notesPublic: 'Stall 4',
      notesPrivate: '  ',
    );

    expect(delivery, Delivery.sent);
    expect(await entries(), isEmpty);
    final visit = (await db.getAllVisits()).single;
    expect(visit.checkinDate.toUtc(), start);
    expect(visit.checkinPrecision, CheckinPrecision.timestamp);
    expect(visit.method, CheckinMethod.gps);
    expect((await db.getSiteBySiteId(7))!.visited, isTrue);
    final draft = writer.drafts.single;
    expect(draft.siteId, 7);
    expect(draft.latitude, 40);
    expect(draft.notesPublic, 'Stall 4');
    expect(draft.notesPrivate, isNull);
  });

  for (final result in [
    WriteResult.retry,
    // supercharging.life does not refuse check-ins, so this is retried too.
    WriteResult.rejected,
  ]) {
    test('a check-in answered ${result.outcome.name} waits to send', () async {
      final outbox = installTestOutbox(db, writer: FakeWriter([result]));

      expect(await outbox.record(siteId: 7), Delivery.waiting);

      final entry = (await entries()).single;
      expect(entry.state, OutboxState.waiting);
      expect(entry.attempts, 1);
      expect(entry.lastError, result.message);
      final pending = await outbox.pending();
      expect(pending.values.single.maybeSent, isTrue);
    });
  }

  test('a writer that throws leaves the Visit Pending, not lost', () async {
    final outbox = installTestOutbox(db, writer: _ThrowingWriter());

    expect(await outbox.record(siteId: 7), Delivery.waiting);
    expect(await db.getAllVisits(), hasLength(1));
    expect((await entries()).single.state, OutboxState.waiting);
  });

  test('offline, a check-in waits and sends once back online', () async {
    final writer = FakeWriter();
    final offline = installTestOutbox(db, writer: writer, online: false);
    expect(await offline.record(siteId: 7), Delivery.waiting);
    expect(writer.drafts, isEmpty);
    expect((await offline.pending()).values.single.maybeSent, isFalse);

    await installTestOutbox(db, writer: writer).sendDue();

    expect(writer.drafts, hasLength(1));
    expect(await entries(), isEmpty);
  });

  test('with sending off (web), a check-in only waits', () async {
    final writer = FakeWriter();
    final outbox = installTestOutbox(db, writer: writer, sendingEnabled: false);

    expect(await outbox.record(siteId: 7), Delivery.waiting);
    await outbox.sendDue();

    expect(writer.drafts, isEmpty);
    expect((await entries()).single.state, OutboxState.waiting);
  });

  test('signed out, it waits for sign-in, then sends after it', () async {
    final writer = FakeWriter();
    final session = FakeSession(signedIn: false);
    final outbox = installTestOutbox(db, writer: writer, session: session);

    expect(await outbox.record(siteId: 7), Delivery.waitingForSignIn);
    expect(writer.drafts, isEmpty);
    expect(
      (await outbox.pending()).values.single.state,
      OutboxState.waitingForSignIn,
    );

    session.signedIn = true;
    await outbox.sendDue();

    expect(writer.drafts, hasLength(1));
    expect(await outbox.pending(), isEmpty);
  });

  test('an expired session waits for sign-in without a backoff', () async {
    final session = FakeSession();
    final outbox = installTestOutbox(
      db,
      writer: FakeWriter([WriteResult.needsSignIn]),
      session: session,
    );

    expect(await outbox.record(siteId: 7), Delivery.waitingForSignIn);

    final entry = (await entries()).single;
    expect(entry.state, OutboxState.waitingForSignIn);
    expect(entry.attempts, 0);
    expect(entry.lastAttemptAt, isNull);
    expect(session.expired, 1);
  });

  test('sign-out leaves a send claimed by another engine in flight', () async {
    final visitId = await _pendingVisit(db, state: OutboxState.waiting);
    final writer = FakeWriter();
    final outbox = CheckinOutbox(
      db: db,
      writer: writer,
      isOnline: () async => true,
      isSignedIn: () async {
        await (db.update(
          db.outboxEntries,
        )..where((t) => t.visitId.equals(visitId))).write(
          OutboxEntriesCompanion(
            state: const Value(OutboxState.sending),
            attempts: const Value(1),
            lastAttemptAt: Value(start),
          ),
        );
        return false;
      },
      markSessionExpired: () async {},
      now: () => start,
    );

    await outbox.sendDue();

    expect(writer.drafts, isEmpty);
    final entry = (await entries()).single;
    expect(entry.state, OutboxState.sending);
    expect(entry.attempts, 1);
  });

  test('a failed send waits out its backoff before the next try', () async {
    final clock = FakeClock(start);
    final writer = FakeWriter([WriteResult.retry, WriteResult.accepted]);
    final outbox = installTestOutbox(db, writer: writer, clock: clock);
    await outbox.record(siteId: 7);

    await outbox.sendDue();
    expect(writer.drafts, hasLength(1));

    clock.advance(const Duration(minutes: 1));
    await outbox.sendDue();
    expect(writer.drafts, hasLength(2));
    expect(await entries(), isEmpty);
  });

  test('an interrupted send is sent again after 10 minutes', () async {
    final clock = FakeClock(start);
    final writer = FakeWriter();
    final outbox = installTestOutbox(db, writer: writer, clock: clock);
    final visitId = await _pendingVisit(
      db,
      state: OutboxState.sending,
      attempts: 3,
      lastAttemptAt: start.subtract(const Duration(minutes: 9)),
    );

    await outbox.sendDue();
    expect(writer.drafts, isEmpty);
    expect(await outbox.remove(visitId), isFalse);

    clock.advance(const Duration(minutes: 1));
    await outbox.sendDue();
    expect(writer.drafts, hasLength(1));
    expect(await entries(), isEmpty);
  });

  test('overlapping sends post a check-in once', () async {
    final writer = FakeWriter();
    final outbox = installTestOutbox(db, writer: writer, online: false);
    await outbox.record(siteId: 7);
    final online = installTestOutbox(db, writer: writer);

    await Future.wait([online.sendDue(), online.sendDue()]);

    expect(writer.drafts, hasLength(1));
  });

  test('removing a Pending Visit deletes it and unmarks the Site', () async {
    final outbox = installTestOutbox(db, online: false);
    await outbox.record(siteId: 7);
    final visit = (await db.getAllVisits()).single;

    expect(await outbox.remove(visit.id), isTrue);

    expect(await db.getAllVisits(), isEmpty);
    expect(await entries(), isEmpty);
    expect((await db.getSiteBySiteId(7))!.visited, isFalse);
  });

  test('a Sending Visit found in an import is settled, not resent', () async {
    final writer = FakeWriter();
    final outbox = installTestOutbox(
      db,
      writer: writer,
      clock: FakeClock(start.add(const Duration(hours: 1))),
    );
    final sending = await _pendingVisit(
      db,
      state: OutboxState.sending,
      at: start,
      lastAttemptAt: start,
    );
    final waiting = await _pendingVisit(
      db,
      state: OutboxState.waiting,
      at: start.add(const Duration(minutes: 5)),
    );

    await outbox.settleFromImport([
      for (final (id, at) in [
        (501, start),
        (502, start.add(const Duration(minutes: 5))),
      ])
        VisitsCompanion(
          checkinId: Value(id),
          siteId: const Value(7),
          checkinDate: Value(at),
          checkinTime: Value(at),
          importedAt: Value(at),
        ),
    ]);

    final left = await entries();
    expect(left.map((e) => e.visitId), [waiting]);
    final visits = {for (final v in await db.getAllVisits()) v.id: v};
    expect(visits[sending]!.checkinId, 501);
    expect(visits[waiting]!.checkinId, isNull);
    await outbox.sendDue();
    expect(writer.drafts.map((d) => d.checkinAt.toUtc()), [
      start.add(const Duration(minutes: 5)),
    ]);
  });

  for (final optedIn in [false, true]) {
    test('the vehicle joins the private note only when opted in '
        '($optedIn)', () async {
      await db.upsertVehicle(
        const VehiclesCompanion(
          id: Value('car'),
          label: Value('Alpha'),
          make: Value('Tesla'),
          model: Value('Model Y'),
          year: Value('2024'),
        ),
      );
      await db.updateUserSettings(
        UserSettingsTableCompanion(includeVehicleInPrivateNote: Value(optedIn)),
      );
      final outbox = installTestOutbox(db, online: false);

      await outbox.record(siteId: 7, notesPrivate: 'Private', vehicleId: 'car');

      final visit = (await db.getAllVisits()).single;
      expect(visit.vehicleId, 'car');
      expect(
        visit.notesPrivate,
        optedIn ? 'Private\nVehicle: 2024 Tesla Model Y' : 'Private',
      );
    });
  }

  group('production wiring', () {
    late List<RequestOptions> requests;
    late List<Response<dynamic> Function(RequestOptions)> answers;

    ApiService api({String? sessionId = 'test-session'}) {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              requests.add(request);
              final answer =
                  answers[(requests.length - 1).clamp(0, answers.length - 1)];
              handler.resolve(answer(request));
            },
          ),
        );
      return ApiService(dio: dio, sessionId: sessionId);
    }

    setUp(() {
      requests = [];
      answers = [(r) => Response(requestOptions: r, statusCode: 200)];
      const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (_) async => ['wifi']);
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    });

    test(
      'the form carries notes, user id and position, never vehicle ids',
      () async {
        await db.updateUserSettings(
          const UserSettingsTableCompanion(odUserId: Value(42)),
        );
        final outbox = CheckinOutbox.live(api: api());

        final delivery = await outbox.record(
          siteId: 7,
          latitude: 40,
          longitude: -105,
          accuracy: 12,
          notesPublic: 'Public',
          notesPrivate: 'Private',
          vehicleId: 'local-id',
        );

        expect(delivery, Delivery.sent);
        final data = requests.single.data as FormData;
        final form = Map<String, String>.fromEntries(data.fields);
        expect(form['supercharger_id'], '7');
        expect(form['notes_public'], 'Public');
        expect(form['notes_private'], 'Private');
        expect(form['user_id'], '42');
        expect(form['log_coords_lat'], '40.0');
        expect(form['log_coords_lon'], '-105.0');
        expect(form['log_coords_accuracy'], '12.0');
        expect(form.containsKey('vehicle_id'), isFalse);
      },
    );

    test('the check-in detail redirect gives the Visit its id', () async {
      answers = [
        (r) => Response(
          requestOptions: r,
          statusCode: 302,
          headers: Headers.fromMap({
            'location': ['/supercharging/checkin_detail.php?id=90210'],
          }),
        ),
      ];
      final outbox = CheckinOutbox.live(api: api());

      expect(await outbox.record(siteId: 7), Delivery.sent);

      final form = Map.fromEntries((requests.single.data as FormData).fields);
      expect(form['destination'], 'checkin_detail');
      expect((await db.getAllVisits()).single.checkinId, 90210);
      expect(
        checkinIdFromRedirect('/supercharging/user_detail.php?id=5'),
        isNull,
      );
    });

    test('an unexpected answer is retried, not treated as a refusal', () async {
      answers = [(r) => Response(requestOptions: r, statusCode: 400)];
      final result = await UnofficialCheckinWriter(api()).submit(
        CheckinDraft(
          siteId: 7,
          checkinAt: start,
          precision: CheckinPrecision.timestamp,
        ),
      );
      expect(result.outcome, WriteOutcome.retry);
    });

    test(
      'a signed-out answer signs the user out but keeps lastLoginAt',
      () async {
        answers = [
          (r) => Response(
            requestOptions: r,
            statusCode: 200,
            data: 'Login to your account',
          ),
        ];
        final loginAt = DateTime.utc(2026, 1, 1);
        await db.updateUserSettings(
          UserSettingsTableCompanion(lastLoginAt: Value(loginAt)),
        );
        FlutterSecureStorage.setMockInitialValues({
          'sclsession': 'test-session',
        });
        final outbox = CheckinOutbox.live(api: api(sessionId: null));

        expect(await outbox.record(siteId: 7), Delivery.waitingForSignIn);

        expect(await Session.instance.isSignedIn(), isFalse);
        final settings = await db.getUserSettings();
        expect(
          settings.lastLoginAt?.millisecondsSinceEpoch,
          loginAt.millisecondsSinceEpoch,
        );
      },
    );
  });

  test('v20 moves pending check-ins into the outbox', () async {
    // Rebuild the v19 shape on top of the current schema.
    await db.customStatement('DROP TABLE outbox_entries');
    await db.customStatement(
      "ALTER TABLE visits ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'synced'",
    );
    await db.customStatement(
      'ALTER TABLE visits ADD COLUMN pending_id INTEGER',
    );
    await db.customStatement('''
      CREATE TABLE pending_checkins (id INTEGER PRIMARY KEY, site_id INTEGER,
        checkin_date INTEGER, created_at INTEGER, latitude REAL,
        longitude REAL, accuracy REAL, status TEXT, attempts INTEGER,
        last_attempt_at INTEGER, last_error TEXT)
    ''');
    final rows = [
      (1, 'submitting', 2, 1000, null),
      (2, 'failed', 4, 2000, 'Check-in date is before the site opened'),
      (3, 'pending', 0, null, 'Sign in to supercharging.life again'),
      (4, 'pending', 1, 3000, 'Network error, will retry'),
      (5, 'completed', 1, 4000, null),
    ];
    for (final (id, status, attempts, lastAt, error) in rows) {
      await db.customStatement(
        'INSERT INTO pending_checkins VALUES (?, 7, 0, 0, 40, -83, 5, ?, ?, '
        '?, ?)',
        [id, status, attempts, lastAt, error],
      );
      await db.customStatement(
        'INSERT INTO visits (id, site_id, checkin_date, checkin_time, '
        'imported_at, sync_status, pending_id) VALUES (?, 7, 0, 0, 0, ?, ?)',
        [id, status == 'completed' ? 'synced' : 'pending', id],
      );
    }

    await db.migration.onUpgrade(Migrator(db), 19, 20);

    final byVisit = {for (final e in await entries()) e.visitId: e};
    expect(byVisit.keys, unorderedEquals([1, 2, 3, 4]));
    expect(byVisit[1]!.state, OutboxState.sending);
    expect(byVisit[1]!.attempts, 2);
    expect(byVisit[2]!.state, OutboxState.waiting);
    expect(byVisit[2]!.attempts, 0);
    expect(byVisit[2]!.lastError, isNull);
    expect(byVisit[3]!.state, OutboxState.waitingForSignIn);
    expect(byVisit[4]!.state, OutboxState.waiting);
    expect(byVisit[4]!.lastError, 'Network error, will retry');
    expect(byVisit[4]!.latitude, 40);
    expect(await db.getAllVisits(), hasLength(5));
    final tables = await db
        .customSelect(
          "SELECT 1 FROM sqlite_master WHERE name = 'pending_checkins'",
        )
        .get();
    expect(tables, isEmpty);
    final columns = await db
        .customSelect(
          "SELECT name FROM pragma_table_info('visits') "
          "WHERE name IN ('sync_status', 'pending_id')",
        )
        .get();
    expect(columns, isEmpty);
  });
}

class _ThrowingWriter implements CheckinWriter {
  @override
  Future<WriteResult> submit(CheckinDraft draft) => throw StateError('boom');
}

/// A Pending Visit at Site 7 written straight to the tables.
Future<int> _pendingVisit(
  AppDatabase db, {
  required OutboxState state,
  DateTime? at,
  int attempts = 0,
  DateTime? lastAttemptAt,
}) async {
  final when = at ?? DateTime.utc(2026, 11, 18, 14);
  final id = await db
      .into(db.visits)
      .insert(
        VisitsCompanion.insert(
          siteId: 7,
          checkinDate: when,
          checkinTime: when,
          importedAt: when,
        ),
      );
  await db
      .into(db.outboxEntries)
      .insert(
        OutboxEntriesCompanion.insert(
          visitId: Value(id),
          state: Value(state),
          attempts: Value(attempts),
          lastAttemptAt: Value(lastAttemptAt),
        ),
      );
  return id;
}
