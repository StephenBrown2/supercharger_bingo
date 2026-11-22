import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { chromium, firefox } from 'playwright';

const baseURL = process.env.BINGO_BASE_URL ?? 'http://localhost:8787';

const site = id => ({
  id, locationId: `browser-${id}`, name: `Browser charger ${id}`, status: 'OPEN',
  address: { street: '1 Main', city: 'New York', state: 'NY', zip: '10001',
    countryId: 1, country: 'USA', regionId: 100, region: 'North America' },
  gps: { latitude: 40.7, longitude: -74 }, dateOpened: '2024-01-15',
  stallCount: 8, counted: true, elevationMeters: 0, powerKilowatt: 250,
  solarCanopy: false, battery: false, otherEVs: false, statusDays: 1,
  urlDiscuss: false, stalls: null, plugs: null,
});

for (const engine of [chromium, firefox]) {
test(`one location grant is reused through setup, map, and a private-tab refresh (${engine.name()})`, async () => {
  const browser = await engine.launch();
  try {
    const context = await browser.newContext({
      viewport: { width: 773, height: 601 }, hasTouch: true,
      permissions: ['geolocation'], geolocation: { latitude: 40.7, longitude: -74 },
    });
    await context.addInitScript(() => {
      window.locationRequests = 0;
      for (const name of ['getCurrentPosition', 'watchPosition']) {
        const original = navigator.geolocation[name].bind(navigator.geolocation);
        navigator.geolocation[name] = (...args) => {
          window.locationRequests++;
          return original(...args);
        };
      }
      const query = navigator.permissions.query.bind(navigator.permissions);
      navigator.permissions.query = descriptor => descriptor.name === 'geolocation'
        ? Promise.resolve({ state: 'prompt' }) : query(descriptor);
    });
    await context.route('**/service/supercharge/sites?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 1, results: [site(51)] },
    }));
    await context.route('**/service/supercharge/changes?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 0, results: [] },
    }));
    const page = await context.newPage();
    page.setDefaultTimeout(10000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('button', { name: 'Continue locally', exact: true }).click({ force: true });
    await page.getByRole('button', { name: 'Allow location', exact: true }).waitFor();
    assert.equal(await page.evaluate(() => window.locationRequests), 0);
    await page.getByRole('button', { name: 'Allow location', exact: true }).click({ force: true });
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
    const requestsAfterGrant = await page.evaluate(() => window.locationRequests);
    assert.equal(requestsAfterGrant, 1, 'granting location should start only one browser watch');
    for (const title of ['Units', 'Distances', 'Alerts', 'Theme']) {
      await page.getByRole('button', { name: 'Next', exact: true }).click({ force: true });
      await page.getByText(title, { exact: true }).waitFor();
      await page.waitForTimeout(450);
    }
    await page.getByRole('button', { name: 'Done', exact: true }).click({ force: true });
    await page.getByText('1 sites', { exact: true }).waitFor();
    await page.waitForTimeout(750);
    assert.equal(await page.evaluate(() => window.locationRequests), requestsAfterGrant,
      'passive setup and map loads must not ask for location again');
    await page.reload();
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByText('1 sites', { exact: true }).waitFor();
    await page.waitForTimeout(750);
    assert.equal(await page.evaluate(() => window.locationRequests), 0,
      'a refresh must not ask for a new private-session grant');
  } finally {
    await browser.close();
  }
});

test(`setup continues during import and map shows site pages before history finishes (${engine.name()})`, async () => {
  const browser = await engine.launch();
  let requestedUsername;
  let releaseExport;
  let releaseHistory;
  const exported = new Promise(resolve => { releaseExport = resolve; });
  const history = new Promise(resolve => { releaseHistory = resolve; });
  try {
    const context = await browser.newContext({
      viewport: { width: 773, height: 601 }, hasTouch: true,
      permissions: ['geolocation'], geolocation: { latitude: 40.7, longitude: -74 },
    });
    await context.route('**/service/supercharge/sites?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 2, results: [site(50), site(51)] },
    }));
    await context.route('**/service/supercharge/changes?*', async route => {
      await history;
      await route.fulfill({ headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 0, results: [] } });
    });
    await context.route('**/life/supercharging/ajax.php?*', route => {
      const params = new URL(route.request().url()).searchParams;
      if (params.get('content') === 'user_list_for_datatables') requestedUsername = params.get('search[value]');
      return route.fulfill({ json: { data: params.get('content') === 'user_list_for_datatables'
        ? [{ user_id: '1', displayname: 'browser-test' }] : [] } });
    });
    const book = await readFile(new URL('./fixtures/web-import.xlsx', import.meta.url));
    await context.route('**/life/supercharging/export.php?*', async route => {
      await exported;
      await route.fulfill({ contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', body: book });
    });
    const page = await context.newPage();
    page.setDefaultTimeout(10000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('textbox', { name: /username/ }).focus();
    await page.waitForTimeout(450);
    await page.getByRole('textbox', { name: /username/ }).pressSequentially('browser-test', { delay: 30 });
    assert.equal(await page.getByRole('textbox', { name: /username/ }).inputValue(), 'browser-test');
    await page.getByRole('textbox', { name: /username/ }).press('Tab');
    await page.getByRole('button', { name: 'Import visits', exact: true }).evaluate(el => el.click());
    await page.getByText('Location', { exact: true }).waitFor().catch(async error => {
      console.error(`Import entry screen (${engine.name()}): ${await page.locator('body').innerText()}`);
      console.error(`Username field: ${await page.getByRole('textbox', { name: /username/ }).inputValue()}`);
      await page.screenshot({ path: `build/web-import-entry-failure-${engine.name()}.png` });
      throw error;
    });
    const allow = page.getByRole('button', { name: 'Allow location', exact: true });
    if (await allow.count()) await allow.click({ force: true });
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
    await page.getByText('Importing visits in the background', { exact: true }).waitFor().catch(async error => {
      console.error(`Import request username: ${requestedUsername}; screen: ${await page.locator('body').innerText()}`);
      throw error;
    });
    for (const title of ['Units', 'Distances', 'Alerts', 'Theme']) {
      await page.getByRole('button', { name: 'Next', exact: true }).click({ force: true });
      await page.getByText(title, { exact: true }).waitFor();
      await page.waitForTimeout(450);
    }
    await page.getByRole('button', { name: 'Done', exact: true }).click({ force: true });
    await page.getByText('2 sites', { exact: true }).waitFor();
    await page.waitForTimeout(750);
    await page.screenshot({ path: `build/web-progressive-import-${engine.name()}.png` });
    releaseExport();
    await page.getByText('1 sites', { exact: true }).waitFor();
    await page.getByText('Importing visits in the background', { exact: true }).waitFor({ state: 'hidden' });
    releaseHistory();
  } finally {
    releaseExport();
    releaseHistory();
    await browser.close();
  }
});
}

test('import on a new browser loads sites when the first fix is slow', async () => {
  const browser = await chromium.launch();
  try {
    const context = await browser.newContext({
      viewport: { width: 773, height: 601 }, hasTouch: true,
      permissions: ['geolocation'], geolocation: { latitude: 40.7, longitude: -74 },
    });
    await context.addInitScript(() => {
      const locate = navigator.geolocation.getCurrentPosition.bind(navigator.geolocation);
      navigator.geolocation.getCurrentPosition = (success, error, options) =>
        locate(position => setTimeout(() => success(position), 3000), error, options);
      const watch = navigator.geolocation.watchPosition.bind(navigator.geolocation);
      navigator.geolocation.watchPosition = (success, error, options) =>
        watch(position => setTimeout(() => success(position), 3000), error, options);
    });
    await context.route('**/service/supercharge/sites?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' },
      json: { recordCount: 2, results: [site(50), site(51)] },
    }));
    await context.route('**/service/supercharge/changes?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 0, results: [] },
    }));
    await context.route('**/life/supercharging/ajax.php?*', route => route.fulfill({
      json: { data: new URL(route.request().url()).searchParams.get('content') === 'user_list_for_datatables'
        ? [{ user_id: '1', displayname: 'browser-test' }] : [] },
    }));
    const book = await readFile(new URL('./fixtures/web-import.xlsx', import.meta.url));
    await context.route('**/life/supercharging/export.php?*', route => route.fulfill({
      contentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', body: book,
    }));
    const page = await context.newPage();
    page.on('pageerror', error => console.error(`Slow-fix page error: ${error.message}`));
    page.setDefaultTimeout(10000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('textbox', { name: /username/ }).focus();
    await page.waitForTimeout(450);
    await page.getByRole('textbox', { name: /username/ }).pressSequentially('browser-test', { delay: 30 });
    assert.equal(await page.getByRole('textbox', { name: /username/ }).inputValue(), 'browser-test');
    await page.getByRole('textbox', { name: /username/ }).press('Tab');
    await page.getByRole('button', { name: 'Import visits', exact: true }).evaluate(el => el.click());
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor().catch(async error => {
      console.error(`Slow-fix entry screen: ${await page.locator('body').innerText()}`);
      throw error;
    });
    for (const title of ['Units', 'Distances', 'Alerts', 'Theme']) {
      await page.getByRole('button', { name: 'Next', exact: true }).click({ force: true });
      await page.getByText(title, { exact: true }).waitFor();
      await page.waitForTimeout(450);
    }
    await page.getByRole('button', { name: 'Done', exact: true }).click({ force: true });
    await page.getByText('1 sites', { exact: true }).waitFor().catch(async error => {
      console.error(`Rendered screen: ${await page.locator('body').innerText()}`);
      throw error;
    });
    await page.getByRole('button', { name: 'Center on my location', exact: true }).click({ force: true });
    await page.waitForTimeout(750);
    await page.screenshot({ path: 'build/web-import-first-load.png' });
    await page.touchscreen.tap(773 * 5 / 8, 601 - 35);
    await page.getByRole('button', { name: 'Delete check-in', exact: true }).waitFor();
    const text = await page.locator('body').evaluate(el => [el.innerText,
      ...Array.from(el.querySelectorAll('[aria-label]'), node => node.getAttribute('aria-label')),
    ].join('\n'));
    assert.match(text, /Browser charger 50/);
  } finally {
    await browser.close();
  }
});

test('setup refreshes location after returning from browser settings', async () => {
  const browser = await chromium.launch();
  try {
    const context = await browser.newContext({ geolocation: { latitude: 40.7, longitude: -74 } });
    const page = await context.newPage();
    page.setDefaultTimeout(5000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('button', { name: 'Continue locally', exact: true }).click({ force: true });
    await page.getByRole('button', { name: 'Allow location', exact: true }).waitFor();
    await page.evaluate(() => window.dispatchEvent(new Event('blur')));
    await context.grantPermissions(['geolocation']);
    await page.evaluate(() => window.dispatchEvent(new Event('focus')));
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
  } finally {
    await browser.close();
  }
});

test('setup shows existing browser notification permission without another request', async () => {
  const browser = await chromium.launch({ channel: 'chromium' });
  try {
    const context = await browser.newContext({
      permissions: ['geolocation', 'notifications'], geolocation: { latitude: 40.7, longitude: -74 },
    });
    const page = await context.newPage();
    page.setDefaultTimeout(5000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('button', { name: 'Continue locally', exact: true }).click({ force: true });
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
    for (const title of ['Units', 'Distances', 'Alerts']) {
      await page.getByRole('button', { name: 'Next', exact: true }).click({ force: true });
      await page.getByText(title, { exact: true }).waitFor();
      await page.waitForTimeout(450);
    }
    await page.getByText('Notifications allowed', { exact: true }).waitFor();
  } finally {
    await browser.close();
  }
});

test('setup keeps the granted result when the browser permission query is stale', async () => {
  const browser = await chromium.launch();
  try {
    const context = await browser.newContext({
      viewport: { width: 393, height: 760 }, hasTouch: true, colorScheme: 'dark',
      permissions: ['geolocation'], geolocation: { latitude: 40.7, longitude: -74 },
    });
    await context.addInitScript(() => {
      const query = navigator.permissions.query.bind(navigator.permissions);
      navigator.permissions.query = descriptor => descriptor.name === 'geolocation'
        ? Promise.resolve({ state: 'prompt' }) : query(descriptor);
    });
    const page = await context.newPage();
    page.setDefaultTimeout(5000);
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await page.getByRole('button', { name: 'Continue locally', exact: true }).click({ force: true });
    await page.getByRole('button', { name: 'Allow location', exact: true }).click({ force: true });
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
    assert.equal(await page.getByRole('button', { name: 'Allow location', exact: true }).count(), 0);
    await page.waitForTimeout(450);
    await page.screenshot({ path: 'build/web-permission-granted.png' });
  } finally {
    await browser.close();
  }
});
