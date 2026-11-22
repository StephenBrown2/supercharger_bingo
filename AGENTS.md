# Android release APKs

Build Android release APKs with `flutter build apk --release --split-per-abi`.
Install the APK from `build/app/outputs/flutter-apk/` that matches the target
device's ABI. For a physical Pixel 9, use `app-arm64-v8a-release.apk`.

# Android verification

Verify native Android app changes on both a Pixel 9 and a Pixel 8a Android
emulator, each running the latest publicly released Android version, before
declaring the work complete. Install the updated app on each emulator and
exercise the affected flows. Report the results for both devices and any
verification that could not be completed.

If an emulator is held by another session (`DEVICE_IN_USE`), don't skip the
check and don't take over or close that session. Find the holder with
`ListAgents` and ask it with `SendMessage` to release the emulator, passing
`notify_when_idle: true`. Then resume when it replies. When you finish, close
your device sessions and tell it the emulators are free and which build you
left installed.

# Android browser verification

For web changes, test the release build in the actual Chrome and Firefox apps
on one Android emulator, either Pixel 9 or Pixel 8a. Use the latest publicly
released Android version and stable browser releases, and record their versions.
Desktop Playwright, including mobile viewport or user-agent emulation, does not
satisfy these checks.

Exercise the web flows listed below in both browsers. Normal mode is sufficient
when the test site's data is cleared for fresh-session checks; private mode is
optional. Include these regression cases:

- Start with fresh browser storage and import a TMC username. Setup must remain
  usable during a slow import, with progress visible until it finishes.
- Delay site and history responses. Markers must appear as site pages arrive,
  without a reload, and reflect imported visits when the import finishes.
- Grant, deny, and revoke/regrant location; leave and return to the page; then
  open Settings, load the map, and refresh. Distinguish Android's browser-app
  permission from the site's permission. Passive loads must not repeat prompts
  after a grant or automatically request a missing grant. An explicit Allow
  location or recenter action may request access again.
- Check notification permission labels after granting access and returning
  from browser settings. Check reload persistence and unavailable network.

Report results for both browsers, the emulator and versions used, the tab mode,
and any unavailable checks. Clear site data only in a test profile so existing
user visits are preserved. If optional private mode blocks screenshots, record
observed steps and results; screenshots are not a prerequisite for testing.

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
continuation or the username import demo as GitHub or Google authentication.
Username import and the community data behind First pins and alerts read
supercharging.life through the Worker's `/life/*` proxy (`worker.js`); exercise
them with `npx wrangler dev`, since `flutter run` has no proxy. Browser alerts
show only while the page is open. To test them in Playwright, launch with
`channel: 'chromium'`: the default headless shell reports
`Notification.permission` as denied even when granted.

# Web deployment

The web release runs on Cloudflare as the static-assets Worker `app`, at
`https://supercharger.bingo` (also `www.` and
`https://app.supercharger-bingo.workers.dev`). Porkbun is the registrar; DNS
is on Cloudflare. Full steps are in `docs/web-deployment.md`.

- Build with `flutter build web --release --no-web-resources-cdn`, then
  `npx --yes wrangler@4.166.0 deploy --dry-run --outdir <scratch dir>` to check
  the upload.
- Deploy with `CLOUDFLARE_API_TOKEN` set from a token the user provides (the
  "Edit Cloudflare Workers" template). Never commit or log the token. Deploying
  publishes to users, so deploy only when asked.
- Smoke-test locally with `npx wrangler dev` and `npm run test:web`, or the
  live site with `BINGO_BASE_URL=https://supercharger.bingo npm run test:web`.
  These cover the viewport matrix in desktop Chromium and startup regressions
  in desktop Chromium and Firefox. Run the Android browser checks separately.
- A new workers.dev hostname fails TLS for about two minutes while its
  certificate is issued. Wait for HTTP 200 before testing.
- Renaming the Worker in `wrangler.jsonc` deploys a second Worker; the old one
  stays live until deleted. The account workers.dev subdomain cannot be renamed
  through the API, only released and claimed again.

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
