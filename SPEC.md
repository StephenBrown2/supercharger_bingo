# Tesla Supercharger Check-in App: Technical Spec (v0.5)

## 1. Overview

A mobile-first (not mobile-only) Flutter app for tracking "First" check-ins at newly opened Tesla Superchargers. Site data comes from the supercharge.info API. Check-ins are logged locally first and synced when connectivity allows. For the POC, check-ins write to supercharging.life through its unofficial endpoint behind an abstracted interface; the official supercharging.life API becomes the default writer once it exists. Desktop and PWA builds are in scope.

This is v0.5. Section 2.2 and Section 13 were revised to keep the prototype's unofficial-endpoint write path and webview auth in place for the POC, abstracted behind interfaces rather than replaced outright.

## 2. Data Sources

### 2.1 supercharge.info API

Schema and behavior are taken from the supercharge-info/supercharge.info-api repository.
See https://github.com/supercharge-info/supercharge.info-api/tree/e61485e11d8a3f4204ef77720e63aee9d308ada2/service-war/src/main/java/com/redshiftsoft/tesla/web/mvc
Two endpoints matter:

- **allSites:** full site list. Each record carries id, optional locationId, name, status, address (street/city/state/zip plus countryId/country and regionId/region), gps (lat/lon), dateOpened (nullable, date only), stallCount, a per-generation stalls breakdown (v2/v3/v4/urban/accessible/trailerFriendly/other), a plugs map, powerKilowatt, elevationMeters, statusDays, and flags (counted, solarCanopy, battery, otherEVs, urlDiscuss). Extra metadata (facilityName, plugshareId, osmId, hours, accessNotes) is available and worth persisting even if unused in v1.
- **allChanges:** delta feed of ADD/UPDATE events with siteId, date, changeType, siteStatus, prevStatus, stall/power deltas, a notify flag, and an embedded full site object. Used for incremental sync and for driving "new Supercharger" notifications.

**Region filtering:** requests must be scoped by region (and ideally country/state) based on the user's location to keep response sizes down. The allSites payload is large; pulling the whole planet on every sync is wasteful.

**Status enum (authoritative, 8 values):** `OPEN`, `EXPANDING`, `CONSTRUCTION`, `PERMIT`, `PLAN`, `VOTING`, `CLOSED_TEMP`, `CLOSED_PERM`. This replaces the four-value guess in v0.1. See Section 5 for how each status maps to behavior.

**Enum consolidation:** the auto-generated Dart has duplicated `EnumValues`, `Country`, `Region`, `Status`, `Address`, `Gps`, and `Stalls` definitions across the allSites and allChanges files. Consolidate into one shared models library before building on it.

**Timezone:** derived per site from coordinates using the bundled tz dataset, stored as an IANA string. Needed for the site-local "First" day boundary (Section 4).

### 2.2 supercharging.life

No official API exists yet. The target end state is to submit check-ins, and eventually pull community First data, through that official API. Scraping unofficial PHP datatable endpoints, as the prototype does, is not part of that target design.

For the POC, full local-only is too strict: the only way to get real check-ins onto supercharging.life today is through the unofficial `checkin.php` endpoint, which the prototype already does. That's kept as the POC's write path, with two things acknowledged up front: it's fragile (it can break without notice if supercharging.life changes markup or adds anti-scraping defenses), and it only works at all if the webview cookie-capture session (Section 8) stays valid long enough to post. Because of that fragility, all check-in writes go through a single backend-writer interface (Section 13, Phase 5) so the POC's unofficial-endpoint implementation and the eventual official-API implementation are interchangeable without touching the rest of the app. Community and personal history continue to come from the manual, user-triggered XLSX export import in the interim (Section 9); that stays in place regardless of which writer is active, since the unofficial endpoints don't reliably surface the same data the export does.

When the official API ships, it becomes the default writer and the source of real-time community First data, retiring the unofficial endpoint and the XLSX import.

## 3. Domain Model

Store only the minimum needed for app operation, not the full API record. The supercharge.info models in Section 2.1 are for parsing the response; most of those fields are dropped on ingestion. If a feature later needs richer metadata (stall breakdown, elevation, plugs, facility info), query the API to backfill that site on demand rather than storing it speculatively now.

| Field | Type | Notes |
|---|---|---|
| id | int | Stable supercharge.info id |
| name | string | |
| region, country | string | Kept for region-scoped sync and filtering |
| lat, lon | float | Needed for map, distance, timezone derivation |
| timezone | string | IANA, derived at ingestion |
| status | enum | 8-value supercharge.info status |
| date_opened | date, nullable | Date only, no time |
| has_first | bool | Any community First recorded |
| first_date | date, nullable | Site-local date of the earliest qualifying check-in, drives pin color |
| visited | bool | Current user has a check-in here |
| last_synced | timestamp | |

Everything else (address detail, stall counts, power, plugs, elevation, flags) is intentionally omitted and backfilled from the API only if and when a feature requires it.

### Checkin (local + synced personal history)

| Field | Type | Notes |
|---|---|---|
| id | UUID | Client-generated, idempotent sync |
| site_id | int | |
| vehicle_id | UUID, nullable | Local association only, never sent to supercharging.life (its form has no vehicle field) |
| checkin_date | date | Always present |
| checkin_time | time, nullable | Present for timestamped check-ins, absent for date-only history |
| precision | enum | DATE_ONLY or TIMESTAMP |
| method | enum | GPS or MANUAL |
| public_comment | text, nullable | |
| private_comment | text, nullable | Restored; the live form has both public and private notes |
| sync_status | enum | PENDING, SYNCED, FAILED |
| created_at_device | timestamp | |

### Community check-in (others, for First tracking)

Mirrors what the XLSX import and (future) API provide: site_id, user id, username/display name, checkin_date, checkin_time (when available), is_first flag, days_after_open. The `distinct_user_super_seq` and `days_after_open` fields are not core to local First detection but are retained because the XLSX carries them and they are useful for display.

### Vehicle

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| label | string | Required nickname |
| vin | string, nullable | Encrypted at rest, never displayed (Section 8) |
| make, model, year, trim | string, nullable | Derived from VIN if available, displayed only if the user opts in |

Vehicles are a purely local concept and do not participate in supercharging.life sync. "Display opt-in" is the control that, when enabled, appends the derived vehicle info (make/model/year/trim, never the raw VIN) to the check-in's private note. That is the only place vehicle data surfaces, and the private note is local/admin-visible only, never public.

## 4. "First" Determination

Shared Firsts are allowed and are a deliberate social feature. Once one person claims the First at a site, others who check in before the next site-local midnight share it, and coordinating that scramble is part of the appeal. This removes the v0.1 problem entirely: no tie-break logic is needed, and the DATE_ONLY ordering ambiguity no longer matters, because same-day check-ins are not ranked against each other.

A check-in qualifies as a First if its checkin_date (and checkin_time when available), evaluated in the site's local timezone, falls on or after the site's date_opened. A check-in dated before date_opened is invalid (you cannot have charged at a site before it opened) and is rejected, not counted. Any check-in on or after date_opened is valid.

First eligibility is open-ended until claimed. A site with no check-ins has its First available indefinitely to whoever checks in first, regardless of how long ago it opened. The first valid check-in starts the clock: the shared-First window then runs until the next midnight in the site's local timezone. Anyone whose qualifying check-in lands on that same site-local calendar day shares the First. After that local midnight, the First is closed and no further shares are possible. So first_date is the site-local date of the earliest check-in (not date_opened), and that date is what the pin color in Section 5 keys off of.

First status is community-wide, not per-user. Until the official API exists, it's derived from imported community history (XLSX) and whatever the active write-path implementation surfaces (Section 2.2, Section 9), with the freshness caveat noted there. Under the future API it becomes authoritative and real-time.

## 5. Site Status, Filtering, and Pin Color

### Status to behavior

The 8 statuses map to behavior as follows:

- **Operational (chargeable, eligible for check-in and First):** OPEN, EXPANDING. EXPANDING behaves identically to OPEN.
- **Construction:** CONSTRUCTION. Visible, not chargeable. Shown in the Unvisited + Construction filter.
- **Permit:** PERMIT. Visible only under All (or when explicitly selected). Not included in Unvisited + Construction by default, since it is uncertain whether the site will materialize.
- **Not displayed unless explicitly selected:** PLAN, VOTING. There is no site to check in to yet, so these are irrelevant to normal views and hidden by default.
- **Closed:** CLOSED_TEMP and CLOSED_PERM. Shown only under All. CLOSED_TEMP gets its own distinct icon (it may reopen), separate from CLOSED_PERM.

### Filters

Four top-level filters. The original "Show Visited" option is restored, since the prototype dropped it:

- **Unvisited (default):** operational sites (OPEN, EXPANDING) with no check-in by the current user. This is the launch view.
- **Unvisited + Construction:** operational plus CONSTRUCTION sites with no check-in. Does not include PERMIT, PLAN, or VOTING by default.
- **Visited:** any site the current user has checked into, regardless of status.
- **All:** every site regardless of status, including PERMIT, PLAN, VOTING, and both closed states.

### Pin color and shape

The prototype's status-based colors are kept in spirit but remapped to the Okabe-Ito colorblind-safe palette, and the First-state coloring from the original brief is layered on top. Color is always paired with a distinct shape/glyph so the state survives full color blindness (WCAG 1.4.1).

First-state coloring (applies to operational sites):

- **Green (`#009E73`), open-circle glyph:** no First recorded yet. Up for grabs.
- **Yellow (`#F0E442`), clock glyph:** a First exists and first_date equals today in the site's local timezone. Still inside the shared-First window.
- **Red (`#D55E00`), filled-check glyph:** a First exists and its date has passed (site-local).

Status coloring (for non-operational sites, where First does not apply): use distinct Okabe-Ito hues paired with their own glyphs, for example blue (`#0072B2`) for construction, purple/violet for permit/plan/voting, and grey for closed. Visited sites carry a check overlay regardless of color.

Because the green/yellow/red boundary moves purely with the passage of time, it is recomputed at render time from stored dates, not pushed as an event.

## 6. Check-in Flow

Modeled on the live supercharging.life check-in form, with two deliberate changes: add a most-recent-check-in indicator, and omit the "Save and then go to..." navigation dropdown for now.

1. Request location. On denial, fall back to a manual, alphabetical full-site search (mirrors the site's `?gps=n` mode).
2. Show the 10 closest sites, closest preselected, each formatted as `name (status) (distance)`. Distance uses the user's unit preference (Section 7).
3. For each listed site, show the user's most recent check-in there if one exists, otherwise "No previous check-in." This is the addition beyond the current web form.
4. Date defaults to the current timestamp. Optional public note and private note. Optional vehicle selection (defaults to last used).
5. Write locally with a full timestamp and the device timezone, queue for sync, never block on network.

Fields carried over from the live form: Supercharger picker, link to search all locations, Date (current timestamp), Notes (Private), Notes (Public). Deferred: the post-save navigation dropdown.

## 7. Settings

- **Distance units:** metric or imperial. Default imperial.
- **Check-in search radius:** how far out the nearest-site list reaches. Separate from notification radius.
- **Notification radius:** distance within which new-site and First-eligible alerts fire.
- **Polling interval:** background sync cadence.
- **Notifications:** toggles for the two channels in Section 10.
- **Data management (POC-era, expected to shrink once the API lands):** import visit history (XLSX), force-sync sites, sync check-in counts, re-sync user data, clear local data, reset database.

## 8. Authentication and VIN Handling

### Auth

Target state is shared authentication with supercharging.life, which uses GitHub and Google social login. The app should adopt the same providers so a single identity spans both. Until the official API and its auth flow exist, the prototype's webview session-cookie capture stays in place as the POC mechanism rather than being replaced outright (it's what makes the Section 2.2 unofficial write path work at all), hardened for reliability, and built behind an auth interface so swapping in shared OAuth later is mechanical rather than a rewrite (Section 13, Phase 6).

### VIN

VINs are encrypted at rest and never displayed. Entry is manual and optional. If a VIN is entered, the app offers a one-time online decode (NHTSA vPIC) to derive make, model, year, and trim, which is then saved locally so it is available offline afterward. Only the derived fields are ever shown, and only when the user has enabled display (Section 3). Online decode does not conflict with the local-first goal: offline-first matters for the check-in path, not for one-time vehicle setup, and full offline-only operation is not a requirement. vPIC being US-centric is an accepted limitation; manual entry of make/model/year/trim remains available for vehicles it cannot decode.

## 9. Local-First Architecture and Sync

- **Local storage:** drift (SQLite), relational, migration-tracked.
- **Outbox pattern:** local writes marked PENDING, flushed by a sync worker on reconnect (connectivity_plus) with backoff.
- **Idempotency:** client-generated UUID check-in ids make retries safe upserts.
- **Site sync:** region-scoped allSites for the initial pull, allChanges deltas thereafter.
- **Community/personal history (POC):** community First data is polled on a best-effort basis from the XLSX export until the official API exists. The tri-color pin state is therefore best-effort during this period, with the understanding that the yellow "First today" window may lag reality between polls.
- **Check-in writes (POC):** routed through the backend-writer interface described in Section 2.2 and Section 13 (Phase 5); the active implementation is the unofficial `checkin.php` POST, swapped for the official endpoint once it exists.
- **Future:** the official supercharging.life API replaces the XLSX import, supplies real-time community First data, and accepts check-in submissions.

### Provisional API contract (to request of supercharging.life)

This is not a contract supercharging.life offers today. It is what the app needs from them, stated up front so it can drive implementation coordination once they build the official API. Auth is assumed to be the shared GitHub/Google social login (Section 8).

```
POST   /v1/auth/oauth/{provider}/callback   exchange social login for a session
GET    /v1/sites?region={region}&since={cursor}   region-scoped site deltas
GET    /v1/sites/{id}                        single-site backfill of richer metadata
GET    /v1/checkins?since={cursor}           community First data (site, date, time, is_first)
POST   /v1/checkins                          submit a check-in, idempotent on client id
PATCH  /v1/checkins/{id}                      edit notes
GET    /v1/users/me/checkins                  personal history (replaces XLSX import)
```

The two endpoints that retire the current workarounds are `GET /v1/checkins` (replaces best-effort XLSX polling for community data) and `GET /v1/users/me/checkins` (replaces the XLSX personal-history import).

## 10. Notifications

In scope, using background sync (Workmanager on mobile, platform services on desktop/web). Two local channels:

- **New Superchargers:** a site opening within the notification radius (driven by allChanges ADD/UPDATE-to-OPEN events).
- **First-Eligible Alerts:** a nearby site entering or sitting in the First-eligible window.

Both honor the configurable notification radius. Server-pushed notifications from supercharging.life are a future addition once the API exists.

## 11. Suggested Tech Stack

Flutter with Material 3, drift for local SQLite, flutter_map with OpenStreetMap tiles, geolocator with an IP-based fallback for desktop, connectivity_plus for sync triggering, Workmanager for background tasks. State management per your preference (Provider is in the prototype; Riverpod is a reasonable upgrade for the sync-heavy parts).

## 12. Out of Scope (v1)

Route planning, real-time stall availability, leaderboards beyond the basic First marker, and in-app moderation. Public-comment moderation is explicitly deferred to supercharging.life administrators and is not handled in this app.

## 13. Migration Plan: Prototype to Spec

The existing `supercharger_bingo` prototype is a real starting point, not a throwaway: it already has working drift persistence, supercharge.info parsing, GPS-plus-IP location, a timezone dataset and lookup, background sync scaffolding with the two notification channels, and a check-in screen with nearest-site sorting. The work is changing what it stores and how it talks to supercharging.life, not starting over.

**Phase 1, schema and status (foundational, do first).** `SiteStatus` in `database.dart` currently has 6 values (`open, construction, permit, planned, closed, unknown`); it needs to become the real 8-value enum (`open, expanding, construction, permit, plan, voting, closedTemp, closedPerm`), which is a drift migration (bump `schemaVersion` past 3). At the same time, trim the `Sites` table down to the Section 3 field list and drop the rest (street/city/zip, stall breakdowns v2/v3/v4, power, elevation) rather than carrying them forward; they were reasonable to capture but the spec deliberately excludes them now. This phase gates everything else, since the filter and pin-color logic both key off status.

**Phase 2, filters and pins.** `MapFilter` has `openUnvisited, openUnvisitedConstruction, all`; add a fourth `visited` value (Section 5's "Show Visited" was dropped in the prototype and needs restoring). Rewrite the marker logic in `map_screen.dart`, which currently colors by status using plain Material colors (red/orange/blue/purple) plus a separate green star for First-eligible, to use the Okabe-Ito palette with shape redundancy and the three-state green/yellow/red First coloring from Section 5, computed at render time from each site's earliest check-in date and timezone, not from `date_opened`.

**Phase 3, check-in flow.** Add a `notesPrivate` column to `Visits` and `PendingCheckins` (currently public-only); add the most-recent-check-in lookup and display in the nearby-sites list, which the prototype sorts by distance but doesn't currently annotate; add a `Vehicles` table and the optional vehicle selector, with VIN encrypted via `flutter_secure_storage` (already a dependency, currently used for the session cookie) and the one-time vPIC enrichment call.

**Phase 4, settings cleanup.** Flip the `UnitSystem` default from metric to imperial; the radius settings (`notificationRadiusKm`, `checkinRadiusKm`) already exist as separate fields and don't need structural change, just labeling and default review. Low-risk, no dependencies beyond Phase 1, and cheap enough to clear before the more involved network-layer work in Phases 5 and 6.

**Phase 5, abstract the write path.** `ApiService.submitCheckin` currently POSTs directly to `checkin.php`. Rather than disabling it, extract a `CheckinWriter` interface with a single method (something like `submitCheckin(Checkin) -> Future<WriteResult>`) and move the existing `checkin.php` POST behind it as the POC implementation. This keeps the unofficial endpoint as the active write path, per the relaxed Section 2.2 stance, while making clear it's swappable: when the official API ships, a second implementation calling that endpoint drops in behind the same interface with no changes to the check-in screen or sync worker. Worth tracking write failures distinctly from network failures here, since the unofficial endpoint can fail in ways a real API wouldn't (markup changes, session expiry, anti-scraping responses), and `PendingCheckins` needs to handle "write rejected" as a different state than "write pending, retry later."

**Phase 6, harden auth.** Keep the webview cookie-capture login rather than replacing it; it's the only thing making Phase 5's POC writer work. The improvement here is robustness: detect and surface session expiry instead of failing silently, retry or re-prompt login when the captured cookie stops working, and extract the session-management logic behind an auth interface so swapping in shared GitHub/Google OAuth later, once the official API supports it, is a second implementation rather than a rewrite. This pairs naturally with Phase 5, since both are about making the current unofficial-endpoint POC dependable enough to rely on while waiting for the real API.

**Ongoing, in parallel:** the Section 9 provisional API contract is the artifact to take to supercharging.life for coordination; it doesn't block any of the phases above and can start immediately.

Recommended order is 1 through 3 as the core rebuild, then 4 as quick cleanup, then 5 and 6 together since they're tightly coupled (the write interface in 5 depends on the session in 6 actually staying alive).
