import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../database/database.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

/// Mutable settings wrapper for the UI
class MutableSettings {
  int? userId;
  String? username;
  bool isAuthenticated;
  PollingInterval pollingInterval;
  double notificationRadiusKm;
  MapFilter mapFilter;
  bool showVisitedOnMap;
  double checkinRadiusKm;
  UnitSystem unitSystem;
  DateTime? lastSitesSyncAt;
  DateTime? lastCheckinHistorySyncAt;
  DateTime? lastXlsxSyncAt;

  MutableSettings({
    this.userId,
    this.username,
    this.isAuthenticated = false,
    this.pollingInterval = PollingInterval.hours24,
    this.notificationRadiusKm = 100.0,
    this.mapFilter = MapFilter.openUnvisited,
    this.showVisitedOnMap = false,
    this.checkinRadiusKm = 5000.0,
    this.unitSystem = UnitSystem.metric,
    this.lastSitesSyncAt,
    this.lastCheckinHistorySyncAt,
    this.lastXlsxSyncAt,
  });

  factory MutableSettings.from(UserSettingsTableData data) {
    return MutableSettings(
      userId: data.odUserId,
      username: data.username,
      isAuthenticated: data.isAuthenticated,
      pollingInterval: data.pollingInterval,
      notificationRadiusKm: data.notificationRadiusKm,
      mapFilter: data.mapFilter,
      showVisitedOnMap: data.showVisitedOnMap,
      checkinRadiusKm: data.checkinRadiusKm,
      unitSystem: data.unitSystem,
      lastSitesSyncAt: data.lastSitesSyncAt,
      lastCheckinHistorySyncAt: data.lastCheckinHistorySyncAt,
      lastXlsxSyncAt: data.lastXlsxSyncAt,
    );
  }

  UserSettingsTableCompanion toCompanion() {
    return UserSettingsTableCompanion(
      odUserId: Value(userId),
      username: Value(username),
      isAuthenticated: Value(isAuthenticated),
      pollingInterval: Value(pollingInterval),
      notificationRadiusKm: Value(notificationRadiusKm),
      mapFilter: Value(mapFilter),
      showVisitedOnMap: Value(showVisitedOnMap),
      checkinRadiusKm: Value(checkinRadiusKm),
      unitSystem: Value(unitSystem),
    );
  }
}

/// Settings screen with notification, polling, and advanced options
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  MutableSettings? _settings;
  bool _isLoading = true;
  bool _isSyncingSites = false;
  int? _siteCount;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSiteCount();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.getUserSettings();
    setState(() {
      _settings = MutableSettings.from(settings);
      _isLoading = false;
    });
  }

  Future<void> _loadSiteCount() async {
    final sites = await DatabaseService.getSites();
    if (mounted) {
      setState(() => _siteCount = sites.length);
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      await DatabaseService.updateUserSettings(_settings!.toCompanion());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Account section
                _buildSectionHeader(theme, 'Account'),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_settings?.username ?? 'Not logged in'),
                  subtitle: _settings?.isAuthenticated == true
                      ? Text('User ID: ${_settings?.userId}')
                      : const Text('Tap to log in'),
                  trailing: _settings?.isAuthenticated == true
                      ? TextButton(
                          onPressed: _handleLogout,
                          child: const Text('Log out'),
                        )
                      : null,
                  onTap: _settings?.isAuthenticated != true
                      ? _handleLogin
                      : null,
                ),
                const Divider(),

                // Notifications section
                _buildSectionHeader(theme, 'Notifications'),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('New Superchargers'),
                  subtitle: const Text('High priority by default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openNotificationSettings('new_superchargers'),
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('First-Eligible Alerts'),
                  subtitle: const Text('High priority by default'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openNotificationSettings('first_eligible'),
                ),
                const Divider(),

                // Polling section
                _buildSectionHeader(theme, 'Background Sync'),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Polling Interval'),
                  subtitle: Text(_getPollingIntervalLabel()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPollingIntervalPicker,
                ),
                ListTile(
                  leading: const Icon(Icons.radar),
                  title: const Text('Notification Radius'),
                  subtitle: Text(
                    _settings?.unitSystem == UnitSystem.imperial
                        ? '${(_settings!.notificationRadiusKm * 0.621371).toStringAsFixed(0)} mi'
                        : '${_settings?.notificationRadiusKm.toStringAsFixed(0)} km',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showRadiusPicker,
                ),
                ListTile(
                  leading: const Icon(Icons.near_me),
                  title: const Text('Check-in Search Radius'),
                  subtitle: Text(
                    _settings?.unitSystem == UnitSystem.imperial
                        ? '${(_settings!.checkinRadiusKm * 0.621371).toStringAsFixed(0)} mi'
                        : '${_settings?.checkinRadiusKm.toStringAsFixed(0)} km',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showCheckinRadiusPicker,
                ),
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Distance Units'),
                  subtitle: Text(
                    _settings?.unitSystem == UnitSystem.metric
                        ? 'Metric (km)'
                        : 'Imperial (miles)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showUnitSystemPicker,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Note: iOS may limit background refresh to once per day due to system restrictions.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                const Divider(),

                // Advanced section
                _buildSectionHeader(theme, 'Advanced'),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Sync Visit History'),
                  subtitle: _settings?.lastXlsxSyncAt != null
                      ? Text(
                          'Last synced: ${_formatDate(_settings!.lastXlsxSyncAt!)}',
                        )
                      : const Text('Import visits from supercharging.life'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _handleSyncHistory,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Clear Local Data'),
                  subtitle: const Text('Remove all cached data'),
                  onTap: _handleClearData,
                ),
                const Divider(),

                // About section
                _buildSectionHeader(theme, 'About'),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Supercharger Bingo'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Open Source Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
                const Divider(),

                // Debug section
                _buildSectionHeader(theme, 'Debug'),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text('Force Sync Sites'),
                  subtitle: Text('${_siteCount ?? 0} sites in database'),
                  trailing: _isSyncingSites
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isSyncingSites ? null : _handleForceSyncSites,
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Sync Check-in Counts'),
                  subtitle: const Text('Update which sites have been visited'),
                  trailing: _isSyncingSites
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isSyncingSites ? null : _handleSyncCheckinCounts,
                ),
                ListTile(
                  leading: const Icon(Icons.person_search),
                  title: const Text('Re-sync User Data'),
                  subtitle: Text(
                    _settings?.username != null
                        ? 'Sync visits for ${_settings!.username}'
                        : 'No username set',
                  ),
                  trailing: _isSyncingSites
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: (_isSyncingSites || _settings?.username == null)
                      ? null
                      : _handleResyncUserData,
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('Reset Database'),
                  subtitle: const Text('Clear all data and re-sync'),
                  onTap: _handleResetDatabase,
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPollingIntervalLabel() {
    switch (_settings?.pollingInterval) {
      case PollingInterval.minutes15:
        return '15 minutes';
      case PollingInterval.hour1:
        return '1 hour';
      case PollingInterval.hours4:
        return '4 hours';
      case PollingInterval.hours6:
        return '6 hours';
      case PollingInterval.hours12:
        return '12 hours';
      case PollingInterval.hours24:
      case null:
        return '24 hours';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleLogin() {
    // TODO: Navigate to WebView login screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Login not yet implemented')));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out? Your local data will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out')));
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _openNotificationSettings(String channel) {
    // TODO: Open system notification settings for the channel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $channel notification settings...')),
    );
  }

  void _showPollingIntervalPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Polling Interval'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: PollingInterval.values.map((interval) {
                final label = switch (interval) {
                  PollingInterval.minutes15 => '15 minutes',
                  PollingInterval.hour1 => '1 hour',
                  PollingInterval.hours4 => '4 hours',
                  PollingInterval.hours6 => '6 hours',
                  PollingInterval.hours12 => '12 hours',
                  PollingInterval.hours24 => '24 hours',
                };
                final isSelected = _settings?.pollingInterval == interval;
                return ListTile(
                  title: Text(label),
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _settings?.pollingInterval = interval;
                    });
                    _saveSettings();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _showRadiusPicker() {
    final controller = TextEditingController();
    final isImperial = _settings?.unitSystem == UnitSystem.imperial;
    final initialDisplayValue = isImperial
        ? (_settings?.notificationRadiusKm ?? 100) * 0.621371
        : (_settings?.notificationRadiusKm ?? 100);
    controller.text = initialDisplayValue.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Radius'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final isImperial = _settings?.unitSystem == UnitSystem.imperial;
            final displayValue = isImperial
                ? (_settings?.notificationRadiusKm ?? 100) * 0.621371
                : (_settings?.notificationRadiusKm ?? 100);
            final unit = isImperial ? 'mi' : 'km';
            final minValue = isImperial ? 6.0 : 10.0;
            final maxValue = isImperial ? 1000.0 : 1609.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: displayValue.clamp(minValue, maxValue),
                  min: minValue,
                  max: maxValue,
                  divisions: 99,
                  label: '${displayValue.toStringAsFixed(0)} $unit',
                  onChanged: (value) {
                    setDialogState(() {
                      _settings?.notificationRadiusKm = isImperial
                          ? value / 0.621371
                          : value;
                    });
                    setState(() {});
                    controller.text = value.toStringAsFixed(0);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Exact value ($unit)',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final numValue = double.tryParse(value);
                          if (numValue != null &&
                              numValue >= minValue &&
                              numValue <= maxValue) {
                            setDialogState(() {
                              _settings?.notificationRadiusKm = isImperial
                                  ? numValue / 0.621371
                                  : numValue;
                            });
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveSettings();
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCheckinRadiusPicker() {
    final controller = TextEditingController();
    final isImperial = _settings?.unitSystem == UnitSystem.imperial;
    final initialDisplayValue = isImperial
        ? (_settings?.checkinRadiusKm ?? 5000) * 0.621371
        : (_settings?.checkinRadiusKm ?? 5000);
    controller.text = initialDisplayValue.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in Search Radius'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            final isImperial = _settings?.unitSystem == UnitSystem.imperial;
            final displayValue = isImperial
                ? (_settings?.checkinRadiusKm ?? 5000) * 0.621371
                : (_settings?.checkinRadiusKm ?? 5000);
            final unit = isImperial ? 'mi' : 'km';
            final minValue = isImperial ? 62.0 : 100.0;
            final maxValue = isImperial ? 6214.0 : 10000.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: displayValue.clamp(minValue, maxValue),
                  min: minValue,
                  max: maxValue,
                  divisions: 99,
                  label: '${displayValue.toStringAsFixed(0)} $unit',
                  onChanged: (value) {
                    setDialogState(() {
                      _settings?.checkinRadiusKm = isImperial
                          ? value / 0.621371
                          : value;
                    });
                    setState(() {});
                    controller.text = value.toStringAsFixed(0);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Exact value ($unit)',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final numValue = double.tryParse(value);
                          if (numValue != null &&
                              numValue >= minValue &&
                              numValue <= maxValue) {
                            setDialogState(() {
                              _settings?.checkinRadiusKm = isImperial
                                  ? numValue / 0.621371
                                  : numValue;
                            });
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveSettings();
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUnitSystemPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<UnitSystem>(
              title: const Text('Metric (kilometers)'),
              value: UnitSystem.metric,
              groupValue: _settings?.unitSystem,
              onChanged: (value) {
                setState(() {
                  _settings?.unitSystem = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
            RadioListTile<UnitSystem>(
              title: const Text('Imperial (miles)'),
              value: UnitSystem.imperial,
              groupValue: _settings?.unitSystem,
              onChanged: (value) {
                setState(() {
                  _settings?.unitSystem = value!;
                });
                Navigator.pop(context);
                _saveSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSyncHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Visit History'),
        content: const Text(
          'This will download and import your visit history from supercharging.life. '
          'This is normally done automatically on first login.\n\n'
          'Use this option only for troubleshooting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement XLSX import
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing history...')),
              );
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  void _handleClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will remove all cached supercharger data and visit history. '
          'You will need to sync again to restore the data.\n\n'
          'Your account will remain logged in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await DatabaseService.clearAll();
              await _loadSettings();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Local data cleared')),
                );
              }
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForceSyncSites() async {
    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await SyncService.instance.syncSites();
      await _loadSiteCount();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Synced $_siteCount sites')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  Future<void> _handleSyncCheckinCounts() async {
    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await SyncService.instance.syncSuperchargerCheckinCounts();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Synced check-in counts')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  Future<void> _handleResyncUserData() async {
    final username = _settings?.username;
    if (username == null) return;

    setState(() => _isSyncingSites = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final success = await SyncService.instance.syncUserByUsername(username);
      await _loadSettings();
      if (mounted) {
        if (success) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Synced user data')),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingSites = false);
      }
    }
  }

  void _handleResetDatabase() {
    // Remember current username before reset
    final currentUsername = _settings?.username;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: Text(
          'This will delete ALL data including your visit history and settings, '
          'then re-sync supercharger sites.\n\n'
          '${currentUsername != null ? 'Your username ($currentUsername) will be preserved and re-synced.\n\n' : ''}'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              setState(() => _isSyncingSites = true);

              try {
                // Clear everything
                await DatabaseService.clearAll();

                // Re-sync sites first
                await SyncService.instance.syncSites();
                await _loadSiteCount();

                // Sync check-in counts
                await SyncService.instance.syncSuperchargerCheckinCounts();

                // Re-sync user data if we had a username
                if (currentUsername != null && currentUsername.isNotEmpty) {
                  await SyncService.instance.syncUserByUsername(
                    currentUsername,
                  );
                }

                await _loadSettings();

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Database reset. Synced $_siteCount sites.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Reset failed: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isSyncingSites = false);
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
