What this change does: A First and its countdown use the earliest known opening day. Check-ins from before that day stay in history and do not count. Opening days are recorded while the app applies the regional change pages it already syncs. The first sync of a region, and one upgrade pass, walk that history from the start. Later polls apply only newer rows.

P1 is resolved. P2 is resolved. No new findings.

Assumed load: one person, on a phone or a desktop. Site sync runs at launch and again on the alert poll. The default poll is 24 hours. The shortest setting is 15 minutes. Each poll syncs the one region for the saved location.

Assumptions: change pages arrive newest first, which is what the existing cursor loop requires. A date-only change date keeps the calendar day on that row. I used the earlier review's measurement of the global file (22,808,716 bytes, 24,377 rows) and did not download it again. Scope still excludes repairing upstream dates and ids, and a cached check-in history that never contained the earlier visit.

Paging and the cursor: [`_syncRegion`](/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:147) saves `lastChangeId` only after [`_applyNewerChanges`](/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:181) returns. A thrown request leaves the saved cursor in place, so the next poll retries that range. `seenSites` lasts for the whole walk, and the first page is the newest, so an older page does not replace the current site row. Opening days already stored can only move earlier. [`recordFirstOpeningDates`](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:820) writes when the saved day is missing or later, so an older OPEN day on a later page still lands. The id stored at the end is the newest id the walk actually saw. A change that shows up after the first page is still applied on the next poll.

Upgrade and first install: a missing region row loads sites, then applies history from cursor 0. The v18 step adds `first_opened` and sets existing `region_syncs.last_change_id` to 0 once ([`database.dart`](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:578)). An upgraded row is already there, so the next sync replays changes from cursor 0 and does not page `/sites` again. Visit rows stay. The migration test inserts cursor 900 and expects 0, with the check-in still present. The regional test expects the April 16, 2025 OPEN to survive the May 15 reopen, a new `SyncService`, and a later poll, and expects no `/allChanges` request.

Scale: the full walk is once per region, on first install or on the first sync after this upgrade. After the cursor is the newest id, a poll reads the newest page of 200 rows until it reaches that id. At about 936 bytes a row from the earlier global file, that page is about 190 KB. [`syncCommunityData`](/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:263) fetches check-in history and counts. Startup, the phone background poll, and the desktop poll run site sync before the First check. The phone path is [`backgroundSyncCallback`](/home/stephen/Projects/supercharger_bingo/lib/services/notification_service.dart:586). The web poll runs site sync, which is where opening days are written.

P2: the three fixtures in [`phase2_filter_db_test.dart`](/home/stephen/Projects/supercharger_bingo/test/phase2_filter_db_test.dart:46) store opening dates and check-in dates with `DateTime.utc`. The expected days stay local calendar dates, which is what `_checkinDay` returns. The visit clocks in those fixtures stay local. Both full logs end at 134 passed, including under `TZ=Pacific/Auckland`.

Looks good. Ship.

Verdict: Ship.

Checked: regional sync, community sync, the v18 cursor reset, and the callers in `main.dart`, `notification_service.dart`, and `desktop_background_service.dart`, plus `region_sync_test.dart`, the v18 migration test, and the three phase 2 fixtures. Log tails: `/tmp/bingo-final-full-test.log` and `/tmp/bingo-auckland-full-test.log`.

Not checked: a physical device, the live `/changes` feed, and a fresh test run.
