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

    test('first date today (site-local) => today (shared window)', () {
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
        computeFirstState(firstDate: DateTime(2026, 6, 17), siteLocalNow: now),
        FirstState.passed,
      );
    });
  });

  group('markerStyleFor (supercharging.life colours + glyphs)', () {
    MarkerStyle style(SiteStatus status, [FirstState? first, bool v = false]) =>
        markerStyleFor(
          status: status,
          firstState: first ?? FirstState.upForGrabs,
          visited: v,
        );

    test('First states are green, sky blue, and a plain red Open', () {
      expect(style(SiteStatus.open).color, LifePin.green);
      expect(style(SiteStatus.open).glyph, Icons.circle_outlined);
      final today = style(SiteStatus.expanding, FirstState.today);
      expect(today.color, const Color(0xFF56B4E9));
      expect(glyphForeground(today.color), Colors.black);
      expect(today.glyph, Icons.schedule);
      final open = style(SiteStatus.open, FirstState.passed);
      expect(open.color, LifePin.red);
      expect(open.glyph, isNull);
      expect(open.label, 'Open');
    });

    test('statuses match the supercharging.life map', () {
      expect(style(SiteStatus.construction).color, LifePin.yellow);
      expect(style(SiteStatus.permit).color, LifePin.blue);
      expect(style(SiteStatus.plan).color, LifePin.orange);
      expect(style(SiteStatus.voting).color, LifePin.orange);
      expect(style(SiteStatus.closedTemp).color, LifePin.violet);
      expect(style(SiteStatus.closedPerm).color, LifePin.black);
    });

    test('every state has its own glyph', () {
      final glyphs = [
        style(SiteStatus.open).glyph,
        style(SiteStatus.open, FirstState.today).glyph,
        style(SiteStatus.open, FirstState.passed).glyph,
        style(SiteStatus.construction).glyph,
        style(SiteStatus.permit).glyph,
        style(SiteStatus.plan).glyph,
        style(SiteStatus.voting).glyph,
        style(SiteStatus.closedTemp).glyph,
        style(SiteStatus.closedPerm).glyph,
        style(SiteStatus.open, null, true).glyph,
      ];
      expect(glyphs.toSet(), hasLength(glyphs.length));
    });

    test('visited is a grey check whatever the First state', () {
      final s = style(SiteStatus.open, FirstState.upForGrabs, true);
      expect(s.glyph, Icons.check_circle);
      expect(s.color, LifePin.grey);
      expect(glyphForeground(s.color), Colors.white);
    });
  });

  test('MapFilter matches the supercharging.life My Map order', () {
    expect(MapFilter.values, [
      MapFilter.openUnvisited,
      MapFilter.all,
      MapFilter.visited,
      MapFilter.unvisitedNacs,
      MapFilter.openUnvisitedConstruction,
    ]);
  });

  test('check-in row label matches name (status) (distance)', () {
    expect(
      checkinPickerLabel(
        name: 'Upper Sandusky, OH',
        status: SiteStatus.open,
        distance: '12.0 mi',
      ),
      'Upper Sandusky, OH (OPEN) (12.0 mi)',
    );
    expect(
      checkinPickerLabel(name: 'Upper Sandusky, OH', status: SiteStatus.open),
      'Upper Sandusky, OH (OPEN)',
    );
  });
}
