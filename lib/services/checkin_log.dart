import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Field log of the check-in flow: Site confirmation, recording, every send
/// attempt and its HTTP answer. One JSON object per line in
/// `checkin_log.jsonl` in the app documents folder, kept on the device only.
///
/// Read it from Settings > Debug > Copy check-in log, or on a debug build with
/// `adb exec-out run-as bingo.supercharger.checkin cat app_flutter/checkin_log.jsonl`.
/// Lines also go to the console (logcat) prefixed `checkin_log`.
// ponytail: whole-file rewrite when trimming; fine at 256 KB, use a rotating
// pair of files if the log needs to grow.
class CheckinLog {
  /// Trim to the newest half once the file passes this size.
  @visibleForTesting
  static int maxBytes = 256 * 1024;

  /// Where the log lives. Tests point this at a temporary folder.
  @visibleForTesting
  static Future<Directory> Function() directory =
      getApplicationDocumentsDirectory;

  /// Web has no documents folder; the log stays in memory for the session.
  static final _memory = <String>[];
  static Future<void> _writes = Future.value();

  /// Record [name] with [data]. Never throws: logging must not break a
  /// check-in.
  static Future<void> event(
    String name, [
    Map<String, Object?> data = const {},
  ]) {
    final String line;
    try {
      line = jsonEncode({
        't': _timestamp(DateTime.now()),
        'e': name,
        ...data.map((k, v) => MapEntry(k, v is DateTime ? _timestamp(v) : v)),
      });
    } catch (e) {
      debugPrint('checkin_log: could not encode $name: $e');
      return Future.value();
    }
    debugPrint('checkin_log $line');
    final run = _writes.then((_) => _append(line));
    _writes = run.catchError((Object e) {
      debugPrint('checkin_log: write failed: $e');
    });
    return _writes;
  }

  /// The whole log, oldest first.
  static Future<String> read() async {
    await _writes;
    if (kIsWeb) return _memory.join('\n');
    final file = await _file();
    return await file.exists() ? file.readAsString() : '';
  }

  static Future<void> clear() async {
    await _writes;
    _memory.clear();
    if (kIsWeb) return;
    final file = await _file();
    if (await file.exists()) await file.delete();
  }

  static Future<void> _append(String line) async {
    if (kIsWeb) {
      _memory.add(line);
      if (_memory.length > 2000) _memory.removeRange(0, 1000);
      return;
    }
    final file = await _file();
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
    if (await file.length() > maxBytes) {
      final lines = await file.readAsLines();
      await file.writeAsString(
        '${lines.skip(lines.length ~/ 2).join('\n')}\n',
        flush: true,
      );
    }
  }

  static Future<File> _file() async =>
      File('${(await directory()).path}/checkin_log.jsonl');

  /// Local time with its UTC offset, so field notes line up with the log.
  static String _timestamp(DateTime t) {
    final local = t.toLocal();
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final h = offset.inHours.abs().toString().padLeft(2, '0');
    final m = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${local.toIso8601String()}$sign$h:$m';
  }
}
