// Web background service
// ignore_for_file: avoid_web_libraries_in_flutter

import '../../database/database.dart';
import '../web_background_service.dart';

Future<void> startBackgroundSync(PollingInterval interval) async {
  await WebBackgroundService.instance.startSync(interval);
}

void stopBackgroundSync() {
  WebBackgroundService.instance.stopSync();
}

bool get isBackgroundSyncRunning => WebBackgroundService.instance.isRunning;
