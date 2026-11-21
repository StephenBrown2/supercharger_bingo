import assert from 'node:assert/strict';
import { test } from 'node:test';
import { chromium } from 'playwright';

const baseURL = process.env.BINGO_BASE_URL ?? 'http://localhost:8787';
const profiles = [
  [773, 601, 1.53], [1254, 601, 1.53], [1183, 920, 1],
  [1920, 920, 1], [1200, 1920, 1], [1200, 800, 1],
  [1920, 1200, 1], [2200, 1300, 1], [2560, 1440, 1],
];

test('browser setup requests foreground location', async () => {
  const browser = await chromium.launch();
  try {
    const context = await browser.newContext();
    const page = await context.newPage();
    page.setDefaultTimeout(10000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('button', { name: 'Continue locally', exact: true }).click();
    await page.getByRole('button', { name: 'Allow location', exact: true }).waitFor();
    assert.match(await page.locator('body').innerText(), /while this page is open/);
  } finally {
    await browser.close();
  }
});

for (const [width, height, deviceScaleFactor] of profiles) {
  test(`local browser flows at ${width}x${height}, DPR ${deviceScaleFactor}`, async () => {
    const browser = await chromium.launch();
    let page;
    try {
      const context = await browser.newContext({
        viewport: { width, height }, deviceScaleFactor, hasTouch: true,
        geolocation: { latitude: 40.7, longitude: -74 },
        permissions: ['geolocation'],
        colorScheme: 'dark',
      });
      if (width === 773) {
        // Keep the check-in lifecycle independent of upstream data changes.
        await context.route('**/service/supercharge/sites?*', route => route.fulfill({
          headers: { 'access-control-allow-origin': '*' },
          json: { recordCount: 1, results: [{
            id: 50, locationId: 'browser-test', name: 'Browser test charger', status: 'OPEN',
            address: { street: '1 Main', city: 'New York', state: 'NY', zip: '10001',
              countryId: 1, country: 'USA', regionId: 100, region: 'North America' },
            gps: { latitude: 40.7, longitude: -74 }, dateOpened: '2024-01-15',
            stallCount: 8, counted: true, elevationMeters: 0, powerKilowatt: 250,
            solarCanopy: false, battery: false, otherEVs: false, statusDays: 1,
            urlDiscuss: false, stalls: null, plugs: null,
          }] },
        }));
        await context.route('**/service/supercharge/changes?*', route => route.fulfill({
          headers: { 'access-control-allow-origin': '*' },
          json: { recordCount: 0, results: [] },
        }));
      }
      page = await context.newPage();
      page.setDefaultTimeout(15000);
      const errors = [];
      const accountRequests = [];
      page.on('request', request => {
        if (new URL(request.url()).hostname === 'supercharging.life') accountRequests.push(request.url());
      });
      page.on('pageerror', error => errors.push(error.message));
      page.on('console', message => {
        if (/unsafe header|overflowed|unhandled exception/i.test(message.text())) {
          errors.push(message.text());
        }
      });
      await page.goto(baseURL);
      await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
      // Flutter's semantics containers overlap; send the real pointer click
      // without Playwright's DOM interception check and verify each transition.
      const click = name => page.getByRole('button', { name, exact: true }).click({ force: true });
      const accessibleText = () => page.locator('body').evaluate(el => [
        el.innerText,
        ...Array.from(el.querySelectorAll('[aria-label]'), node => node.getAttribute('aria-label')),
      ].join('\n'));
      assert.equal(await page.getByRole('button', { name: /Login with/ }).count(), 0);
      await click('Continue locally');
      await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
      for (const title of ['Units', 'Distances', 'Alerts', 'Theme']) {
        await click('Next');
        await page.getByText(title, { exact: true }).waitFor();
        await page.waitForTimeout(450);
      }
      await click('Done');
      await page.getByText('Settings', { exact: true }).waitFor();
      // NavigationDestination labels are painted on canvas in material_ui.
      await page.touchscreen.tap(width * 5 / 8, height - 35);
      await page.getByText('No visits yet', { exact: true }).waitFor();
      await page.touchscreen.tap(width * 7 / 8, height - 35);
      await page.getByText('Distance Units').waitFor();
      await page.reload();
      await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
      await page.getByRole('button', { name: /Charger type/ }).waitFor();
      if (width === 773) {
        await page.getByText('1 sites', { exact: true }).waitFor();
        await page.touchscreen.tap(width / 8, height - 35);
        await page.getByRole('button', { name: 'Check In', exact: true }).waitFor();
        await page.waitForTimeout(450);
        await page.getByRole('button', { name: 'Check In', exact: true }).evaluate(el => el.click());
        await page.getByRole('textbox', { name: 'Private note (optional)' }).waitFor();
        await page.getByRole('button', { name: 'Check In', exact: true }).last().evaluate(el => el.click());
        await page.getByRole('textbox', { name: 'Private note (optional)' }).waitFor({ state: 'hidden' });
        await page.getByRole('button', { name: 'Close', exact: true }).waitFor({ state: 'hidden' });
        await page.waitForTimeout(450);
        await page.touchscreen.tap(width * 5 / 8, height - 35);
        await page.getByRole('button', { name: 'Discard check-in', exact: true }).waitFor();
        assert.match(await accessibleText(), /Pending/);
        await page.reload();
        await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
        await page.getByRole('button', { name: /Charger type/ }).waitFor();
        await page.touchscreen.tap(width * 5 / 8, height - 35);
        await page.getByRole('button', { name: 'Discard check-in', exact: true }).waitFor();
        assert.match(await accessibleText(), /Pending/);
        await click('Discard check-in');
        await click('Discard');
        await page.getByText('No visits yet', { exact: true }).waitFor();
      }
      console.log(`${width}x${height}: setup, visits, settings and reload passed`);
      assert.deepEqual(errors, []);
      assert.deepEqual(accountRequests, []);
    } catch (error) {
      console.error(page?.url(), await page?.locator('body').innerText({ timeout: 1000 }).catch(error => error.message));
      await page?.screenshot({ path: 'build/web-smoke-failure.png', timeout: 1000 }).catch(() => {});
      throw error;
    } finally {
      await browser.close();
    }
  });
}

test('release assets include the local SQLite runtime', async () => {
  for (const [file, type] of [
    ['sqlite3.wasm', 'application/wasm'],
    ['drift_worker.js', 'javascript'],
    ['flutter_bootstrap.js', 'javascript'],
  ]) {
    const response = await fetch(`${baseURL}/${file}`);
    assert.equal(response.status, 200, file);
    assert.ok(response.headers.get('content-type')?.includes(type), file);
  }
});

test('the import proxy only forwards the two public reads', async () => {
  for (const path of [
    '/life/supercharging/checkin.php',
    '/life/supercharging/ajax.php?content=checkin_list_for_datatables',
    '/life/supercharging/export.php?action=other',
  ]) {
    assert.equal((await fetch(`${baseURL}${path}`)).status, 404, path);
  }
});
