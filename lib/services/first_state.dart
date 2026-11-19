import '../database/database.dart';
import 'checkin_rules.dart';
import 'database_service.dart';

/// Where an Operational Site stands in the race for its First (SPEC Section 4).
enum FirstState {
  /// No known First. The next qualifying Check-in takes it.
  upForGrabs,

  /// The First is today at the Site; a Check-in before the next site-local
  /// midnight shares it.
  today,

  /// The First day has ended, or the Site has Check-ins whose dates are
  /// missing from the cached Community history.
  passed,
}

/// OPEN or EXPANDING: the user can charge, and the Site has a First state.
bool isOperational(SiteStatus status) =>
    status == SiteStatus.open || status == SiteStatus.expanding;

/// Up for grabs or First today: a Check-in now would take or share the First.
bool isFirstEligible(FirstState? state) =>
    state == FirstState.upForGrabs || state == FirstState.today;

/// First state of each Operational Site in [sites] at the instant [now].
/// Sites that are not Operational have no key.
Future<Map<int, FirstState>> firstStates(
  Iterable<Site> sites,
  DateTime now,
) async {
  final operational = sites.where((s) => isOperational(s.status)).toList();
  if (operational.isEmpty) return {};
  final evidence = await DatabaseService.getFirstEvidence([
    for (final site in operational) site.siteId,
  ]);
  return {
    for (final site in operational)
      site.siteId: firstStateOf(
        site,
        history: evidence.history[site.siteId] ?? const [],
        visits: evidence.visits[site.siteId] ?? const [],
        now: now,
      )!,
  };
}

/// Who took the First at [site] in Community history, in check-in order.
/// Empty when the First is unknown or has aged out of the history.
Future<List<String>> firstDayNames(Site site) async {
  final evidence = await DatabaseService.getFirstEvidence([site.siteId]);
  final rows = _first(
    site,
    evidence.history[site.siteId] ?? const [],
    const [],
  ).rows;
  return [for (final row in rows) row.displayName ?? row.username];
}

/// The First rule. [history] is the Site's Community history in check-in
/// order; [visits] are the user's confirmed Visits there (none Pending).
/// Null when the Site is not Operational.
FirstState? firstStateOf(
  Site site, {
  required List<SiteCheckin> history,
  required List<Visit> visits,
  required DateTime now,
}) {
  if (!isOperational(site.status)) return null;
  final first = _first(site, history, visits);
  final day = first.day;
  if (day == null) {
    return first.claimed ? FirstState.passed : FirstState.upForGrabs;
  }
  return day.isBefore(siteLocalDay(site, now))
      ? FirstState.passed
      : FirstState.today;
}

/// The First day and its Community history rows. [claimed] marks a Site
/// known to have Check-ins whose dates are not cached.
({DateTime? day, bool claimed, List<SiteCheckin> rows}) _first(
  Site site,
  List<SiteCheckin> history,
  List<Visit> visits,
) {
  // The feed's dates are already site-local calendar dates.
  DateTime rowDay(SiteCheckin row) =>
      siteLocalDay(site, row.checkinDate, precision: CheckinPrecision.dateOnly);
  bool premature(SiteCheckin row) => checkinPrecedesOpening(
    site,
    row.checkinDate,
    precision: CheckinPrecision.dateOnly,
  );
  // A premature First flag can suppress the rightful later rows' flags.
  // ponytail: recovery uses cached history; fetch full history if the feed
  // truncates it.
  final invalidFirst = history.any(
    (row) => row.isFirstAtSupercharger && premature(row),
  );
  final eligible = history
      .where(
        (row) => !premature(row) && (row.isFirstAtSupercharger || invalidFirst),
      )
      .toList();
  final days = [
    for (final row in eligible) rowDay(row),
    for (final visit in visits)
      if (!checkinPrecedesOpening(
        site,
        visit.checkinDate,
        precision: visit.checkinPrecision,
      ))
        siteLocalDay(
          site,
          visit.checkinDate,
          precision: visit.checkinPrecision,
        ),
  ];
  if (days.isEmpty) {
    // Missing history must not reopen a claimed Site, but a known premature
    // Check-in explains the community count, so that Site stays open.
    final claimed = site.hasCheckins && !history.any(premature);
    return (day: null, claimed: claimed, rows: const []);
  }
  final day = days.reduce((a, b) => a.isBefore(b) ? a : b);
  return (
    day: day,
    claimed: true,
    rows: eligible.where((row) => rowDay(row) == day).toList(),
  );
}
