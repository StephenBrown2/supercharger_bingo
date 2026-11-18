import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/checkin_rules.dart';
import '../services/database_service.dart';
import '../services/life_time.dart';
import '../services/sync_service.dart';

/// Check-in dialog modeled on the live supercharging.life form (SPEC Section 6):
/// public note, private note, optional vehicle selector, and the user's most
/// recent check-in at this site. Saves to the PendingCheckins outbox and sends
/// right away. Returns null if cancelled, otherwise the outbox status after the
/// send: `completed`, `failed` (refused) or `pending` (retried later).
Future<PendingStatus?> showCheckinDialog(
  BuildContext context, {
  required Site site,
  required double distanceKm,
  Position? position,
}) async {
  final vehicles = await DatabaseService.getVehicles();
  final lastVisit = await DatabaseService.db.getLastVisitDate(site.siteId);
  final settings = await DatabaseService.getUserSettings();
  final lastVehicleId = await DatabaseService.db.getLastUsedVehicleId();
  if (!context.mounted) return null;

  return showDialog<PendingStatus>(
    context: context,
    builder: (context) => _CheckinDialog(
      site: site,
      distanceKm: distanceKm,
      position: position,
      vehicles: vehicles,
      lastVisit: lastVisit,
      unitSystem: settings.unitSystem,
      includeVehicleInPrivateNote: settings.includeVehicleInPrivateNote,
      lastVehicleId: lastVehicleId,
    ),
  );
}

String _formatDate(DateTime d) => formatCalendarDate(d);

class _CheckinDialog extends StatefulWidget {
  final Site site;
  final double distanceKm;
  final Position? position;
  final List<Vehicle> vehicles;
  final DateTime? lastVisit;
  final UnitSystem unitSystem;
  final bool includeVehicleInPrivateNote;
  final String? lastVehicleId;

  const _CheckinDialog({
    required this.site,
    required this.distanceKm,
    required this.position,
    required this.vehicles,
    required this.lastVisit,
    required this.unitSystem,
    required this.includeVehicleInPrivateNote,
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
  late final DateTime _checkinAt;

  @override
  void initState() {
    super.initState();
    _checkinAt = DateTime.now();
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

    // No dismissal mid-send: the result would be lost and the user could
    // submit the same check-in again.
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
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
                formatLifeDateField(
                  _checkinAt,
                  precision: CheckinPrecision.timestamp,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
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
                  // Closed while sending: the dialog pops itself when the send ends.
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _selectedVehicleId = value),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
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
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final rejection = checkinOpeningRejection(widget.site, _checkinAt);
    if (rejection != null) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(rejection)));
      }
      return;
    }
    final now = _checkinAt;
    final pos = widget.position;
    final vehicle = widget.vehicles
        .where((v) => v.id == _selectedVehicleId)
        .firstOrNull;
    final privateNotes = <String>[
      if (_privateController.text.isNotEmpty) _privateController.text,
    ];
    if (vehicle != null && widget.includeVehicleInPrivateNote) {
      final details = [
        vehicle.year,
        vehicle.make,
        vehicle.model,
        vehicle.trim,
      ].where((s) => s != null && s.isNotEmpty).join(' ');
      if (details.isNotEmpty) privateNotes.add('Vehicle: $details');
    }

    try {
      final status = await SyncService.instance.submitCheckin(
        method: pos == null ? CheckinMethod.manual : CheckinMethod.gps,
        PendingCheckinsCompanion(
          siteId: Value(widget.site.siteId),
          checkinDate: Value(now),
          checkinPrecision: const Value(CheckinPrecision.timestamp),
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

      if (mounted) Navigator.pop(context, status);
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
