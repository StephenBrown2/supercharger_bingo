// Native background service (desktop and mobile)
import 'dart:io' show Platform;

import '../../database/database.dart';
import '../desktop_background_service.dart';

Future<void> startBackgroundSync(PollingInterval interval) async {
  // Desktop platforms: use timer-based sync
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    await DesktopBackgroundService.instance.startSync(interval);
  }
  // Mobile platforms handled separately via workmanager in notification_service
}

void stopBackgroundSync() {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    DesktopBackgroundService.instance.stopSync();
  }
}

bool get isBackgroundSyncRunning {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return DesktopBackgroundService.instance.isRunning;
  }
  return false;
}
