# Admin role investigation handoff

## Result

On 2026-11-17 the user signed out and back into the diagnostic Android build on a physical Pixel 9. A live, filtered log capture recorded exactly one role-probe result:

```text
[life-role] {"adminLink":false}
```

No recognized role or moderation-capability fields were captured. This does not prove the account is a regular user or that the server has no role information. The probe does not label the authentication stage, so this single result also does not establish that every authenticated response was inspected. Do not enable admin notifications based on this result.

## Diagnostic code and device state

- `lib/services/life_role_diagnostics.dart` contains the allowlisted page probe and Dart log sanitizer.
- `lib/screens/login/login_webview_mobile.dart` runs it before handing the existing session probe to the login page, which can immediately close the WebView after sign-in.
- `test/life_role_diagnostics_test.dart` checks privacy filtering, doubly encoded WebView JSON, malformed results and the own-site guard.
- Diagnostic logging requires `--dart-define=LIFE_ROLE_DIAGNOSTICS=true`; it is off by default.
- The probe checks selected window fields and objects, body/html role attributes, and admin navigation hints on the exact host `supercharging.life`. It does not inspect OAuth provider pages, raw HTML, cookies, network responses or all possible JavaScript state.
- Only booleans, 0/1, recognized role words, fixed field names and the placeholder `present` may reach the role logs. Never log raw session probes, credentials, cookies, tokens, names or page contents.
- The installed APK was verified against the local diagnostic APK by SHA-256: `5913563011af48a19e2b0c721293faa872782ba19a2b0f5b3b0a06c00ffa8835`.
- All 139 tests passed; static analysis was clean; the JavaScript probe passed a mocked own-site/provider and privacy self-check.
- The temporary diagnostic source changes were left uncommitted. The earlier First-eligibility fix was already committed and pushed separately as `e9bd81a10e56ee33891ca905cf4ad4de03d7fae4`.
- Capture file: `/tmp/bingo-life-role-session.log`. The capture was deliberately stopped after reading it; exit 130 is expected, not an app failure. Temporary files may not survive.
- Last connected endpoint was `100.89.225.71:34303`; rediscover before use. The user set a 30-minute screen timeout and explicitly requested leaving that setting in place.

## Future investigation

Look for a documented, authenticated server response that explicitly identifies the current account's moderation capability, or ask the site maintainer to expose one. `canReviewCheckins` was a proposed field name, not a verified existing API field. Existing app settings store identity and authentication state, without an admin role. Public profiles and the common page script previously inspected did not provide a verified role signal.

If another diagnostic sign-in is necessary, capture safe authentication-stage booleans alongside role signals, retain the filtered capture before asking the user to sign in, and avoid duplicate app launches or UI automation during their sign-in. The user reported unexpected automatic phone actions during the first attempt and was unsure which instance was active. The only UI action recorded in that attempt was one app relaunch after installation; the later check used metadata and logs only.

A menu hint, username, user ID, or absence of a role field is not sufficient evidence of authorization. Admin alerts should require a verified positive capability response, remain off for unknown, expired or signed-out sessions, and leave record corrections to a human admin. No admin-alert feature was implemented and no records were changed.

## Check-in report files

The Signal-ready list is `reports/Admin checkin correction handoff.md`. Detailed evidence from its earlier version is preserved in `research_notes/Community checkin audit/admin-handoff-evidence.md`. Both use previously audited data; this formatting pass did not recheck live records. Keep reports and research notes out of the app-code commit unless explicitly requested.

## Release restored

After the investigation, the user requested reinstalling the standard release and closing device panels. Rebuilt with `flutter build apk --release --target-platform android-arm64` without the diagnostic define, and installed successfully in place on the Pixel. Role diagnostics are disabled in that installed release. App data was retained; no further sign-in or UI verification was performed.
