import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/services/api_service.dart';

void main() {
  group('ApiService.parseSiteStatus (SPEC Section 2.1)', () {
    test('maps every status, reading EXPANDING as OPEN', () {
      expect(ApiService.parseSiteStatus('OPEN'), SiteStatus.open);
      expect(ApiService.parseSiteStatus('EXPANDING'), SiteStatus.open);
      expect(
        ApiService.parseSiteStatus('CONSTRUCTION'),
        SiteStatus.construction,
      );
      expect(ApiService.parseSiteStatus('PERMIT'), SiteStatus.permit);
      expect(ApiService.parseSiteStatus('PLAN'), SiteStatus.plan);
      expect(ApiService.parseSiteStatus('VOTING'), SiteStatus.voting);
      expect(ApiService.parseSiteStatus('CLOSED_TEMP'), SiteStatus.closedTemp);
      expect(ApiService.parseSiteStatus('CLOSED_PERM'), SiteStatus.closedPerm);
    });

    test('is case-insensitive', () {
      expect(ApiService.parseSiteStatus('open'), SiteStatus.open);
      expect(ApiService.parseSiteStatus('closed_perm'), SiteStatus.closedPerm);
    });

    test('returns null for unrecognized or null status (site is skipped)', () {
      expect(ApiService.parseSiteStatus(null), isNull);
      expect(ApiService.parseSiteStatus(''), isNull);
      expect(ApiService.parseSiteStatus('UNKNOWN'), isNull);
      // Legacy prototype values that are no longer valid:
      expect(ApiService.parseSiteStatus('PLANNED'), isNull);
      expect(ApiService.parseSiteStatus('CLOSED'), isNull);
    });

    test('enum has seven values, with no EXPANDING', () {
      expect(SiteStatus.values.length, 7);
    });
  });
}
