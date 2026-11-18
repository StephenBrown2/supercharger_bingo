# supercharging.life changes for official API access

Request for the supercharging.life maintainer, written 2026-11-18. It lists every
server change Supercharger Bingo needs to sign users in and read and write
check-ins through a supported API, on Android, iOS, desktop and the web release
at `https://supercharger.bingo`. The existing GitHub and Google sign-in stays
exactly as it is. The new pieces sit on top of it.

Endpoint names, lifetimes and field names below are proposals to agree on, not
existing routes. The site source is not public, so everything about the current
site comes from its observable behavior.

## 1. What the app does today

| Need | Current unofficial call | Problem |
| --- | --- | --- |
| Sign in | Webview opens `/oauth.php?provider=GitHub` or `Google`, then reads `SCLSESSION` from `document.cookie` | Google blocks embedded webviews ("disallowed_useragent"), so the app spoofs the user agent. The cookie only works because it is not HttpOnly. Impossible from a normal browser on another origin. |
| Detect sign-out | Looks for a redirect to `login.php` or the text "Login to your account" | Breaks if wording or markup changes. |
| Submit a check-in | Multipart POST to `/supercharging/checkin.php` with the session cookie (`supercharger_id`, `date`, `user_id`, `notes_public`, `notes_private`, `log_coords_lat`, `log_coords_lon`, `log_coords_accuracy`) | Success is a 302 with no check-in id. No idempotency, so a lost response can create a duplicate on retry. |
| Delete a check-in | GET `/supercharging/misc.php?action=delete_checkin&checkin_id=N` | A state change on GET, confirmed only by guessing the redirect target. |
| Personal history | GET `/supercharging/export.php?action=user_xlsx&user_id=N`, after finding the id through `ajax.php?content=user_list_for_datatables` by display name | Spreadsheet parsing; display-name lookup is ambiguous. |
| Community Firsts | `ajax.php?content=first_checkin_history_list_for_datatables` | DataTables shape, no cursor, no CORS header. |
| One site's history | `ajax.php?content=supercharger_checkin_history_list_for_datatables&id=N` | Same. |
| Check-in counts | `ajax.php?content=supercharger_list_for_datatables` (`checkin_qty`) | Same, and returns the full site list to get one number each. |
| Admin capability | None; a diagnostic probe found no role signal (see [admin role investigation](research/Admin%20role%20investigation.md)) | No supported way to know whether the user can review check-ins. |

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

1. `login.php` and `oauth.php` accept a `return` parameter.
2. Accept only a relative path on supercharging.life that starts with
   `/oauth/authorize?`. Reject absolute URLs, `//host`, backslashes and anything
   else, to avoid an open redirect.
3. Store it in the server session before redirecting to GitHub or Google (the
   provider round trip loses query parameters), then redirect there after the
   session is established instead of the usual landing page.

## 4. Add: OAuth 2.0 authorization server

supercharging.life becomes an OAuth 2.0 authorization server for its own API,
using the authorization code grant with PKCE, as in OAuth 2.1 and the
[OAuth security BCP (RFC 9700)](https://www.rfc-editor.org/rfc/rfc9700). Only
public clients are needed, so there are no client secrets. Implicit and password
grants are not offered.

### 4.1 Client registry

A small table maintained by the site admin:

| Field | Purpose |
| --- | --- |
| `client_id` | Public identifier, for example `supercharger-bingo-web` |
| `name` | Shown on the consent screen and the connected apps page |
| `redirect_uris` | Exact strings, compared byte for byte (loopback is the one exception, below) |
| `allowed_origins` | Exact origins allowed by CORS on the token and API endpoints |
| `allowed_scopes` | Upper bound on what the client may request |
| `enabled` | Lets the admin cut off a client instantly |

Initial clients:

| Client | Redirect URI | CORS origin |
| --- | --- | --- |
| `supercharger-bingo-web` | `https://supercharger.bingo/auth/callback` | `https://supercharger.bingo` |
| `supercharger-bingo-web-dev` | `http://localhost:8787/auth/callback` | `http://localhost:8787` |
| `supercharger-bingo-mobile` | `https://supercharger.bingo/auth/app` (Android App Link and iOS Universal Link, verified by `assetlinks.json` and `apple-app-site-association` on supercharger.bingo) | none |
| `supercharger-bingo-desktop` | `http://127.0.0.1/auth/callback` on any port, per [RFC 8252 section 7.3](https://www.rfc-editor.org/rfc/rfc8252#section-7.3) | none |

Native apps open these pages in the system browser (Android Custom Tabs, iOS
`ASWebAuthenticationSession`), not a webview. That ends the Google webview block
and the user agent workaround, and lets the user's existing supercharging.life,
GitHub or Google browser session carry over.

### 4.2 `GET /oauth/authorize`

Parameters: `response_type=code`, `client_id`, `redirect_uri`, `scope`,
`state`, `code_challenge`, `code_challenge_method=S256`.

1. Unknown or disabled client, or a redirect URI not registered for it: show an
   error page. Never redirect to an unverified URI.
2. Missing `code_challenge`, a method other than `S256`, or a scope outside the
   client's allowance: redirect back with `error=invalid_request` or
   `invalid_scope` and the original `state`.
3. No valid `SCLSESSION`: redirect to `login.php?return=<this request>`
   (section 3). The user picks GitHub or Google as they do today.
4. First authorization for this user and client, or new scopes: show a consent
   page naming the client and the scopes, with Allow and Deny. Deny returns
   `error=access_denied`. The consent POST needs a CSRF token and the page
   should send `frame-ancestors 'none'` so it cannot be clickjacked.
5. Issue a code: random, at least 128 bits, single use, valid 60 seconds, stored
   with the user, client, exact redirect URI, scopes and code challenge.
6. Redirect to `redirect_uri?code=...&state=...&iss=https://supercharging.life`.
   The `iss` value follows [RFC 9207](https://www.rfc-editor.org/rfc/rfc9207).

### 4.3 `POST /oauth/token`

Form-encoded. CORS allowed for the client's registered origins.

- `grant_type=authorization_code`, `code`, `redirect_uri`, `client_id`,
  `code_verifier`. Check that the code exists, is unexpired and unused, that
  client and redirect URI match, and that `BASE64URL(SHA256(code_verifier))`
  equals the stored challenge. Mark the code used before responding. If a used
  code is presented again, revoke the tokens it produced.
- `grant_type=refresh_token`, `refresh_token`, `client_id`. Rotate on every use:
  return a new refresh token and invalidate the old one. If an already-rotated
  refresh token comes back, revoke that whole token family (reuse detection).

Success, with `Cache-Control: no-store`:

```json
{
  "access_token": "opaque random string",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "opaque random string",
  "scope": "profile checkins:read checkins:write"
}
```

Errors use the standard `{"error": "invalid_grant"}` body with HTTP 400.

Suggested lifetimes: access token 1 hour; refresh token 90 days sliding, so a
car or phone that checks in occasionally stays signed in. Store only a SHA-256
hash of each token. Opaque tokens checked against the database are simpler than
JWTs here and revoke immediately.

### 4.4 `POST /oauth/revoke`

[RFC 7009](https://www.rfc-editor.org/rfc/rfc7009) revocation for an access or
refresh token, CORS allowed for registered origins. Always returns 200. The app
calls it on sign-out.

### 4.5 Connected apps page

A section in the existing account settings listing each authorized client, its
scopes and last use, with a Revoke button. Signing out of the website does not
revoke app tokens; this page does.

### 4.6 Optional: metadata

`/.well-known/oauth-authorization-server`
([RFC 8414](https://www.rfc-editor.org/rfc/rfc8414)) listing the endpoints,
`S256` and the scopes. Lets standard OAuth libraries configure themselves.

### 4.7 Scopes

| Scope | Allows |
| --- | --- |
| `profile` | `GET /api/v1/me` |
| `checkins:read` | Reading the user's own check-ins, including private notes |
| `checkins:write` | Creating, editing and deleting the user's own check-ins |

Community reads are public and need no scope (section 5.3).

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
  - 403 `insufficient_scope` or not the owner.
  - 404 unknown or not visible. 409 idempotency conflict. 422 validation, with
    `fields`. 429 with `Retry-After`. 5xx only for server faults.
- **CORS.** Public read endpoints: `Access-Control-Allow-Origin: *`.
  Authenticated endpoints: echo the request `Origin` only if it is in a client's
  `allowed_origins`, with `Vary: Origin`. Answer `OPTIONS` preflights with
  `Access-Control-Allow-Methods: GET, POST, PATCH, DELETE`,
  `Access-Control-Allow-Headers: Authorization, Content-Type, Idempotency-Key`,
  and `Access-Control-Max-Age: 600`. Never send `Allow-Credentials`; no cookies
  are involved.
- **Cookies.** API responses must not set `SCLSESSION`. Public `ajax.php`
  currently sets a new one on every anonymous request.
- **Times.** ISO 8601 with offset, for example `2026-11-10T00:05:53-05:00`,
  plus a `precision` field of `timestamp` or `date` where a check-in may have
  only a calendar date. Today's history rows use `2026-11-10 00:05:53-05`.
- **IDs.** Integers, matching the existing check-in, user and supercharger ids.
  Supercharger ids stay the supercharge.info site ids.
- **Lists.** Cursor pagination: `?since=<cursor>&limit=<n>` returns
  `{"items": [...], "next_cursor": "..."}`. The cursor covers creates, edits and
  deletions (deleted rows come back as `{"id": N, "deleted": true}`), so the app
  can sync incrementally instead of downloading everything.
- **Rate limits.** Per token and per IP for anonymous reads. Publish the limits.
  Send `RateLimit` headers if convenient.

### 5.2 Account

`GET /api/v1/me` (scope `profile`)

```json
{
  "id": 50202,
  "display_name": "example",
  "profile_url": "https://supercharging.life/supercharging/user.php?id=50202",
  "capabilities": { "review_checkins": false }
}
```

`capabilities.review_checkins` is true only for accounts that can moderate
check-ins. The app will offer admin alerts only on an explicit `true`. This
replaces the display-name lookup through `user_list_for_datatables` and answers
the open admin-role question.

### 5.3 Community data, public

| Endpoint | Replaces | Returns per item |
| --- | --- | --- |
| `GET /api/v1/checkins?first_only=true&since=` | `first_checkin_history_list_for_datatables` | `id`, `supercharger_id`, `user_id`, `user_display_name`, `checked_in_at`, `precision`, `is_first`, `notes_public` |
| `GET /api/v1/superchargers/{id}/checkins?since=` | `supercharger_checkin_history_list_for_datatables` | Same as above |
| `GET /api/v1/superchargers/counts?since=` | `checkin_qty` from `supercharger_list_for_datatables` | `supercharger_id`, `checkin_count`, `first_checkin_at` |

`first_only=true` limits results to First check-ins. Without it the endpoint
returns all public check-ins. Private notes and coordinates never appear here.

### 5.4 The user's check-ins

`GET /api/v1/me/checkins?since=` (scope `checkins:read`) replaces the XLSX
export. Items carry the community fields plus `notes_private`, `latitude`,
`longitude`, `accuracy_m`, `created_at` and `updated_at`.

`POST /api/v1/checkins` (scope `checkins:write`) replaces the `checkin.php`
form. Requires an `Idempotency-Key` header holding a UUID the app generates once
per pending check-in.

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

- The owner comes from the token. Ignore or reject any `user_id` in the body.
- Validate the same rules the web form enforces today (site exists, date not in
  the future, note length, coordinate ranges, duplicate visit rules). Return 422
  with `fields` explaining each failure.
- Response 201 with the full stored check-in, including its `id` and the
  server's `is_first` decision.
- Store the idempotency key with the user and a hash of the body for at least
  7 days. The same key and body again returns the original check-in with 200.
  The same key with a different body returns 409.

`PATCH /api/v1/checkins/{id}` (scope `checkins:write`, owner only) updates
`notes_public` and `notes_private`. Returns the updated check-in.

`DELETE /api/v1/checkins/{id}` (scope `checkins:write`, owner only) replaces
`misc.php?action=delete_checkin`. Returns 204, or 404 if the check-in does not
exist or is not the caller's. A repeated delete of the caller's own deleted
check-in also returns 204.

## 6. Recommended hardening, independent of the app

- Make `misc.php?action=delete_checkin` require POST with a CSRF token. As a GET,
  any page the user visits can delete their check-ins with an image tag.
- After the app moves to the official API, set `SCLSESSION` with `HttpOnly` and
  `SameSite=Lax`. Today the native app reads it through `document.cookie`, so
  doing this earlier breaks the current app's sign-in.
- Stop issuing a session cookie to anonymous `ajax.php` requests.

## 7. Delivery order

Each step is useful on its own and none breaks existing users.

1. Public community reads (5.3) with CORS. Unblocks community data on the web
   release with no auth work at all.
2. Return-to support (3), authorize, token and revoke endpoints (4), and
   `GET /api/v1/me`.
3. Personal reads and writes (5.4), connected apps page (4.5).
4. Hardening (6), after the app release that uses the official API is out.

## 8. What the maintainer needs to send back

- Final URLs, field names and scope names, if different from above.
- Registered client ids and confirmation of the redirect URIs and origins.
- Token lifetimes and rate limits.
- A test account (or a staging host) where check-ins can be created and deleted.

## 9. App changes once the API exists

For reference; none of this needs work on supercharging.life.

- Add an official API `CheckinWriter` next to the `checkin.php` writer and make
  it the default. Send the pending check-in's UUID as `Idempotency-Key`.
- Replace webview cookie capture with system-browser OAuth (PKCE) on every
  platform, store the refresh token in secure storage, and handle 401 by
  refreshing once.
- Sync community Firsts, counts and personal history from the cursor endpoints
  and retire the XLSX import and display-name lookup.
- Gate admin alerts on `capabilities.review_checkins`.
- Update `docs/SPEC.md` sections 8 and 9 to match.

## 10. Acceptance checks

On the production HTTPS origin, a real Tesla browser and each native platform:

- Sign in with GitHub and with Google; `GET /api/v1/me` shows the right account.
- Create a check-in, then see it on supercharging.life with the same id.
- Simulate a lost response and retry with the same key: exactly one check-in.
- Reload and relaunch: still signed in, history intact.
- Let the access token expire: the app refreshes silently. Revoke from the
  connected apps page: the app asks the user to sign in again.
- Delete a check-in, then confirm it is gone on the site.
- Sign in on the website directly still works exactly as before.
- Local pending records survive every failure and never appear as confirmed.
