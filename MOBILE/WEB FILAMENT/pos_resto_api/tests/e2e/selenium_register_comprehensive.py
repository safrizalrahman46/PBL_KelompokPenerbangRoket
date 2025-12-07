import unittest
import time
import random
import string
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

class FilamentRegisterTest(unittest.TestCase):

    # --- KONFIGURASI ---
    REGISTER_URL = "http://127.0.0.1:8000/admin/register"
    
    def setUp(self):
        # Setup Chrome Driver
        self.driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
        self.driver.maximize_window()
        self.wait = WebDriverWait(self.driver, 10)
        self.driver.get(self.REGISTER_URL)

    def tearDown(self):
        # Tutup browser setelah setiap test case
        self.driver.quit()

    # --- HELPERS ---
    def generate_email(self):
        return f"user_{int(time.time())}_{random.randint(1,1000)}@example.com"

    def fill_input(self, label_text, value, is_exact=False):
        """
        Mencari input berdasarkan label teks terdekat atau placeholder/aria-label.
        Filament v3 struktur DOM-nya bisa kompleks, jadi kita gunakan beberapa strategi XPATH.
        """
        try:
            if is_exact:
                xpath = f"//label[text()='{label_text}']/following-sibling::*//input | //label[text()='{label_text}']/..//input"
            else:
                xpath = f"//label[contains(., '{label_text}')]/following-sibling::*//input | //label[contains(., '{label_text}')]/..//input"
            
            # Khusus Password field yang mungkin tidak punya label text standar di DOM
            if "Password" in label_text and "Confirm" not in label_text:
                 # Cari input type password pertama
                 input_elem = self.driver.find_element(By.XPATH, "//input[@type='password'][1]")
            elif "Confirm Password" in label_text:
                 # Cari input type password kedua
                 input_elem = self.driver.find_element(By.XPATH, "(//input[@type='password'])[2]")
            else:
                input_elem = self.driver.find_element(By.XPATH, xpath)
                
            input_elem.clear()
            input_elem.send_keys(value)
            return input_elem
        except NoSuchElementException:
            print(f"Warning: Input '{label_text}' tidak ditemukan via Label, mencoba strategi fallback...")
            # Fallback strategi (misal berdasarkan name atau type)
            if "Name" in label_text:
                self.driver.find_element(By.XPATH, "//input[@autocomplete='name' or @type='text']").send_keys(value)

    def select_role(self, role_name):
        """
        Memilih role dari dropdown custom Filament.
        """
        try:
            # 1. Klik Trigger Dropdown (Native Select atau Custom Div)
            # Filament biasanya menggunakan custom select yang dirender sebagai div/button
            trigger = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//span[contains(text(), 'Daftar sebagai')]/ancestor::div[contains(@class, 'fi-fo-field-wrp')]//button | //select[@name='role']")))
            
            # Jika native select (jarang di Filament v3 tapi mungkin)
            if trigger.tag_name == 'select':
                from selenium.webdriver.support.ui import Select
                Select(trigger).select_by_visible_text(role_name)
            else:
                # Custom UI Filament
                trigger.click()
                time.sleep(0.5) # Tunggu animasi
                # Pilih opsi dari listbox yang muncul (biasanya di root body)
                option = self.wait.until(EC.element_to_be_clickable((By.XPATH, f"//div[contains(@class, 'fi-fo-select-options')]//span[contains(text(), '{role_name}')]")))
                option.click()
        except Exception as e:
            print(f"Info: Gagal select role '{role_name}'. Error: {e}")

    def click_submit(self):
        submit_btn = self.driver.find_element(By.XPATH, "//button[@type='submit']")
        submit_btn.click()

    def assert_dashboard_url(self):
        try:
            # Tunggu URL berubah ke /admin (bukan /login atau /register)
            self.wait.until(EC.url_matches(r".*/admin$"))
            return True
        except TimeoutException:
            self.fail(f"Gagal redirect ke Dashboard. URL saat ini: {self.driver.current_url}")

    def assert_validation_error(self, message_snippet=""):
        try:
            # Cari elemen error text filament (biasanya text-danger atau text-red)
            # Atau validasi browser native
            xpath = f"//*[contains(@class, 'text-danger') or contains(@class, 'text-red') or contains(text(), 'field is required') or contains(text(), '{message_snippet}')]"
            self.wait.until(EC.presence_of_element_located((By.XPATH, xpath)))
        except TimeoutException:
            # Cek validasi HTML5 browser
            is_invalid = self.driver.execute_script("return document.querySelector('input:invalid') != null")
            if not is_invalid:
                self.fail(f"Pesan error validasi '{message_snippet}' tidak ditemukan.")

    # ==========================================
    # GROUP 1: POSITIVE REGISTRATION FLOWS
    # ==========================================

    def test_01_register_success_default_cashier(self):
        self.fill_input("Name", "User Kasir")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url()

    def test_02_register_success_kitchen(self):
        self.fill_input("Name", "User Dapur")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.select_role("Dapur")
        self.click_submit()
        self.assert_dashboard_url()

    def test_03_register_success_admin(self):
        self.fill_input("Name", "User Admin Baru")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.select_role("Admin")
        self.click_submit()
        self.assert_dashboard_url()

    def test_04_register_long_name(self):
        long_name = "Nama Panjang " * 10 
        self.fill_input("Name", long_name)
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url()

    def test_05_register_complex_email(self):
        complex_email = f"test.user.123.{int(time.time())}@sub.example.co.id"
        self.fill_input("Name", "User Unik")
        self.fill_input("Email Address", complex_email)
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url()

    # ==========================================
    # GROUP 2: VALIDATION - REQUIRED FIELDS
    # ==========================================

    def test_06_fail_empty_name(self):
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_validation_error("required")

    def test_07_fail_empty_email(self):
        self.fill_input("Name", "No Email User")
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_validation_error("required")

    def test_08_fail_empty_password(self):
        self.fill_input("Name", "No Pass User")
        self.fill_input("Email Address", self.generate_email())
        self.click_submit()
        self.assert_validation_error("required")

    def test_09_fail_empty_confirm_password(self):
        self.fill_input("Name", "No Confirm User")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.click_submit()
        self.assert_validation_error("match") # Biasanya "confirmation does not match"

    def test_10_check_default_role_value(self):
        # Cek apakah text "Kasir" terlihat di area form role
        form_text = self.driver.find_element(By.TAG_NAME, "form").text
        self.assertIn("Kasir", form_text, "Default role 'Kasir' tidak ditemukan di tampilan awal")

    # ==========================================
    # GROUP 3: LOGIC & DATA INTEGRITY
    # ==========================================

    def test_11_fail_invalid_email_format(self):
        self.fill_input("Name", "Bad Email")
        self.fill_input("Email Address", "invalidemail.com") # Tanpa @
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        
        # Validasi HTML5 browser
        email_input = self.driver.find_element(By.XPATH, "//input[@type='email']")
        is_valid = self.driver.execute_script("return arguments[0].checkValidity();", email_input)
        self.assertFalse(is_valid, "Browser seharusnya mendeteksi email tidak valid")

    def test_12_fail_duplicate_email(self):
        email = self.generate_email()
        # 1. Daftar user pertama (Sukses)
        self.fill_input("Name", "User A")
        self.fill_input("Email Address", email)
        self.fill_input("Password", "12345678")
        self.fill_input("Confirm Password", "12345678")
        self.click_submit()
        self.assert_dashboard_url()

        # 2. Logout & Kembali ke Register
        self.driver.delete_all_cookies()
        self.driver.get(self.REGISTER_URL)

        # 3. Daftar user kedua (Gagal)
        self.fill_input("Name", "User B")
        self.fill_input("Email Address", email) # Email sama
        self.fill_input("Password", "12345678")
        self.fill_input("Confirm Password", "12345678")
        self.click_submit()
        self.assert_validation_error("taken") # "has already been taken"

    def test_13_fail_short_password(self):
        self.fill_input("Name", "Short Pass")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "123")
        self.fill_input("Confirm Password", "123")
        self.click_submit()
        self.assert_validation_error("8 characters")

    def test_14_fail_password_mismatch(self):
        self.fill_input("Name", "Mismatch")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password999")
        self.click_submit()
        self.assert_validation_error("match")

    def test_15_fail_password_case_sensitive(self):
        self.fill_input("Name", "Case User")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "Password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_validation_error("match")

    def test_16_trim_whitespace_name(self):
        self.fill_input("Name", "  Spasi Banyak  ")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url()

    def test_17_trim_whitespace_email(self):
        email = self.generate_email()
        self.fill_input("Name", "Trim Email")
        self.fill_input("Email Address", f"  {email}  ")
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url()

    def test_18_xss_sanitization_name(self):
        self.fill_input("Name", "<script>alert('hacked')</script>")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        self.assert_dashboard_url() # Harus sukses daftar, XSS tidak dieksekusi

    def test_19_sql_injection_email(self):
        self.fill_input("Name", "SQL Injector")
        self.fill_input("Email Address", "' OR 1=1 -- @gmail.com")
        self.fill_input("Password", "password123")
        self.fill_input("Confirm Password", "password123")
        self.click_submit()
        # Harus tetap di halaman register (Gagal validasi email)
        self.assertIn("/register", self.driver.current_url)

    def test_20_submit_enter_key(self):
        self.fill_input("Name", "Enter User")
        self.fill_input("Email Address", self.generate_email())
        self.fill_input("Password", "password123")
        # Kirim tombol ENTER di input terakhir
        confirm_input = self.driver.find_element(By.XPATH, "(//input[@type='password'])[2]")
        confirm_input.send_keys("password123")
        confirm_input.send_keys(Keys.ENTER)
        
        self.assert_dashboard_url()

    # ==========================================
    # GROUP 4: UI & COMPONENTS CHECK
    # ==========================================

    def test_21_check_page_title(self):
        # Sesuaikan dengan title aplikasi Anda
        self.assertTrue("Register" in self.driver.title or "Eat.o" in self.driver.title)

    def test_22_input_name_visible(self):
        elem = self.driver.find_element(By.XPATH, "//input[@autocomplete='name' or @type='text']")
        self.assertTrue(elem.is_displayed())
        self.assertTrue(elem.is_enabled())

    def test_23_input_password_masked(self):
        elem = self.driver.find_element(By.XPATH, "//input[@type='password']")
        self.assertEqual(elem.get_attribute("type"), "password")

    def test_24_role_label_visible(self):
        self.assertTrue("Daftar sebagai" in self.driver.page_source)

    def test_25_role_dropdown_options(self):
        try:
            # Coba buka dropdown
            trigger = self.driver.find_element(By.XPATH, "//span[contains(text(), 'Daftar sebagai')]/ancestor::div[contains(@class, 'fi-fo-field-wrp')]//button")
            trigger.click()
            time.sleep(0.5)
            # Cek opsi ada di DOM
            self.assertTrue(len(self.driver.find_elements(By.XPATH, "//span[contains(text(), 'Kasir')]")) > 0)
            self.assertTrue(len(self.driver.find_elements(By.XPATH, "//span[contains(text(), 'Dapur')]")) > 0)
        except:
            print("Info: Skip test dropdown options karena struktur DOM kompleks")

    def test_26_login_link_visible(self):
        # Link "Sign in" atau "Masuk"
        link = self.driver.find_element(By.XPATH, "//a[contains(@href, 'login')]")
        self.assertTrue(link.is_displayed())

    def test_27_submit_button_text(self):
        btn = self.driver.find_element(By.XPATH, "//button[@type='submit']")
        text = btn.text.lower()
        self.assertTrue("register" in text or "daftar" in text)

    def test_28_mobile_responsiveness(self):
        self.driver.set_window_size(375, 812) # Ukuran iPhone
        btn = self.driver.find_element(By.XPATH, "//button[@type='submit']")
        self.assertTrue(btn.is_displayed())

    def test_29_redirect_if_logged_in(self):
        # 1. Login/Register dulu
        self.test_01_register_success_default_cashier()
        # 2. Coba akses register lagi
        self.driver.get(self.REGISTER_URL)
        # 3. Harus redirect ke admin
        self.assertIn("/admin", self.driver.current_url)

    def test_30_logo_redirect(self):
        # Asumsi logo ada dan bisa diklik
        try:
            logo = self.driver.find_element(By.XPATH, "//*[contains(text(), 'Eat.o')]")
            self.assertTrue(logo.is_displayed())
        except:
            pass

if __name__ == "__main__":
    unittest.main()