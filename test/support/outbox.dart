import 'dart:io';

import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/checkin_form.dart';
import 'package:supercharger_bingo/services/checkin_log.dart';
import 'package:supercharger_bingo/services/checkin_outbox.dart';
import 'package:supercharger_bingo/services/checkin_writer.dart';
import 'package:supercharger_bingo/services/write_result.dart';

/// Backend writer that records drafts and answers from [results] in order,
/// repeating the last one.
class FakeWriter implements CheckinWriter {
  final List<WriteResult> results;
  final drafts = <CheckinDraft>[];

  FakeWriter([this.results = const [WriteResult.accepted]]);

  @override
  Future<WriteResult> submit(CheckinDraft draft) async {
    drafts.add(draft);
    return results[(drafts.length - 1).clamp(0, results.length - 1)];
  }
}

/// A test clock the test moves by hand.
class FakeClock {
  DateTime now;
  FakeClock(this.now);
  DateTime call() => now;
  void advance(Duration by) => now = now.add(by);
}

/// Session the outbox sees: [signedIn] and how often it was marked expired.
class FakeSession {
  bool signedIn;
  var expired = 0;
  FakeSession({this.signedIn = true});
}

Directory? _logDir;

/// An outbox over [db] built from fakes, also installed as the app's outbox.
CheckinOutbox installTestOutbox(
  AppDatabase db, {
  CheckinWriter? writer,
  FakeClock? clock,
  FakeSession? session,
  bool online = true,
  bool sendingEnabled = true,
}) {
  // Keep the check-in log out of the real documents folder.
  CheckinLog.directory = () async =>
      _logDir ??= Directory.systemTemp.createTempSync('checkin_log');
  final s = session ?? FakeSession();
  final outbox = CheckinOutbox(
    db: db,
    writer: writer ?? FakeWriter(),
    isSignedIn: () async => s.signedIn,
    markSessionExpired: () async {
      s.signedIn = false;
      s.expired++;
    },
    isOnline: () async => online,
    now: clock == null ? null : () => clock.now,
    sendingEnabled: sendingEnabled,
  );
  CheckinOutbox.instance = outbox;
  return outbox;
}
