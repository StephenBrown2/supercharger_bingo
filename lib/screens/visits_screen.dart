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

  Future<void> _delete(Visit visit, String name) async {
    if (_deleting) return;
    final pending = _pending[visit.id];
    final synced = pending == null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete check-in?'),
        content: Text(
          synced
              ? 'Delete this check-in at $name from supercharging.life and '
                    'this app? This cannot be undone.'
              : pending.maybeSent
              ? '$name may already be on supercharging.life. This removes it '
                    'from the app only, so check supercharging.life too.'
              : '$name has not been sent to supercharging.life, so this '
                    'removes it from the app only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _deleting) return;
    setState(() => _deleting = true);
    try {
      if (synced) {
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not uniquely match this check-in on supercharging.life. Nothing was deleted.',
                ),
              ),
            );
          }
          await _load();
          return;
        }
        final result = await (widget.api ?? ApiService.instance).deleteCheckin(
          id,
        );
        if (result.outcome != WriteOutcome.accepted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Could not delete check-in.'),
              ),
            );
          }
          return;
        }
      }
      if (!synced) {
        if (!await CheckinOutbox.instance.remove(visit.id) && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This check-in is being sent. Try again shortly.'),
            ),
          );
        }
        await _load();
        return;
      }
      await DatabaseService.db.deleteVisit(visit);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not finish deletion. Refresh your visits.'),
          ),
        );
      }
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
                          tooltip: 'Delete check-in',
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
