import { test, expect } from '@playwright/test';

test.describe('Filament Admin Login Flow', () => {

    // Ganti dengan akun Admin yang SUDAH ADA di database lokal Anda
    const credentials = {
        email: 'admin@example.com', // Pastikan email ini ada di tabel users
        password: 'password'        // Pastikan passwordnya benar
    };

    /**
     * TEST 1: LOGIN SUKSES
     * Skenario: Buka halaman -> Isi Form -> Masuk Dashboard
     */
    test('User can login and access dashboard', async ({ page }) => {
        
        // 1. Buka Halaman Login
        // Karena baseURL sudah diset di config, cukup '/admin/login'
        // Tapi kita pakai full URL biar jelas sesuai request Anda.
        await page.goto('http://127.0.0.1:8000/admin/login');

        // Pastikan halaman terbuka (Cek Judul Halaman)
        await expect(page).toHaveTitle(/Eat.o|Login/); 

        // 2. Isi Form Login
        // Filament menggunakan input type="email" dan type="password"
        await page.fill('input[type="email"]', credentials.email);
        await page.fill('input[type="password"]', credentials.password);

        // 3. Klik Tombol "Sign in"
        // Filament biasanya menggunakan tombol type="submit"
        await page.click('button[type="submit"]');

        // 4. Verifikasi Berhasil Masuk
        // Tunggu URL berubah. Jika pakai Multi-Tenancy, URL mungkin jadi /admin/nama-resto
        await expect(page).toHaveURL(/\/admin/); 

        // Cek apakah ada teks "Dashboard" (biasanya di breadcrumb atau sidebar)
        // Kita gunakan .first() karena kata Dashboard mungkin muncul 2x
        await expect(page.getByText('Dashboard', { exact: true }).first()).toBeVisible();
    });

    /**
     * TEST 2: LOGIN GAGAL (Negative Test)
     * Skenario: Password Salah -> Muncul Pesan Error
     */
    test('Show error on invalid credentials', async ({ page }) => {
        await page.goto('http://127.0.0.1:8000/admin/login');

        // Isi password asal-asalan
        await page.fill('input[type="email"]', credentials.email);
        await page.fill('input[type="password"]', 'password_salah_123');
        await page.click('button[type="submit"]');

        // Filament akan memunculkan pesan error validasi
        // Pesan default Laravel: "These credentials do not match our records."
        // Atau jika bahasa Indonesia: "Kredensial tersebut tidak cocok..."
        const errorMessage = page.locator('text=/These credentials|Kredensial/');
        await expect(errorMessage).toBeVisible();
        
        // Pastikan TIDAK masuk ke dashboard (URL masih di login)
        await expect(page).toHaveURL(/login/);
    });

});