# Map filter terminology and charger types

Match the supplied upstream screenshots so users see familiar filter names, and add the fork's independent charger type selector.

## Scope and behavior

- Show status chips in this order: Tesla EV (Open), Non-Tesla EV (Open), Open + Construction, Visited, All.
- Keep Tesla EV (Open) as the default. Preserve the existing matching rules: the three unvisited choices remain unvisited, OPEN stays OPEN only, and Open + Construction adds CONSTRUCTION.
- Add a single type selector with All types (default), V2, V3, V4, Urban, and Unknown. Apply it together with any status chip.
- Match a named type when that site's corresponding stall count is positive. Mixed sites can match more than one type. Treat a positive upstream `stalls.other` count as Unknown. Also treat missing type data or no positive named type counts as Unknown, as approved.
- Keep the existing map controls and use the app's Material selection widgets. No new dependencies or settings persistence.

## Approach

Retain upstream stall type counts in the local site cache, including the distinction between `other` and unspecified data, and filter the loaded map sites by the selected type. Keeping the existing status queries avoids changing their behavior. A separate network request per selection would make an otherwise cached map depend on connectivity.

Add a database migration and regenerate Drift code. Invalidate region sync cursors so the next sync repopulates type data for existing sites, following the existing `otherEvs` migration. Preserve visits, pending check-ins, and community history. Cached sites without type data remain Unknown until refreshed.

## Files and validation

Update the map screen, database schema and generated code, API-to-database mapping, and current filter documentation. Add focused checks for combined filtering, mixed types, combined unknown and unspecified data, parsing, and migration/backfill behavior. Run the relevant Flutter tests and analyzer.

## Limits

The screenshots do not specify the fork's classification logic. The combined Unknown definition follows the existing upstream `Stalls` model. No live fork comparison was performed. Verify the affected UI on Pixel 9 and Pixel 8a emulators, each running Android 17.
