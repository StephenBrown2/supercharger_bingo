import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/screens/map_marker_style.dart';

void main() {
  group('computeFirstState (SPEC Section 4/5)', () {
    final now = DateTime(2026, 6, 18, 14, 0);

    test('no check-in date => up for grabs', () {
      expect(
        computeFirstState(firstDate: null, siteLocalNow: now),
        FirstState.upForGrabs,
      );
    });

    test('first date today (site-local) => today (yellow window)', () {
      expect(
        computeFirstState(
          firstDate: DateTime(2026, 6, 18, 9, 30),
          siteLocalNow: now,
        ),
        FirstState.today,
      );
    });

    test('first date before today => passed', () {
      expect(
        computeFirstState(
          firstDate: DateTime(2026, 6, 17),
          siteLocalNow: now,
        ),
        FirstState.passed,
      );
    });
  });

  group('markerStyleFor (Okabe-Ito + glyph redundancy)', () {
    test('operational up-for-grabs is green open-circle', () {
      final s = markerStyleFor(
        status: SiteStatus.open,
        firstState: FirstState.upForGrabs,
        visited: false,
      );
      expect(s.color, OkabeIto.green);
      expect(s.glyph, Icons.circle_outlined);
    });

    test('operational first-today is yellow clock', () {
      final s = markerStyleFor(
        status: SiteStatus.expanding,
        firstState: FirstState.today,
        visited: false,
      );
      expect(s.color, OkabeIto.yellow);
      expect(s.glyph, Icons.schedule);
    });

    test('operational first-passed is red filled-check', () {
      final s = markerStyleFor(
        status: SiteStatus.open,
        firstState: FirstState.passed,
        visited: false,
      );
      expect(s.color, OkabeIto.vermillion);
    });

    test('construction is blue, ignores first state', () {
      final s = markerStyleFor(
        status: SiteStatus.construction,
        firstState: FirstState.upForGrabs,
        visited: false,
      );
      expect(s.color, OkabeIto.blue);
      expect(s.glyph, Icons.construction);
    });

    test('permit/plan/voting are reddish-purple', () {
      for (final status in [
        SiteStatus.permit,
        SiteStatus.plan,
        SiteStatus.voting,
      ]) {
        final s = markerStyleFor(
          status: status,
          firstState: FirstState.upForGrabs,
          visited: false,
        );
        expect(s.color, OkabeIto.reddishPurple, reason: '$status');
      }
    });

    test('closed temp and perm are grey with distinct glyphs', () {
      final temp = markerStyleFor(
        status: SiteStatus.closedTemp,
        firstState: FirstState.upForGrabs,
        visited: false,
      );
      final perm = markerStyleFor(
        status: SiteStatus.closedPerm,
        firstState: FirstState.upForGrabs,
        visited: false,
      );
      expect(temp.color, OkabeIto.grey);
      expect(perm.color, OkabeIto.grey);
      expect(temp.glyph, isNot(perm.glyph));
    });

    test('visited carries a check overlay regardless of colour', () {
      final s = markerStyleFor(
        status: SiteStatus.open,
        firstState: FirstState.upForGrabs,
        visited: true,
      );
      expect(s.glyph, Icons.check_circle);
      // Underlying colour preserved.
      expect(s.color, OkabeIto.green);
    });
  });

  test('MapFilter now includes a visited value (Show Visited restored)', () {
    expect(MapFilter.values.contains(MapFilter.visited), isTrue);
  });
}
