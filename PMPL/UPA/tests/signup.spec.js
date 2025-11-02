import { test, expect } from '@playwright/test';

test.describe('Signup Form Automation Test', () => {

  // Helper untuk isi form valid
  async function fillValidForm(page) {
    await page.goto('http://127.0.0.1:8000/signup');

    // Pilih Role
    await page.selectOption('select[name="role"]', { label: 'Student' });

    // Isi data input
    const random = Date.now(); // biar unik tiap kali test
    await page.fill('input[name="username"]', `tester${random}`);
    await page.fill('input[name="email"]', `tester${random}@gmail.com`);
    await page.fill('input[name="password"]', 'StrongPass123!');
    await page.fill('input[name="password_confirmation"]', 'StrongPass123!');
    await page.fill('input[name="fullname"]', 'Automated Tester');
    await page.fill('input[name="nim"]', '2341760152');
    await page.fill('input[name="nik"]', '1234567890123456');
    await page.fill('input[name="phone_number"]', '081234567890');
    await page.fill('textarea[name="origin_address"]', 'Jl. Mawar No. 1, Malang');
    await page.fill('textarea[name="current_address"]', 'Jl. Melati No. 2, Surabaya');

    // Select dropdown
    await page.selectOption('select[name="study_program"]', { label: 'Business Information System' });
    await page.selectOption('select[name="major"]', { label: 'Information Technology' });
    await page.selectOption('select[name="campus"]', { label: 'Main' });
  }

  // ✅ TC01 - Successful signup
  test('TC01 - User can sign up successfully with valid data', async ({ page }) => {
    await fillValidForm(page);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/login/); // redirect ke login
  });

  // ❌ TC02 - Missing username
  test('TC02 - Should show error if username empty', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.fill('input[name="email"]', 'nouser@gmail.com');
    await page.fill('input[name="password"]', 'StrongPass123!');
    await page.fill('input[name="password_confirmation"]', 'StrongPass123!');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ❌ TC03 - Password mismatch
  test('TC03 - Should show error if password confirmation does not match', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.fill('input[name="password"]', 'StrongPass123!');
    await page.fill('input[name="password_confirmation"]', 'StrongPass999!');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ❌ TC04 - Weak password
  test('TC04 - Should reject weak password', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.fill('input[name="password"]', '123');
    await page.fill('input[name="password_confirmation"]', '123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ❌ TC05 - Invalid email
  test('TC05 - Should reject invalid email format', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.fill('input[name="email"]', 'invalidemail');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ❌ TC06 - Duplicate email
  test('TC06 - Should not allow duplicate email', async ({ page }) => {
    await fillValidForm(page);
    await page.fill('input[name="email"]', '2341760152@gmail.com'); // dummy existing email
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ✅ TC07 - Dropdown options validation
  test('TC07 - Should contain correct dropdown options', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');

    const roleOptions = await page.$$eval('select[name="role"] option', opts => opts.map(o => o.textContent.trim()));
    expect(roleOptions).toContain('Student');
    expect(roleOptions).toContain('Admin');
    expect(roleOptions).toContain('Educational Staff');

    const campusOptions = await page.$$eval('select[name="campus"] option', opts => opts.map(o => o.textContent.trim()));
    expect(campusOptions).toEqual(expect.arrayContaining(['Main', 'PSDKU Kediri', 'PSDKU Lumajang']));
  });

  // ✅ TC08 - Link to login works
  test('TC08 - "Already have account? Log in" link works', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.click('text=Log in');
    await expect(page).toHaveURL(/login/);
  });

  // ✅ TC09 - SQL Injection defense
  test('TC09 - Prevents SQL injection in username', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.fill('input[name="username"]', "' OR 1=1 --");
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

  // ❌ TC10 - All fields empty
  test('TC10 - Should reject submission with all fields empty', async ({ page }) => {
    await page.goto('http://127.0.0.1:8000/signup');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/signup/);
  });

});
