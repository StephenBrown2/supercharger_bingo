# Android verification

Always verify changes on both a Pixel 9 Android emulator and a Pixel 8a Android
emulator, each running Android 17, before declaring the work complete. Install
the updated app on each emulator and exercise the affected flows. Report the
results for both devices and any verification that could not be completed.

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
