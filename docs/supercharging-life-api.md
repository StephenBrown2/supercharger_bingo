# supercharging.life changes for Supercharger Bingo

Request for the supercharging.life maintainer, written 2026-11-18 and pared
down 2026-11-21. Supercharger Bingo (SCB) runs on Android and as a web app at
`https://supercharger.bingo`.

**Android needs nothing from you today.** It signs in through the existing
GitHub and Google login in a webview and uses the site's own pages and
endpoints (section 1).

**The web app cannot do any of that.** Browsers block a page on
supercharger.bingo from reading supercharging.life responses or sending its
cookie. So web users get no community data and cannot sign in. Their
check-ins stay on their device.

Part 1 is the smallest set of changes that fixes the web app. It touches no
existing page except one redirect after login, and none of it is throwaway: it
is the first slice of the full API. Part 2 lists improvements, highest impact
first, each one independent and optional.

Names, lifetimes and fields are proposals. Change anything that fits the site
better, and tell us (section 9). The full end-state contract, after Part 2, is
[supercharging-life-openapi.yaml](supercharging-life-openapi.yaml).

## 1. What SCB uses today

| Need | Current call |
| --- | --- |
| Sign in | Webview opens `/oauth.php?provider=GitHub` or `Google`, then reads `SCLSESSION` from `document.cookie` |
| Submit a check-in | Multipart POST to `/supercharging/checkin.php` with the session cookie |
| Delete a check-in | GET `/supercharging/misc.php?action=delete_checkin&checkin_id=N` |
| Personal history | `/supercharging/export.php?action=user_xlsx&user_id=N`, with the id found by display name through `ajax.php?content=user_list_for_datatables` |
| Community Firsts, counts, one site's history | `ajax.php?content=` `first_checkin_history_list_for_datatables`, `supercharger_list_for_datatables`, `supercharger_checkin_history_list_for_datatables` |

None of this changes. Android keeps using it until it moves to the new sign-in
(section 7.2).

# Part 1: the minimum for the web app

Two steps, in impact order. Step 1 is one line and helps every web user,
signed in or not. Step 2 is the sign-in and the four calls behind it.

## 2. Step 1: let browsers read community data

Add one response header to `/supercharging/ajax.php` for the three community
`content` values in section 1:

```
Access-Control-Allow-Origin: *
```

The app sends plain GETs, so browsers send no preflight and no cookie. These
responses are already public, so this exposes nothing new. The web map then
shows Firsts and check-in counts like Android does, using the parser the app
already has.

## 3. Step 2a: sign-in for apps

A minimal OAuth 2.0 authorization code grant with PKCE: two pages, one table
for codes and one for tokens. There is one client, so no client registry
yet. Hard-code it:

| `client_id` | Redirect URI, compared byte for byte |
| --- | --- |
| `supercharger-bingo-web` | `https://supercharger.bingo/auth/callback` |

The existing GitHub and Google login stays exactly as it is. These pages never
talk to GitHub or Google; they send a signed-out user through `login.php` and
continue afterwards. The app never sees `SCLSESSION` or provider tokens.

### 3.1 Return to the app after login

The only change to existing login code. When `/oauth/authorize` sends a
signed-out user to `login.php`, it first stores its own request URL in the
server session. After a successful GitHub or Google sign-in, if that value is
set, clear it and redirect there instead of the usual landing page.

Only ever redirect to a value `/oauth/authorize` stored itself, a relative path
starting with `/oauth/authorize?`. Never take the target from a query
parameter, or the login becomes an open redirect.

### 3.2 `GET /oauth/authorize`

Parameters, all required: `response_type=code`, `client_id`, `redirect_uri`,
`scope=checkins`, `state`, `code_challenge`, `code_challenge_method=S256`.

1. Wrong `client_id` or `redirect_uri`: show an error page. Never redirect to
   an unverified URI.
2. Any other parameter missing or wrong: redirect to the redirect URI with
   `error=invalid_request&state=...`.
3. No valid `SCLSESSION`: store this URL (section 3.1) and redirect to
   `login.php`.
4. Signed in: create a code (random, at least 128 bits, single use, valid 60
   seconds), stored with the user id and `code_challenge`. Redirect to
   `https://supercharger.bingo/auth/callback?code=...&state=...`.

No consent page: the redirect URI is fixed to supercharger.bingo, and a stolen
code is useless without the PKCE verifier only the app holds.

### 3.3 `POST /oauth/token`

Form-encoded: `grant_type=authorization_code`, `code`, `redirect_uri`,
`client_id`, `code_verifier`.

Check that the code exists, is unexpired and unused, and that
`BASE64URL(SHA256(code_verifier))` equals the stored challenge. Delete or mark
the code used in the same transaction that creates the token. Response, with
`Cache-Control: no-store`:

```json
{
  "access_token": "opaque random string",
  "token_type": "Bearer",
  "expires_in": 7776000,
  "scope": "checkins"
}
```

Any failure: HTTP 400 with `{"error": "invalid_grant"}` (or
`invalid_request`).

Store only a SHA-256 hash of the token, with the user id and an expiry 90 days
out. Push the expiry forward on use, so an occasional user stays signed in.
When it does expire, the app asks the user to sign in again. Always returning
`scope` now lets section 7.4 add `admin` later without changing the app's
parser.

### 3.4 `POST /oauth/revoke`

Form-encoded `token` and `client_id`. Delete the token's row. Always return
200, even for an unknown token. The app calls this on sign-out.

## 4. Step 2b: four personal endpoints

### 4.1 Rules for these endpoints and the token endpoints

- **Auth.** `Authorization: Bearer <token>` only, never `SCLSESSION`. Browsers
  do not attach bearer tokens on their own, so these endpoints need no CSRF
  tokens.
- **CORS.** Every response, errors included, sends
  `Access-Control-Allow-Origin: *`. Answer `OPTIONS` preflights before any auth
  check with 204 and `Access-Control-Allow-Methods: GET, POST, DELETE`,
  `Access-Control-Allow-Headers: Authorization, Content-Type` and
  `Access-Control-Max-Age: 600`. Never send `Access-Control-Allow-Credentials`.
  No cookies are involved, so `*` is as safe as an origin list.
- **Errors.** JSON `{"error": "code", "message": "human text"}`, never an HTML
  page and never a redirect to `login.php`. 401 for a missing, expired or
  revoked token. 404 for anything unknown or not the caller's, never 403. 422
  for validation failures, with the message the web form would show.
- **No cookies.** These responses set no `SCLSESSION`.
- **Times.** RFC 3339 with offset, for example `2026-11-10T00:05:53-05:00`.
  A check-in with only a calendar date has `"precision": "date"`, otherwise
  `"timestamp"`.
- **IDs.** The existing integer user, check-in and supercharger ids.

### 4.2 `GET /api/v1/me`

```json
{
  "id": 50202,
  "display_name": "example",
  "profile_url": "https://supercharging.life/supercharging/user.php?id=50202"
}
```

Replaces the display-name lookup.

### 4.3 `GET /api/v1/me/checkins`

Replaces the XLSX export. `{"items": [...]}`, every check-in of the caller,
each with `id`, `supercharger_id`, `checked_in_at`, `precision`,
`notes_public`, `notes_private`, `latitude`, `longitude`, `accuracy_m` and
`created_at`. Null where the site has no value.

### 4.4 `POST /api/v1/checkins`

Replaces the `checkin.php` form. Reuse the form's insert and validation code.

```json
{
  "supercharger_id": 2419,
  "checked_in_at": "2026-11-10T00:05:53-05:00",
  "precision": "timestamp",
  "notes_public": "optional",
  "notes_private": "optional",
  "latitude": 34.9,
  "longitude": -117.0,
  "accuracy_m": 12.5
}
```

The owner comes from the token; ignore or reject any `user_id`. Apply the same
rules the form does today, returning 422 on failure. On success return 201 with
the stored check-in as in section 4.3, so the app learns its id.

### 4.5 `DELETE /api/v1/checkins/{id}`

Replaces `misc.php?action=delete_checkin`. 204 when the caller's check-in is
deleted, 404 otherwise.

## 5. What the app does with Part 1

The app work is ours. Once Part 1 is live, the web app signs in through
`/oauth/authorize` with ordinary page redirects, which work in the Tesla
browser. It then sends its pending check-ins and imports the user's history.
Android stays on its current path. The app-side list is in
[supercharging-life-api-app-changes.md](supercharging-life-api-app-changes.md).

## 6. Checks for Part 1

On production, in a desktop browser and the Tesla browser:

- The web map shows community Firsts and counts while signed out.
- Sign in with GitHub and with Google from supercharger.bingo, including from
  signed out on supercharging.life. `GET /api/v1/me` shows the right account.
- Create a check-in from the web app and see it on supercharging.life with the
  same id. Delete it and see it gone.
- Signing in on supercharging.life directly still works exactly as before.

# Part 2: later, highest impact first

Each item stands alone. None blocks the web app.

## 7. Improvements

### 7.1 Idempotency keys (no duplicate check-ins)

**Why:** today a check-in whose response is lost, common on a weak car
connection, is sent again and can land twice. The app already queues and
retries, so this is the most likely source of bad data.

**Change:** `POST /api/v1/checkins` takes an `Idempotency-Key` header, a UUID
the app creates once per check-in. Add a permanent table
`checkin_keys(user_id, client_uuid, checkin_id)` with
`UNIQUE(user_id, client_uuid)`. In the create transaction, insert the key row
first:

- Insert succeeds: create the check-in, store its id on the key row, 201. A
  validation failure rolls back the key too, so a corrected retry can use it.
- Unique violation: if the check-in still exists and is the caller's, 200 with
  it. Otherwise it was deleted since, so 410 `gone`, so a late retry never
  recreates it.

Rows are never deleted, so no delete path needs to change. Add `client_uuid`
to `GET /api/v1/me/checkins` items from this table, and let `DELETE` return
204 again for a check-in the table shows was the caller's.

### 7.2 Android on the same sign-in

**Why:** Android's webview sign-in is the most fragile part of the app today.
Google blocks sign-in in webviews, so the app spoofs a browser user agent, and
reading the cookie only works because `SCLSESSION` is not HttpOnly. Either can
break without notice.

**Change:** accept a second hard-coded redirect URI,
`https://supercharger.bingo/auth/app`, for client
`supercharger-bingo-mobile`. It is an Android App Link, verified by
`assetlinks.json` on supercharger.bingo, so only SCB can receive it. The app
opens `/oauth/authorize` in Custom Tabs, which reuses the user's existing
browser sign-in. After that release, section 8's cookie hardening becomes
possible.

### 7.3 Refresh tokens

**Why:** a 90-day bearer token in browser storage is a long-lived credential if
it leaks. Short access tokens limit that.

**Change:** issue 1-hour access tokens with a 90-day sliding refresh token.
Rotate the refresh token on every use and store each token family's state:

- A replaced refresh token presented again revokes the whole family (reuse
  detection).
- For 60 seconds after rotation, the just-replaced token is accepted once and
  issues a fresh pair, revoking the pair issued before. This keeps a user
  signed in when a car's connection drops the refresh response.
- Rotation, the grace path and revocation run in one transaction that locks
  the family.

Revoking a refresh token revokes its family. The OpenAPI file describes the
exact rules.

### 7.4 `admin` scope

**Why:** the app can show admins alerts about suspect check-ins, such as one
dated before a site opened. No supported signal says who is an admin (see the
[admin role investigation](research/Admin%20role%20investigation.md)).

**Change:** the app requests `scope=checkins admin`. Grant `admin` only to
accounts that can edit and delete any user's check-ins, at the moment the token
is issued, and list it in the token response's `scope`. With refresh tokens,
recheck on each refresh and drop `admin` if the permission is gone; never add
it back without a new sign-in.

### 7.5 JSON community endpoints

**Why:** the app parses DataTables rows, downloads the whole
site list to get one count per site, and has no way to skip an unchanged poll.

**Change:**

- `GET /api/v1/superchargers/summary`: one row per site with a valid check-in,
  with `supercharger_id`, `checkin_count`, `first_date` and `firsts` (each
  First's id, user, display name, time and precision).
- `GET /api/v1/superchargers/{id}/checkins`: every public check-in at the site,
  with `is_first` and `notes_public`. Private notes and coordinates never
  appear.

What counts as a First: convert `checked_in_at` to the site's IANA timezone
(from its coordinates), not the stored offset. Archived check-in 63684 is
stored as `2024-02-15 00:45:21-05` but happened on 14 February at the site, its
opening day. A check-in is valid if that site-local date is on or after the
site's earliest opening date, or the site has none. `first_date` is the
earliest valid date, and every valid check-in on it is a First. Compute this
when reading, so backdating and deletions are always reflected.

### 7.6 Cheaper polling

Every list returns an `ETag`; a matching `If-None-Match` gets 304 with no body.
Public reads send `Cache-Control: public, max-age=60`. Publish rate limits and
return 429 with `Retry-After`. Add `ETag`, `Retry-After` and
`WWW-Authenticate` to `Access-Control-Expose-Headers`, and `If-None-Match` and
`Idempotency-Key` to `Access-Control-Allow-Headers`.

### 7.7 Sign out all apps

One button in account settings that deletes every app token for the user.
Signing out of the website does not revoke app tokens; this does.

### 7.8 iOS and desktop

Only if SCB ships there. iOS uses the same `/auth/app` URI as a Universal Link
(`apple-app-site-association`). Desktop uses `http://127.0.0.1:<any
port>/auth/callback` (RFC 8252), matched by parsing, not by prefix. Because any
local program can listen on a loopback port, desktop also needs a consent page
with Allow and Deny, a CSRF token and `frame-ancestors 'none'`.

## 8. Site hardening, independent of the app

- `misc.php?action=delete_checkin` changes state on a GET, so any page a
  signed-in user visits can delete their check-ins with an image tag. Make it
  POST with a CSRF token. SCB stops calling it once it uses section 4.5.
- After Android moves to section 7.2, set `SCLSESSION` with `HttpOnly` and
  `SameSite=Lax`. Doing it earlier breaks Android sign-in.
- Stop setting a session cookie on anonymous `ajax.php` requests.

## 9. What to send back

- Final URLs and field names, if different.
- When Part 1 is live, and a test account or staging host where check-ins can
  be created and deleted.
- For section 7.4, which existing permission means "can edit and delete any
  check-in".
