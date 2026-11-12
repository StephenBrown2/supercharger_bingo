import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
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
  Map<int, PendingCheckin> _pending = {};
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final visits = await DatabaseService.getVisits();
    visits.sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
    final names = <int, String>{};
    final pending = <int, PendingCheckin>{};
    for (final visit in visits) {
      if (!names.containsKey(visit.siteId)) {
        final site = await DatabaseService.getSiteBySiteId(visit.siteId);
        names[visit.siteId] = site?.name ?? 'Site ${visit.siteId}';
      }
      final pendingId = visit.pendingId;
      if (pendingId != null) {
        final row = await DatabaseService.getPendingCheckin(pendingId);
        if (row != null) pending[pendingId] = row;
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
    final synced = visit.syncStatus == VisitSyncStatus.synced;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete check-in?'),
        content: Text(
          synced
              ? 'Delete this check-in at $name from supercharging.life and '
                    'this app? This cannot be undone.'
              : '$name has not synced to supercharging.life, so this removes it '
                    'from the app only.',
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
          final settings = await DatabaseService.getUserSettings();
          final username = settings.username;
          if (username != null && username.isNotEmpty) {
            await SyncService(
              apiService: widget.api,
            ).syncUserByUsername(username);
            final refreshed = await DatabaseService.getVisits();
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
      await DatabaseService.deleteVisit(visit);
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
                  final queued = visit.pendingId == null
                      ? null
                      : _pending[visit.pendingId];
                  final failed = queued?.status == PendingStatus.failed;
                  final pending =
                      visit.syncStatus == VisitSyncStatus.pending && !failed;
                  final label = failed
                      ? 'Not synced'
                      : (pending ? 'Pending' : null);
                  return ListTile(
                    title: Text(
                      _siteNames[visit.siteId] ?? 'Site ${visit.siteId}',
                    ),
                    subtitle: Text(_formatDate(visit.checkinDate)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label != null)
                          Text(
                            label,
                            style: TextStyle(
                              color: failed
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.tertiary,
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
