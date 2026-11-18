# Web deployment implementation plan

Goal: prepare the Flutter web release for supercharger.bingo and test Tesla layouts.
Current scope: local pending browser check-ins. Real login and remote submission
are deferred by the user's subsequent instruction.

- [x] Research CSS viewports separately from panel resolutions and update AGENTS.md.
- [x] Reproduce web setup and runtime issues in release Chromium, then add regression checks.
- [x] Fix browser headers, foreground location setup, HTTPS behavior and web metadata.
- [x] Add Cloudflare static hosting configuration and deployment instructions.
- [x] Run Flutter analysis/tests, release browser checks and Pixel 9/8a Android 17 checks.
- [x] Record upstream authentication contract and remaining release blockers.

Live web authentication and remote submission remain future upstream work.
See docs/web-verification-2026-11-18.md for the initial verification coverage.

Keep native authentication behavior and existing local data intact. Do not deploy
publicly without a deployment instruction. Do not claim live web sign-in works.
The pre-existing work was checkpointed in bdb7dae before this scope change.
