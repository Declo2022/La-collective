---
name: web-app-testing
description: >-
  Test web applications end-to-end by driving a real browser — navigate flows,
  interact with the UI, assert on what actually renders, and capture
  screenshots. Use when the user says "test the web app", "write an e2e/browser
  test", "check the UI works", "click through the flow", "take a screenshot", or
  wants to verify a change behaves correctly in the running app rather than only
  in unit tests.
---

# Web App Testing

Verify a web app by exercising it the way a user would: launch it, drive the
browser through real flows, and assert on rendered state — not just that code
compiles. Prefer observing behavior over trusting the diff.

## Environment note

Chromium is pre-installed and Playwright is configured to find it
(`PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers`). **Do not run
`playwright install`** — it re-downloads unnecessarily. If a project pins a
different Playwright version, launch with
`executablePath: '/opt/pw-browsers/chromium'` instead of downloading.

## Workflow

1. **Get the app running.** Find the dev/start command (`package.json` scripts,
   `README`, project `CLAUDE.md`) and launch it in the background. Wait for the
   server to be ready (poll the URL) before driving the browser — never assume
   it's up. Use the `run` skill if present.
2. **Pick the layer.** Match the tool to the goal:
   - Existing e2e suite (Playwright/Cypress) → run and extend it.
   - Ad-hoc verification of a change → drive Chromium via Playwright directly.
   - Pure logic with no DOM → a unit test is cheaper; don't spin a browser.
3. **Drive real flows.** Navigate, fill inputs, click, wait for the resulting
   state. Select by user-facing semantics (role, label, text) over brittle CSS
   or XPath.
4. **Assert on rendered reality.** Check visible text, element state, URL, and
   network results — the things a user or a stakeholder would check. Capture a
   screenshot for visual/UI changes.
5. **Report faithfully.** State what you drove and what you observed. If it
   failed, show the actual error/screenshot; only say "works" after you saw it
   work.
6. **Clean up.** Stop the dev server and any browser you launched.

## Writing resilient tests

- **Query by accessibility semantics.** `getByRole`, `getByLabel`, `getByText`
  first; fall back to `data-testid`; avoid deep CSS/XPath that breaks on
  restyle.
- **Wait for conditions, not time.** Use auto-waiting locators / explicit
  `expect(...).toBeVisible()`; never `sleep(n)` to "let it load".
- **Isolate and reset state.** Each test sets up and tears down its own data;
  don't depend on test ordering or leftover state.
- **Test behavior, not implementation.** Assert on what the user sees and can
  do, not internal component internals.
- **Cover the unhappy paths.** Empty states, validation errors, loading, and
  failure responses — not just the golden path.

## What to verify for a UI change

- The new/changed element renders and is reachable in the flow.
- Interactions produce the expected result (submit → confirmation, etc.).
- It holds at mobile and desktop viewport sizes.
- Keyboard navigation and focus work; no console errors on the page.
- Screenshot the before/after for visual changes.

## Escalate rather than fake a pass

- If the app can't start (missing env vars, secrets, external services), that's
  an environment blocker — report it, don't stub the whole world to force green.
- If a flow needs credentials or third-party state you don't have, say so.

For copy-ready Playwright setup — launch, common interactions, waiting,
screenshots, and a background-server pattern — read `references/playwright.md`.
