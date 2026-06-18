import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/vehicle_service.dart';

/// Local vehicle management (SPEC Section 3 / Section 8). Vehicles are local
/// only and never synced. The raw VIN is stored in secure storage and never
/// displayed; only the derived make/model/year/trim are shown, and only when
/// the user opts in.
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
    final vehicles = await DatabaseService.getVehicles();
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
          : ListView(
              children: _vehicles.map(_buildTile).toList(),
            ),
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
      subtitle: v.displayOptIn && derived.isNotEmpty
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
    await DatabaseService.deleteVehicle(v.id);
    await _load();
  }

  Future<void> _showAddDialog() async {
    final labelController = TextEditingController();
    final vinController = TextEditingController();
    bool displayOptIn = false;
    bool working = false;

    final added = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add vehicle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Nickname (required)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vinController,
                  decoration: const InputDecoration(
                    labelText: 'VIN (optional)',
                    helperText: 'Stored securely, never shown',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show decoded make/model'),
                  value: displayOptIn,
                  onChanged: (v) => setDialogState(() => displayOptIn = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: working ? null : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: working || labelController.text.trim().isEmpty
                  ? null
                  : () async {
                      setDialogState(() => working = true);
                      await _save(
                        label: labelController.text.trim(),
                        vin: vinController.text.trim(),
                        displayOptIn: displayOptIn,
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    },
              child: working
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );

    labelController.dispose();
    vinController.dispose();
    if (added == true) await _load();
  }

  Future<void> _save({
    required String label,
    required String vin,
    required bool displayOptIn,
  }) async {
    final id = _newId();
    VehicleDecode? decoded;
    if (vin.isNotEmpty) {
      await VehicleService.instance.storeVin(id, vin);
      // One-time online decode; null on failure (manual entry still works).
      decoded = await VehicleService.instance.decodeVin(vin);
    }

    await DatabaseService.upsertVehicle(
      VehiclesCompanion(
        id: Value(id),
        label: Value(label),
        make: Value(decoded?.make),
        model: Value(decoded?.model),
        year: Value(decoded?.year),
        trim: Value(decoded?.trim),
        displayOptIn: Value(displayOptIn),
        hasVin: Value(vin.isNotEmpty),
      ),
    );
  }
}
