import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/database_service.dart';

/// Check-in dialog modeled on the live supercharging.life form (SPEC Section 6):
/// public note, private note, optional vehicle selector, and the user's most
/// recent check-in at this site. Writes locally to the PendingCheckins outbox
/// and never blocks on the network. Returns true if a check-in was queued.
Future<bool> showCheckinDialog(
  BuildContext context, {
  required Site site,
  required double distanceKm,
  Position? position,
}) async {
  final vehicles = await DatabaseService.getVehicles();
  final lastVisit = await DatabaseService.db.getLastVisitDate(site.siteId);
  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _CheckinDialog(
      site: site,
      distanceKm: distanceKm,
      position: position,
      vehicles: vehicles,
      lastVisit: lastVisit,
    ),
  );
  return result ?? false;
}

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _CheckinDialog extends StatefulWidget {
  final Site site;
  final double distanceKm;
  final Position? position;
  final List<Vehicle> vehicles;
  final DateTime? lastVisit;

  const _CheckinDialog({
    required this.site,
    required this.distanceKm,
    required this.position,
    required this.vehicles,
    required this.lastVisit,
  });

  @override
  State<_CheckinDialog> createState() => _CheckinDialogState();
}

class _CheckinDialogState extends State<_CheckinDialog> {
  final _publicController = TextEditingController();
  final _privateController = TextEditingController();
  String? _selectedVehicleId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Default to the most recently added vehicle (last used proxy).
    if (widget.vehicles.isNotEmpty) {
      _selectedVehicleId = widget.vehicles.last.id;
    }
  }

  @override
  void dispose() {
    _publicController.dispose();
    _privateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final site = widget.site;

    return AlertDialog(
      title: const Text('Check In'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(site.name, style: theme.textTheme.titleMedium),
            Text(
              '${widget.distanceKm.toStringAsFixed(1)} km away',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            // Most recent check-in indicator (SPEC Section 6, item 3).
            Text(
              widget.lastVisit != null
                  ? 'Last check-in: ${_formatDate(widget.lastVisit!)}'
                  : 'No previous check-in.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _publicController,
              decoration: const InputDecoration(
                labelText: 'Public note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _privateController,
              decoration: const InputDecoration(
                labelText: 'Private note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (widget.vehicles.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(
                  labelText: 'Vehicle (optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...widget.vehicles.map(
                    (v) => DropdownMenuItem<String?>(
                      value: v.id,
                      child: Text(v.label),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedVehicleId = value),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Check In'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final now = DateTime.now();
    final pos = widget.position;

    await DatabaseService.addPendingCheckin(
      PendingCheckinsCompanion(
        siteId: Value(widget.site.siteId),
        checkinDate: Value(now),
        createdAt: Value(now),
        latitude: Value(pos?.latitude),
        longitude: Value(pos?.longitude),
        accuracy: Value(pos?.accuracy),
        notesPublic: Value(
          _publicController.text.isEmpty ? null : _publicController.text,
        ),
        notesPrivate: Value(
          _privateController.text.isEmpty ? null : _privateController.text,
        ),
        vehicleId: Value(_selectedVehicleId),
      ),
    );
    // Optimistically reflect the check-in on the map.
    await DatabaseService.markSiteVisited(widget.site.siteId, true);

    if (mounted) Navigator.pop(context, true);
  }
}
