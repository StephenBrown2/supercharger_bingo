import 'package:material_ui/material_ui.dart';

import '../database/database.dart';
import '../services/first_state.dart';

/// Marker styling for the map (SPEC Section 5).
///
/// Each supercharging.life map color is swapped for its nearest Okabe-Ito
/// color, which stays distinct under color blindness. Every state also keeps
/// its own glyph (WCAG 1.4.1). First today uses sky blue to distinguish it
/// from construction yellow.
class LifePin {
  static const Color green = Color(0xFF009E73);
  static const Color red = Color(0xFFD55E00);
  static const Color skyBlue = Color(0xFF56B4E9);
  static const Color yellow = Color(0xFFF0E442);
  static const Color blue = Color(0xFF0072B2);
  static const Color orange = Color(0xFFE69F00);
  static const Color violet = Color(0xFFCC79A7);
  static const Color black = Color(0xFF000000);

  /// Okabe-Ito has no grey. This is the grey usually paired with it.
  static const Color grey = Color(0xFF999999);
}

/// Resolved marker appearance: a colour plus a redundant glyph and a label.
class MarkerStyle {
  final Color color;

  /// Null draws a plain marker.
  final IconData? glyph;
  final String label;

  const MarkerStyle(this.color, this.glyph, this.label);
}

/// Readable glyph colour on a filled [background]: black on light fills (e.g.
/// the construction pin), white on dark ones.
Color glyphForeground(Color background) => background == LifePin.grey
    ? Colors.white
    : background.computeLuminance() > 0.179
    ? Colors.black
    : Colors.white;

/// Wire spelling used on supercharging.life, for the check-in picker row.
String siteStatusWireName(SiteStatus status) {
  switch (status) {
    case SiteStatus.open:
      return 'OPEN';
    case SiteStatus.construction:
      return 'CONSTRUCTION';
    case SiteStatus.permit:
      return 'PERMIT';
    case SiteStatus.plan:
      return 'PLAN';
    case SiteStatus.voting:
      return 'VOTING';
    case SiteStatus.closedTemp:
      return 'CLOSED_TEMP';
    case SiteStatus.closedPerm:
      return 'CLOSED_PERM';
  }
}

/// `name (status) (distance)`. Distance is omitted when location is unknown.
String checkinPickerLabel({
  required String name,
  required SiteStatus status,
  String? distance,
}) {
  final statusName = siteStatusWireName(status);
  if (distance == null || distance.isEmpty) return '$name ($statusName)';
  return '$name ($statusName) ($distance)';
}

/// Resolve the marker style for a site. Operational sites use [firstState];
/// non-operational sites use status-based styling. Visited sites are a grey
/// check, as on supercharging.life.
MarkerStyle markerStyleFor({
  required SiteStatus status,
  required FirstState firstState,
  required bool visited,
}) {
  final base = _baseStyle(status, firstState);
  if (visited) {
    return MarkerStyle(
      LifePin.grey,
      Icons.check_circle,
      'Visited: ${base.label}',
    );
  }
  return base;
}

MarkerStyle _baseStyle(SiteStatus status, FirstState firstState) {
  if (isOperational(status)) {
    switch (firstState) {
      case FirstState.upForGrabs:
        return const MarkerStyle(
          LifePin.green,
          Icons.circle_outlined,
          'First up for grabs',
        );
      case FirstState.today:
        return const MarkerStyle(
          LifePin.skyBlue,
          Icons.schedule,
          'First today',
        );
      case FirstState.passed:
        // The common case, so it stays plain.
        return const MarkerStyle(LifePin.red, null, 'Open');
    }
  }
  switch (status) {
    case SiteStatus.construction:
      return const MarkerStyle(
        LifePin.yellow,
        Icons.construction,
        'Construction',
      );
    case SiteStatus.permit:
      return const MarkerStyle(LifePin.blue, Icons.description, 'Permit');
    case SiteStatus.plan:
      return const MarkerStyle(LifePin.orange, Icons.event_note, 'Plan');
    case SiteStatus.voting:
      return const MarkerStyle(LifePin.orange, Icons.how_to_vote, 'Voting');
    case SiteStatus.closedTemp:
      return const MarkerStyle(
        LifePin.violet,
        Icons.pause_circle_outline,
        'Closed (temporary)',
      );
    case SiteStatus.closedPerm:
      return const MarkerStyle(LifePin.black, Icons.block, 'Closed');
    case SiteStatus.open:
      // Handled by the operational branch above; unreachable.
      return const MarkerStyle(LifePin.green, Icons.circle_outlined, 'Open');
  }
}

/// The round map pin: [style]'s color, a white rim, and its glyph. The map and
/// the legend both draw it, so they always match.
class PinDot extends StatelessWidget {
  final MarkerStyle style;
  final double size;

  const PinDot(this.style, {super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size / 14),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
      ),
      child: Icon(
        style.glyph,
        color: glyphForeground(style.color),
        size: size * 4 / 7,
        semanticLabel: style.label,
      ),
    );
  }
}
