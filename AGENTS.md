# Android verification

Always verify changes on both a Pixel 9 Android emulator and a Pixel 8a Android
emulator, each running the latest publicly released Android version, before
declaring the work complete. Install the updated app on each emulator and
exercise the affected flows. Report the results for both devices and any
verification that could not be completed.

# Tesla browser verification

For web changes, test the release build at every size below (width x height).
These are a regression matrix, not an official Tesla viewport standard.
Browser chrome, split view, firmware, keyboard and zoom change the usable area.

| CSS viewport | DPR | Coverage and evidence |
| --- | --- | --- |
| 773 x 601 | 1.53 | Model 3 Highland split browser, owner-measured 2026.26+ profile |
| 1254 x 601 | 1.53 | Expanded browser, derived by the same emulator author |
| 1183 x 920 | 1 | Pre-2026.26 split browser, emulator-derived |
| 1920 x 920 | 1 | Pre-2026.26 expanded browser, emulator-derived |
| 1200 x 1920 | 1 | Legacy S/X portrait panel, synthetic upper-bound layout test |
| 1200 x 800 | 1 | Legacy S/X reduced-height stress test, synthetic |
| 1920 x 1200 | 1 | Standard 3/Y landscape panel, synthetic upper-bound test |
| 2200 x 1300 | 1 | Refreshed S/X panel, synthetic upper-bound test |
| 2560 x 1440 | 1 | Cybertruck and QHD 3/Y panels, synthetic upper-bound test |

Viewport sources: [measured and derived emulator profiles](https://github.com/mildchef/tesla-emulator/blob/main/src/shared/profiles.ts).
Panel source: [TeslaTap hardware research](https://teslatap.com/undocumented/).
Researched 2026-11-18. Physical panel sizes are not browser viewport measurements;
actual S/X, Cybertruck and QHD browser CSS viewports still need in-car calibration.
Record window.innerWidth, window.innerHeight, devicePixelRatio, screen dimensions,
model, MCU and firmware when a car is available, then add that measured profile.

Exercise first launch, login, setup, map/filter/search, check-in, visits, settings,
reload and saved-data persistence. Require no overflow, clipped controls or
uncaught errors. Repeat with touch, light/dark themes, denied location, reduced
height for the keyboard, and unavailable network. Verify on actual Intel and AMD
Tesla browsers before claiming in-car compatibility; desktop emulation only
verifies layout. Report unavailable devices and flows explicitly.

The current web release is local only. Real login and remote check-in submission
are deferred. Verify that visits stay pending, survive reload and can be deleted
locally. Explain that clearing browser data removes them. Do not present local
continuation as GitHub or Google authentication.

# Flutter and Dart upgrades

You are authorized to upgrade the Flutter SDK, the Dart SDK, Kotlin, and this
project's pub dependencies without asking first. This covers:

- Running `flutter upgrade` and `flutter channel` on the SDK at `/opt/flutter`.
- Stashing local changes in `/opt/flutter` (such as its regenerated
  `pubspec.lock`) so the upgrade can run: `git -C /opt/flutter stash`. Stash,
  don't discard, and don't use `flutter upgrade --force`.
- Running `flutter pub upgrade`, `flutter pub upgrade --major-versions`, and
  `flutter pub add` in this project.
- Upgrading Kotlin: the `org.jetbrains.kotlin.android` version in
  `android/settings.gradle.kts`, plus the Kotlin settings in
  `android/app/build.gradle.kts` that the upgrade requires.
- Editing `pubspec.yaml`, `pubspec.lock`, generated plugin registrant files, and
  `analysis_options.yaml`, plus code changes those upgrades require (including
  `dart fix --apply` migrations).

This doesn't cover other system packages, other projects, or pushing to a
remote.
