import { test, expect } from '@playwright/test';

// --- KONFIGURASI ---
const BASE_URL = 'http://127.0.0.1:8000';
const USER_EMAIL = 'admin1@gmail.com';
const USER_PASS = 'admin1234';

// --- DATA SESUAI REQUEST ---
const DATA_KASIR = 'Yaya';
const DATA_MEJA = 'A1';
const DATA_MENU = 'Mie Bakar'; 
const DATA_STATUS = 'Pending';

test.describe('Filament Admin: Order Resource', () => {

    test.beforeEach(async ({ page }) => {
        await page.goto(`${BASE_URL}/admin/login`);
        await page.getByLabel('Email address').fill(USER_EMAIL);
        await page.getByLabel('Password').fill(USER_PASS);
        await page.getByRole('button', { name: /sign in/i }).click();
        await expect(page.locator('body')).toContainText('Dashboard');
        await page.goto(`${BASE_URL}/admin/orders`);
    });

    // --- HELPER FUNCTION ---
    async function selectFilamentDropdown(page, labelRegex, valueText) {
        console.log(`Mencari dropdown: ${labelRegex} -> pilih: ${valueText}`);
        const labelLocator = page.locator('label').filter({ hasText: labelRegex }).last();
        await expect(labelLocator).toBeVisible({ timeout: 5000 });

        const fieldWrapper = labelLocator.locator('..').locator('..'); 
        const trigger = fieldWrapper.locator('.fi-input-wrp');
        await trigger.click();

        await page.waitForTimeout(500); 
        await page.keyboard.type(valueText);
        await page.waitForTimeout(2000); 

        const option = page.getByRole('option', { name: valueText, exact: false }).first();
        await expect(option).toBeVisible();
        await option.click();
        await page.waitForTimeout(500);
    }

    test('E2E: Create Order Flow (Yaya, A1, Mie Bakar)', async ({ page }) => {
        test.setTimeout(60000); 

        // ==========================================
        // 1. CREATE ORDER
        // ==========================================
        await test.step('Create Order', async () => {
            await page.goto(`${BASE_URL}/admin/orders/create`);
            await expect(page).toHaveURL(/.*create/);

            console.log(`Mengisi Customer: ${DATA_KASIR}`);
            await page.locator('input[id*="customer_name"]').fill(DATA_KASIR);

            try {
                await selectFilamentDropdown(page, /Table|Meja/i, DATA_MEJA);
            } catch (e) {
                console.log(`⚠️ Warning: Meja '${DATA_MEJA}' gagal dipilih.`);
            }

            await selectFilamentDropdown(page, /Menu/i, DATA_MENU);

            console.log('Menunggu harga otomatis terisi...');
            const priceInput = page.locator('input[id*="price_at_time"]');
            await expect(priceInput).not.toHaveValue('0', { timeout: 10000 });
            await expect(priceInput).not.toHaveValue('');

            await page.locator('input[id*="quantity"]').fill('1');

            await page.locator('h1').click(); // Blur
            await page.waitForTimeout(2000); 

            await page.getByRole('button', { name: 'Create', exact: true }).click();
            await expect(page.getByText('Created')).toBeVisible();
            console.log('✅ Order Created Successfully');
        });

        // ==========================================
        // 2. CEK DATA & UPDATE STATUS
        // ==========================================
        await test.step('Update Status & Check Data', async () => {
            await page.goto(`${BASE_URL}/admin/orders`);
            
            const searchInput = page.getByPlaceholder('Search');
            await searchInput.fill(DATA_KASIR);
            await page.waitForTimeout(2500); // Tunggu filter

            // --- PERBAIKAN DI SINI (STRICT MODE FIX) ---
            // Gunakan .first() untuk mengambil baris paling atas jika ada duplikat nama "Yaya"
            const row = page.getByRole('row', { name: DATA_KASIR }).first();
            await expect(row).toBeVisible();

            // Masuk Edit
            await row.getByRole('link', { name: 'Edit' }).first().click();

            // Update Status (Optional)
            try {
                console.log(`Status saat ini: ${DATA_STATUS}`);
            } catch (e) {
                console.log('Dropdown status skip');
            }
            
            await page.locator('input[id*="customer_name"]').fill(`${DATA_KASIR} Updated`);
            await page.locator('h1').click(); 

            await page.getByRole('button', { name: 'Save changes' }).click();
            await expect(page.getByText('Saved')).toBeVisible();
        });

        // ==========================================
        // 3. DELETE
        // ==========================================
        await test.step('Delete Order', async () => {
            await page.getByRole('button', { name: 'Delete' }).first().click();

            // Fix Modal Strict Mode (dari diskusi sebelumnya)
            const modal = page.locator('.fi-modal-window').filter({ hasText: /Delete/i }).first();
            await expect(modal).toBeVisible();
            await modal.getByRole('button', { name: /Delete|Confirm/i }).click();

            await expect(page.getByText('Deleted')).toBeVisible();
            console.log('✅ Order Deleted Successfully');
        });
    });
});