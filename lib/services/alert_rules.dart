import '../models/supercharge_info.dart';
import '../screens/map_marker_style.dart';

/// A new-site alert: allChanges ADD of an OPEN site, or an UPDATE that
/// becomes OPEN from some other status (SPEC Section 10).
bool isOpeningChange(AllChanges change) {
  if (change.siteStatus != Status.OPEN) return false;
  if (change.changeType == ChangeType.ADD) return true;
  return change.changeType == ChangeType.UPDATE &&
      change.prevStatus != null &&
      change.prevStatus != Status.OPEN;
}

/// The shared First window is the yellow pin: a First exists and its date
/// is still today at the site. A site with no First, or one whose First day
/// has passed, is not in that window.
bool isInFirstWindow({
  required DateTime? earliestCheckin,
  required DateTime siteLocalNow,
}) {
  return computeFirstState(
        firstDate: earliestCheckin,
        siteLocalNow: siteLocalNow,
      ) ==
      FirstState.today;
}

/// Which opening changes should notify, and the cursor to store afterward.
///
/// A null [lastNotifiedChangeId] is the first poll: record the newest id and
/// do not alert, so history is not dumped. The cursor still advances when
/// [notifyNewSites] is off, so turning the toggle on later does not replay it.
class OpeningAlertPlan {
  final List<AllChanges> toAlert;
  final int? nextCursor;

  const OpeningAlertPlan({required this.toAlert, required this.nextCursor});
}

OpeningAlertPlan planOpeningAlerts({
  required List<AllChanges> changes,
  required int? lastNotifiedChangeId,
  required bool notifyNewSites,
}) {
  int? next = lastNotifiedChangeId;
  for (final change in changes) {
    if (next == null || change.id > next) next = change.id;
  }
  if (lastNotifiedChangeId == null || !notifyNewSites) {
    return OpeningAlertPlan(toAlert: const [], nextCursor: next);
  }
  final fresh = changes
      .where(
        (change) => change.id > lastNotifiedChangeId && isOpeningChange(change),
      )
      .toList();
  return OpeningAlertPlan(toAlert: fresh, nextCursor: next);
}

/// Time left in a First window, for the notification text: "5h 12m",
/// "45m", or "under a minute".
String formatTimeLeft(Duration left) {
  if (left.inMinutes < 1) return 'under a minute';
  final hours = left.inHours;
  final minutes = left.inMinutes % 60;
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes}m';
}

/// "A", "A and B", or "A, B and C".
String joinNames(List<String> names) => switch (names.length) {
  0 => '',
  1 => names.single,
  _ => '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}',
};
