import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'checkin_log.dart';
import 'database_service.dart';

typedef SessionCredential = ({String id, String cookie});

/// The persisted supercharging.life sign-in. Each engine reads secure storage
/// directly, and changes notify listeners in the engine that made the change.
class Session extends ChangeNotifier {
  Session._();

  static final instance = Session._();
  static const _storage = FlutterSecureStorage();
  static const _key = 'sclsession';

  Future<SessionCredential?> current() async {
    if (kIsWeb) return null;
    try {
      final stored = await _storage.read(key: _key);
      if (stored == null || stored.isEmpty) return null;
      // Older installs stored only the cookie.
      final separator = stored.indexOf(':');
      if (separator == -1) return (id: '', cookie: stored);
      return (
        id: stored.substring(0, separator),
        cookie: stored.substring(separator + 1),
      );
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> isSignedIn() async => await current() != null;

  Future<void> signIn(String cookie) async {
    if (kIsWeb) return;
    if (cookie.isEmpty) throw ArgumentError('A Session needs a cookie.');
    final random = Random.secure();
    final id = base64UrlEncode(List.generate(16, (_) => random.nextInt(256)));
    await _mutate(() => _storage.write(key: _key, value: '$id:$cookie'));
    notifyListeners();
  }

  Future<void> signOut() => _end();

  Future<void> markExpired(SessionCredential used) => _end(used: used);

  Future<void> _end({SessionCredential? used}) async {
    if (kIsWeb) return;
    final ended = await _mutate(() async {
      if (used != null && await current() != used) return false;
      await _storage.delete(key: _key);
      return true;
    });
    if (!ended) return;
    CheckinLog.event(used == null ? 'session.signOut' : 'session.expired');
    notifyListeners();
  }

  // A write lock serializes secure storage mutations across Android engines.
  Future<T> _mutate<T>(Future<T> Function() action) {
    final db = DatabaseService.db;
    return db.transaction(() async {
      await db.customStatement('PRAGMA busy_timeout = 5000');
      await db.customStatement('UPDATE user_settings SET id = id WHERE 0');
      return action();
    });
  }
}
