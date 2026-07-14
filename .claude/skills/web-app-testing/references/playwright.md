# Playwright Reference

Copy-ready snippets for driving a web app. Adapt selectors and URLs to the app.
Remember: **do not run `playwright install`** in this environment — Chromium is
already at `/opt/pw-browsers`.

## Ad-hoc verification script (Node)

```js
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch(); // headless by default
  const page = await browser.newPage();

  await page.goto('http://localhost:3000');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secret');
  await page.getByRole('button', { name: 'Continue' }).click();

  // assert on rendered reality
  await page.waitForURL('**/dashboard');
  const heading = await page.getByRole('heading', { level: 1 }).textContent();
  console.log('Heading:', heading);

  await page.screenshot({ path: 'dashboard.png', fullPage: true });
  await browser.close();
})().catch((e) => { console.error(e); process.exit(1); });
```

If the project pins a Playwright version, launch with an explicit path:

```js
const browser = await chromium.launch({
  executablePath: '/opt/pw-browsers/chromium',
});
```

## Playwright Test (@playwright/test)

```ts
import { test, expect } from '@playwright/test';

test('user can submit the contact form', async ({ page }) => {
  await page.goto('/contact');
  await page.getByLabel('Name').fill('Ada');
  await page.getByLabel('Message').fill('Hello');
  await page.getByRole('button', { name: 'Send' }).click();

  await expect(page.getByText('Thanks, we’ll be in touch')).toBeVisible();
});

test('shows a validation error on empty submit', async ({ page }) => {
  await page.goto('/contact');
  await page.getByRole('button', { name: 'Send' }).click();
  await expect(page.getByText('Name is required')).toBeVisible();
});
```

## Common interactions

```js
await page.getByRole('link', { name: 'Docs' }).click();
await page.getByRole('checkbox', { name: 'Remember me' }).check();
await page.getByRole('combobox', { name: 'Country' }).selectOption('FR');
await page.getByPlaceholder('Search').fill('shoes');
await page.getByRole('button', { name: 'Add to cart' }).click();
await page.keyboard.press('Enter');
```

## Waiting for conditions (never sleep)

```js
await expect(page.getByRole('alert')).toBeVisible();     // auto-retries
await page.waitForURL('**/checkout');
await page.getByText('Loading').waitFor({ state: 'hidden' });
await page.waitForResponse((r) => r.url().includes('/api/cart') && r.ok());
```

## Responsive check

```js
await page.setViewportSize({ width: 375, height: 812 }); // mobile
await page.screenshot({ path: 'mobile.png' });
await page.setViewportSize({ width: 1280, height: 800 }); // desktop
```

## Catch console/page errors

```js
page.on('console', (m) => m.type() === 'error' && console.log('console:', m.text()));
page.on('pageerror', (e) => console.log('pageerror:', e.message));
```

## Background dev server pattern (bash)

Launch the server, wait until it answers, run the test, then stop it:

```bash
npm run dev &          # or the project's start command
SERVER_PID=$!
# wait for readiness (up to ~30s)
for i in $(seq 1 30); do
  curl -sf http://localhost:3000 >/dev/null && break
  sleep 1
done
node verify.js
kill $SERVER_PID
```

Prefer the harness's background-run mechanism over a raw `&` when available so
the process is tracked and cleaned up.
