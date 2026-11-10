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
  final settings = await DatabaseService.getUserSettings();
  final lastVehicleId = await DatabaseService.db.getLastUsedVehicleId();
  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _CheckinDialog(
      site: site,
      distanceKm: distanceKm,
      position: position,
      vehicles: vehicles,
      lastVisit: lastVisit,
      unitSystem: settings.unitSystem,
      lastVehicleId: lastVehicleId,
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
  final UnitSystem unitSystem;
  final String? lastVehicleId;

  const _CheckinDialog({
    required this.site,
    required this.distanceKm,
    required this.position,
    required this.vehicles,
    required this.lastVisit,
    required this.unitSystem,
    required this.lastVehicleId,
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
    if (widget.vehicles.any((v) => v.id == widget.lastVehicleId)) {
      _selectedVehicleId = widget.lastVehicleId;
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
    final imperial = widget.unitSystem == UnitSystem.imperial;
    final distance = imperial
        ? widget.distanceKm / 1.609344
        : widget.distanceKm;
    final distanceUnit = imperial ? 'mi' : 'km';

    return AlertDialog(
      title: const Text('Check In'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(site.name, style: theme.textTheme.titleMedium),
            Text(
              '${distance.toStringAsFixed(1)} $distanceUnit away',
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
    final vehicle = widget.vehicles
        .where((v) => v.id == _selectedVehicleId)
        .firstOrNull;
    final privateNotes = <String>[
      if (_privateController.text.isNotEmpty) _privateController.text,
    ];
    if (vehicle != null && vehicle.displayOptIn) {
      final details = [
        vehicle.year,
        vehicle.make,
        vehicle.model,
        vehicle.trim,
      ].where((s) => s != null && s.isNotEmpty).join(' ');
      if (details.isNotEmpty) privateNotes.add('Vehicle: $details');
    }

    try {
      await DatabaseService.db.transaction(() async {
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
              privateNotes.isEmpty ? null : privateNotes.join('\n'),
            ),
            vehicleId: Value(_selectedVehicleId),
          ),
        );
        await DatabaseService.markSiteVisited(widget.site.siteId, true);
      });

      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save check-in. Please try again.'),
          ),
        );
      }
    }
  }
}
