# Web deployment

## Release status

The current release uses local browser storage without real login. Visits remain
pending and are not sent to supercharging.life. Account and community history sync
are unavailable. Clearing browser data removes saved visits. Live authentication
is deferred; see [the future integration request](supercharging-life-api.md).
Completed checks and remaining coverage are recorded in the
[verification report](web-verification-2026-11-18.md).

## Build and test

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
npm ci
npx playwright install chromium --only-shell
npx wrangler dev
```

In a second terminal, run `npm run test:web`. The default URL is
`http://localhost:8787`; `BINGO_BASE_URL` can select a deployed staging URL.
The checks exercise the actual release build and SQLite assets. The viewport
matrix and manual verification requirements are in [AGENTS.md](../AGENTS.md).
Headless Chromium does not prove compatibility with Tesla hardware or firmware.

Use the JavaScript build with rendering resources bundled locally. Both `web/sqlite3.wasm` and
`web/drift_worker.js` must ship beside the Flutter bootstrap files. Do not enable
cross-origin isolation headers without retesting external map resources and login.
The database has browser storage fallbacks and must be checked on the real car.
Browser data belongs to its origin, so staging data will not migrate automatically
to supercharger.bingo. Clearing browser data removes local visits and settings.

## Cloudflare

`wrangler.jsonc` serves `build/web` as static assets with SPA route fallback.
No Worker script or paid server is required for the frontend. `_headers` avoids
long caching of entry points so a reload can pick up a new app version.

Validate the upload without publishing:

```sh
npx wrangler deploy --dry-run --outdir /tmp/supercharger-bingo-worker
```

After all release gates pass, deploy with `npx wrangler deploy` (log in with
`npx wrangler login` or set `CLOUDFLARE_API_TOKEN`). The Worker is `app`, served
at `https://supercharger.bingo`, `https://www.supercharger.bingo` and
`https://app.supercharger-bingo.workers.dev`. Porkbun stays the registrar; the
DNS zone moved to Cloudflare on 2026-11-21 with Porkbun's parking records
removed. Both hostnames are Worker custom domains, so Cloudflare manages their
DNS records and HTTPS. Check the real HTTPS origin for location permissions,
local check-in, deletion and reload persistence.

Static asset requests and storage are currently free. Any later authentication
Worker or proxy has separate request limits. Check [Cloudflare's billing docs](https://developers.cloudflare.com/workers/static-assets/billing-and-limitations/)
before enabling backend services. [Custom domain docs](https://developers.cloudflare.com/workers/configuration/routing/custom-domains/).
