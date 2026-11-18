What this change does: A First and its countdown now use the earliest known opening day, and they ignore check-ins from before that day. The old visit rows stay in the database. A later reopening does not erase the earlier day, and a stale First alert is cancelled when that window is no longer open.

Assumed load: one person, on a phone or a desktop, with community sync at launch and again on the alert poll. The poll can be every 15 minutes. Site sync already stays small after the first pull: it asks one region for changes newer than a saved id.

## Should fix

1. **Opening history is downloaded in full on every community sync** (`/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:257-272`, writes at `/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:818-829`)
   - **What this is:** Each community sync reads the supercharge.info change feed and stores the earliest day a site became OPEN.
   - **Problem:** The feed is the whole history, not the new rows. On 17 Nov 2026 it was 22,808,716 bytes and 24,377 rows, and 9,562 sites had an opening transition. `syncCommunityData` downloads and parses that on every launch and every poll. It then runs one update per site even when the saved day does not change. The 15 minute poll would move about 2 GB a day. Steady-state site sync already avoids this by keeping a per-region cursor (`/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:95-99`).
   - **Fix:** Save the newest change id already applied. Before downloading, ask each of the four regions for its newest change id (`fetchNewestChangeId` already does that with one row). Skip the full feed when none is newer. The first successful pass still reads the full feed once. Later passes apply only rows with a higher id.
   - **If we skip it:** Every launch and every poll spends the data and the time of a 23 MB parse, then thousands of database updates, to store dates that are already there.

2. **Three updated First tests fail east of UTC** (`/home/stephen/Projects/supercharger_bingo/test/phase2_filter_db_test.dart:46-64`, `:109-128`, and `:179-196`)
   - **What this is:** These tests insert opening dates and check-in dates, then expect `getEarliestCheckinDates` to return that calendar day.
   - **Problem:** The inserts use `DateTime(year, month, day)`, which is midnight in the device's zone. The read path takes the UTC year, month, and day (`/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:760-763`). The app's own parser stores `DateTime.utc` for those fields, and the new tests do too. These three tests still use local midnight. Under `TZ=Pacific/Auckland`, `flutter test test/phase2_filter_db_test.dart` fails three times: 1 May comes back as 30 April (`phase2_filter_db_test.dart:64`), 2 May comes back as 1 May (`:126`), and 11 Nov comes back as 10 Nov (`:195`). The reopen expect at line 140 never runs there. The same command's other tests pass. `first_opening_eligibility_test.dart`, `first_notification_cleanup_test.dart`, `region_sync_test.dart`, `life_rules_test.dart`, and `supercharge_info_parse_test.dart` passed in that same zone.
   - **Fix:** Store those opening dates and check-in dates with `DateTime.utc`, the same way `parseSiteCheckin` and the new eligibility tests do. Leave the expects as the calendar day `_checkinDay` returns.
   - **If we skip it:** `flutter test` fails in Pacific/Auckland and any other zone east of UTC. A run in UTC or the US stays green and hides it.

No user-facing First is wrong for dates this app stores. New writes use a UTC calendar day. The v18 upgrade rewrites old local-midnight `date_opened` and `checkin_date` values before the next sync, and that test passed in Pacific/Auckland. Visit clocks are left alone. I would not delete a block of lines. The 78 generated lines are the new column. The new tests cover the branches this change adds.

Accepted limits, left as written: the feed's OPEN day can differ from the true local opening (Montebello), a short cached history cannot prove a missing earlier First, a remapped site id needs a maintainer, and a legacy date saved in another device zone cannot be rebuilt. The recovery shortcut at `database.dart:801` stays inside that cached-history limit.

Verdict: fix required.

Not checked: a physical device, the map widget test, and the full 134-test suite. `git diff --check` on this scope was clean.
