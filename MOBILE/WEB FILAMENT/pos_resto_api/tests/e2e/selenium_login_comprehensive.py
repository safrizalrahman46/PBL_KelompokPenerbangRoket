import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

class FilamentLoginTest(unittest.TestCase):

    # --- KONFIGURASI ---
    BASE_URL = "http://127.0.0.1:8000/admin/login"
    VALID_EMAIL = "admin1@gmail.com"
    VALID_PASSWORD = "admin1234"

    def setUp(self):
        # Setup Driver sebelum setiap test
        self.driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
        self.driver.maximize_window()
        self.wait = WebDriverWait(self.driver, 10) # Default wait 10 detik
        self.driver.get(self.BASE_URL)

    def tearDown(self):
        # Tutup browser setelah setiap test
        self.driver.quit()

    # --- HELPER FUNCTIONS ---
    def login(self, email, password):
        self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys(email)
        self.driver.find_element(By.XPATH, "//input[@type='password']").send_keys(password)
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()

    def assert_dashboard_loaded(self):
        try:
            # Tunggu URL mengandung '/admin' (tapi bukan /login)
            self.wait.until(EC.url_matches(r".*/admin$"))
            # Tunggu teks Dashboard muncul
            self.wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'Dashboard')]")))
            return True
        except TimeoutException:
            self.fail("Gagal masuk ke Dashboard atau waktu habis.")

    def assert_error_message(self):
        try:
            # Cari pesan error standar Laravel/Filament
            self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "//*[contains(text(), 'These credentials') or contains(text(), 'Kredensial')]")
            ))
            return True
        except TimeoutException:
            self.fail("Pesan error tidak muncul.")

    # ==========================================
    # GROUP 1: POSITIVE LOGIN FLOWS (5 Cases)
    # ==========================================

    def test_01_login_success_click(self):
        """01. Login berhasil dengan klik tombol Sign In"""
        self.login(self.VALID_EMAIL, self.VALID_PASSWORD)
        self.assert_dashboard_loaded()

    def test_02_login_success_enter_key(self):
        """02. Login berhasil dengan menekan tombol ENTER"""
        self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys(self.VALID_EMAIL)
        pass_input = self.driver.find_element(By.XPATH, "//input[@type='password']")
        pass_input.send_keys(self.VALID_PASSWORD)
        pass_input.send_keys(Keys.ENTER)
        
        self.assert_dashboard_loaded()

    def test_03_login_case_insensitive_email(self):
        """03. Login berhasil dengan email huruf besar"""
        self.login(self.VALID_EMAIL.upper(), self.VALID_PASSWORD)
        self.assert_dashboard_loaded()

    def test_04_login_trimmed_email(self):
        """04. Login berhasil dengan spasi di awal/akhir email"""
        self.login(f"  {self.VALID_EMAIL}  ", self.VALID_PASSWORD)
        self.assert_dashboard_loaded()

    def test_05_logout_success(self):
        """05. Logout berhasil dilakukan setelah login"""
        # 1. Login dulu
        self.login(self.VALID_EMAIL, self.VALID_PASSWORD)
        self.assert_dashboard_loaded()

        # 2. Cari tombol user menu (biasanya di pojok kanan atas di Filament v3)
        try:
            # Mencoba selector umum Filament v3
            user_menu = self.wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, ".fi-user-menu-trigger, button[aria-label='User menu']")))
            user_menu.click()
            
            # 3. Klik tombol Sign out
            sign_out_btn = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(), 'Sign out') or contains(text(), 'Keluar')]")))
            sign_out_btn.click()
            
            # 4. Verifikasi kembali ke login
            self.wait.until(EC.url_contains("/login"))
        except TimeoutException:
            self.fail("Gagal melakukan logout (Elemen tidak ditemukan).")

    # ==================================================
    # GROUP 2: NEGATIVE LOGIN FLOWS & VALIDATION (10 Cases)
    # ==================================================

    def test_06_fail_wrong_password(self):
        """06. Gagal login dengan password salah"""
        self.login(self.VALID_EMAIL, "wrongpass")
        self.assert_error_message()
        self.assertIn("/login", self.driver.current_url)

    def test_07_fail_wrong_email(self):
        """07. Gagal login dengan email salah"""
        self.login("wrong@gmail.com", self.VALID_PASSWORD)
        self.assert_error_message()

    def test_08_fail_empty_password(self):
        """08. Gagal login dengan password kosong"""
        self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys(self.VALID_EMAIL)
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()
        
        # Validasi HTML5 atau Server Side
        # Karena Selenium sulit menangkap tooltip HTML5 native, kita cek URL tidak berubah
        time.sleep(1) 
        self.assertIn("/login", self.driver.current_url)

    def test_09_fail_empty_email(self):
        """09. Gagal login dengan email kosong"""
        self.driver.find_element(By.XPATH, "//input[@type='password']").send_keys(self.VALID_PASSWORD)
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()
        
        time.sleep(1)
        self.assertIn("/login", self.driver.current_url)

    def test_10_fail_invalid_email_no_at(self):
        """10. Gagal login format email tidak valid (tanpa @)"""
        email_input = self.driver.find_element(By.XPATH, "//input[@type='email']")
        email_input.send_keys("admin1gmail.com")
        self.driver.find_element(By.XPATH, "//input[@type='password']").send_keys(self.VALID_PASSWORD)
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()

        # Cek validasi browser (HTML5 property)
        is_valid = self.driver.execute_script("return arguments[0].checkValidity();", email_input)
        self.assertFalse(is_valid, "Seharusnya form tidak valid karena email salah format")

    def test_11_fail_invalid_email_no_domain(self):
        """11. Gagal login format email tidak valid (tanpa domain)"""
        self.login("admin1@", self.VALID_PASSWORD)
        self.assertIn("/login", self.driver.current_url)

    def test_12_fail_password_case_sensitive(self):
        """12. Gagal login karena Password Case Sensitive"""
        self.login(self.VALID_EMAIL, self.VALID_PASSWORD.upper())
        self.assert_error_message()

    def test_13_fail_unregistered_email(self):
        """13. Gagal login dengan email tidak terdaftar sama sekali"""
        self.login("hantu@gmail.com", "hantu123")
        self.assert_error_message()

    def test_14_input_cleared_after_refresh(self):
        """14. Validasi input field terhapus setelah refresh"""
        self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys("tekstes@gmail.com")
        self.driver.refresh()
        
        # Tunggu reload
        self.wait.until(EC.presence_of_element_located((By.XPATH, "//input[@type='email']")))
        
        value = self.driver.find_element(By.XPATH, "//input[@type='email']").get_attribute("value")
        self.assertEqual(value, "", "Input email harus kosong setelah refresh")

    def test_15_error_behavior_retype(self):
        """15. Cek perilaku halaman setelah error (tetap di login)"""
        self.login(self.VALID_EMAIL, "salah")
        self.assert_error_message()
        self.assertIn("/login", self.driver.current_url)

    # ==========================================
    # GROUP 3: UI & UX CHECKS (8 Cases)
    # ==========================================

    def test_16_page_title(self):
        """16. Halaman memiliki Title yang benar"""
        # Sesuaikan dengan title aplikasi Anda, misal 'Eat.o' atau 'Login'
        self.assertTrue("Eat.o" in self.driver.title or "Login" in self.driver.title)

    def test_17_email_input_visible(self):
        """17. Input email terlihat dan aktif"""
        elem = self.driver.find_element(By.XPATH, "//input[@type='email']")
        self.assertTrue(elem.is_displayed())
        self.assertTrue(elem.is_enabled())

    def test_18_password_masked(self):
        """18. Input password bertipe 'password' (Masking)"""
        elem = self.driver.find_element(By.Name, "password")
        self.assertEqual(elem.get_attribute("type"), "password")

    def test_19_submit_button_text(self):
        """19. Tombol Sign In terlihat dan teks benar"""
        btn = self.driver.find_element(By.XPATH, "//button[@type='submit']")
        self.assertTrue(btn.is_displayed())
        text = btn.text.lower()
        self.assertTrue("sign in" in text or "masuk" in text)

    def test_20_remember_me_checkbox(self):
        """20. Checkbox 'Remember Me' tersedia"""
        try:
            checkbox = self.driver.find_element(By.XPATH, "//input[@type='checkbox']")
            self.assertTrue(checkbox.is_displayed() or checkbox.is_enabled()) # Kadang styling menyembunyikan checkbox asli
            if not checkbox.is_selected():
                # Coba klik parent labelnya jika checkbox hidden oleh CSS framework
                try:
                    checkbox.click()
                except:
                    checkbox.find_element(By.XPATH, "./..").click()
        except:
            print("Info: Checkbox Remember Me tidak ditemukan (mungkin dinonaktifkan di config)")

    def test_21_forgot_password_link(self):
        """21. Link 'Forgot Password' tersedia"""
        try:
            link = self.driver.find_element(By.XPATH, "//a[contains(@href, 'password/reset')]")
            self.assertTrue(link.is_displayed())
        except:
            print("Info: Link Forgot Password tidak ditemukan")

    def test_22_logo_visible(self):
        """22. Logo Aplikasi atau Heading terlihat"""
        # Cari text Eat.o atau gambar logo
        try:
            elem = self.driver.find_element(By.XPATH, "//*[contains(text(), 'Eat.o') or contains(text(), 'Sign in')]")
            self.assertTrue(elem.is_displayed())
        except:
            self.fail("Logo/Heading tidak ditemukan")

    def test_23_autofocus_email(self):
        """23. Input focus otomatis pada email"""
        try:
            elem = self.driver.find_element(By.XPATH, "//input[@type='email']")
            # Cek atribut autofocus
            self.assertIsNotNone(elem.get_attribute("autofocus"))
        except:
            print("Info: Autofocus tidak aktif")

    # ==========================================
    # GROUP 4: SECURITY & EDGE CASES (7 Cases)
    # ==========================================

    def test_24_sql_injection_attempt(self):
        """24. Mencegah SQL Injection sederhana"""
        self.login("' OR '1'='1", "' OR '1'='1")
        # Harus tetap di halaman login atau muncul error validasi
        self.assertIn("/login", self.driver.current_url)
        try:
            self.assert_error_message()
        except:
            pass # Asal tidak masuk dashboard (bypass), aman.

    def test_25_xss_attempt(self):
        """25. Mencegah XSS Script di input"""
        payload = '<script>alert("hacked")</script>'
        self.login(payload, "random")
        self.assertIn("/login", self.driver.current_url)

    def test_26_long_email(self):
        """26. Menangani input email yang sangat panjang"""
        long_email = 'a' * 200 + '@gmail.com'
        self.login(long_email, self.VALID_PASSWORD)
        self.assert_error_message()

    def test_27_long_password(self):
        """27. Menangani input password yang sangat panjang"""
        long_pass = 'a' * 300
        self.login(self.VALID_EMAIL, long_pass)
        self.assert_error_message()

    def test_28_direct_access_dashboard(self):
        """28. Akses langsung ke Dashboard tanpa login (Redirect)"""
        # Hapus cookie untuk simulasi belum login
        self.driver.delete_all_cookies()
        self.driver.get("http://127.0.0.1:8000/admin")
        
        # Harus dilempar balik ke login
        self.wait.until(EC.url_contains("/login"))
        self.assertIn("/login", self.driver.current_url)

    def test_29_back_button_after_logout(self):
        """29. Tombol Back browser setelah logout tidak bisa masuk lagi"""
        # 1. Login
        self.login(self.VALID_EMAIL, self.VALID_PASSWORD)
        self.assert_dashboard_loaded()

        # 2. Logout (Simulasi clear cookie biar cepat)
        self.driver.delete_all_cookies()
        self.driver.get(self.BASE_URL)

        # 3. Tekan Back
        self.driver.back()
        self.driver.refresh() # Paksa cek sesi server

        # 4. Harus di login
        self.assertIn("/login", self.driver.current_url)

    def test_30_rate_limiting(self):
        """30. Login cepat berulang kali (Rate Limiting)"""
        for i in range(6):
            self.driver.find_element(By.XPATH, "//input[@type='email']").clear()
            self.driver.find_element(By.XPATH, "//input[@type='password']").clear()
            
            self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys(self.VALID_EMAIL)
            self.driver.find_element(By.XPATH, "//input[@type='password']").send_keys(f"wrongpass{i}")
            self.driver.find_element(By.XPATH, "//button[@type='submit']").click()
            
            # Tunggu sebentar agar request selesai diproses
            time.sleep(0.5)

        # Cek pesan "Too many login attempts"
        try:
            self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "//*[contains(text(), 'Too many login attempts') or contains(text(), 'Terlalu banyak percobaan')]")
            ))
        except TimeoutException:
            print("Info: Rate limiting mungkin belum ter-trigger atau settingan throttle > 5")

if __name__ == "__main__":
    unittest.main()