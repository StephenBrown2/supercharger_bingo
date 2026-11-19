import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/services/checkin_log.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('checkin_log');
    CheckinLog.directory = () async => dir;
    CheckinLog.maxBytes = 256 * 1024;
    await CheckinLog.clear();
  });
  tearDown(() => dir.delete(recursive: true));

  test('each event is one JSON line with a local time and offset', () async {
    await CheckinLog.event('record', {
      'visit': 3,
      'at': DateTime.utc(2026, 11, 21, 15),
    });

    final line = jsonDecode((await CheckinLog.read()).trim()) as Map;
    expect(line['e'], 'record');
    expect(line['visit'], 3);
    expect(line['t'], matches(RegExp(r'[+-]\d\d:\d\d$')));
    expect(
      DateTime.parse(line['at'] as String).toUtc(),
      DateTime.utc(2026, 11, 21, 15),
    );
  });

  test('past the size limit it keeps the newest half', () async {
    CheckinLog.maxBytes = 2000;
    for (var i = 0; i < 60; i++) {
      await CheckinLog.event('send.start', {'visit': i});
    }

    final lines = const LineSplitter().convert(await CheckinLog.read());
    expect(
      await File('${dir.path}/checkin_log.jsonl').length(),
      lessThan(2000),
    );
    expect((jsonDecode(lines.last) as Map)['visit'], 59);
    expect((jsonDecode(lines.first) as Map)['visit'], greaterThan(0));
  });

  test('clear empties it', () async {
    await CheckinLog.event('app.start');
    await CheckinLog.clear();
    expect(await CheckinLog.read(), isEmpty);
  });
}
