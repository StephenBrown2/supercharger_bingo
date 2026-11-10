import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';

/// Personal visits, including check-ins that have not synced yet.
class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit>? _visits;
  Map<int, String> _siteNames = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final visits = await DatabaseService.getVisits();
    visits.sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
    final names = <int, String>{};
    for (final visit in visits) {
      if (names.containsKey(visit.siteId)) continue;
      final site = await DatabaseService.getSiteBySiteId(visit.siteId);
      names[visit.siteId] = site?.name ?? 'Site ${visit.siteId}';
    }
    if (!mounted) return;
    setState(() {
      _visits = visits;
      _siteNames = names;
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Visits'), centerTitle: true),
      body: visits == null
          ? const Center(child: CircularProgressIndicator())
          : visits.isEmpty
          ? const Center(child: Text('No visits yet'))
          : ListView.separated(
              itemCount: visits.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final visit = visits[index];
                final pending = visit.syncStatus == VisitSyncStatus.pending;
                return ListTile(
                  title: Text(
                    _siteNames[visit.siteId] ?? 'Site ${visit.siteId}',
                  ),
                  subtitle: Text(_formatDate(visit.checkinDate)),
                  trailing: pending
                      ? Text(
                          'Pending',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                );
              },
            ),
    );
  }
}
