# Web deployment implementation plan

Goal: prepare the Flutter web release for supercharger.bingo and test Tesla layouts.
Live supercharging.life login and confirmed remote submission are release gates.

- [x] Research CSS viewports separately from panel resolutions and update AGENTS.md.
- [x] Reproduce web setup and runtime issues in release Chromium, then add regression checks.
- [x] Fix browser headers, foreground location setup, HTTPS behavior and web metadata.
- [x] Add Cloudflare static hosting configuration and deployment instructions.
- [x] Run Flutter analysis/tests, release browser checks and Pixel 9/8a Android 17 checks.
- [x] Record upstream authentication contract and remaining release blockers.

Live web authentication and confirmed remote submission remain blocked on the
upstream integration. See docs/web-verification-2026-11-18.md for exact coverage.

Keep native authentication behavior and existing local data intact. Do not deploy
publicly or claim live web sign-in works until the upstream integration is agreed
and verified. Preserve pre-existing working-tree changes.
