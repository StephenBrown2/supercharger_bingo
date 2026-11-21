import '../database/database.dart';
import 'checkin_rules.dart';
import 'first_state.dart' show isOperational;
import 'life_time.dart';

/// Site confirmation for a Check-in the user should double-check first.
class SiteConfirmation {
  /// Why this Site needs confirming, shown above the required public note.
  final String message;

  /// Up to three nearby Operational Sites to offer under "Did you mean?".
  /// Empty means go straight to confirming this Site.
  final List<SiteWithDistance> alternatives;

  const SiteConfirmation(this.message, this.alternatives);
}

/// Null when a Check-in at [site] at [at] can go ahead. Otherwise the user
/// confirms it with a public note, after "Did you mean?" when [nearby] holds
/// Operational Sites other than [site]. The opening date is checked first,
/// then the status.
SiteConfirmation? confirmSite(
  Site site,
  DateTime at,
  List<SiteWithDistance> nearby,
) {
  final message = _reason(site, at);
  if (message == null) return null;
  final alternatives = nearby
      .where(
        (s) => s.site.siteId != site.siteId && isOperational(s.site.status),
      )
      .take(3)
      .toList();
  return SiteConfirmation(message, alternatives);
}

String? _reason(Site site, DateTime at) {
  if (checkinPrecedesOpening(site, at)) {
    final opened = formatCalendarDate(site.firstOpeningDay!.toUtc());
    return 'This Site is listed as opening on $opened. '
        'If it opened early, say so in your note.';
  }
  return switch (site.status) {
    SiteStatus.open => null,
    SiteStatus.construction ||
    SiteStatus.permit ||
    SiteStatus.plan ||
    SiteStatus.voting =>
      'This Site is listed as ${_statusWord(site.status)}. '
          'If it just opened, say so in your note.',
    SiteStatus.closedTemp || SiteStatus.closedPerm =>
      'This Site is listed as closed. Say what you found in your note, '
          'such as charging despite the closure.',
  };
}

String _statusWord(SiteStatus status) => switch (status) {
  SiteStatus.construction => 'under construction',
  SiteStatus.permit => 'in permitting',
  SiteStatus.plan => 'planned',
  SiteStatus.voting => 'up for a vote',
  _ => status.name,
};
