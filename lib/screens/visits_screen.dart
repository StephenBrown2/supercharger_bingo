import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';

/// Personal visits, including check-ins that have not synced yet. A check-in
/// that has not reached supercharging.life can be deleted here.
class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit>? _visits;
  Map<int, String> _siteNames = {};
  Map<int, PendingCheckin> _pending = {};

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete check-in?'),
        content: Text(
          '$name has not synced to supercharging.life, so this removes it '
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
    if (confirmed != true) return;
    await DatabaseService.deleteUnsyncedVisit(visit);
    await _load();
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
                    trailing: label == null
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                onPressed: () => _delete(
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
