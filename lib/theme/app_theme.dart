import 'package:drift/drift.dart' show Value;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';

import '../database/database.dart';
import '../services/database_service.dart';

/// Tesla torch red, used as the color itself. A red seed through
/// [ColorScheme.fromSeed] shifts into brown, so this scheme is written out
/// and the page stays a cool gray.
const Color teslaRed = Color(0xFFE82127);
const Color lifePage = Color(0xFFF9FAFB);
const Color lifeInk = Color(0xFF111827);
const Color lifeDarkPage = Color(0xFF111827);
const Color lifeDarkInk = Color(0xFFE5E7EB);

final ColorScheme lifeLightScheme = _lifeScheme(Brightness.light);
final ColorScheme lifeDarkScheme = _lifeScheme(Brightness.dark);

ColorScheme _lifeScheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  return ColorScheme(
    brightness: brightness,
    primary: teslaRed,
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: light ? const Color(0xFFFDE8E9) : const Color(0xFF5C1216),
    onPrimaryContainer: light
        ? const Color(0xFF5C1216)
        : const Color(0xFFFDE8E9),
    secondary: light ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
    onSecondary: light ? const Color(0xFFFFFFFF) : const Color(0xFF1F2937),
    secondaryContainer: light
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF374151),
    onSecondaryContainer: light
        ? const Color(0xFF1F2937)
        : const Color(0xFFE5E7EB),
    tertiary: light ? const Color(0xFF0CA678) : const Color(0xFF5DCAA0),
    onTertiary: light ? const Color(0xFFFFFFFF) : const Color(0xFF04362A),
    error: const Color(0xFFD63939),
    onError: const Color(0xFFFFFFFF),
    errorContainer: light ? const Color(0xFFFFE4E5) : const Color(0xFF5C1216),
    onErrorContainer: light ? const Color(0xFF5C1216) : const Color(0xFFFFE4E5),
    surface: light ? lifePage : lifeDarkPage,
    onSurface: light ? lifeInk : lifeDarkInk,
    surfaceDim: light ? const Color(0xFFE5E7EB) : const Color(0xFF0B1220),
    surfaceBright: light ? const Color(0xFFFFFFFF) : const Color(0xFF374151),
    surfaceContainerLowest: light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0B1220),
    surfaceContainerLow: light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1F2937),
    surfaceContainer: light ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937),
    surfaceContainerHigh: light
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF374151),
    surfaceContainerHighest: light
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF374151),
    onSurfaceVariant: light ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
    outline: const Color(0xFF9CA3AF),
    outlineVariant: light ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
    inverseSurface: light ? lifeDarkPage : lifePage,
    onInverseSurface: light ? lifeDarkInk : lifeInk,
    inversePrimary: teslaRed,
    surfaceTint: const Color(0x00000000),
  );
}

String appearanceLabel(AppAppearance appearance) {
  return switch (appearance) {
    AppAppearance.light => 'Light',
    AppAppearance.dark => 'Dark',
    AppAppearance.system => 'System',
    AppAppearance.materialYou => 'Material You',
  };
}

/// Extra line under a theme choice. Light and Dark need none.
String? appearanceDetail(AppAppearance appearance) {
  return switch (appearance) {
    AppAppearance.system => 'Automatic Light/Dark',
    AppAppearance.materialYou =>
      'Wallpaper colors when the device provides them',
    AppAppearance.light || AppAppearance.dark => null,
  };
}

ThemeMode themeModeFor(AppAppearance appearance) {
  return switch (appearance) {
    AppAppearance.light => ThemeMode.light,
    AppAppearance.dark => ThemeMode.dark,
    AppAppearance.system || AppAppearance.materialYou => ThemeMode.system,
  };
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required bool materialYou,
  ColorScheme? dynamicScheme,
}) {
  final scheme = materialYou && dynamicScheme != null
      ? dynamicScheme
      : (brightness == Brightness.light ? lifeLightScheme : lifeDarkScheme);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(color: scheme.surfaceContainerLow, elevation: 0),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: scheme.primary.withValues(alpha: 0.16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
      side: BorderSide(color: scheme.outlineVariant),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    // Material 3 Expressive, for the components material_ui supports so far.
    elevatedButtonTheme: const ElevatedButtonThemeData(
      variant: StyleVariant.material3Expressive,
    ),
    iconButtonTheme: const IconButtonThemeData(
      variant: StyleVariant.material3Expressive,
    ),
  );
}

/// Holds the saved appearance and tells the root app to rebuild.
class AppearanceController extends ChangeNotifier {
  AppearanceController(this.appearance);

  AppAppearance appearance;

  Future<void> update(AppAppearance value) async {
    if (value == appearance) return;
    appearance = value;
    notifyListeners();
    await DatabaseService.db.updateUserSettings(
      UserSettingsTableCompanion(appAppearance: Value(value)),
    );
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    required AppearanceController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppearanceController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppearanceScope>();
    assert(scope != null, 'AppearanceScope is missing above this context');
    return scope!.notifier!;
  }
}

/// Root widget that applies the saved appearance, including Material You.
class AppThemeBuilder extends StatelessWidget {
  const AppThemeBuilder({
    super.key,
    required this.controller,
    required this.builder,
  });

  final AppearanceController controller;
  final Widget Function(ThemeData light, ThemeData dark, ThemeMode mode)
  builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AppearanceScope(
          controller: controller,
          child: DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final materialYou =
                  controller.appearance == AppAppearance.materialYou;
              return builder(
                buildAppTheme(
                  brightness: Brightness.light,
                  materialYou: materialYou,
                  dynamicScheme: lightDynamic,
                ),
                buildAppTheme(
                  brightness: Brightness.dark,
                  materialYou: materialYou,
                  dynamicScheme: darkDynamic,
                ),
                themeModeFor(controller.appearance),
              );
            },
          ),
        );
      },
    );
  }
}
