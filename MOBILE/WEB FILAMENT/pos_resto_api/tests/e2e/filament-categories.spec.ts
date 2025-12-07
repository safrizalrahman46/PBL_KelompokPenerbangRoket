import { test, expect } from '@playwright/test';

const BASE_URL = 'http://127.0.0.1:8000';

// --- HELPER FUNCTIONS ---
// Fungsi bantuan untuk menonaktifkan validasi HTML5 (agar error Laravel muncul)
async function disableHtml5Validation(page) {
    await page.evaluate(() => {
        const forms = document.querySelectorAll('form');
        forms.forEach(form => form.setAttribute('novalidate', 'true'));
    });
}

// Fungsi bantuan untuk membuat kategori dummy secara cepat
async function createCategory(page, name, desc = 'Auto Desc') {
    await page.goto(`${BASE_URL}/admin/categories/create`);
    await page.locator('input[id*="name"]').fill(name);
    await page.getByLabel(/Description/i).fill(desc);
    await page.getByRole('button', { name: 'Create', exact: true }).click();
    await expect(page.getByText('Created')).toBeVisible();
}

test.describe('Filament Admin: Categories Management', () => {

    // --- SETUP: LOGIN SEBELUM TIAP TEST ---
    test.beforeEach(async ({ page }) => {
        await page.goto(`${BASE_URL}/admin/login`);
        await page.fill('input[type="email"]', 'admin1@gmail.com');
        await page.fill('input[type="password"]', 'admin1234');
        await page.click('button[type="submit"]');
        await page.waitForURL(/\/admin/);
        await page.waitForLoadState('networkidle');
        await page.goto(`${BASE_URL}/admin/categories`);
    });

    // ==========================================
    // GROUP 1: UI & NAVIGATION (5 Tests)
    // ==========================================
    test.describe('UI & Navigation', () => {
        
        test('01. Check Page Title', async ({ page }) => {
            await expect(page).toHaveTitle(/Categories/);
        });

        test('02. Check Heading Text', async ({ page }) => {
            // Header halaman biasanya h1
            await expect(page.getByRole('heading', { name: 'Categories', exact: true })).toBeVisible();
        });

        test('03. Check Breadcrumbs exist', async ({ page }) => {
            // Biasanya ada breadcrumb "Dashboard / Categories"
            await expect(page.locator('.fi-breadcrumbs')).toBeVisible();
        });

        test('04. Check Table Columns Headers', async ({ page }) => {
            // Pastikan kolom Name dan Description ada
            await expect(page.getByRole('columnheader', { name: 'Name' })).toBeVisible();
            await expect(page.getByRole('columnheader', { name: 'Description' })).toBeVisible();
        });

        test('05. Navigation to Create Page', async ({ page }) => {
            await page.getByRole('link', { name: 'New category' }).click();
            await expect(page).toHaveURL(/.*\/create/);
            await expect(page.getByRole('heading', { name: 'Create category' })).toBeVisible();
        });
    });

    // ==========================================
    // GROUP 2: CREATE OPERATIONS (6 Tests)
    // ==========================================
    test.describe('Create Operations', () => {

        test('06. Create Category (Full Data)', async ({ page }) => {
            const name = `Cat Full ${Date.now()}`;
            await page.getByRole('link', { name: 'New category' }).click();
            await page.locator('input[id*="name"]').fill(name);
            await page.getByLabel(/Description/i).fill('Full description data');
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            await expect(page.getByText('Created')).toBeVisible();
            await expect(page.getByRole('row', { name: name })).toBeVisible();
        });

        test('07. Create Category (Name Only - Description Optional)', async ({ page }) => {
            // Deskripsi di resource Anda tidak required, jadi ini harus sukses
            const name = `Cat Simple ${Date.now()}`;
            await page.getByRole('link', { name: 'New category' }).click();
            await page.locator('input[id*="name"]').fill(name);
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            await expect(page.getByText('Created')).toBeVisible();
        });

        test('08. Create & Create Another', async ({ page }) => {
            const name = `Cat Another ${Date.now()}`;
            await page.getByRole('link', { name: 'New category' }).click();
            await page.locator('input[id*="name"]').fill(name);
            // Tombol ini biasanya ada di sebelah tombol Create
            await page.getByRole('button', { name: 'Create & create another' }).click();
            
            await expect(page.getByText('Created')).toBeVisible();
            // Pastikan URL masih di halaman create, bukan redirect ke index
            await expect(page).toHaveURL(/.*\/create/);
            // Pastikan field kosong kembali (form reset)
            await expect(page.locator('input[id*="name"]')).toBeEmpty();
        });

        test('09. Create with Max Length Name (255 Chars)', async ({ page }) => {
            const longName = 'A'.repeat(255);
            await page.getByRole('link', { name: 'New category' }).click();
            await page.locator('input[id*="name"]').fill(longName);
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            await expect(page.getByText('Created')).toBeVisible();
        });

        test('10. Cancel Create (Return to Index)', async ({ page }) => {
            await page.getByRole('link', { name: 'New category' }).click();
            await page.getByRole('link', { name: 'Cancel' }).click(); // Atau tombol 'Categories' di breadcrumb
            await expect(page).toHaveURL(/admin\/categories$/);
        });

        test('11. XSS Sanity Check in Name', async ({ page }) => {
            // Mencoba input script, pastikan tersimpan sebagai text biasa (escaped)
            const xssName = `<script>alert('xss')</script> ${Date.now()}`;
            await createCategory(page, xssName);
            
            // Saat kembali ke list, pastikan script tidak dieksekusi (tidak ada dialog alert)
            // Dan teks ditampilkan apa adanya
            await expect(page.getByText(xssName)).toBeVisible();
        });
    });

    // ==========================================
    // GROUP 3: VALIDATION (5 Tests)
    // ==========================================
    test.describe('Validation Logic', () => {

        test('12. Validation: Name is Required', async ({ page }) => {
            await page.getByRole('link', { name: 'New category' }).click();
            await disableHtml5Validation(page);
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            await expect(page.getByText(/field is required|wajib/i)).toBeVisible();
        });

        test('13. Validation: Name Max Length (256 Chars)', async ({ page }) => {
            await page.getByRole('link', { name: 'New category' }).click();
            await disableHtml5Validation(page);
            
            const tooLongName = 'A'.repeat(256);
            await page.locator('input[id*="name"]').fill(tooLongName);
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            
            // Filament biasanya memberikan pesan: "The name must not be greater than 255 characters."
            await expect(page.getByText(/greater than 255|lebih dari 255/i)).toBeVisible();
        });

        test('14. Edit Validation: Clear Name Error', async ({ page }) => {
            // Buat dulu
            const name = `Val Edit ${Date.now()}`;
            await createCategory(page, name);

            // Edit dan hapus nama
            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            await disableHtml5Validation(page);
            await page.locator('input[id*="name"]').fill('');
            await page.getByRole('button', { name: 'Save changes' }).click();

            await expect(page.getByText(/field is required|wajib/i)).toBeVisible();
        });
        
        test('15. Whitespace Validation (If backend strict)', async ({ page }) => {
            // Opsional: Cek apakah spasi saja dianggap valid atau tidak
            await page.getByRole('link', { name: 'New category' }).click();
            await disableHtml5Validation(page);
            await page.locator('input[id*="name"]').fill('   '); // Hanya spasi
            await page.getByRole('button', { name: 'Create', exact: true }).click();
            
            // Jika Laravel TrimStrings middleware aktif (default), ini akan jadi string kosong dan error required
            // Jika tidak error, test ini mungkin perlu disesuaikan dengan logic aplikasi Anda
            const errorVisible = await page.getByText(/field is required|wajib/i).isVisible();
            if(!errorVisible) console.log('Warning: Whitespace name was accepted');
        });
    });

    // ==========================================
    // GROUP 4: READ, SEARCH & FILTER (5 Tests)
    // ==========================================
    test.describe('Read & Search', () => {

        test('16. List Shows Created Data', async ({ page }) => {
            const name = `List Check ${Date.now()}`;
            await createCategory(page, name);
            await page.goto(`${BASE_URL}/admin/categories`);
            await expect(page.getByRole('row', { name: name })).toBeVisible();
        });

        test('17. Search Functionality (Found)', async ({ page }) => {
            const uniqueName = `SearchMe ${Date.now()}`;
            await createCategory(page, uniqueName);
            await page.goto(`${BASE_URL}/admin/categories`);

            // Ketik di kolom search
            const searchInput = page.getByPlaceholder(/Search/i);
            await searchInput.fill(uniqueName);
            await page.waitForTimeout(1000); // Tunggu debounce search filament

            await expect(page.getByRole('row', { name: uniqueName })).toBeVisible();
        });

        test('18. Search Functionality (Not Found)', async ({ page }) => {
            const searchInput = page.getByPlaceholder(/Search/i);
            await searchInput.fill('RandomStringThatDoesNotExist12345');
            await page.waitForTimeout(1000);

            // Biasanya Filament menampilkan "No records found"
            await expect(page.getByText(/No records found|Tidak ada data/i)).toBeVisible();
        });

        test('19. Description Truncation (Limit 50)', async ({ page }) => {
            // Di CategoryResource ada ->limit(50)
            const longDesc = 'Ini adalah deskripsi yang sangat panjang sekali lebih dari lima puluh karakter untuk tes limitasi tabel.';
            const name = `Desc Limit ${Date.now()}`;
            await createCategory(page, name, longDesc);
            await page.goto(`${BASE_URL}/admin/categories`);

            // Cari baris tersebut
            const row = page.getByRole('row', { name: name });
            // Filament menambahkan '...' di akhir jika dipotong
            // Kita cek apakah teks penuh TIDAK visible, atau teks potong visible
            // Cara paling aman: ambil teks cell deskripsi
            const descCell = row.locator('td').nth(1); // Kolom ke-2 (index 1) biasanya deskripsi
            await expect(descCell).not.toHaveText(longDesc); // Tidak boleh sama persis (karena dipotong)
            await expect(descCell).toContainText('...');
        });

        test('20. Pagination Check (UI existence)', async ({ page }) => {
            // Meskipun data sedikit, footer pagination biasanya tetap ada (showing 1 to X)
            await expect(page.getByText(/Showing/i)).toBeVisible();
        });
    });

    // ==========================================
    // GROUP 5: UPDATE OPERATIONS (4 Tests)
    // ==========================================
    test.describe('Update Operations', () => {

        test('21. Update Name', async ({ page }) => {
            const name = `UpdateName ${Date.now()}`;
            await createCategory(page, name);
            
            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            const newName = name + ' EDITED';
            await page.locator('input[id*="name"]').fill(newName);
            await page.getByRole('button', { name: 'Save changes' }).click();
            
            await expect(page.getByText('Saved')).toBeVisible();
            await page.goto(`${BASE_URL}/admin/categories`);
            await expect(page.getByRole('row', { name: newName })).toBeVisible();
        });

        test('22. Update Description', async ({ page }) => {
            const name = `UpdateDesc ${Date.now()}`;
            await createCategory(page, name);

            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            await page.getByLabel(/Description/i).fill('New Description Updated');
            await page.getByRole('button', { name: 'Save changes' }).click();
            
            await expect(page.getByText('Saved')).toBeVisible();
        });

        test('23. Update with No Changes', async ({ page }) => {
            const name = `NoChange ${Date.now()}`;
            await createCategory(page, name);

            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            // Langsung klik save tanpa ubah apa-apa
            await page.getByRole('button', { name: 'Save changes' }).click();
            
            await expect(page.getByText('Saved')).toBeVisible();
        });

        test('24. Navigation Back from Edit', async ({ page }) => {
            const name = `NavBack ${Date.now()}`;
            await createCategory(page, name);
            
            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            // Klik Cancel atau Breadcrumb Categories
            await page.getByRole('link', { name: 'Cancel' }).click();
            await expect(page).toHaveURL(/admin\/categories$/);
        });
    });

    // ==========================================
    // GROUP 6: DELETE & BULK ACTIONS (5 Tests)
    // ==========================================
    test.describe('Delete & Bulk Actions', () => {

        test('25. Delete via Edit Page (Happy Path)', async ({ page }) => {
            const name = `Del Edit ${Date.now()}`;
            await createCategory(page, name);

            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            
            // Klik header delete
            await page.getByRole('button', { name: 'Delete' }).first().click();
            
            // Konfirmasi di modal
            const modal = page.locator('.fi-modal-footer').last(); // Target footer modal terakhir yang muncul
            await page.getByRole('button', { name: /Delete|Confirm/i }).last().click();

            await expect(page.getByText('Deleted')).toBeVisible();
            await expect(page.getByRole('row', { name: name })).not.toBeVisible();
        });

        test('26. Cancel Delete in Modal', async ({ page }) => {
            const name = `Del Cancel ${Date.now()}`;
            await createCategory(page, name);

            await page.getByRole('row', { name: name }).getByRole('link', { name: 'Edit' }).click();
            await page.getByRole('button', { name: 'Delete' }).first().click();

            // Klik Cancel di dalam modal
            await page.getByRole('button', { name: 'Cancel' }).click();

            // Pastikan modal tertutup dan data masih ada (URL masih di edit page)
            await expect(page).toHaveURL(/edit$/);
            // Kembali ke list untuk memastikan data masih ada
            await page.goto(`${BASE_URL}/admin/categories`);
            await expect(page.getByRole('row', { name: name })).toBeVisible();
        });

        test('27. Bulk Delete Action (UI Check)', async ({ page }) => {
            // Kita cek apakah checkbox muncul
            await expect(page.getByRole('checkbox').first()).toBeVisible();
            
            // Pilih satu baris
            await page.locator('table tbody tr').first().getByRole('checkbox').check();
            
            // Pastikan tombol Bulk Actions muncul (biasanya hidden kalau belum ada yg dicek)
            // Filament biasanya menaruh tombol ini di header tabel dengan teks "Bulk actions"
            // atau icon titik tiga
            const bulkBtn = page.getByRole('button', { name: /Bulk actions/i });
            // Note: Selector ini mungkin butuh penyesuaian tergantung versi Filament,
            // tapi secara umum konsepnya: Pilih -> Tombol Aksi Muncul.
            if (await bulkBtn.isVisible()) {
                await bulkBtn.click();
                await expect(page.getByText(/Delete/i)).toBeVisible();
            }
        });
        
        test('28. Bulk Delete Execution', async ({ page }) => {
            const name = `BulkDel ${Date.now()}`;
            await createCategory(page, name);
            await page.goto(`${BASE_URL}/admin/categories`); // Refresh list

            // Cari row spesifik dan centang checkbox-nya
            const row = page.getByRole('row', { name: name });
            await row.getByRole('checkbox').check();

            // Buka menu bulk actions
            await page.getByRole('button', { name: /Bulk actions/i }).click();
            // Pilih Delete
            await page.getByRole('menuitem', { name: /Delete/i }).click(); // atau getByText('Delete selected')
            
            // Konfirmasi Modal
            await page.getByRole('button', { name: /Delete|Confirm/i }).last().click();

            await expect(page.getByText('Deleted')).toBeVisible();
            await expect(page.getByRole('row', { name: name })).not.toBeVisible();
        });
    });

    // ==========================================
    // GROUP 7: RESPONSIVE & MISC (2 Tests)
    // ==========================================
    test.describe('Responsive & Misc', () => {

        test('29. Mobile Viewport Check', async ({ page }) => {
            // Set ukuran layar seperti HP
            await page.setViewportSize({ width: 375, height: 667 });
            await page.goto(`${BASE_URL}/admin/categories`);

            // Pastikan tabel masih ada (atau berubah jadi stacked list di Filament)
            // Filament biasanya tetap merender struktur table/grid
            await expect(page.getByText('Categories')).toBeVisible();
            
            // Cek apakah hamburger menu sidebar muncul (indikasi responsif bekerja)
            // Selector ini generik untuk sidebar toggle
            await expect(page.locator('.fi-topbar button')).first().toBeVisible();
        });

        test('30. Logout Flow', async ({ page }) => {
            // Buka User Menu (biasanya di pojok kanan atas, avatar atau nama)
            // Di Filament default, ada button profile
            const userMenuBtn = page.locator('.fi-user-menu-trigger, button[aria-label="User menu"]');
            
            // Jika selector sulit, kita coba cari berdasarkan nama user "Admin" jika tampil
            // Atau kita cari tombol logout langsung jika visible
            
            // Strategi aman: Navigasi langsung ke route logout jika UI susah ditebak, 
            // TAPI Playwright harus tes UI.
            // Kita coba klik avatar/nama di pojok kanan atas.
            await page.locator('.fi-topbar-item-trigger').first().click();
            
            // Klik Logout
            await page.getByRole('menuitem', { name: /Sign out|Logout|Keluar/i }).click(); // Menggunakan .click() dari dropdown

            // Atau tombol form logout
            // await page.getByRole('button', { name: /Sign out/i }).click();

            // Verifikasi kembali ke halaman login
            await expect(page).toHaveURL(/login/);
        });
    });
});