import assert from 'node:assert/strict';
import { test } from 'node:test';
import { chromium, firefox } from 'playwright';

const baseURL = process.env.BINGO_BASE_URL ?? 'http://localhost:8787';
const site = {
  id: 51, locationId: 'recovery', name: 'Location recovery charger', status: 'OPEN',
  address: { street: '1 Main', city: 'New York', state: 'NY', zip: '10001',
    countryId: 1, country: 'USA', regionId: 100, region: 'North America' },
  gps: { latitude: 40.7, longitude: -74 }, dateOpened: '2024-01-15',
  stallCount: 8, counted: true, elevationMeters: 0, powerKilowatt: 250,
  solarCanopy: false, battery: false, otherEVs: false, statusDays: 1,
  urlDiscuss: false, stalls: null, plugs: null,
};

async function openApp(engine) {
  const browser = await engine.launch();
  try {
    const context = await browser.newContext({ viewport: { width: 773, height: 601 }, hasTouch: true });
    await context.addInitScript(() => {
      const watches = new Map();
      window.geo = {
        requests: 0, deny: false, hold: false, nextId: 0, cleared: 0,
        position: () => ({ timestamp: Date.now(), coords: {
          latitude: 40.7, longitude: -74, accuracy: 10, altitude: null,
          altitudeAccuracy: null, heading: null, speed: null,
        } }),
        error: code => {
          for (const callbacks of watches.values()) callbacks.error({ code, message: 'Test position error' });
        },
        emit: () => {
          for (const callbacks of watches.values()) callbacks.success(window.geo.position());
        },
      };
      navigator.permissions.query = () => Promise.resolve({ state: 'prompt' });
      navigator.geolocation.getCurrentPosition = (success, error) => {
        window.geo.requests++;
        queueMicrotask(() => {
          if (window.geo.deny) error({ code: 1, message: 'Permission denied' });
          else if (!window.geo.hold) success(window.geo.position());
        });
      };
      navigator.geolocation.watchPosition = (success, error) => {
        window.geo.requests++;
        const id = ++window.geo.nextId;
        watches.set(id, { success, error });
        queueMicrotask(() => {
          if (window.geo.deny) error({ code: 1, message: 'Permission denied' });
          else if (!window.geo.hold) success(window.geo.position());
        });
        return id;
      };
      navigator.geolocation.clearWatch = id => {
        window.geo.cleared++;
        watches.delete(id);
      };
    });
    await context.route('**/service/supercharge/sites?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 1, results: [site] },
    }));
    await context.route('**/service/supercharge/changes?*', route => route.fulfill({
      headers: { 'access-control-allow-origin': '*' }, json: { recordCount: 0, results: [] },
    }));
    await context.route('**/life/supercharging/ajax.php?*', route => route.fulfill({ json: { data: [] } }));
    const page = await context.newPage();
    page.setDefaultTimeout(5000);
    await page.clock.install();
    await page.goto(baseURL);
    await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
    await click(page, 'Continue locally');
    await page.getByRole('button', { name: 'Allow location', exact: true }).waitFor();
    return { browser, page };
  } catch (error) {
    await browser.close();
    throw error;
  }
}

const click = (page, name) => page.getByRole('button', { name, exact: true }).evaluate(el => el.click());

async function finishSetup(page, allow = true) {
  if (allow) {
    await click(page, 'Allow location');
    await page.getByText('Allowed while the app is open', { exact: true }).waitFor();
  }
  for (const title of ['Units', 'Distances', 'Alerts', 'Theme']) {
    await click(page, 'Next');
    await page.getByText(title, { exact: true }).waitFor();
    await page.waitForTimeout(450);
  }
  await click(page, 'Done');
  await page.getByRole('button', { name: 'Center on my location', exact: true }).waitFor();
  await page.waitForTimeout(450);
}

async function openDrawer(page) {
  await page.touchscreen.tap(773 / 8, 601 - 35);
  await page.getByRole('button', { name: 'Close', exact: true }).waitFor();
  await page.waitForTimeout(450);
}

for (const engine of [chromium, firefox]) {
  test(`check-in reuses a quiet granted watch (${engine.name()})`, async () => {
    const { browser, page } = await openApp(engine);
    try {
      await finishSetup(page);
      await page.getByText('1 sites', { exact: true }).waitFor();
      await page.clock.fastForward(2 * 60 * 1000);
      await openDrawer(page);
      await click(page, 'Check In');
      await page.getByRole('textbox', { name: 'Private note (optional)' }).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 1);
    } finally { await browser.close(); }
  });

  for (const recovery of ['Center on my location', 'Retry']) {
    test(`${recovery} restores nearby sites after a reload (${engine.name()})`, async () => {
      const { browser, page } = await openApp(engine);
      try {
        await finishSetup(page);
        await page.getByText('1 sites', { exact: true }).waitFor();
        await page.reload();
        await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
        await page.getByText('1 sites', { exact: true }).waitFor();
        await openDrawer(page);
        await page.getByRole('button', { name: 'Retry', exact: true }).waitFor();
        await click(page, recovery);
        await page.getByRole('button', { name: 'Retry', exact: true }).waitFor({ state: 'hidden' });
        await page.getByRole('button', { name: 'Search all locations', exact: true }).waitFor();
        assert.equal(await page.evaluate(() => window.geo.requests), 1);
      } finally { await browser.close(); }
    });
  }

  test(`denying check-in location asks only once (${engine.name()})`, async () => {
    const { browser, page } = await openApp(engine);
    try {
      await finishSetup(page);
      await page.getByText('1 sites', { exact: true }).waitFor();
      await page.reload();
      await page.locator('flt-semantics-placeholder').evaluate(el => el.click());
      await page.getByText('1 sites', { exact: true }).waitFor();
      await openDrawer(page);
      await page.evaluate(() => { window.geo.deny = true; });
      await click(page, 'Check In');
      await page.getByRole('textbox', { name: 'Private note (optional)' }).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 1);
      assert.equal(await page.evaluate(() => window.geo.cleared), 1);
      await click(page, 'Cancel');
      await page.evaluate(() => { window.geo.deny = false; });
      await click(page, 'Center on my location');
      await page.getByRole('button', { name: 'Retry', exact: true }).waitFor({ state: 'hidden' });
      await page.getByRole('button', { name: 'Search all locations', exact: true }).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 2);
    } finally { await browser.close(); }
  });

  test(`a transient watch error and quiet cache do not cause a new request (${engine.name()})`, async () => {
    const { browser, page } = await openApp(engine);
    try {
      await finishSetup(page);
      await page.getByText('1 sites', { exact: true }).waitFor();
      await page.evaluate(() => window.geo.error(2));
      await page.clock.fastForward(6 * 60 * 1000);
      await click(page, 'Center on my location');
      await page.getByText(/Located: 40.7000/).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 1);
    } finally { await browser.close(); }
  });

  test(`Center downloads sites when setup skipped location (${engine.name()})`, async () => {
    const { browser, page } = await openApp(engine);
    try {
      await finishSetup(page, false);
      await click(page, 'Center on my location');
      await page.getByText('1 sites', { exact: true }).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 1);
    } finally { await browser.close(); }
  });

  test(`a late first fix loads sites without another request (${engine.name()})`, async () => {
    const { browser, page } = await openApp(engine);
    try {
      await page.evaluate(() => { window.geo.hold = true; });
      await click(page, 'Allow location');
      await page.clock.fastForward(21000);
      await page.getByText('Location not available yet', { exact: true }).waitFor();
      await finishSetup(page, false);
      await page.evaluate(() => window.geo.emit());
      await page.getByText('1 sites', { exact: true }).waitFor();
      assert.equal(await page.evaluate(() => window.geo.requests), 1);
    } finally { await browser.close(); }
  });
}
