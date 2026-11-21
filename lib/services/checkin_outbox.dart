import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import 'api_service.dart';
import 'checkin_form.dart';
import 'checkin_log.dart';
import 'checkin_writer.dart';
import 'database_service.dart';
import 'session.dart';
import 'write_result.dart';

/// What [CheckinOutbox.record] did with a new Check-in.
enum Delivery {
  /// supercharging.life confirmed it.
  sent,

  /// Pending: sending is off, offline, or the send failed. Sent later.
  waiting,

  /// Pending until the user signs in to supercharging.life.
  waitingForSignIn,
}

/// The outbox state of one Pending Visit.
class PendingVisit {
  final OutboxState state;

  /// Why the last send failed, for display. Null when it has not failed.
  final String? lastError;

  /// A send was attempted without a confirmed answer, so the Check-in may
  /// already be on supercharging.life.
  final bool maybeSent;

  const PendingVisit({
    required this.state,
    this.lastError,
    required this.maybeSent,
  });
}

/// What [CheckinOutbox.discard] did with a Pending Visit.
enum Discard {
  /// The Visit is gone from the app.
  discarded,

  /// supercharging.life accepted the send under way, so it stays Confirmed.
  confirmed,

  /// Another engine is sending it right now. Nothing changed.
  busy,

  /// It was not Pending. Nothing changed.
  notPending,
}

/// Check-in outbox: records Check-ins and sends them to supercharging.life.
///
/// Every send in this isolate runs through one queue, so a Check-in is never
/// posted twice at once here. A Visit holds the Check-in; its outbox entry
/// holds sending data and is deleted once supercharging.life confirms it.
class CheckinOutbox {
  static CheckinOutbox? _instance;

  /// The app's outbox. Tests replace it with one built from fakes.
  static CheckinOutbox get instance => _instance ??= CheckinOutbox.live();
  static set instance(CheckinOutbox outbox) => _instance = outbox;

  /// An entry still Sending this long after its last attempt was interrupted
  /// (the app was killed mid-send) and is sent again.
  // ponytail: the unofficial endpoint has no idempotency key, so a send that
  // landed before the kill becomes a duplicate unless an import settles it
  // first; the official API's Idempotency-Key removes that
  // (docs/supercharging-life-api-app-changes.md). Background isolates can
  // also overlap this isolate's queue for the same reason.
  static const interruptedAfter = Duration(minutes: 10);

  final AppDatabase _db;
  final CheckinWriter _writer;
  final DateTime Function() _now;
  final Future<bool> Function() _isSignedIn;
  final Future<void> Function() _markSessionExpired;
  final Future<bool> Function() _isOnline;
  final bool _sendingEnabled;

  /// Bumped on every outbox change, so screens can re-read [pending].
  final ValueNotifier<int> changes = ValueNotifier(0);

  Future<void> _queue = Future.value();

  /// Visits a send in this isolate is posting right now.
  final Set<int> _sendingNow = {};

  CheckinOutbox({
    required AppDatabase db,
    required CheckinWriter writer,
    required Future<bool> Function() isSignedIn,
    required Future<void> Function() markSessionExpired,
    required Future<bool> Function() isOnline,
    DateTime Function()? now,
    bool sendingEnabled = true,
  }) : _db = db,
       _writer = writer,
       _isSignedIn = isSignedIn,
       _markSessionExpired = markSessionExpired,
       _isOnline = isOnline,
       _now = now ?? DateTime.now,
       _sendingEnabled = sendingEnabled;

  /// Production wiring. The web release is local only, so it never sends.
  /// Tests pass their own [api] to exercise the real writer and session.
  factory CheckinOutbox.live({ApiService? api}) {
    final life = api ?? ApiService.instance;
    final outbox = CheckinOutbox(
      db: DatabaseService.db,
      writer: UnofficialCheckinWriter(life),
      isSignedIn: life.isSignedIn,
      // The live writer expires the credential attached to its request.
      markSessionExpired: () async {},
      isOnline: () async {
        try {
          final results = await Connectivity().checkConnectivity();
          return results.any((r) => r != ConnectivityResult.none);
        } catch (_) {
          return false;
        }
      },
      sendingEnabled: !kIsWeb,
    );
    if (api == null && !kIsWeb) {
      Session.instance.addListener(() => outbox._sessionChanged().ignore());
    }
    return outbox;
  }

  Future<void> _sessionChanged() async {
    if (await _isSignedIn()) {
      await sendDue(reason: 'sign-in');
    } else {
      await _holdWaiting();
    }
  }

  Future<void> _holdWaiting() async {
    await (_db.update(
      _db.outboxEntries,
    )..where((t) => t.state.equalsValue(OutboxState.waiting))).write(
      const OutboxEntriesCompanion(state: Value(OutboxState.waitingForSignIn)),
    );
    _changed();
  }

  /// Record a Check-in at [siteId] made now and send it right away.
  ///
  /// The Visit is saved first, so an app kill mid-send still leaves it
  /// Pending. Once saved this never throws: a failed send leaves it Pending.
  /// When [vehicleId] names a vehicle and the user opted in, its description
  /// is added to the private note.
  Future<Delivery> record({
    required int siteId,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? notesPublic,
    String? notesPrivate,
    String? vehicleId,
  }) async {
    final at = _now();
    final privateNote = await _privateNote(notesPrivate, vehicleId);
    final visitId = await _db.transaction(() async {
      final id = await _db
          .into(_db.visits)
          .insert(
            VisitsCompanion.insert(
              siteId: siteId,
              checkinDate: at,
              checkinTime: at,
              checkinPrecision: const Value(CheckinPrecision.timestamp),
              method: Value(
                latitude == null ? CheckinMethod.manual : CheckinMethod.gps,
              ),
              notesPublic: Value(_blankToNull(notesPublic)),
              notesPrivate: Value(privateNote),
              vehicleId: Value(vehicleId),
              geoDistanceAccuracy: Value(accuracy?.round()),
              importedAt: at,
            ),
          );
      await _db
          .into(_db.outboxEntries)
          .insert(
            OutboxEntriesCompanion.insert(
              visitId: Value(id),
              latitude: Value(latitude),
              longitude: Value(longitude),
              accuracy: Value(accuracy),
            ),
          );
      await _db.markSiteVisited(siteId, true);
      return id;
    });
    _changed();
    CheckinLog.event('record', {
      'visit': visitId,
      'site': siteId,
      'at': at,
      'lat': latitude,
      'lon': longitude,
      'accuracy': accuracy,
      'publicNoteChars': _blankToNull(notesPublic)?.length ?? 0,
      'privateNoteChars': privateNote?.length ?? 0,
      'vehicle': vehicleId != null,
    });

    final watch = Stopwatch()..start();
    Delivery delivery;
    try {
      await _enqueue(() async {
        final entry = await _entry(visitId);
        // A sync that ran first may already have tried it.
        if (entry != null && entry.attempts == 0) {
          await _sendIfPossible(entry, 'record');
        }
      });
      final entry = await _entry(visitId);
      delivery = entry == null
          ? Delivery.sent
          : entry.state == OutboxState.waitingForSignIn
          ? Delivery.waitingForSignIn
          : Delivery.waiting;
    } catch (e) {
      CheckinLog.event('record.error', {'visit': visitId, 'error': '$e'});
      delivery = Delivery.waiting;
    }
    CheckinLog.event('record.delivery', {
      'visit': visitId,
      'delivery': delivery.name,
      'ms': watch.elapsedMilliseconds,
    });
    return delivery;
  }

  /// Send every entry that is due: waiting past its backoff, waiting for a
  /// sign-in that may now exist, or interrupted mid-send.
  /// [reason] names what started it, for the check-in log.
  Future<void> sendDue({String reason = 'unspecified'}) => _enqueue(() async {
    final online = _sendingEnabled && await _isOnline();
    final entries = await _db.select(_db.outboxEntries).get();
    final now = _now();
    final due = entries.where((e) => _isDue(e, now)).toList();
    if (entries.isNotEmpty) {
      CheckinLog.event('sendDue', {
        'reason': reason,
        'sendingEnabled': _sendingEnabled,
        'online': online,
        'pending': entries.length,
        'due': due.map((e) => e.visitId).toList(),
      });
    }
    if (!online) return;
    for (final entry in due) {
      await _send(entry, reason);
    }
  });

  /// Pending Visits by visit id.
  Future<Map<int, PendingVisit>> pending() async {
    return {
      for (final e in await _db.select(_db.outboxEntries).get())
        e.visitId: PendingVisit(
          state: e.state,
          lastError: e.lastError,
          maybeSent: e.attempts > 0,
        ),
    };
  }

  /// Discard a Pending Visit. One this isolate is sending right now is
  /// discarded only if that send fails; if supercharging.life accepts it, it
  /// stays as a Confirmed Visit. Nothing remembers a discard across an app
  /// kill, so the Visit then stays Pending.
  // ponytail: another engine's send (the Live Update) is not waited for; the
  // caller gets [Discard.busy] and asks the user to try again.
  Future<Discard> discard(int visitId) async {
    if (!_sendingNow.contains(visitId)) return _discardNow(visitId);
    CheckinLog.event('discard.afterSend', {'visit': visitId});
    return _enqueue(() async {
      final kept = await _visit(visitId);
      if (await _entry(visitId) == null) {
        return kept == null ? Discard.discarded : Discard.confirmed;
      }
      return _discardNow(visitId);
    });
  }

  Future<Discard> _discardNow(int visitId) async {
    final entry = await _entry(visitId);
    if (entry == null) return Discard.notPending;
    if (entry.state == OutboxState.sending && !_interrupted(entry, _now())) {
      CheckinLog.event('discard.busy', {'visit': visitId});
      return Discard.busy;
    }
    CheckinLog.event('discard', {
      'visit': visitId,
      'state': entry.state.name,
      'attempts': entry.attempts,
    });
    final visit = await _visit(visitId);
    if (visit != null) await _db.deleteVisit(visit);
    _changed();
    return Discard.discarded;
  }

  /// Match the user's Visits from supercharging.life against local ones,
  /// settling any Sending entry whose Check-in turned up there.
  Future<void> settleFromImport(List<VisitsCompanion> imported) async {
    final before = await pending();
    await _db.reconcileVisitIds(imported);
    final after = await pending();
    final settled = before.keys.where((id) => !after.containsKey(id)).toList();
    CheckinLog.event('settleFromImport', {
      'imported': imported.length,
      'settled': settled,
      'stillPending': after.length,
    });
    _changed();
  }

  bool _isDue(OutboxEntry entry, DateTime now) => switch (entry.state) {
    OutboxState.waiting => pendingReadyToRetry(
      entry.lastAttemptAt,
      entry.attempts,
      now,
    ),
    OutboxState.waitingForSignIn => true,
    OutboxState.sending => _interrupted(entry, now),
  };

  bool _interrupted(OutboxEntry entry, DateTime now) {
    final last = entry.lastAttemptAt;
    return last == null || !now.isBefore(last.add(interruptedAfter));
  }

  Future<void> _sendIfPossible(OutboxEntry entry, String reason) async {
    final online = _sendingEnabled && await _isOnline();
    if (!online) {
      CheckinLog.event('send.skipped', {
        'visit': entry.visitId,
        'reason': reason,
        'sendingEnabled': _sendingEnabled,
        'online': false,
      });
      return;
    }
    await _send(entry, reason);
  }

  /// One send attempt. The result is written to the entry; a send that throws
  /// leaves it waiting.
  Future<void> _send(OutboxEntry entry, String reason) async {
    final id = entry.visitId;
    final watch = Stopwatch()..start();
    final unchanged = _db.update(_db.outboxEntries)
      ..where(
        (t) =>
            t.visitId.equals(id) &
            t.state.equalsValue(entry.state) &
            t.attempts.equals(entry.attempts),
      );
    var claimed = false;
    try {
      if (!await _isSignedIn()) {
        CheckinLog.event('send.signedOut', {'visit': id, 'reason': reason});
        if (await unchanged.write(_waitForSignIn) != 0) _changed();
        return;
      }
      CheckinLog.event('send.start', {
        'visit': id,
        'reason': reason,
        'fromState': entry.state.name,
        'attempt': entry.attempts + 1,
        'lastAttemptAt': entry.lastAttemptAt,
      });
      claimed =
          await unchanged.write(
            OutboxEntriesCompanion(
              state: const Value(OutboxState.sending),
              lastAttemptAt: Value(_now()),
              attempts: Value(entry.attempts + 1),
            ),
          ) !=
          0;
      if (!claimed) return;
      _sendingNow.add(id);
      _changed();
      final draft = await _draftFor(entry);
      if (draft == null) {
        // The Visit is gone; nothing to send.
        await _delete(id);
        return;
      }
      final result = await _writer.submit(draft);
      CheckinLog.event('send.result', {
        'visit': id,
        'outcome': result.outcome.name,
        'message': result.message,
        'checkinId': result.checkinId,
        'ms': watch.elapsedMilliseconds,
      });
      switch (result.outcome) {
        case WriteOutcome.accepted:
          final checkinId = result.checkinId;
          if (checkinId != null) {
            final holder = await _db.attachCheckinId(id, checkinId);
            CheckinLog.event('send.attached', {
              'visit': id,
              'checkinId': checkinId,
              'heldBy': holder,
            });
          }
          await _delete(id);
        case WriteOutcome.needsSignIn:
          await _update(id, _waitForSignIn);
          CheckinLog.event('session.expired', {'visit': id});
          await _markSessionExpired();
        case WriteOutcome.retry || WriteOutcome.rejected:
          await _update(
            id,
            OutboxEntriesCompanion(
              state: const Value(OutboxState.waiting),
              lastError: Value(result.message ?? WriteResult.retry.message),
            ),
          );
          if (!await _isSignedIn()) await _holdWaiting();
      }
    } catch (e) {
      CheckinLog.event('send.error', {
        'visit': id,
        'error': '$e',
        'ms': watch.elapsedMilliseconds,
      });
      if (!claimed) return;
      await _update(
        id,
        OutboxEntriesCompanion(
          state: const Value(OutboxState.waiting),
          lastError: Value(WriteResult.retry.message),
        ),
      );
      if (!await _isSignedIn()) await _holdWaiting();
    } finally {
      _sendingNow.remove(id);
    }
  }

  /// No backoff while waiting for a session: send as soon as one exists.
  static const _waitForSignIn = OutboxEntriesCompanion(
    state: Value(OutboxState.waitingForSignIn),
    lastError: Value(null),
    attempts: Value(0),
    lastAttemptAt: Value(null),
  );

  Future<CheckinDraft?> _draftFor(OutboxEntry entry) async {
    final visit = await _visit(entry.visitId);
    if (visit == null) return null;
    final settings = await _db.getUserSettings();
    return CheckinDraft(
      siteId: visit.siteId,
      checkinAt: visit.checkinDate,
      precision: visit.checkinPrecision,
      latitude: entry.latitude,
      longitude: entry.longitude,
      accuracy: entry.accuracy,
      notesPublic: visit.notesPublic,
      notesPrivate: visit.notesPrivate,
      userId: settings.odUserId,
    );
  }

  Future<String?> _privateNote(String? note, String? vehicleId) async {
    final lines = [?_blankToNull(note)];
    if (vehicleId != null) {
      final settings = await _db.getUserSettings();
      final vehicle = await _db.getVehicle(vehicleId);
      if (vehicle != null && settings.includeVehicleInPrivateNote) {
        final details = [
          vehicle.year,
          vehicle.make,
          vehicle.model,
          vehicle.trim,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
        if (details.isNotEmpty) lines.add('Vehicle: $details');
      }
    }
    return lines.isEmpty ? null : lines.join('\n');
  }

  static String? _blankToNull(String? s) =>
      s == null || s.trim().isEmpty ? null : s;

  Future<Visit?> _visit(int visitId) => (_db.select(
    _db.visits,
  )..where((t) => t.id.equals(visitId))).getSingleOrNull();

  Future<OutboxEntry?> _entry(int visitId) => (_db.select(
    _db.outboxEntries,
  )..where((t) => t.visitId.equals(visitId))).getSingleOrNull();

  Future<void> _update(int visitId, OutboxEntriesCompanion change) async {
    await (_db.update(
      _db.outboxEntries,
    )..where((t) => t.visitId.equals(visitId))).write(change);
    _changed();
  }

  Future<void> _delete(int visitId) async {
    await (_db.delete(
      _db.outboxEntries,
    )..where((t) => t.visitId.equals(visitId))).go();
    _changed();
  }

  void _changed() => changes.value++;

  Future<T> _enqueue<T>(Future<T> Function() job) {
    final run = _queue.then((_) => job());
    _queue = run.then((_) {}, onError: (_) {});
    return run;
  }
}
