# First eligibility rules

## What does the app already do?

### Takeaway
The app already filters community First dates against a known opening date, but its check-in-count fallback can put the discarded First straight back into effect. A date filter alone does not fully solve the problem.

### Cited Findings
- `getEarliestCheckinDates` accepts only server-marked First rows, rejects rows before a known `dateOpened`, and allows rows when the opening date is unknown. [Source](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:677)
- When no qualifying row remains and `hasCheckins` is true, the same method substitutes the opening date, or year 2000 if unknown. Thus a premature check-in can still make a newly opened site appear claimed on its opening day. [Source](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:706)
- History sync marks every site in the feed as having check-ins without checking its date; the separate count feed also sets the flag. [Source](/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:224)
- First notifications use this derived date, and run only for currently OPEN sites. [Source](/home/stephen/Projects/supercharger_bingo/lib/services/notification_service.dart:393)
- The names query independently selects the earliest server-marked First without checking the opening date. [Source](/home/stephen/Projects/supercharger_bingo/lib/database/database.dart:930)
- Local submission already rejects pre-opening dates. The rule compares site-local calendar dates for timestamps and preserves the calendar date for date-only entries. A missing opening date does not reject the entry. [Source](/home/stephen/Projects/supercharger_bingo/lib/services/checkin_rules.dart:11); [Source](/home/stephen/Projects/supercharger_bingo/lib/services/sync_service.dart:519)
- Existing test coverage verifies pre-opening filtering and allows opening-day entries, but that test does not set `hasCheckins=true`, so it does not exercise the fallback interaction. [Source](/home/stephen/Projects/supercharger_bingo/test/phase2_filter_db_test.dart:107)

### Inferences
- The smallest reliable policy is to preserve the user's history but exclude visits before the site's first actual opening day from First eligibility. Apply it to all users and entry methods.
- An opening-day visit should qualify. Use the site's calendar day, rather than the time a database editor marked the site OPEN. A legitimate early opening can precede that update.
- A never-opened site in planning, permit, construction or voting status should not award a First. A site closed now may have valid visits from when it was open, so current CLOSED status alone cannot invalidate its history.
- The count fallback cannot prove that any post-opening visit exists. For a complete fix, counts must reflect qualifying visits or the app needs sufficiently complete dated history. Merely changing the date predicate leaves false awards possible.
- If a valid later entry lacks the server's cached First flag because a bad earlier entry won, the client cannot reliably promote the correct person using only server-marked First rows. The upstream award should be recomputed, or full per-site history is needed.
- Unknown opening dates should be flagged as unverified rather than treated as proven invalid. The actual opening day and the date a site was marked OPEN are different evidence.

### Gaps
- No app code was changed and no tests were run, since this task requests investigation.
- The current code inspection does not establish whether Barstow's opening date is accurate or whether its upstream First flag has been corrected.
