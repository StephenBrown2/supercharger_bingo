import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/database.dart';
import 'api_service.dart';
import 'checkin_form.dart';
import 'checkin_writer.dart';
import 'database_service.dart';
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
    return CheckinOutbox(
      db: DatabaseService.db,
      writer: UnofficialCheckinWriter(life),
      isSignedIn: () async {
        final session = await life.getSessionCookie();
        return session != null && session.isNotEmpty;
      },
      markSessionExpired: () async {
        await life.clearSessionCookie();
        await DatabaseService.updateUserSettings(
          const UserSettingsTableCompanion(isAuthenticated: Value(false)),
        );
      },
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

    try {
      await _enqueue(() async {
        final entry = await _entry(visitId);
        // A sync that ran first may already have tried it.
        if (entry != null && entry.attempts == 0) await _sendIfPossible(entry);
      });
      final entry = await _entry(visitId);
      if (entry == null) return Delivery.sent;
      return entry.state == OutboxState.waitingForSignIn
          ? Delivery.waitingForSignIn
          : Delivery.waiting;
    } catch (_) {
      return Delivery.waiting;
    }
  }

  /// Send every entry that is due: waiting past its backoff, waiting for a
  /// sign-in that may now exist, or interrupted mid-send.
  Future<void> sendDue() => _enqueue(() async {
    if (!_sendingEnabled || !await _isOnline()) return;
    final now = _now();
    for (final entry in await _db.select(_db.outboxEntries).get()) {
      if (_isDue(entry, now)) await _send(entry);
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

  /// Remove a Pending Visit. Returns false, removing nothing, while it may be
  /// mid-send. A Visit supercharging.life has confirmed is not removed here.
  Future<bool> remove(int visitId) async {
    final entry = await _entry(visitId);
    if (entry == null) return false;
    if (entry.state == OutboxState.sending && !_interrupted(entry, _now())) {
      return false;
    }
    final visit = await (_db.select(
      _db.visits,
    )..where((t) => t.id.equals(visitId))).getSingleOrNull();
    if (visit != null) await _db.deleteVisit(visit);
    _changed();
    return true;
  }

  /// Match the user's Visits from supercharging.life against local ones,
  /// settling any Sending entry whose Check-in turned up there.
  Future<void> settleFromImport(List<VisitsCompanion> imported) async {
    await _db.reconcileVisitIds(imported);
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

  Future<void> _sendIfPossible(OutboxEntry entry) async {
    if (!_sendingEnabled || !await _isOnline()) return;
    await _send(entry);
  }

  /// One send attempt. The result is written to the entry; a send that throws
  /// leaves it waiting.
  Future<void> _send(OutboxEntry entry) async {
    final id = entry.visitId;
    try {
      if (!await _isSignedIn()) {
        await _update(id, _waitForSignIn);
        return;
      }
      await _update(
        id,
        OutboxEntriesCompanion(
          state: const Value(OutboxState.sending),
          lastAttemptAt: Value(_now()),
          attempts: Value(entry.attempts + 1),
        ),
      );
      final draft = await _draftFor(entry);
      if (draft == null) {
        // The Visit is gone; nothing to send.
        await _delete(id);
        return;
      }
      final result = await _writer.submit(draft);
      switch (result.outcome) {
        case WriteOutcome.accepted:
          await _delete(id);
        case WriteOutcome.needsSignIn:
          await _update(id, _waitForSignIn);
          await _markSessionExpired();
        case WriteOutcome.retry || WriteOutcome.rejected:
          await _update(
            id,
            OutboxEntriesCompanion(
              state: const Value(OutboxState.waiting),
              lastError: Value(result.message ?? WriteResult.retry.message),
            ),
          );
      }
    } catch (_) {
      await _update(
        id,
        OutboxEntriesCompanion(
          state: const Value(OutboxState.waiting),
          lastError: Value(WriteResult.retry.message),
        ),
      );
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
    final visit = await (_db.select(
      _db.visits,
    )..where((t) => t.id.equals(entry.visitId))).getSingleOrNull();
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

  Future<void> _enqueue(Future<void> Function() job) {
    final run = _queue.then((_) => job());
    _queue = run.catchError((_) {});
    return run;
  }
}
