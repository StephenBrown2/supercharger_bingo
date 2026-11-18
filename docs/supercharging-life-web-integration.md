# Integration request for the supercharging.life maintainer

We want Supercharger Bingo at `https://supercharger.bingo` to let Tesla browser
users sign in with their existing supercharging.life account and submit check-ins.

## Observed constraints, 2026-11-18

- GitHub authorization at `/oauth.php?provider=GitHub` uses
  `https://supercharging.life/oauth.php` as its OAuth redirect URI.
- `SCLSESSION` belongs to `.supercharging.life`. A page on supercharger.bingo
  cannot read it, including through an iframe or popup.
- Public history/count responses at `/supercharging/ajax.php` omit
  `Access-Control-Allow-Origin`. Chromium rejects the app's direct requests.
- The native app inspects the webview session and posts the unofficial
  `/supercharging/checkin.php` form. A normal browser cannot use that approach.

## Proposed supported integration, to agree before implementation

Keep provider login on supercharging.life. Register Supercharger Bingo as a
client with an exact allowed callback, `https://supercharger.bingo/auth/callback`.
After login, return a short-lived, single-use authorization code and the original
state to that callback. Bind the code to the client, callback and a PKCE S256
challenge. Exchange it using the verifier for a scoped API credential. Never put
the session cookie or an access token into a URL. Reject reused or expired codes,
incorrect verifiers, state mismatches and unregistered redirect URIs.

Provide documented endpoints for:

- Code exchange, account identity, credential expiry and logout/revocation.
- Reading community history/counts and the signed-in user's visits.
- Creating a check-in, returning its canonical ID and accepted contents.
- Deleting an owned check-in with an explicit confirmed result.

Allow the production origin through CORS, including preflight for required
methods and authorization headers. Agree on a separate development client/origin.
Enforce ownership, input validation and scopes on the server. Return an explicit
unauthorized response for expired credentials, and accept an idempotency key for
creation so a dropped connection cannot create duplicate visits on retry.

These are proposed capabilities, not existing endpoint names. Please confirm the
URLs, request/response schemas, scopes, credential lifetime, rate limits, client
registration and testing account. A secure same-origin backend with an agreed
one-time session exchange is an alternative if browser API credentials are not
supported; a generic CORS proxy cannot solve the login handoff.

## Acceptance checks

On the production HTTPS origin and a real Tesla: complete GitHub/Google login,
verify account identity, create a check-in and confirm it on supercharging.life,
reload and confirm persistence, test expiry/relogin/logout, and retry a simulated
lost response without duplicating the check-in. Local pending records must remain
intact on failure and must never be presented as confirmed remote submissions.
