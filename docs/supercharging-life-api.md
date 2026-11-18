# supercharging.life changes for official API access

Request for the supercharging.life maintainer, written 2026-11-18. It lists every
server change Supercharger Bingo needs to sign users in and read and write
check-ins through a supported API, on Android, iOS, desktop and the web release
at `https://supercharger.bingo`. The existing GitHub and Google sign-in stays
exactly as it is. The new pieces sit on top of it.

Endpoint names, lifetimes and field names below are proposals to agree on, not
existing routes. The machine-readable contract is
[supercharging-life-openapi.yaml](supercharging-life-openapi.yaml). The site
source is not public, so everything about the current
site comes from its observable behavior.

## 1. What the app does today

| Need | Current unofficial call | Problem |
| --- | --- | --- |
| Sign in | Webview opens `/oauth.php?provider=GitHub` or `Google`, then reads `SCLSESSION` from `document.cookie` | Google blocks embedded webviews ("disallowed_useragent"), so the app spoofs the user agent. The cookie only works because it is not HttpOnly. Impossible from a normal browser on another origin. |
| Detect sign-out | Looks for a redirect to `login.php` or the text "Login to your account" | Breaks if wording or markup changes. |
| Submit a check-in | Multipart POST to `/supercharging/checkin.php` with the session cookie (`supercharger_id`, `date`, `user_id`, `notes_public`, `notes_private`, `log_coords_lat`, `log_coords_lon`, `log_coords_accuracy`) | Success is a 302 with no check-in id. No idempotency, so a lost response can create a duplicate on retry. |
| Delete a check-in | GET `/supercharging/misc.php?action=delete_checkin&checkin_id=N` | A state change on GET, confirmed only by guessing the redirect target. |
| Personal history | GET `/supercharging/export.php?action=user_xlsx&user_id=N`, after finding the id through `ajax.php?content=user_list_for_datatables` by display name | Spreadsheet parsing; display-name lookup is ambiguous. |
| Community Firsts | `ajax.php?content=first_checkin_history_list_for_datatables` | DataTables shape, no caching validators, no CORS header. |
| One site's history | `ajax.php?content=supercharger_checkin_history_list_for_datatables&id=N` | Same. |
| Check-in counts | `ajax.php?content=supercharger_list_for_datatables` (`checkin_qty`) | Same, and returns the full site list to get one number each. |
| Admin capability | None; a diagnostic probe found no role signal (see [admin role investigation](research/Admin%20role%20investigation.md)) | No supported way to know whether the user can edit any check-in. |

Observed 2026-11-18: public `ajax.php` responses set a fresh `SCLSESSION`
(`domain=.supercharging.life; secure`, 7 day Max-Age, not HttpOnly, no SameSite)
and send no `Access-Control-Allow-Origin`, so browsers on other origins cannot
read them.

## 2. Keep: existing sign-in

No change to any of these:

- The GitHub and Google OAuth apps and their registered redirect URI,
  `https://supercharging.life/oauth.php`.
- `login.php`, `oauth.php?provider=...`, account creation and account linking.
- `SCLSESSION` as the website's own session, and every existing page and form.
- The unofficial endpoints in section 1. The app keeps using them as a fallback
  until the official API is live and verified, then stops.

The new authorization layer below never talks to GitHub or Google itself. When
a user is not signed in, it sends them through the existing login and then
continues. Third-party apps never see provider tokens or the site cookie.

## 3. Add: return-to support in the existing login

The only change to the existing login code.

1. `login.php` and `oauth.php` accept a `return` parameter. The caller
   percent-encodes it, because the authorize URL inside it contains `&`.
2. Decode it once. Accept it only if it is a relative path that starts with
   `/oauth/authorize?` and contains no control characters (including CR and
   LF) and no backslashes. Ignore anything else, including absolute URLs and
   `//host`, and fall back to the usual landing page. This prevents an open
   redirect.
3. Store it in the server session before redirecting to GitHub or Google (the
   provider round trip loses query parameters), then redirect there after the
   session is established instead of the usual landing page.

## 4. Add: OAuth 2.0 authorization server

supercharging.life becomes an OAuth 2.0 authorization server for its own API,
using the authorization code grant with PKCE, as in OAuth 2.1 and the
[OAuth security BCP (RFC 9700)](https://www.rfc-editor.org/rfc/rfc9700). Only
public clients are needed, so there are no client secrets. Implicit and password
grants are not offered.

### 4.1 Scopes

| Scope | Granted to | Allows |
| --- | --- | --- |
| `checkins` | Every user | Reading the account and the user's own check-ins, including private notes; creating and deleting them |
| `admin` | Only accounts that can edit and delete any user's check-ins | Marks the token as an admin's. No admin endpoints exist yet; the app uses it to decide who sees admin alerts |

Clients request `scope=checkins admin`. The server always grants `checkins` and
grants `admin` only when the account has that permission at the moment the
token is issued. The `scope` field of every token response lists exactly what
was granted, so it is the app's one source of admin status. The permission is
checked again on every refresh, and a token family's scopes only ever shrink:
a user who loses the permission drops `admin`
within one access token lifetime, and a user who gains or regains it gets
`admin` the next time they sign in.
No other supported signal exists today (see the
[admin role investigation](research/Admin%20role%20investigation.md)), so the
maintainer decides which existing site permission maps to `admin` (section 8).

### 4.2 Client registry

A small table maintained by the site admin, edited directly; no management UI:

| Field | Purpose |
| --- | --- |
| `client_id` | Public identifier, for example `supercharger-bingo-web` |
| `name` | Shown on the consent screen |
| `redirect_uris` | Exact strings, compared byte for byte (loopback is the one exception, below) |
| `enabled` | Lets the admin cut off a client instantly |

Clients:

| Client | Redirect URI |
| --- | --- |
| `supercharger-bingo-web` | `https://supercharger.bingo/auth/callback` |
| `supercharger-bingo-mobile` | `https://supercharger.bingo/auth/app` (Android App Link and iOS Universal Link, verified by `assetlinks.json` and `apple-app-site-association` on supercharger.bingo) |
| `supercharger-bingo-desktop` | `http://127.0.0.1/auth/callback` on any port, per [RFC 8252 section 7.3](https://www.rfc-editor.org/rfc/rfc8252#section-7.3) |
| `supercharger-bingo-web-dev` | `http://localhost:8787/auth/callback`, registered only on a staging host, never production |

Match the desktop loopback URI by parsing it, not by string prefix: scheme
`http`, host exactly `127.0.0.1`, path exactly `/auth/callback`, no userinfo,
query or fragment. Only the port may vary. Reject `localhost`.

Native apps open these pages in the system browser (Android Custom Tabs, iOS
`ASWebAuthenticationSession`), not a webview. That ends the Google webview block
and the user agent workaround, and lets the user's existing supercharging.life,
GitHub or Google browser session carry over. The Tesla browser uses ordinary
top-level redirects.

### 4.3 `GET /oauth/authorize`

Parameters: `response_type=code`, `client_id`, `redirect_uri`, `scope`,
`state`, `code_challenge`, `code_challenge_method=S256`. All are required.

1. Unknown or disabled client, or a redirect URI not registered for it: show an
   error page. Never redirect to an unverified URI.
2. `response_type` other than `code`, missing `state` or `code_challenge`, or a
   method other than `S256`: redirect back with `error=invalid_request`. A scope
   other than `checkins` and `admin`, or no `checkins`: `error=invalid_scope`.
   Every redirect back to a verified client, success or error, carries `iss`,
   and carries `state` whenever the request supplied one.
3. No valid `SCLSESSION`: redirect to `login.php?return=<this request URL,
   percent-encoded>` (section 3). The user picks GitHub or Google as they do
   today.
4. Desktop loopback client: always show a consent page naming the client, with
   Allow and Deny, because any local program can listen on a loopback port
   ([RFC 8252 section 8.6](https://www.rfc-editor.org/rfc/rfc8252#section-8.6)).
   Deny returns `error=access_denied` with `state` and `iss`. The consent POST needs a CSRF token and
   the page sends `frame-ancestors 'none'` so it cannot be clickjacked. Bind
   each consent form to the exact client, redirect URI, scope, state and code
   challenge it shows (for example a single-use id for the stored request), so
   an approval cannot apply to a different request opened in another tab. The web
   and mobile clients skip consent: their redirect URIs are HTTPS URLs on
   supercharger.bingo, and a stolen code is useless without the PKCE verifier.
5. Issue a code: random, at least 128 bits, single use, valid 60 seconds, stored
   with the user, client, exact redirect URI, granted scopes and code challenge.
6. Redirect to `redirect_uri?code=...&state=...&iss=https://supercharging.life`.
   The `iss` value follows [RFC 9207](https://www.rfc-editor.org/rfc/rfc9207).

### 4.4 `POST /oauth/token`

Form-encoded.

- `grant_type=authorization_code`, `code`, `redirect_uri`, `client_id`,
  `code_verifier`. Check that the code exists, is unexpired and unused, that
  client and redirect URI match, and that `BASE64URL(SHA256(code_verifier))`
  equals the stored challenge. Mark the code used in the same transaction that
  issues tokens. If a used code is presented again, revoke the tokens it
  produced.
- `grant_type=refresh_token`, `refresh_token`, `client_id`. The refresh token
  must belong to that client. Rotate on every use: return a new pair and mark
  the old refresh token replaced. The token family stores its current scopes,
  starting with what the authorization granted. Each refresh, including the
  grace path below, grants those scopes minus `admin` if the account no longer
  has that permission, and saves the result back to the family. Scopes only
  ever shrink, so restoring the permission later takes a new sign-in.
- Lost responses. For 60 seconds after rotation, the immediately replaced
  refresh token is accepted once more: it issues a fresh pair in the same
  family and revokes the pair issued before. This works with hashed storage,
  since nothing is returned twice, and keeps a user signed in when a weak car
  connection drops the refresh response. It is a small replay window traded
  for that; the app sends only one refresh at a time, so it never relies on the
  window for concurrency.
- Reuse detection. Revoke the whole token family when a replaced refresh token
  is presented after the window or a second time, or when anyone presents a
  token that the grace path revoked.
- Locking. Rotation, the grace path and revocation all run in one transaction
  that locks the token family, so requests using different tokens of the same
  family cannot race.

Every response, including errors, sends `Cache-Control: no-store`. Success:

```json
{
  "access_token": "opaque random string",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "opaque random string",
  "scope": "checkins admin"
}
```

Errors use the standard body, for example `{"error": "invalid_grant"}`: HTTP 400
for `invalid_request`, `invalid_grant` and `unsupported_grant_type`, and HTTP 401
for `invalid_client` (unknown or disabled client). Rate limiting returns 429 with
`Retry-After`.

Suggested lifetimes: access token 1 hour; refresh token 90 days sliding, so a
car or phone that checks in occasionally stays signed in. Opaque tokens checked
against the database are the simplest choice, revoke immediately and need only a
SHA-256 hash stored. JWT access tokens (as issued by `league/oauth2-server`) are
fine too, but then a revoked access token keeps working until it expires,
including after reuse detection, so prefer opaque tokens.

### 4.5 `POST /oauth/revoke`

[RFC 7009](https://www.rfc-editor.org/rfc/rfc7009) revocation for an access or
refresh token, with `token`, optional `token_type_hint` and `client_id`.
Revoking a refresh token revokes its whole family. Returns 200 for any token,
including unknown or already revoked ones, and 503 only if revocation could not
be stored, so the app retries. The app calls it on sign-out.

### 4.6 Sign out all apps

One button in the existing account settings that revokes every app token for
the user. Signing out of the website does not revoke app tokens; this button
does. A per-app list can come later if third-party clients ever exist.

## 5. Add: versioned JSON API under `/api/v1`

### 5.1 Rules for every endpoint

- **Auth.** `Authorization: Bearer <access_token>` only. The API must not accept
  `SCLSESSION`. Bearer-only means another site cannot ride the user's browser
  cookie, so the API needs no CSRF tokens.
- **Errors.** JSON, never an HTML page and never a redirect to `login.php`.
  Shape: `{"error": "code", "message": "human text", "fields": {"name": "problem"}}`.
  - 401 with `WWW-Authenticate: Bearer error="invalid_token"` for a missing,
    expired or revoked token. The app refreshes once, then asks the user to sign
    in again.
  - 404 for anything unknown or not the caller's. Never 403 for another user's
    check-in, so ids cannot be probed for ownership.
  - Public endpoints ignore any `Authorization` header, so an expired token
    never turns a public read into a 401.
  - 410 for a replayed create whose check-in was deleted (section 5.4).
  - 422 validation, with `fields`. 429 with `Retry-After`. 5xx only for server
    faults.
- **CORS.** Every `/api/v1`, `/oauth/token` and `/oauth/revoke` response,
  including errors, sends `Access-Control-Allow-Origin: *` and
  `Access-Control-Expose-Headers: Retry-After, WWW-Authenticate, ETag`. No
  cookies are involved, so a wildcard is as safe as an origin list: the bearer
  token is the boundary, and anyone holding one can call the API from a server
  anyway. Answer `OPTIONS` preflights before any auth check, never with 401,
  with `Access-Control-Allow-Methods: GET, POST, DELETE`,
  `Access-Control-Allow-Headers: Authorization, Content-Type, Idempotency-Key, If-None-Match`
  and `Access-Control-Max-Age: 600`. Never send `Allow-Credentials`.
- **Cookies.** API responses must not set `SCLSESSION`. Public `ajax.php`
  currently sets a new one on every anonymous request.
- **Lists.** Every list returns the full current set as a snapshot with an
  `ETag`. A request with a matching `If-None-Match` gets 304 with no body.
  Deletions show up as absence. No cursors, change feeds or tombstones: the
  largest list is about one row per site, roughly 100 KB gzipped, and an
  unchanged poll costs one 304.
- **Caching.** Public reads send `Cache-Control: public, max-age=60`, so a CDN
  or the site's own server absorbs repeat polls. `GET /api/v1/me/checkins`
  sends `Cache-Control: private, no-cache` with its `ETag`. Every other
  authenticated response sends `Cache-Control: no-store`.
- **Times.** RFC 3339 with offset, for example `2026-11-10T00:05:53-05:00`,
  plus a `precision` field of `timestamp` or `date` where a check-in may have
  only a calendar date. A `date` value is local midnight at the site. Calendar
  dates such as `first_date` are plain `YYYY-MM-DD` in the site's local time.
  The current DataTables rows use `2026-11-10 00:05:53-05` instead.
- **IDs.** Integers, matching the existing check-in, user and supercharger ids.
  Supercharger ids stay the supercharge.info site ids.
- **Rate limits.** Per token and per IP for anonymous reads. Publish the limits.

### 5.2 Account

`GET /api/v1/me`

```json
{
  "id": 50202,
  "display_name": "example",
  "profile_url": "https://supercharging.life/supercharging/user.php?id=50202"
}
```

This replaces the display-name lookup through `user_list_for_datatables`. Admin
status is not repeated here; it comes from the `admin` scope (section 4.1).

### 5.3 Community data, public

**What counts as a First.** A check-in's site-local date comes from converting
`checked_in_at` to the site's IANA timezone (derivable from its coordinates),
not from the offset it was stored with: archived check-in 63684 is stored as
`2024-02-15 00:45:21-05` but happened on 14 February at the site, its opening
day. A `date` precision check-in keeps its recorded calendar date. A check-in
is valid if its site-local date is on or after the site's
earliest opening date; a later reopening never invalidates earlier visits, and
a site with no known opening date treats every check-in as valid. A site's
`first_date` is the date of its earliest valid check-in. Every valid check-in
on that date is a First, so Firsts can be shared. Compute this when reading,
not as a stored flag, so backdated check-ins, corrections and deletions are
always reflected.

| Endpoint | Replaces | Returns |
| --- | --- | --- |
| `GET /api/v1/superchargers/summary` | `first_checkin_history_list_for_datatables` and `checkin_qty` from `supercharger_list_for_datatables` | One row per site with at least one valid check-in: `supercharger_id`, `checkin_count` (valid check-ins only), `first_date`, and `firsts` (each First's `id`, `user_id`, `user_display_name`, `checked_in_at`, `precision`). A site that is absent has no valid check-ins |
| `GET /api/v1/superchargers/{id}/checkins` | `supercharger_checkin_history_list_for_datatables` | Every public check-in at the site, including ones dated before it opened: `id`, `user_id`, `user_display_name`, `checked_in_at`, `precision`, `is_first`, `notes_public`. 404 for an unknown site, an empty list for a site with none |

Private notes and coordinates never appear here.

### 5.4 The user's check-ins

`GET /api/v1/me/checkins` replaces the XLSX export. Each item has `id`,
`client_uuid`, `supercharger_id`, `checked_in_at`, `precision`, `is_first`,
`notes_public`, `notes_private`, `latitude`, `longitude`, `accuracy_m` and
`created_at`.

`POST /api/v1/checkins` replaces the `checkin.php` form. Requires an
`Idempotency-Key` header holding a UUID the app generates once per pending
check-in; a missing or malformed key is 400 `invalid_request`.

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

- The owner comes from the token. A `user_id` or any other unknown field in the
  body is a 422.
- Validate the same rules the web form enforces today (site exists, not in the
  future, site-local date (section 5.3) not before the site's earliest opening
  date, note length, coordinate ranges, duplicate visit rules). Return 422 with
  `fields` explaining each failure.
- `latitude` and `longitude` come together; `accuracy_m` needs both.
- Response 201 with the stored check-in, including its `id` and `is_first`.

Idempotency uses one small permanent table,
`checkin_keys(user_id, client_uuid, checkin_id)` with
`UNIQUE(user_id, client_uuid)`. Rows are never deleted, so no delete path (this
API, the website or admin tools) needs to change, and existing check-in queries
stay as they are. Check that the `Idempotency-Key` header is a UUID (else 400).
Then, in the create transaction, insert the key row before parsing or
validating the body:

- Insert succeeds (new key): parse and validate the body, create the check-in,
  store its id on the key row, commit, 201. A malformed body (400) or a
  validation failure (422) rolls back the key too, so a corrected retry can use
  it.
- Unique violation (key already used by this user): the body is not parsed or
  compared; the app never reuses a key for a different check-in. If the
  check-in the key points to still exists and belongs to the caller, 200 with
  it as stored now.
- Otherwise, the check-in has since been deleted: 410 `gone`, so a late retry
  never recreates it. The owner check matters because some databases (MySQL
  before 8.0) can reuse a deleted row's id after a restart; it applies equally
  where `GET /api/v1/me/checkins` fills `client_uuid` from `checkin_keys`.
- Two requests with the same key at once: the second insert waits on the unique
  index until the first commits or rolls back, then follows the rules above.

`DELETE /api/v1/checkins/{id}` replaces `misc.php?action=delete_checkin`.
Returns 204. Deleting the caller's own already deleted check-in returns 204
again if `checkin_keys` shows it was theirs, otherwise 404. A check-in that
never existed or is someone else's returns 404.

Editing notes after submission is not needed; the app has no edit flow.

## 6. Recommended hardening, independent of the app

- Make `misc.php?action=delete_checkin` require POST with a CSRF token. As a GET,
  any page the user visits can delete their check-ins with an image tag.
- After the app moves to the official API, set `SCLSESSION` with `HttpOnly` and
  `SameSite=Lax`. Today the native app reads it through `document.cookie`, so
  doing this earlier breaks the current app's sign-in.
- Stop issuing a session cookie to anonymous `ajax.php` requests.

## 7. Delivery order

Each step is useful on its own and none breaks existing users.

1. Public community reads (5.3). Unblocks community data on the web release with
   no auth work at all.
2. Return-to support (3), authorize, token and revoke endpoints (4), and
   `GET /api/v1/me`.
3. Personal reads and writes (5.4) and the sign-out-all button (4.6).
4. Hardening (6), after the app release that uses the official API is out.

## 8. What the maintainer needs to send back

- Final URLs and field names, if different from above.
- How the site records today which accounts can edit and delete any user's
  check-ins, and confirmation that exactly those accounts get `admin`.
- Registered client ids and confirmation of the redirect URIs.
- Token lifetimes and rate limits.
- A test account (or a staging host) where check-ins can be created and deleted.

## 9. App changes once the API exists

None of this needs work on supercharging.life. The list, including what the
app already does in preparation, is in
[supercharging-life-api-app-changes.md](supercharging-life-api-app-changes.md).

## 10. Acceptance checks

On the production HTTPS origin, real Intel and AMD Tesla browsers and each
native platform:

- Sign in with GitHub and with Google; `GET /api/v1/me` shows the right account.
- An admin account's token response includes `admin`, a regular account's does
  not. Removing the permission drops `admin` at the next refresh; restoring it
  and refreshing again still gives no `admin`; signing in again does.
- Create a check-in, then see it on supercharging.life with the same id.
- Simulate a lost response and retry with the same key: exactly one check-in.
  Delete it, retry again: 410, and no new check-in.
- Reload and relaunch: still signed in, history intact.
- Let the access token expire: the app refreshes silently. Drop the refresh
  response and retry within 60 seconds: still signed in. Press "sign out all
  apps": the app asks the user to sign in again.
- Delete a check-in, then confirm it is gone on the site.
- Sign in on the website directly still works exactly as before.
- Local pending records survive every failure and never appear as confirmed.
