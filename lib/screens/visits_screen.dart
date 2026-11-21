import 'package:material_ui/material_ui.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/checkin_outbox.dart';
import '../services/write_result.dart';
import '../services/sync_service.dart';

/// Personal visits, including check-ins that have not synced yet.
class VisitsScreen extends StatefulWidget {
  final ApiService? api;

  const VisitsScreen({super.key, this.api});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit>? _visits;
  Map<int, String> _siteNames = {};
  Map<int, PendingVisit> _pending = {};
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    CheckinOutbox.instance.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    CheckinOutbox.instance.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final visits = await DatabaseService.db.getAllVisits();
    visits.sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
    final names = <int, String>{};
    final pending = await CheckinOutbox.instance.pending();
    for (final visit in visits) {
      if (!names.containsKey(visit.siteId)) {
        final site = await DatabaseService.db.getSiteBySiteId(visit.siteId);
        names[visit.siteId] = site?.name ?? 'Site ${visit.siteId}';
      }
    }
    if (!mounted) return;
    setState(() {
      _visits = visits;
      _siteNames = names;
      _pending = pending;
    });
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  void _say(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Discard a Pending Visit; supercharging.life never had it.
  Future<void> _discard(Visit visit, String name, PendingVisit pending) async {
    final ok = await _confirm(
      'Discard check-in?',
      pending.maybeSent
          ? '$name may already be on supercharging.life. This removes it '
                'from the app only, so check supercharging.life too.'
          : '$name has not been sent to supercharging.life, so this '
                'removes it from the app only.',
      'Discard',
    );
    if (!ok) return;
    if (pending.state == OutboxState.sending) {
      _say('$name is being sent. It is discarded if the send fails.');
    }
    switch (await CheckinOutbox.instance.discard(visit.id)) {
      case Discard.discarded || Discard.notPending:
        break;
      case Discard.confirmed:
        _say(
          '$name reached supercharging.life before it could be discarded, '
          'so it was kept. Delete it if you meant to.',
        );
      case Discard.busy:
        _say('This check-in is being sent. Try again shortly.');
    }
  }

  /// Delete a Confirmed Visit: from supercharging.life first, then the app.
  Future<void> _delete(Visit visit, String name) async {
    if (_deleting) return;
    final pending = _pending[visit.id];
    if (pending != null) return _discard(visit, name, pending);
    final ok = await _confirm(
      'Delete check-in?',
      'Delete this check-in at $name from supercharging.life and '
          'this app? This cannot be undone.',
      'Delete',
    );
    if (!ok || _deleting) return;
    setState(() => _deleting = true);
    try {
      if (visit.checkinId == null) {
        final settings = await DatabaseService.db.getUserSettings();
        final username = settings.username;
        if (username != null && username.isNotEmpty) {
          await SyncService(
            apiService: widget.api,
          ).syncUserByUsername(username);
          final refreshed = await DatabaseService.db.getAllVisits();
          visit = refreshed.firstWhere(
            (v) => v.id == visit.id,
            orElse: () => visit,
          );
        }
      }
      final id = visit.checkinId;
      if (id == null || id <= 0) {
        _say(
          'Could not uniquely match this check-in on supercharging.life. '
          'Nothing was deleted.',
        );
        await _load();
        return;
      }
      final result = await (widget.api ?? ApiService.instance).deleteCheckin(
        id,
      );
      if (result.outcome != WriteOutcome.accepted) {
        _say(result.message ?? 'Could not delete check-in.');
        return;
      }
      await DatabaseService.db.deleteVisit(visit);
      await _load();
    } catch (_) {
      _say('Could not finish deletion. Refresh your visits.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final visits = _visits;
    // No app bar: the tab already says Visits.
    return Scaffold(
      body: SafeArea(
        child: visits == null
            ? const Center(child: CircularProgressIndicator())
            : visits.isEmpty
            ? const Center(child: Text('No visits yet'))
            : ListView.separated(
                itemCount: visits.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  final pending = _pending[visit.id];
                  final label = pending == null ? null : 'Pending';
                  final detail = switch (pending?.state) {
                    null => null,
                    OutboxState.sending => 'Sending',
                    OutboxState.waitingForSignIn =>
                      'Waiting for supercharging.life sign-in',
                    OutboxState.waiting => pending!.lastError,
                  };
                  return ListTile(
                    title: Text(
                      _siteNames[visit.siteId] ?? 'Site ${visit.siteId}',
                    ),
                    subtitle: Text(
                      detail == null
                          ? _formatDate(visit.checkinDate)
                          : '${_formatDate(visit.checkinDate)}\n$detail',
                    ),
                    isThreeLine: detail != null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label != null)
                          Text(
                            label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: pending == null
                              ? 'Delete check-in'
                              : 'Discard check-in',
                          onPressed: _deleting
                              ? null
                              : () => _delete(
                                  visit,
                                  _siteNames[visit.siteId] ?? 'This site',
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
