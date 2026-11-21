# App changes for the official supercharging.life API

Work in Supercharger Bingo that waits on the official API proposed in
[supercharging-life-api.md](supercharging-life-api.md). None of it needs work on
supercharging.life. Section numbers refer to that document.

## Already done

Preparation that works with the current unofficial writer, done 2026-11-18:

- The check-in dialog records through the Check-in outbox
  (`CheckinOutbox.record`), which saves the Visit first and sends at once. It
  stays Pending only when that send fails (offline, signed out, network or
  server error). All sends in one isolate run through one queue, so a check-in
  is not posted twice at once, and an app kill mid-send never loses it.
- Signing in starts a sync, so check-ins waiting for sign-in go out at once.
- A row left `submitting` because the app was killed mid-send is sent again by
  the first sync at least 10 minutes after its last attempt
  (`CheckinOutbox.sendDue`), without the failure backoff. With the unofficial
  endpoint that retry can duplicate a check-in that landed before the kill. An
  import of the user's visits that finds it first settles it instead
  (`CheckinOutbox.settleFromImport`); the idempotency key below removes the
  rest.

## Waiting on the API

Each item needs something only the API provides, shown in brackets.

### Web app, first (Part 1)

- Drop the `kIsWeb` early return in `SyncService.syncCommunityData` once
  `ajax.php` sends the CORS header. [Section 2]
- Web sign-in through `/oauth/authorize` with top-level redirects, a 90-day
  token and no refresh token; ask the user to sign in again when it expires.
  Then send pending check-ins through `POST /api/v1/checkins` and import
  history from `GET /api/v1/me/checkins`. Android stays on its current path.
  [Sections 3 and 4]

### Check-ins

- Add an official API `CheckinWriter` next to the `checkin.php` writer and make
  it the default. [`POST /api/v1/checkins`, section 4.4]
- Give every pending row a UUID when it is queued, backfilling existing rows in
  the same migration, and send it as `Idempotency-Key`. Store the returned id
  before clearing the pending row. Treat 200 and 201 as confirmed, 410 as
  deleted on the server, and 404 on deleting one of its own known ids as already
  deleted. Nothing reads the UUID until the API exists, so it is added with the
  writer rather than now. [Idempotency, section 7.1]
- Send `checked_in_at` in the site's local offset, not the device's. The
  unofficial form's handling of offsets is unknown, so the current writer keeps
  sending what the website itself sends. [Section 7.5]

### Accounts

- Tie every pending check-in and cached personal snapshot to the `/me` id. On
  sign-out, revoke the refresh token and never send a pending check-in as a
  different account; the key is unique per user, so that would create a second
  check-in. Today's account id comes from a display-name lookup that runs only
  during personal history import, so it is not reliable enough to bind rows to.
  [`GET /api/v1/me`, section 4.2]
- Pending check-ins queued before that change have no account. Keep them
  through the database migration and ask the user which account they belong to
  before uploading any of them.

### Sign-in and tokens

- Replace webview cookie capture with system-browser OAuth (PKCE) on every
  platform. Check `state` and `iss` on the callback. Store the refresh token and
  granted scope in the platform's secure storage. Handle 401 by refreshing once.
  Send one refresh at a time per app, re-reading the stored token inside the
  lock; on the web the lock spans tabs (Web Locks API). [Sections 3, 7.2 and 7.3]
- On the web the refresh token lives in browser storage, so any script running
  on supercharger.bingo could read it. Before the web build stores tokens, add a
  strict Content-Security-Policy to `web/_headers` with no third-party scripts,
  and verify it across the Tesla browser matrix in AGENTS.md. If the web app
  ever needs third-party code, move token handling to a same-origin backend with
  an HttpOnly session first. The web build stores no tokens today, so the policy
  would protect nothing yet. [Section 3]

### Sync

- Poll the summary and personal history with `If-None-Match`, and retire the
  XLSX import and display-name lookup. [Sections 4.3, 7.5 and 7.6]
- When a personal snapshot arrives, match server rows by id and pending rows by
  UUID, drop confirmed rows the server no longer has, and keep unmatched pending
  rows. Replace cached Firsts and counts with each summary, so deleting a site's
  last valid visit reopens it. [Sections 4.3 and 7.5]

### Admin

- Show admin alerts only while the latest token response's `scope` contains
  `admin`. The app computes them from public data, for example a check-in dated
  before the site opened. [Section 7.4]

### Docs

- Update `docs/SPEC.md` sections 8 and 9 to match.
