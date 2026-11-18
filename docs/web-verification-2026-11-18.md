# Web verification, 2026-11-18

Status: frontend hosting prepared; public release blocked on the
[supercharging.life integration](supercharging-life-web-integration.md).

## Passed

- `flutter analyze`: no issues.
- `flutter test`: 142 tests passed. Existing widget tests log map tile HTTP 400
  responses under the test runner; these did not fail the suite.
- `flutter build web --release`: built successfully, including SQLite Wasm and
  the Drift worker.
- `BINGO_BASE_URL=http://localhost:8793 npm run test:web`: 11 checks passed using
  the actual release build served by Wrangler 4.164.0.
- All nine AGENTS.md sizes passed first launch, local continuation, setup,
  touch navigation to Visits and Settings, and reload without repeating setup.
  Contexts used dark preference, touch input and the documented DPR. An extra
  fresh-context check verified the foreground location action and explanation.
- Browser checks observed no uncaught page errors, reserved User-Agent header
  errors or logged overflow errors in these local flows.
- Cloudflare dry run packaged the static assets successfully without publishing.
  The local runtime parsed all five header rules. Verified the Wasm MIME type,
  no-cache entry script response and HTML SPA fallback for `/auth/callback`.
- Pixel 9 (`android17`, emulator-5556), Android 17.0: installed debug build 4002,
  opened the app, loaded 3,657 sites, opened Settings and its units dialog,
  opened Visits, and opened the nearby check-in drawer with two sites.
- Pixel 8a (`pixel_8a_android17`, emulator-5558), Android 17.0: same checks passed.
  Both devices were inspected using device screenshots. Existing app data was
  preserved. Build 4002 was used because installed build 4001 rejected version 1.

## Not verified or blocked

- Live web login, credential expiry/logout and confirmed remote create/delete:
  blocked on an upstream supported login/API integration. The current browser
  provider buttons still select a local preference rather than authenticating.
- Chromium reproduced CORS failures for community history and check-in counts.
  The local smoke suite does not claim these remote flows pass. The paginated
  supercharge.info sites endpoint does return CORS-enabled data.
- Real Intel/AMD Tesla hardware, actual S/X/Cybertruck/QHD CSS viewport calibration,
  keyboard resizing, full offline behavior and a production HTTPS origin were
  unavailable. Emulated dimensions do not establish in-car compatibility.
- Automated checks do not submit real check-ins or delete remote records. Native
  login and first-run setup were not repeated on the existing emulator profiles.
- Android builds warn that workmanager_android still applies the Kotlin Gradle
  Plugin; a future Flutter version will require its migration. This build passed.

No public deployment or DNS changes were made.
