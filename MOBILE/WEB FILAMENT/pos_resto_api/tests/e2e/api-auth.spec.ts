import { test, expect } from '@playwright/test';

// Konfigurasi URL API Anda
const BASE_URL = 'http://127.0.0.1:8000/api/v1';

test.describe('API Authentication Flow (Mobile App)', () => {

    // Kita butuh email unik setiap kali test jalan agar tidak error "Email already taken"
    const randomId = Math.floor(Math.random() * 10000);
    const userData = {
        name: 'Test Cashier Playwright',
        email: `cashier_${randomId}@example.com`,
        password: 'password123',
        password_confirmation: 'password123',
        role: 'cashier' // Sesuai validasi: cashier atau kitchen
    };

    let authToken = '';

    /**
     * TEST 1: REGISTER
     * Menguji endpoint POST /api/v1/register
     */
    test('1. Register new cashier successfully', async ({ request }) => {
        const response = await request.post(`${BASE_URL}/register`, {
            data: userData
        });

        // Pastikan server merespon
        expect(response.ok()).toBeTruthy();
        expect(response.status()).toBe(201); // Created

        const body = await response.json();
        
        // Verifikasi struktur JSON respons
        expect(body.message).toBe('User registered successfully');
        expect(body.user.email).toBe(userData.email);
        expect(body.user.role).toBe('cashier');
        
        // Pastikan token dikembalikan (untuk auto-login setelah register)
        expect(body.access_token).toBeDefined();
    });

    /**
     * TEST 2: REGISTER VALIDATION (NEGATIVE TEST)
     * Menguji validasi role yang tidak diizinkan
     */
    test('2. Should fail register with invalid role', async ({ request }) => {
        const response = await request.post(`${BASE_URL}/register`, {
            data: {
                ...userData,
                email: `fail_${randomId}@example.com`,
                role: 'admin' // Role 'admin' tidak boleh daftar lewat API
            }
        });

        expect(response.status()).toBe(422); // Unprocessable Entity (Validation Error)
        
        const body = await response.json();
        // Laravel biasanya mengembalikan error di object 'errors'
        // Error message harusnya: "The selected role is invalid."
        expect(JSON.stringify(body)).toContain('role'); 
    });

    /**
     * TEST 3: LOGIN
     * Menguji endpoint POST /api/v1/login
     */
    test('3. Login with valid credentials', async ({ request }) => {
        const response = await request.post(`${BASE_URL}/login`, {
            data: {
                email: userData.email,
                password: userData.password
            }
        });

        expect(response.status()).toBe(200);

        const body = await response.json();
        expect(body.message).toBe('Login successful');
        expect(body.access_token).toBeDefined();

        // SIMPAN TOKEN UNTUK TEST BERIKUTNYA
        authToken = body.access_token;
    });

    /**
     * TEST 4: LOGIN FAIL (NEGATIVE TEST)
     * Menguji password salah
     */
    test('4. Should fail login with wrong password', async ({ request }) => {
        const response = await request.post(`${BASE_URL}/login`, {
            data: {
                email: userData.email,
                password: 'wrongpassword'
            }
        });

        // Controller Anda melempar ValidationException -> Laravel render jadi 422
        expect(response.status()).toBe(422); 
    });

    /**
     * TEST 5: GET USER PROFILE (PROTECTED ROUTE)
     * Menguji endpoint GET /api/v1/user dengan Bearer Token
     */
    test('5. Get user profile with token', async ({ request }) => {
        // Token harus ada dari langkah Login sebelumnya
        expect(authToken).toBeTruthy();

        const response = await request.get(`${BASE_URL}/user`, {
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Accept': 'application/json'
            }
        });

        expect(response.status()).toBe(200);
        const body = await response.json();
        
        expect(body.email).toBe(userData.email);
    });

    /**
     * TEST 6: LOGOUT
     * Menguji endpoint POST /api/v1/logout
     */
    test('6. Logout successfully', async ({ request }) => {
        const response = await request.post(`${BASE_URL}/logout`, {
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Accept': 'application/json'
            }
        });

        expect(response.status()).toBe(200);
        const body = await response.json();
        expect(body.message).toBe('Successfully logged out');
    });

    /**
     * TEST 7: ACCESS AFTER LOGOUT (NEGATIVE TEST)
     * Memastikan token lama tidak bisa dipakai lagi
     */
    test('7. Token should be invalid after logout', async ({ request }) => {
        const response = await request.get(`${BASE_URL}/user`, {
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Accept': 'application/json'
            }
        });

        // Harusnya 401 Unauthorized
        expect(response.status()).toBe(401);
    });

});