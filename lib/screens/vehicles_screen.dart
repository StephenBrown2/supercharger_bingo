import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:material_ui/material_ui.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/vehicle_service.dart';

/// Local vehicle management (SPEC Section 3 / Section 8). Vehicles are local
/// only and never synced. The raw VIN is stored in secure storage and never
/// displayed. Saved make, model, year, and trim are shown here. A check-in
/// adds them to the private note only when that Check-in setting is on.
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles = await DatabaseService.db.getAllVehicles();
    if (mounted) {
      setState(() {
        _vehicles = vehicles;
        _loading = false;
      });
    }
  }

  String _newId() {
    final rand = Random();
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final tail = List.generate(
      8,
      (_) => rand.nextInt(16).toRadixString(16),
    ).join();
    return '$now-$tail';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
          ? const Center(child: Text('No vehicles yet.'))
          : ListView(children: _vehicles.map(_buildTile).toList()),
    );
  }

  Widget _buildTile(Vehicle v) {
    final derived = [
      v.year,
      v.make,
      v.model,
      v.trim,
    ].where((s) => s != null && s.isNotEmpty).join(' ');
    return ListTile(
      leading: const Icon(Icons.directions_car),
      title: Text(v.label),
      subtitle: derived.isNotEmpty
          ? Text(derived)
          : (v.hasVin ? const Text('VIN stored') : null),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _delete(v),
      ),
    );
  }

  Future<void> _delete(Vehicle v) async {
    await VehicleService.instance.deleteVin(v.id);
    await DatabaseService.db.deleteVehicle(v.id);
    await _load();
  }

  Future<void> _showAddDialog() async {
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => _AddVehicleDialog(onSave: _save),
    );
    if (added == true) await _load();
  }

  Future<void> _save({
    required String label,
    required String vin,
    required String make,
    required String model,
    required String year,
    required String trim,
  }) async {
    final id = _newId();
    String? clean(String value) => value.isEmpty ? null : value;
    var fields = VehicleDecode(
      make: clean(make),
      model: clean(model),
      year: clean(year),
      trim: clean(trim),
    );
    if (vin.isNotEmpty) {
      await VehicleService.instance.storeVin(id, vin);
      // Decode again only when the form still has none of the four fields.
      if (!fields.hasAnyValue) {
        final decoded = await VehicleService.instance.decodeVin(vin);
        if (decoded != null) {
          fields = mergeVehicleFields(
            current: fields,
            decoded: decoded,
            edited: const {},
          );
        }
      }
    }

    await DatabaseService.db.upsertVehicle(
      VehiclesCompanion(
        id: Value(id),
        label: Value(label),
        make: Value(fields.make),
        model: Value(fields.model),
        year: Value(fields.year),
        trim: Value(fields.trim),
        hasVin: Value(vin.isNotEmpty),
      ),
    );
  }
}

/// Owns its text controllers so they are disposed with the route, after the
/// close animation finishes. Disposing them when [showDialog] returns rebuilds
/// the exiting fields against a disposed controller.
class _AddVehicleDialog extends StatefulWidget {
  final Future<void> Function({
    required String label,
    required String vin,
    required String make,
    required String model,
    required String year,
    required String trim,
  })
  onSave;

  const _AddVehicleDialog({required this.onSave});

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _labelController = TextEditingController();
  final _vinController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _trimController = TextEditingController();
  final _edited = <String>{};
  bool _working = false;
  bool _decoding = false;
  bool _suppressEdit = false;
  String? _decodedVin;

  @override
  void dispose() {
    _labelController.dispose();
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _trimController.dispose();
    super.dispose();
  }

  Future<void> _onVinChanged(String raw) async {
    final vin = raw.trim();
    if (vin.length != 17 || vin == _decodedVin || _decoding) return;
    _decoding = true;
    _decodedVin = vin;
    setState(() {});
    final decoded = await VehicleService.instance.decodeVin(vin);
    if (!mounted || _decodedVin != vin) return;
    _decoding = false;
    if (decoded != null) _applyDecode(decoded);
    setState(() {});
  }

  void _applyDecode(VehicleDecode decoded) {
    final merged = mergeVehicleFields(
      current: VehicleDecode(
        make: _makeController.text,
        model: _modelController.text,
        year: _yearController.text,
        trim: _trimController.text,
      ),
      decoded: decoded,
      edited: _edited,
    );
    _setField(_makeController, merged.make);
    _setField(_modelController, merged.model);
    _setField(_yearController, merged.year);
    _setField(_trimController, merged.trim);
  }

  void _setField(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text == next) return;
    _suppressEdit = true;
    controller.text = next;
    _suppressEdit = false;
  }

  void _markEdited(String key) {
    if (_suppressEdit) return;
    _edited.add(key);
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_working && _labelController.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Add vehicle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nickname (required)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _vinController,
              onChanged: _onVinChanged,
              decoration: InputDecoration(
                labelText: 'VIN (optional)',
                helperText: _decoding
                    ? 'Looking up the VIN'
                    : 'Stored securely, never shown',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _makeController,
              onChanged: (_) => _markEdited('make'),
              decoration: const InputDecoration(
                labelText: 'Make',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelController,
              onChanged: (_) => _markEdited('model'),
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              onChanged: (_) => _markEdited('year'),
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _trimController,
              onChanged: (_) => _markEdited('trim'),
              decoration: const InputDecoration(
                labelText: 'Trim',
                helperText: 'Filled from the VIN when it can be decoded',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _working ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canSave
              ? () async {
                  setState(() => _working = true);
                  await widget.onSave(
                    label: _labelController.text.trim(),
                    vin: _vinController.text.trim(),
                    make: _makeController.text.trim(),
                    model: _modelController.text.trim(),
                    year: _yearController.text.trim(),
                    trim: _trimController.text.trim(),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                }
              : null,
          child: _working
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
