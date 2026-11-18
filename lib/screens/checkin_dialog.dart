import 'package:material_ui/material_ui.dart';
import 'package:geolocator/geolocator.dart';

import '../database/database.dart';
import '../services/checkin_outbox.dart';
import '../services/database_service.dart';
import '../services/life_time.dart';

/// Check-in dialog modeled on the live supercharging.life form (SPEC Section 6):
/// public note, private note, optional vehicle selector, and the user's most
/// recent check-in at this site. Records the Check-in in the Check-in outbox,
/// which sends it right away. Returns null if cancelled.
///
/// With [confirmMessage] the user is confirming a Site that needs it (Site
/// confirmation): the message shows at the top and the public note is required.
Future<Delivery?> showCheckinDialog(
  BuildContext context, {
  required Site site,
  required double distanceKm,
  Position? position,
  String? confirmMessage,
}) async {
  final vehicles = await DatabaseService.getVehicles();
  final lastVisit = await DatabaseService.db.getLastVisitDate(site.siteId);
  final settings = await DatabaseService.getUserSettings();
  final lastVehicleId = await DatabaseService.db.getLastUsedVehicleId();
  if (!context.mounted) return null;

  return showDialog<Delivery>(
    context: context,
    builder: (context) => _CheckinDialog(
      site: site,
      distanceKm: distanceKm,
      position: position,
      vehicles: vehicles,
      lastVisit: lastVisit,
      unitSystem: settings.unitSystem,
      lastVehicleId: lastVehicleId,
      confirmMessage: confirmMessage,
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
  final String? lastVehicleId;
  final String? confirmMessage;

  const _CheckinDialog({
    required this.site,
    required this.distanceKm,
    required this.position,
    required this.vehicles,
    required this.lastVisit,
    required this.unitSystem,
    required this.lastVehicleId,
    required this.confirmMessage,
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
    final confirming = widget.confirmMessage != null;
    final noteMissing = confirming && _publicController.text.trim().isEmpty;

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
              if (confirming) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.confirmMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _publicController,
                autofocus: confirming,
                // Rebuild so Check In enables once the required note exists.
                onChanged: confirming ? (_) => setState(() {}) : null,
                decoration: InputDecoration(
                  labelText: confirming
                      ? 'Public note (required)'
                      : 'Public note (optional)',
                  helperText: confirming
                      ? 'Explain why you are checking in here'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                maxLines: confirming ? 3 : 2,
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
            onPressed: _submitting || noteMissing ? null : _submit,
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
    final pos = widget.position;
    try {
      final delivery = await CheckinOutbox.instance.record(
        siteId: widget.site.siteId,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        accuracy: pos?.accuracy,
        notesPublic: _publicController.text,
        notesPrivate: _privateController.text,
        vehicleId: _selectedVehicleId,
      );
      if (mounted) Navigator.pop(context, delivery);
    } catch (_) {
      // Only saving can throw; a failed send comes back as a Delivery.
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
