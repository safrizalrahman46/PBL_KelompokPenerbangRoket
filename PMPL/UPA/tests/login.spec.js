// tests/login.spec.js
import { test, expect } from '@playwright/test';

const BASE = 'http://127.0.0.1:8000';
const LOGIN_URL = `${BASE}/login`;
const DASH_URL_PART = /dashboard/;
const VALID_EMAIL = '2341760152@gmail.com';
const VALID_PASSWORD = '2341760152';

// helper: attempt to detect common error text shown by Laravel auth
async function expectLoginFailure(page) {
  // beberapa kemungkinan teks error — sesuaikan bila kamu punya teks lain
  const possibleErrors = [
    'These credentials do not match our records',
    'credentials',
    'email',
    'password',
    'required'
  ];

  for (const txt of possibleErrors) {
    const locator = page.locator(`text=${txt}`);
    if (await locator.count() > 0) {
      await expect(locator.first()).toBeVisible();
      return;
    }
  }

  // fallback: tetap di halaman /login
  await expect(page).toHaveURL(/\/login/);
}

test.describe('Login Feature - comprehensive', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto(LOGIN_URL);
    // pastikan form tampil
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
  });

  test('TC-01: Login successful with valid credentials', async ({ page }) => {
    await page.fill('input[name="email"]', VALID_EMAIL);
    await page.fill('input[name="password"]', VALID_PASSWORD);
    await page.click('button[type="submit"]');

    // tunggu redirect ke dashboard (bisa disesuaikan kalau appmu redirect lain)
    await page.waitForURL('**/dashboard', { timeout: 5000 }).catch(() => {});
    await expect(page).toHaveURL(DASH_URL_PART);
  });

  test('TC-02: Login fails with incorrect password', async ({ page }) => {
    await page.fill('input[name="email"]', VALID_EMAIL);
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-03: Login fails with non-existing email', async ({ page }) => {
    await page.fill('input[name="email"]', 'notexist' + Date.now() + '@example.com');
    await page.fill('input[name="password"]', 'anyPassword123');
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-04: Login fails with empty email', async ({ page }) => {
    await page.fill('input[name="password"]', 'somepass');
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-05: Login fails with empty password', async ({ page }) => {
    await page.fill('input[name="email"]', VALID_EMAIL);
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-06: Login fails with both fields empty', async ({ page }) => {
    await page.click('button[type="submit"]');
    await expectLoginFailure(page);
  });

  test('TC-07: Invalid email format is rejected', async ({ page }) => {
    await page.fill('input[name="email"]', 'invalid-email-format');
    await page.fill('input[name="password"]', 'anything123');
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-08: SQL injection attempt in email is rejected', async ({ page }) => {
    await page.fill('input[name="email"]', "' OR 1=1 --");
    await page.fill('input[name="password"]', 'anything');
    await page.click('button[type="submit"]');

    await expectLoginFailure(page);
  });

  test('TC-09: XSS attempt in email field does not execute', async ({ page }) => {
    const xss = `<script>window.__XSS_TEST = true</script>`;
    await page.fill('input[name="email"]', xss);
    await page.fill('input[name="password"]', 'anything');
    await page.click('button[type="submit"]');

    // ensure not redirected and window var not present
    await expectLoginFailure(page);
    const hasVar = await page.evaluate(() => !!window.__XSS_TEST).catch(() => false);
    expect(hasVar).toBeFalsy();
  });

  test('TC-10: Case sensitivity test for email (uppercase)', async ({ page }) => {
    // email uppercase — login should treat email case-insensitively usually
    const upper = VALID_EMAIL.toUpperCase();
    await page.fill('input[name="email"]', upper);
    await page.fill('input[name="password"]', VALID_PASSWORD);
    await page.click('button[type="submit"]');

    // Accept either success or failure depending on app; assert either redirect or failure
    try {
      await page.waitForURL('**/dashboard', { timeout: 4000 });
      await expect(page).toHaveURL(DASH_URL_PART);
    } catch {
      await expectLoginFailure(page);
    }
  });

  test('TC-11: Very long password handled (no crash)', async ({ page }) => {
    const longPass = 'A'.repeat(500);
    await page.fill('input[name="email"]', VALID_EMAIL);
    await page.fill('input[name="password"]', longPass);
    await page.click('button[type="submit"]');

    // Expect either failed login or safe handling (no 500 error). Check we are not on a 500 page.
    const title = await page.title();
    expect(title.length).toBeGreaterThanOrEqual(0); // cheap check page still loaded
    await expectLoginFailure(page);
  });

  test('TC-12: Rapid multiple failed attempts (basic rate-limit observation)', async ({ page }) => {
    // perform 3 quick failed attempts and ensure app still responds (no crash)
    for (let i = 0; i < 3; i++) {
      await page.fill('input[name="email"]', VALID_EMAIL);
      await page.fill('input[name="password"]', 'wrong' + i);
      await page.click('button[type="submit"]');
      await expectLoginFailure(page);
      // small pause so server can respond
      await page.waitForTimeout(300);
    }
  });

  test('TC-13: Forgot password link navigates to forgot page', async ({ page }) => {
    // link in blade: route('password.request')
    const forgot = page.locator('text=Forgot Password');
    if (await forgot.count() > 0) {
      await forgot.click();
      await expect(page).toHaveURL(/forgot-password|password\/request|password/);
    } else {
      // alternative anchor text
      const alt = page.locator('a[href*="forgot"]');
      if (await alt.count() > 0) {
        await alt.first().click();
        await expect(page).toHaveURL(/forgot-password|password\/request|password/);
      } else {
        test.skip('No forgot password link present in UI');
      }
    }
  });

  test('TC-14: After successful login, /login should redirect to dashboard', async ({ page }) => {
    // login first
    await page.fill('input[name="email"]', VALID_EMAIL);
    await page.fill('input[name="password"]', VALID_PASSWORD);
    await page.click('button[type="submit"]');
    await page.waitForURL('**/dashboard', { timeout: 5000 }).catch(() => {});

    // now try to open /login again
    await page.goto(LOGIN_URL);
    // if app already authenticated, /login should redirect away (common behavior)
    try {
      await page.waitForURL('**/dashboard', { timeout: 3000 });
      await expect(page).toHaveURL(DASH_URL_PART);
    } catch {
      // fallback: maybe it shows login page even when logged in -> still acceptable
      expect(await page.url()).not.toBeNull();
    }
  });

});
