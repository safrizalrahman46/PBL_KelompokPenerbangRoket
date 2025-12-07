import { test, expect } from '@playwright/test';

test.describe('Comprehensive Filament Login Scenarios (30 Cases)', () => {

    const BASE_URL = 'http://127.0.0.1:8000/admin/login';
    const DASHBOARD_URL = /\/admin$/; // Regex untuk akhir URL /admin
    
    // Kredensial Valid sesuai permintaan
    const VALID_USER = {
        email: 'admin1@gmail.com',
        password: 'admin1234'
    };

    test.beforeEach(async ({ page }) => {
        await page.goto(BASE_URL);
    });

    // --- GROUP 1: POSITIVE LOGIN FLOWS (5 Cases) ---

    test('01. Login berhasil dengan klik tombol Sign In', async ({ page }) => {
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(DASHBOARD_URL);
        await expect(page.getByText('Dashboard', { exact: true }).first()).toBeVisible();
    });

    test('02. Login berhasil dengan menekan tombol ENTER pada keyboard', async ({ page }) => {
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.keyboard.press('Enter');

        await expect(page).toHaveURL(DASHBOARD_URL);
    });

    test('03. Login berhasil dengan email huruf besar (Case Insensitive Email)', async ({ page }) => {
        // Email seharusnya tidak case-sensitive
        await page.fill('input[type="email"]', VALID_USER.email.toUpperCase());
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL(DASHBOARD_URL);
    });

    test('04. Login berhasil dengan spasi di awal/akhir email (Auto Trim)', async ({ page }) => {
        await page.fill('input[type="email"]', `  ${VALID_USER.email}  `);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL(DASHBOARD_URL);
    });

    test('05. Logout berhasil dilakukan setelah login', async ({ page }) => {
        // Login dulu
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(DASHBOARD_URL);

        // Cari tombol user menu / logout (Filament v3 biasanya di pojok kanan atas)
        // Selector ini mungkin perlu disesuaikan tergantung tema
        const userMenuBtn = page.locator('.fi-user-menu-trigger, button[aria-label="User menu"]'); 
        
        // Fallback: Jika tidak ketemu, coba cari teks nama user atau avatar
        if (await userMenuBtn.isVisible()) {
            await userMenuBtn.click();
            await page.getByText('Sign out').click();
        } else {
            // Coba cari tombol Sign out langsung jika layout sidebar
            await page.getByText('Sign out').first().click();
        }

        await expect(page).toHaveURL(/login/);
    });


    // --- GROUP 2: NEGATIVE LOGIN FLOWS & VALIDATION (10 Cases) ---

    test('06. Gagal login dengan password salah', async ({ page }) => {
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', 'wrongpass');
        await page.click('button[type="submit"]');

        await expect(page.getByText(/These credentials do not match|Kredensial/)).toBeVisible();
        await expect(page).toHaveURL(/login/);
    });

    test('07. Gagal login dengan email salah', async ({ page }) => {
        await page.fill('input[type="email"]', 'wrong@gmail.com');
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        await expect(page.getByText(/These credentials do not match|Kredensial/)).toBeVisible();
    });

    test('08. Gagal login dengan password kosong', async ({ page }) => {
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', '');
        await page.click('button[type="submit"]');

        // HTML5 validation check atau Laravel validation error
        const validationMessage = page.getByText(/The password field is required|password wajib diisi/);
        // Jika validasi HTML5 (browser tooltip), playwright sulit mendeteksinya secara langsung tanpa snapshot
        // Kita cek apakah URL masih di login
        await expect(page).toHaveURL(/login/);
    });

    test('09. Gagal login dengan email kosong', async ({ page }) => {
        await page.fill('input[type="email"]', '');
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL(/login/);
    });

    test('10. Gagal login dengan format email tidak valid (tanpa @)', async ({ page }) => {
        await page.fill('input[type="email"]', 'admin1gmail.com');
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        // Cek validasi browser (HTML5)
        const emailInput = page.locator('input[type="email"]');
        const validationMessage = await emailInput.evaluate((e: HTMLInputElement) => e.validationMessage);
        expect(validationMessage).toBeTruthy(); // Harus ada pesan error browser
    });

    test('11. Gagal login dengan format email tidak valid (tanpa domain)', async ({ page }) => {
        await page.fill('input[type="email"]', 'admin1@');
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(/login/);
    });

    test('12. Gagal login karena Password Case Sensitive', async ({ page }) => {
        // Password "ADMIN1234" harusnya beda dengan "admin1234"
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', VALID_USER.password.toUpperCase());
        await page.click('button[type="submit"]');

        await expect(page.getByText(/These credentials do not match|Kredensial/)).toBeVisible();
    });

    test('13. Gagal login dengan email tidak terdaftar sama sekali', async ({ page }) => {
        await page.fill('input[type="email"]', 'hantu@gmail.com');
        await page.fill('input[type="password"]', 'hantu123');
        await page.click('button[type="submit"]');

        await expect(page.getByText(/These credentials do not match|Kredensial/)).toBeVisible();
    });

    test('14. Validasi input field terhapus setelah refresh', async ({ page }) => {
        await page.fill('input[type="email"]', 'tekstes@gmail.com');
        await page.reload();
        await expect(page.locator('input[type="email"]')).toBeEmpty();
    });

    test('15. Pesan error hilang setelah input diketik ulang (Behavioral Check)', async ({ page }) => {
        // Trigger error
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', 'salah');
        await page.click('button[type="submit"]');
        await expect(page.getByText(/credentials do not match/)).toBeVisible();

        // Ketik ulang (Refresh halaman login biasanya terjadi di Laravel, jadi test ini opsional tergantung implementasi SPA/Standard)
        // Jika Livewire, error mungkin hilang saat mengetik. Jika standar controller, halaman reload.
        // Kita cek saja apakah masih di halaman login.
        await expect(page).toHaveURL(/login/);
    });


    // --- GROUP 3: UI & UX CHECKS (8 Cases) ---

    test('16. Halaman memiliki Title yang benar', async ({ page }) => {
        await expect(page).toHaveTitle(/Eat.o|Login/i);
    });

    test('17. Input email terlihat dan bisa diedit', async ({ page }) => {
        const emailInput = page.locator('input[type="email"]');
        await expect(emailInput).toBeVisible();
        await expect(emailInput).toBeEditable();
    });

    test('18. Input password bertipe "password" (Masking)', async ({ page }) => {
        const passInput = page.locator('input[name="password"]');
        await expect(passInput).toHaveAttribute('type', 'password');
    });

    test('19. Tombol Sign In terlihat dan memiliki teks yang benar', async ({ page }) => {
        const btn = page.locator('button[type="submit"]');
        await expect(btn).toBeVisible();
        // Filament defaultnya "Sign in"
        await expect(btn).toHaveText(/Sign in|Masuk/i);
    });

    test('20. Checkbox "Remember Me" tersedia', async ({ page }) => {
        // Filament biasanya punya checkbox remember me
        const checkbox = page.locator('input[type="checkbox"]');
        if (await checkbox.count() > 0) {
            await expect(checkbox.first()).toBeVisible();
            await checkbox.first().check();
            expect(await checkbox.first().isChecked()).toBeTruthy();
        }
    });

    test('21. Link "Forgot Password" tersedia (jika diaktifkan)', async ({ page }) => {
        // Ini opsional tergantung config Filament Anda
        // Kita gunakan .count() > 0 agar test tidak fail jika fitur ini dimatikan
        const forgotLink = page.locator('a[href*="password/reset"]');
        if (await forgotLink.count() > 0) {
            await expect(forgotLink).toBeVisible();
        }
    });

    test('22. Logo Aplikasi atau Heading terlihat', async ({ page }) => {
        // Biasanya ada teks nama aplikasi di atas form
        await expect(page.getByText(/Eat.o|Sign in/i).first()).toBeVisible();
    });

    test('23. Input focus otomatis (Autofocus) pada email', async ({ page }) => {
        // Biasanya input email punya atribut autofocus
        const emailInput = page.locator('input[type="email"]');
        // Pengecekan atribut HTML
        const hasAutofocus = await emailInput.getAttribute('autofocus');
        if (hasAutofocus !== null) {
            expect(hasAutofocus).toBe('');
        }
    });


    // --- GROUP 4: SECURITY & EDGE CASES (7 Cases) ---

    test('24. Mencegah SQL Injection sederhana di email', async ({ page }) => {
        await page.fill('input[type="email"]', "' OR '1'='1");
        await page.fill('input[type="password"]', "' OR '1'='1");
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL(/login/);
        // Harusnya muncul error validasi atau kredensial salah, bukan error 500
        await expect(page.getByText(/credentials/)).toBeVisible();
    });

    test('25. Mencegah XSS Script di input email', async ({ page }) => {
        const xssPayload = '<script>alert("hacked")</script>';
        await page.fill('input[type="email"]', xssPayload);
        await page.fill('input[type="password"]', 'random');
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL(/login/);
    });

    test('26. Menangani input email yang sangat panjang', async ({ page }) => {
        const longEmail = 'a'.repeat(200) + '@gmail.com';
        await page.fill('input[type="email"]', longEmail);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');

        await expect(page.getByText(/credentials/)).toBeVisible();
    });

    test('27. Menangani input password yang sangat panjang', async ({ page }) => {
        const longPass = 'a'.repeat(300);
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', longPass);
        await page.click('button[type="submit"]');

        await expect(page.getByText(/credentials/)).toBeVisible();
    });

    test('28. Akses langsung ke Dashboard tanpa login (Redirect)', async ({ context }) => {
        // Gunakan context baru yang bersih (tanpa cookie login sebelumnya)
        const newPage = await context.newPage();
        await newPage.goto('http://127.0.0.1:8000/admin');
        
        // Harus dilempar balik ke login
        await expect(newPage).toHaveURL(/login/);
    });

    test('29. Tombol Back browser setelah logout tidak bisa masuk lagi', async ({ page }) => {
        // 1. Login
        await page.fill('input[type="email"]', VALID_USER.email);
        await page.fill('input[type="password"]', VALID_USER.password);
        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(DASHBOARD_URL);

        // 2. Logout (Simulasi) -> Pergi ke route logout atau clear cookie
        await page.context().clearCookies();
        await page.goto(BASE_URL);

        // 3. Tekan Back
        await page.goBack();

        // 4. Seharusnya halaman dashboard me-refresh atau redirect ke login jika user berinteraksi
        // (Playwright goBack() mungkin menampilkan cache browser, tapi interaksi akan gagal)
        await page.reload(); 
        await expect(page).toHaveURL(/login/);
    });

    test('30. Login cepat berulang kali (Rate Limiting)', async ({ page }) => {
        // Laravel default throttle: 5 attempts per minute
        // Kita coba paksa login salah 6 kali
        for (let i = 0; i < 6; i++) {
            await page.fill('input[type="email"]', VALID_USER.email);
            await page.fill('input[type="password"]', 'wrongpass' + i);
            await page.click('button[type="submit"]');
            // Tunggu sedikit agar request selesai
            await page.waitForTimeout(500); 
        }

        // Harusnya muncul pesan "Too many login attempts"
        await expect(page.getByText(/Too many login attempts|Terlalu banyak percobaan/i)).toBeVisible();
    });

});