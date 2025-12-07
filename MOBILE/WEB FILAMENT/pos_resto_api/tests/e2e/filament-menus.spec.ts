import { test, expect } from '@playwright/test';

// Ganti sesuai port laravel Anda
const BASE_URL = 'http://127.0.0.1:8000';

test.describe('Filament Admin: Menus Resource', () => {

    // Login sebelum setiap test dijalankan
    test.beforeEach(async ({ page }) => {
        await page.goto(`${BASE_URL}/admin/login`);
        await page.fill('input[type="email"]', 'admin1@gmail.com');
        await page.fill('input[type="password"]', 'admin1234');
        await page.click('button[type="submit"]');
        
        // Tunggu Dashboard siap
        await page.waitForURL(/\/admin/);
        await page.waitForLoadState('networkidle'); 
        
        // Masuk ke halaman Menu
        await page.goto(`${BASE_URL}/admin/menus`);
    });

    test('E2E: Full CRUD Flow (Create, Read, Update, Delete)', async ({ page }) => {
        // Set timeout lebih lama
        test.setTimeout(60000);

        const timestamp = Date.now();
        const menuName = `Menu Test ${timestamp}`;
        const updatedName = `${menuName} Edited`;
        const price = '50000';
        const stock = '100';

        // --- 1. CREATE ---
        await test.step('Create New Menu', async () => {
            await page.getByRole('link', { name: 'New menu' }).click();

            // === A. Select Category: "Soda" ===
            // 1. Cari wrapper field Category
            const categoryWrapper = page.locator('.fi-fo-field-wrp').filter({ hasText: /Category/i }).first();
            
            // 2. Klik area VISUAL inputnya
            await categoryWrapper.locator('.fi-input-wrp').click();

            // 3. Ketik "Soda"
            await page.keyboard.type('Soda');

            // 4. Tunggu opsi "Soda" muncul dan klik
            const sodaOption = page.getByRole('option', { name: 'Soda' }).first();
            await expect(sodaOption).toBeVisible();
            await sodaOption.click();

            // === B. Input Text Fields ===
            await page.locator('input[id*="name"]').fill(menuName);
            await page.locator('input[id*="price"]').fill(price);
            await page.locator('input[id*="stock"]').fill(stock);

            // === C. Upload Image ===
            const buffer = Buffer.from('fake-image-content');
            await page.locator('input[type="file"]').setInputFiles({
                name: 'menu-pic.png',
                mimeType: 'image/png',
                buffer: buffer,
            });
            
            // Gunakan .first() untuk menghindari Strict Mode Violation pada preview gambar
            await expect(page.getByText('menu-pic.png').first()).toBeVisible();

            // === D. Description ===
            await page.locator('textarea').first().fill('Deskripsi menu enak untuk testing');

            // Submit
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            
            // Validasi Sukses
            await expect(page.getByText('Created')).toBeVisible();
        });

        // --- 2. READ (Verifikasi Tabel) ---
        await test.step('Read / Verify in Table', async () => {
            await page.goto(`${BASE_URL}/admin/menus`);
            
            // Cari baris dengan nama menu
            const row = page.getByRole('row', { name: menuName });
            await expect(row).toBeVisible();

            await expect(row).toContainText('Rp 50.000');
            await expect(row).toContainText(stock);
        });

        // --- 3. UPDATE ---
        await test.step('Update Menu', async () => {
            const row = page.getByRole('row', { name: menuName });
            // Gunakan .first() untuk menghindari strict mode violation jika ada multiple edit links
            await row.getByRole('link', { name: 'Edit' }).first().click();

            // Ganti nama & harga
            await page.locator('input[id*="name"]').fill(updatedName);
            await page.locator('input[id*="price"]').fill('60000');

            await page.getByRole('button', { name: 'Save changes' }).click();
            await expect(page.getByText('Saved')).toBeVisible();

            // Cek perubahan di tabel
            await page.goto(`${BASE_URL}/admin/menus`);
            const updatedRow = page.getByRole('row', { name: updatedName });
            await expect(updatedRow).toBeVisible();
            await expect(updatedRow).toContainText('Rp 60.000');
        });

        // --- 4. DELETE ---
        await test.step('Delete Menu', async () => {
            const row = page.getByRole('row', { name: updatedName });
            
            // PERBAIKAN DI SINI: Tambahkan .first()
            // Error sebelumnya terjadi karena Playwright menemukan 2 elemen Link "Edit" di baris ini
            await row.getByRole('link', { name: 'Edit' }).first().click();

            // Klik Delete di Header
            await page.getByRole('button', { name: 'Delete' }).first().click();

            // Tunggu Modal Konfirmasi
            await expect(page.getByText('Are you sure')).toBeVisible();
            
            // Klik Confirm
            await page.getByRole('button', { name: /Delete|Confirm/i }).last().click();

            // Validasi terhapus
            await expect(page.getByText('Deleted')).toBeVisible();
            await expect(page.getByRole('row', { name: updatedName })).not.toBeVisible();
        });
    });

    test('Validation: Required Fields Check', async ({ page }) => {
        await page.getByRole('link', { name: 'New menu' }).click();

        await page.evaluate(() => {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => form.setAttribute('novalidate', 'true'));
        });

        await page.getByRole('button', { name: 'Create', exact: true }).click();

        await expect(page.locator('.text-danger-600').first()).toBeVisible();
        await expect(page.getByText(/name field is required/i)).toBeVisible();
    });
});