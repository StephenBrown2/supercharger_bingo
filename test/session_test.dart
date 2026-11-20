import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/checkin_outbox.dart';
import 'package:supercharger_bingo/services/database_service.dart';
import 'package:supercharger_bingo/services/session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase(NativeDatabase.memory());
  setUpAll(() => DatabaseService.initialize(database: db));
  tearDownAll(db.close);

  test(
    'an old request cannot expire a fresh sign-in with the same cookie',
    () async {
      FlutterSecureStorage.setMockInitialValues({'sclsession': 'old-cookie'});
      final session = Session.instance;
      final old = (await session.current())!;
      expect(old.cookie, 'old-cookie');

      await session.signIn('old-cookie');
      await session.markExpired(old);
      final current = (await session.current())!;
      expect(current.cookie, 'old-cookie');
      expect(current.id, isNot(old.id));

      await session.markExpired(current);
      expect(await session.isSignedIn(), isFalse);
    },
  );

  test('v23 removes the old flag and preserves profile settings', () async {
    await db.customStatement(
      'ALTER TABLE user_settings ADD COLUMN is_authenticated '
      'INTEGER NOT NULL DEFAULT 1',
    );
    await db.updateUserSettings(
      const UserSettingsTableCompanion(
        authProvider: Value(AuthProvider.github),
        displayName: Value('Ada'),
      ),
    );
    await db.migration.onUpgrade(Migrator(db), 22, 23);

    final settings = await db.getUserSettings();
    expect(settings.authProvider, AuthProvider.github);
    expect(settings.displayName, 'Ada');
    expect(
      await db
          .customSelect(
            "SELECT name FROM pragma_table_info('user_settings') "
            "WHERE name = 'is_authenticated'",
          )
          .get(),
      isEmpty,
    );
  });

  test('sign-out holds unsent Check-ins even while offline', () async {
    FlutterSecureStorage.setMockInitialValues({'sclsession': 'test-cookie'});
    const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async => ['none']);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await db.upsertSite(SitesCompanion.insert(siteId: 7, name: 'Test Site'));
    final outbox = CheckinOutbox.instance;
    expect(await outbox.record(siteId: 7), Delivery.waiting);
    final held = Completer<void>();
    void onChange() => held.complete();
    outbox.changes.addListener(onChange);
    try {
      await Session.instance.signOut();
      await held.future.timeout(const Duration(seconds: 5));
      expect(await Session.instance.isSignedIn(), isFalse);
      expect(
        (await outbox.pending()).values.single.state,
        OutboxState.waitingForSignIn,
      );
    } finally {
      outbox.changes.removeListener(onChange);
    }
  });
}
