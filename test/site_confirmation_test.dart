import 'package:flutter_test/flutter_test.dart';
import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/site_confirmation.dart';

void main() {
  Site site(int id, SiteStatus status, {DateTime? opened}) => Site(
    id: id,
    siteId: id,
    name: 'Site $id',
    status: status,
    latitude: 40,
    longitude: -83,
    country: 'US',
    region: 'NA',
    otherEvs: false,
    stallsV2: 0,
    stallsV3: 0,
    stallsV4: 0,
    stallsUrban: 0,
    stallsOther: 0,
    hasCheckins: false,
    visited: false,
    dateOpened: opened,
  );
  SiteWithDistance near(Site s, double km) => (site: s, distanceKm: km);

  final now = DateTime.utc(2026, 11, 18, 15);
  final nearby = [
    near(site(10, SiteStatus.construction), 0.1),
    near(site(11, SiteStatus.open), 0.2),
    near(site(12, SiteStatus.open), 0.3),
    near(site(13, SiteStatus.open), 0.4),
    near(site(14, SiteStatus.open), 0.5),
  ];

  test('an Operational Site that has opened goes ahead', () {
    expect(
      confirmSite(
        site(1, SiteStatus.open, opened: DateTime.utc(2020)),
        now,
        nearby,
      ),
      isNull,
    );
  });

  for (final (status, phrase) in [
    (SiteStatus.construction, 'under construction'),
    (SiteStatus.permit, 'in permitting'),
    (SiteStatus.plan, 'planned'),
    (SiteStatus.voting, 'up for a vote'),
    (SiteStatus.closedTemp, 'closed'),
    (SiteStatus.closedPerm, 'closed'),
  ]) {
    test('a ${status.name} Site asks "Did you mean?" first', () {
      final confirmation = confirmSite(site(1, status), now, nearby)!;
      expect(confirmation.message, contains(phrase));
      // Nearest three Operational Sites, never the Site itself.
      expect(confirmation.alternatives.map((s) => s.site.siteId), [11, 12, 13]);
    });
  }

  test('the opening date is checked before the status', () {
    final confirmation = confirmSite(
      site(1, SiteStatus.construction, opened: DateTime.utc(2027, 1, 15)),
      now,
      nearby,
    )!;
    expect(
      confirmation.message,
      'This Site is listed as opening on 2027-01-15. '
      'If it opened early, say so in your note.',
    );
  });

  test('with nothing Operational nearby it goes straight to confirming', () {
    final confirmation = confirmSite(site(1, SiteStatus.closedPerm), now, [
      near(site(10, SiteStatus.construction), 0.1),
    ])!;
    expect(confirmation.alternatives, isEmpty);
  });
}
