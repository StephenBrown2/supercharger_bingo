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
    await page.getByRole('button', { name: 'Skip for now', exact: true }).click();
    await page.getByRole('button', { name: 'Allow location', exact: true }).waitFor();
    assert.match(await page.locator('body').innerText(), /while this page is open/);
  } finally {
    await browser.close();
  }
});

for (const [width, height, deviceScaleFactor] of profiles) {
  test(`local browser flows at ${width}x${height}, DPR ${deviceScaleFactor}`, async () => {
    const browser = await chromium.launch();
    try {
      const context = await browser.newContext({
        viewport: { width, height }, deviceScaleFactor, hasTouch: true,
        geolocation: { latitude: 40.7, longitude: -74 },
        permissions: ['geolocation'],
        colorScheme: 'dark',
      });
      const page = await context.newPage();
      page.setDefaultTimeout(15000);
      const errors = [];
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
      await click('Skip for now');
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
      console.log(`${width}x${height}: setup, visits, settings and reload passed`);
      assert.deepEqual(errors, []);
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
