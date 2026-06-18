import 'package:flutter/material.dart';

import '../database/database.dart';

/// Marker styling for the map (SPEC Section 5).
///
/// Color is always paired with a distinct shape/glyph so state survives full
/// colour blindness (WCAG 1.4.1). All colours are from the Okabe-Ito
/// colourblind-safe palette.

/// Okabe-Ito colourblind-safe palette.
class OkabeIto {
  static const Color black = Color(0xFF000000);
  static const Color orange = Color(0xFFE69F00);
  static const Color skyBlue = Color(0xFF56B4E9);
  static const Color green = Color(0xFF009E73);
  static const Color yellow = Color(0xFFF0E442);
  static const Color blue = Color(0xFF0072B2);
  static const Color vermillion = Color(0xFFD55E00);
  static const Color reddishPurple = Color(0xFFCC79A7);
  static const Color grey = Color(0xFF999999);
}

/// Three-state First colouring for operational sites. The boundary moves with
/// the passage of time, so it is recomputed at render time from stored dates.
enum FirstState {
  /// No First recorded yet. Up for grabs.
  upForGrabs,

  /// A First exists and its date equals today in the site's local timezone.
  /// Still inside the shared-First window.
  today,

  /// A First exists and its date has passed (site-local).
  passed,
}

/// Resolved marker appearance: a colour plus a redundant glyph and a label.
class MarkerStyle {
  final Color color;
  final IconData glyph;
  final String label;

  const MarkerStyle(this.color, this.glyph, this.label);
}

/// Readable glyph colour on a filled [background]: black on light fills (e.g.
/// the yellow First-today pin), white on dark ones.
Color glyphForeground(Color background) =>
    background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

/// Whether a status is operational (chargeable, First applies): OPEN/EXPANDING.
bool isOperational(SiteStatus status) =>
    status == SiteStatus.open || status == SiteStatus.expanding;

/// Compute the First state for an operational site from its earliest qualifying
/// check-in date ([firstDate], null if none) and the current site-local time
/// ([siteLocalNow]). Pure: compares calendar dates only.
FirstState computeFirstState({
  required DateTime? firstDate,
  required DateTime siteLocalNow,
}) {
  if (firstDate == null) return FirstState.upForGrabs;
  final first = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final today = DateTime(
    siteLocalNow.year,
    siteLocalNow.month,
    siteLocalNow.day,
  );
  if (first.isBefore(today)) return FirstState.passed;
  // Same day, or a (defensive) future date still inside today's window.
  return FirstState.today;
}

/// Resolve the marker style for a site. Operational sites use [firstState];
/// non-operational sites use status-based styling. Visited sites carry a check
/// overlay regardless of colour.
MarkerStyle markerStyleFor({
  required SiteStatus status,
  required FirstState firstState,
  required bool visited,
}) {
  final base = _baseStyle(status, firstState);
  if (visited) {
    // Keep the underlying colour, swap in a check glyph as the overlay.
    return MarkerStyle(base.color, Icons.check_circle, 'Visited: ${base.label}');
  }
  return base;
}

MarkerStyle _baseStyle(SiteStatus status, FirstState firstState) {
  if (isOperational(status)) {
    switch (firstState) {
      case FirstState.upForGrabs:
        return const MarkerStyle(
          OkabeIto.green,
          Icons.circle_outlined,
          'First up for grabs',
        );
      case FirstState.today:
        return const MarkerStyle(
          OkabeIto.yellow,
          Icons.schedule,
          'First today',
        );
      case FirstState.passed:
        return const MarkerStyle(
          OkabeIto.vermillion,
          Icons.task_alt,
          'First taken',
        );
    }
  }
  switch (status) {
    case SiteStatus.construction:
      return const MarkerStyle(
        OkabeIto.blue,
        Icons.construction,
        'Construction',
      );
    case SiteStatus.permit:
      return const MarkerStyle(
        OkabeIto.reddishPurple,
        Icons.description,
        'Permit',
      );
    case SiteStatus.plan:
      return const MarkerStyle(
        OkabeIto.reddishPurple,
        Icons.schedule,
        'Plan',
      );
    case SiteStatus.voting:
      return const MarkerStyle(
        OkabeIto.reddishPurple,
        Icons.how_to_vote,
        'Voting',
      );
    case SiteStatus.closedTemp:
      return const MarkerStyle(
        OkabeIto.grey,
        Icons.pause_circle_outline,
        'Closed (temporary)',
      );
    case SiteStatus.closedPerm:
      return const MarkerStyle(OkabeIto.grey, Icons.block, 'Closed');
    case SiteStatus.open:
    case SiteStatus.expanding:
      // Handled by the operational branch above; unreachable.
      return const MarkerStyle(OkabeIto.green, Icons.circle_outlined, 'Open');
  }
}
