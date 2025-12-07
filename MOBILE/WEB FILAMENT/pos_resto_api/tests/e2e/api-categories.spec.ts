import { test, expect } from '@playwright/test';

const BASE_API_URL = 'http://127.0.0.1:8000/api/v1';

test.describe('API Categories Endpoint (/api/v1/categories)', () => {

    test('1. GET Categories returns valid JSON and 200 OK', async ({ request }) => {
        const response = await request.get(`${BASE_API_URL}/categories`);
        
        // 1. Cek Status Code
        expect(response.status()).toBe(200);
        expect(response.ok()).toBeTruthy();

        // 2. Cek Struktur Data
        const categories = await response.json();
        expect(Array.isArray(categories)).toBeTruthy(); // Harus berupa array

        // 3. Jika ada data, cek detail field-nya
        if (categories.length > 0) {
            const firstCategory = categories[0];
            
            // Pastikan kolom penting ada
            expect(firstCategory).toHaveProperty('id');
            expect(firstCategory).toHaveProperty('name');
            // Description boleh null, jadi tidak wajib dicek isinya, tapi key-nya harus ada
            // expect(firstCategory).toHaveProperty('description'); 
            
            // Cek withCount('menus') dari controller
            expect(firstCategory).toHaveProperty('menus_count'); 
        }
    });

    test('2. Response time is acceptable (< 1s)', async ({ request }) => {
        const start = Date.now();
        await request.get(`${BASE_API_URL}/categories`);
        const duration = Date.now() - start;
        
        // API Category harusnya ringan
        expect(duration).toBeLessThan(1000); 
    });

});