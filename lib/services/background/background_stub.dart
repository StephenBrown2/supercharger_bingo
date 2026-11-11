// Stub for background service - used when platform is not supported
import '../../database/database.dart';

void setAfterSync(Future<void> Function() hook) {}

Future<void> startBackgroundSync(PollingInterval interval) async {
  // No-op on unsupported platforms
}

void stopBackgroundSync() {
  // No-op on unsupported platforms
}

bool get isBackgroundSyncRunning => false;
