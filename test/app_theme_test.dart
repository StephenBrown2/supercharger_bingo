import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supercharger_bingo/database/database.dart';
import 'package:supercharger_bingo/theme/app_theme.dart';

void main() {
  test('palette uses Tesla red itself on cool gray surfaces', () {
    expect(teslaRed, const Color(0xFFE82127));
    expect(lifeLightScheme.primary, teslaRed);
    expect(lifeDarkScheme.primary, teslaRed);
    expect(lifeLightScheme.onPrimary, const Color(0xFFFFFFFF));
    expect(lifeLightScheme.surface, lifePage);
    expect(lifeLightScheme.onSurface, lifeInk);
    expect(lifeDarkScheme.surface, lifeDarkPage);
    expect(lifeDarkScheme.onSurface, lifeDarkInk);
  });

  test('theme mode follows the appearance choice', () {
    expect(themeModeFor(AppAppearance.light), ThemeMode.light);
    expect(themeModeFor(AppAppearance.dark), ThemeMode.dark);
    expect(themeModeFor(AppAppearance.system), ThemeMode.system);
    expect(themeModeFor(AppAppearance.materialYou), ThemeMode.system);
    expect(appearanceLabel(AppAppearance.system), 'System');
    expect(appearanceDetail(AppAppearance.system), 'Automatic Light/Dark');
    expect(appearanceDetail(AppAppearance.light), isNull);
    expect(appearanceLabel(AppAppearance.materialYou), 'Material You');
  });

  test('Material You uses the device scheme when one is provided', () {
    const device = ColorScheme.light(primary: Color(0xFF6750A4));
    final theme = buildAppTheme(
      brightness: Brightness.light,
      materialYou: true,
      dynamicScheme: device,
    );
    expect(theme.colorScheme.primary, const Color(0xFF6750A4));

    final fallback = buildAppTheme(
      brightness: Brightness.light,
      materialYou: true,
    );
    expect(fallback.colorScheme.primary, teslaRed);
  });
}
