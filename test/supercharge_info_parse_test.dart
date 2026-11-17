import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/models/supercharge_info.dart';
import 'package:supercharger_bingo/services/api_service.dart';

Map<String, dynamic> _siteJson({
  String status = 'OPEN',
  bool includePlugs = true,
}) {
  return {
    'id': 12219,
    'locationId': 'montevideo',
    'name': 'Montevideo',
    'status': status,
    'address': {
      'street': 'Av. Italia',
      'city': 'Montevideo',
      'state': 'Montevideo',
      'zip': '11000',
      'countryId': 58,
      'country': 'Uruguay',
      'regionId': 4,
      'region': 'South America',
    },
    'gps': {'latitude': -34.9, 'longitude': -56.2},
    'dateOpened': '2024-01-15',
    'stallCount': 8,
    'counted': true,
    'elevationMeters': 43,
    'powerKilowatt': 250,
    'solarCanopy': false,
    'battery': false,
    'otherEVs': true,
    'statusDays': 3,
    'urlDiscuss': false,
    'stalls': null,
    if (includePlugs) 'plugs': {'nacs': 8} else 'plugs': null,
  };
}

void main() {
  test('Uruguay site with null plugs maps to a companion', () {
    final parsed = ApiService.parseSiteRecord(_siteJson(includePlugs: false));
    expect(parsed, isNotNull);
    expect(parsed!.siteId.value, 12219);
    expect(parsed.name.value, 'Montevideo');
    expect(parsed.country.value, 'Uruguay');
    expect(parsed.region.value, 'South America');
    expect(parsed.status.value, SiteStatus.open);
    expect(parsed.stallCount.value, 8);
    expect(parsed.otherEvs.value, isTrue);
    expect(parsed.dateOpened.value, DateTime.utc(2024, 1, 15));
    expect(parsed.latitude.value, -34.9);
  });

  test('status spelling is normalized before the model parse', () {
    final parsed = ApiService.parseSiteRecord(_siteJson(status: 'open'));
    expect(parsed!.status.value, SiteStatus.open);
  });

  test('unknown or malformed site rows are skipped', () {
    expect(ApiService.parseSiteRecord(_siteJson(status: 'UNKNOWN')), isNull);
    expect(ApiService.parseSiteRecord(_siteJson(status: 'PLANNED')), isNull);
    expect(ApiService.parseSiteRecord({'status': 'OPEN', 'id': 1}), isNull);
  });

  test('AllChanges accepts null prevStatus and detects ADD plus OPEN', () {
    final change = ApiService.parseChangeRecord({
      'id': 9,
      'siteId': 12219,
      'date': '2024-01-15',
      'changeType': 'ADD',
      'siteStatus': 'OPEN',
      'prevStatus': null,
      'stallCount': 8,
      'prevCount': 0,
      'powerKilowatt': 250,
      'notify': true,
      'siteName': 'Montevideo',
      'regionId': 4,
      'region': 'South America',
      'countryId': 58,
      'country': 'Uruguay',
      'state': 'Montevideo',
      'site': _siteJson(includePlugs: false),
      'dateFormatted': 'Jan 15, 2024',
    });

    expect(change, isNotNull);
    expect(change!.prevStatus, isNull);
    expect(change.changeType, ChangeType.ADD);
    expect(change.siteStatus, Status.OPEN);
    expect(change.site.plugs, isNull);
    expect(change.site.address.country, Country.URUGUAY);
  });

  test('a change with an unknown status is skipped', () {
    final change = ApiService.parseChangeRecord({
      'id': 10,
      'siteId': 1,
      'date': '2024-01-15',
      'changeType': 'UPDATE',
      'siteStatus': 'PLANNED',
      'prevStatus': null,
      'stallCount': 0,
      'prevCount': 0,
      'powerKilowatt': 0,
      'notify': false,
      'siteName': 'Nope',
      'regionId': 4,
      'region': 'South America',
      'countryId': 58,
      'country': 'Uruguay',
      'state': null,
      'site': _siteJson(),
      'dateFormatted': 'Jan 15, 2024',
    });
    expect(change, isNull);
  });
}
