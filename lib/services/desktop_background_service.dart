// Background sync service for Linux using Dart Timers
// Since Linux is a desktop app that runs continuously, we can use
// a simple Timer-based approach instead of workmanager

import 'dart:async';

import '../database/database.dart';
import 'sync_service.dart';

/// Background sync service for desktop platforms (Linux, Windows, macOS)
class DesktopBackgroundService {
  static DesktopBackgroundService? _instance;
  static DesktopBackgroundService get instance =>
      _instance ??= DesktopBackgroundService._();

  DesktopBackgroundService._();

  Timer? _syncTimer;
  bool _isRunning = false;
  PollingInterval? _currentInterval;

  /// Runs after each sync. NotificationService sets this so desktop alerts
  /// fire without this file importing the notification plugin.
  Future<void> Function()? afterSync;

  /// Start background sync with the specified interval
  Future<void> startSync(PollingInterval interval) async {
    // Cancel any existing timer
    stopSync();

    final minutes = _pollingIntervalToMinutes(interval);
    final duration = Duration(minutes: minutes);

    _isRunning = true;
    _currentInterval = interval;

    // Run initial sync
    await _performSync();

    // Schedule periodic sync
    _syncTimer = Timer.periodic(duration, (_) async {
      if (_isRunning) {
        await _performSync();
      }
    });
  }

  /// Perform a single sync operation
  Future<void> _performSync() async {
    try {
      // Sync sites, then community First data, then flush pending checkins.
      await SyncService.instance.syncSites();
      await SyncService.instance.syncCommunityData();
      await SyncService.instance.syncPendingCheckins();
      final hook = afterSync;
      if (hook != null) await hook();
    } catch (e) {
      // Log error but don't crash
      // In a real app, consider using a proper logging package
      print('Desktop background sync error: $e');
    }
  }

  /// Stop background sync
  void stopSync() {
    _isRunning = false;
    _syncTimer?.cancel();
    _syncTimer = null;
    _currentInterval = null;
  }

  /// Check if sync is running
  bool get isRunning => _isRunning;

  /// Get the current polling interval
  PollingInterval? get currentInterval => _currentInterval;

  /// Reschedule sync with a new interval
  Future<void> rescheduleSync(PollingInterval interval) async {
    if (_isRunning) {
      await startSync(interval);
    }
  }

  /// Convert PollingInterval enum to minutes
  int _pollingIntervalToMinutes(PollingInterval interval) {
    switch (interval) {
      case PollingInterval.minutes15:
        return 15;
      case PollingInterval.hour1:
        return 60;
      case PollingInterval.hours4:
        return 240;
      case PollingInterval.hours6:
        return 360;
      case PollingInterval.hours12:
        return 720;
      case PollingInterval.hours24:
        return 1440;
    }
  }
}
