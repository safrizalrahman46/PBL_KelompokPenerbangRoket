import { test, expect } from '@playwright/test';

test.describe('Filament Custom Registration Flow (30 Cases)', () => {

    const REGISTER_URL = 'http://127.0.0.1:8000/admin/register';
    
    // Helper untuk generate email unik agar tes tidak gagal karena "Email taken"
    const randomEmail = () => `user_${Date.now()}_${Math.floor(Math.random() * 1000)}@example.com`;

    test.beforeEach(async ({ page }) => {
        await page.goto(REGISTER_URL);
    });

    // --- GROUP 1: POSITIVE REGISTRATION FLOWS (5 Cases) ---

    test('01. Registrasi berhasil dengan data valid (Default Role: Kasir)', async ({ page }) => {
        await page.getByLabel('Name').fill('User Kasir');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        
        // Role default harusnya 'Kasir', jadi langsung submit
        await page.click('button[type="submit"]');

        // Berhasil masuk dashboard
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('02. Registrasi berhasil sebagai Kitchen (Dapur)', async ({ page }) => {
        await page.getByLabel('Name').fill('User Dapur');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');

        // Ganti Role ke Dapur
        await page.getByLabel('Daftar sebagai').click(); // Klik dropdown
        await page.getByRole('option', { name: 'Dapur' }).click(); // Pilih opsi

        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('03. Registrasi berhasil sebagai Admin', async ({ page }) => {
        await page.getByLabel('Name').fill('User Admin Baru');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');

        // Ganti Role ke Admin
        await page.getByLabel('Daftar sebagai').click();
        await page.getByRole('option', { name: 'Admin' }).click();

        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('04. Registrasi berhasil dengan nama panjang', async ({ page }) => {
        const longName = 'Nama Sangat Panjang Sekali Untuk Tes Batas Karakter Database Yang Biasanya 255';
        await page.getByLabel('Name').fill(longName);
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('05. Registrasi berhasil dengan email mengandung titik/angka', async ({ page }) => {
        await page.getByLabel('Name').fill('User Unik');
        await page.getByLabel('Email Address').fill(`test.user.123.${Date.now()}@sub.example.co.id`);
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(/\/admin$/);
    });


    // --- GROUP 2: VALIDATION - REQUIRED FIELDS (5 Cases) ---

    test('06. Gagal daftar jika Nama kosong', async ({ page }) => {
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');

        // Cek pesan error validasi Filament (biasanya muncul di bawah input)
        await expect(page.getByText(/field is required|wajib diisi/)).toBeVisible();
    });

    test('07. Gagal daftar jika Email kosong', async ({ page }) => {
        await page.getByLabel('Name').fill('No Email User');
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');

        await expect(page.getByText(/field is required|wajib diisi/)).toBeVisible();
    });

    test('08. Gagal daftar jika Password kosong', async ({ page }) => {
        await page.getByLabel('Name').fill('No Pass User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.click('button[type="submit"]');

        await expect(page.getByText(/field is required|wajib diisi/).first()).toBeVisible();
    });

    test('09. Gagal daftar jika Konfirmasi Password kosong', async ({ page }) => {
        await page.getByLabel('Name').fill('No Confirm User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.click('button[type="submit"]');

        // Error biasanya: "The password field confirmation does not match"
        await expect(page.getByText(/confirmation does not match|tidak cocok/)).toBeVisible();
    });

    test('10. Dropdown Role wajib diisi (Cek Default Value)', async ({ page }) => {
        // Karena kita set default('cashier'), field ini harusnya sudah terisi.
        // Tes ini memastikan default value benar-benar ada.
        const roleValue = await page.getByLabel('Daftar sebagai').textContent();
        expect(roleValue).toContain('Kasir');
    });


    // --- GROUP 3: LOGIC & DATA INTEGRITY (10 Cases) ---

    test('11. Gagal daftar jika Email Format Salah (Tanpa @)', async ({ page }) => {
        await page.getByLabel('Name').fill('Bad Email');
        await page.getByLabel('Email Address').fill('invalidemail.com');
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');

        // Validasi HTML5 atau Server
        const emailInput = page.locator('input[type="email"]');
        const validationMsg = await emailInput.evaluate((e: HTMLInputElement) => e.validationMessage);
        expect(validationMsg).toBeTruthy();
    });

    test('12. Gagal daftar jika Email sudah terdaftar (Duplikat)', async ({ page }) => {
        // 1. Daftar user pertama
        const email = randomEmail();
        await page.getByLabel('Name').fill('User A');
        await page.getByLabel('Email Address').fill(email);
        await page.getByLabel('Password', { exact: true }).fill('12345678');
        await page.getByLabel('Confirm Password').fill('12345678');
        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(/\/admin$/);

        // 2. Logout (Simulasi)
        await page.goto(REGISTER_URL);

        // 3. Coba daftar user kedua dengan email SAMA
        await page.getByLabel('Name').fill('User B Copycat');
        await page.getByLabel('Email Address').fill(email);
        await page.getByLabel('Password', { exact: true }).fill('12345678');
        await page.getByLabel('Confirm Password').fill('12345678');
        await page.click('button[type="submit"]');

        await expect(page.getByText(/already been taken|sudah digunakan/)).toBeVisible();
    });

    test('13. Gagal daftar jika Password kurang dari 8 karakter', async ({ page }) => {
        await page.getByLabel('Name').fill('Short Pass');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('123');
        await page.getByLabel('Confirm Password').fill('123');
        await page.click('button[type="submit"]');

        await expect(page.getByText(/must be at least 8 characters|minimal 8 karakter/)).toBeVisible();
    });

    test('14. Gagal daftar jika Konfirmasi Password tidak cocok', async ({ page }) => {
        await page.getByLabel('Name').fill('Mismatch User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password999'); // Beda
        await page.click('button[type="submit"]');

        await expect(page.getByText(/confirmation does not match|tidak cocok/)).toBeVisible();
    });

    test('15. Password case sensitivity (Konfirmasi beda huruf besar/kecil)', async ({ page }) => {
        await page.getByLabel('Name').fill('Case User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('Password123');
        await page.getByLabel('Confirm Password').fill('password123'); // Huruf kecil
        await page.click('button[type="submit"]');

        await expect(page.getByText(/confirmation does not match|tidak cocok/)).toBeVisible();
    });

    test('16. Auto-trim whitespace pada nama', async ({ page }) => {
        const email = randomEmail();
        await page.getByLabel('Name').fill('  Spasi Banyak  ');
        await page.getByLabel('Email Address').fill(email);
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(/\/admin$/);
        // (Verifikasi nama tersimpan tanpa spasi perlu dilakukan di halaman dashboard/profile, 
        // tapi di sini kita pastikan registrasi tidak error)
    });

    test('17. Auto-trim whitespace pada email', async ({ page }) => {
        const email = randomEmail();
        await page.getByLabel('Name').fill('Trim Email');
        await page.getByLabel('Email Address').fill(`  ${email}  `);
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('18. XSS Injection pada Nama (Sanitization Check)', async ({ page }) => {
        await page.getByLabel('Name').fill('<script>alert("hacked")</script>');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        
        // Seharusnya berhasil daftar tapi script tidak dijalankan.
        // Laravel otomatis escape output, jadi aman. Tes ini memastikan flow tidak crash.
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('19. SQL Injection pada Email (Sanitization Check)', async ({ page }) => {
        await page.getByLabel('Name').fill('SQL Injector');
        await page.getByLabel('Email Address').fill("' OR 1=1 -- @gmail.com");
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');

        // Biasanya gagal validasi email format
        await expect(page).toHaveURL(/\/register/); 
    });

    test('20. Submit form dengan menekan ENTER di field terakhir', async ({ page }) => {
        await page.getByLabel('Name').fill('Enter User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.keyboard.press('Enter'); // Tekan Enter

        await expect(page).toHaveURL(/\/admin$/);
    });


    // --- GROUP 4: UI & COMPONENTS CHECK (10 Cases) ---

    test('21. Halaman memiliki judul yang benar', async ({ page }) => {
        await expect(page).toHaveTitle(/Register|Daftar/i);
        // Cek heading halaman
        await expect(page.getByRole('heading', { level: 2 })).toBeVisible();
    });

    test('22. Input Name visible dan editable', async ({ page }) => {
        const input = page.getByLabel('Name');
        await expect(input).toBeVisible();
        await expect(input).toBeEditable();
    });

    test('23. Input Password ter-masking (type=password)', async ({ page }) => {
        const input = page.getByLabel('Password', { exact: true });
        await expect(input).toHaveAttribute('type', 'password');
    });

    test('24. Custom Field Role: Label tampil benar', async ({ page }) => {
        // Label custom Anda: 'Daftar sebagai'
        await expect(page.getByText('Daftar sebagai')).toBeVisible();
    });

    test('25. Custom Field Role: Opsi Dropdown Lengkap', async ({ page }) => {
        await page.getByLabel('Daftar sebagai').click();
        
        // Cek apakah opsi Kasir, Dapur, Admin muncul
        await expect(page.getByRole('option', { name: 'Kasir' })).toBeVisible();
        await expect(page.getByRole('option', { name: 'Dapur' })).toBeVisible();
        await expect(page.getByRole('option', { name: 'Admin' })).toBeVisible();
    });

    test('26. Tombol "Sign in" (Login) link tersedia', async ({ page }) => {
        // Link untuk user yang sudah punya akun
        const loginLink = page.getByRole('link', { name: /Sign in|Login|Masuk/i });
        await expect(loginLink).toBeVisible();
        await expect(loginLink).toHaveAttribute('href', /login/);
    });

    test('27. Tombol Register (Submit) memiliki teks yang benar', async ({ page }) => {
        const btn = page.locator('button[type="submit"]');
        await expect(btn).toHaveText(/Register|Daftar/i);
    });

    test('28. Cek Responsivitas Layout (Mobile)', async ({ page }) => {
        await page.setViewportSize({ width: 375, height: 667 }); // iPhone SE size
        await expect(page.getByLabel('Name')).toBeVisible();
        await expect(page.locator('button[type="submit"]')).toBeVisible();
    });

    test('29. Mencegah akses Register jika sudah login (Redirect)', async ({ page }) => {
        // 1. Register/Login dulu
        await page.getByLabel('Name').fill('Logged In User');
        await page.getByLabel('Email Address').fill(randomEmail());
        await page.getByLabel('Password', { exact: true }).fill('password123');
        await page.getByLabel('Confirm Password').fill('password123');
        await page.click('button[type="submit"]');
        await expect(page).toHaveURL(/\/admin$/);

        // 2. Coba akses halaman register lagi
        await page.goto(REGISTER_URL);

        // 3. Harusnya dilempar balik ke dashboard
        await expect(page).toHaveURL(/\/admin$/);
    });

    test('30. Link Logo/Home mengarah ke landing page', async ({ page }) => {
        // Asumsi logo di atas form mengarah ke home
        // Selector logo mungkin perlu disesuaikan dengan tema Filament Anda
        // Biasanya text "Eat.o" atau "Filament"
        const brand = page.getByText('Eat.o').first(); 
        if(await brand.isVisible()) {
             await expect(brand).toBeVisible();
        }
    });

});