import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException

# KONFIGURASI
BASE_URL = "http://127.0.0.1:8000"
ADMIN_EMAIL = "admin1@gmail.com"
ADMIN_PASSWORD = "admin1234"

class FilamentCategoriesTest(unittest.TestCase):

    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        # options.add_argument("--headless") 
        
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 15) 
        
        try:
            self.login()
            self.navigate_to_categories()
        except Exception as e:
            self.driver.save_screenshot("setup_error.png")
            raise e

    def tearDown(self):
        if self.driver:
            self.driver.quit()

    # --- HELPER SAKTI: SAFE CLICK ---
    def safe_click(self, element):
        """
        Mencoba klik biasa dulu. Jika gagal (intercepted/not clickable),
        pakai JavaScript click (memaksa klik pada DOM).
        """
        try:
            element.click()
        except (ElementClickInterceptedException, Exception):
            # Fallback: Pakai JS Executor
            self.driver.execute_script("arguments[0].click();", element)

    # --- LOGIN ---
    def login(self):
        print("Login Process...")
        self.driver.get(f"{BASE_URL}/admin/login")
        
        email_input = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='email']")))
        email_input.clear()
        email_input.send_keys(ADMIN_EMAIL)
        
        self.driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys(ADMIN_PASSWORD)
        
        # Klik tombol submit
        submit_btn = self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        self.safe_click(submit_btn)
        
        # Tunggu dashboard
        self.wait.until(lambda driver: "/login" not in driver.current_url)
        print("Login Success!")

    # --- NAVIGASI ---
    def navigate_to_categories(self):
        print("Navigating to Categories...")
        self.driver.get(f"{BASE_URL}/admin/categories")
        try:
            # Tunggu H1 muncul
            self.wait.until(EC.presence_of_element_located((By.TAG_NAME, "h1")))
        except TimeoutException:
            print("Gagal load Categories.")
            self.driver.save_screenshot("nav_error.png")
            raise

    # --- HELPER CREATE ---
    def create_category_helper(self, name, description="Auto Desc"):
        print(f"Creating Category: {name}")
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        
        # Isi Nama
        name_input = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        name_input.send_keys(name)
        
        # Isi Deskripsi
        try:
            desc_input = self.driver.find_element(By.TAG_NAME, "textarea")
        except:
            desc_input = self.driver.find_element(By.CSS_SELECTOR, "input[id*='description']")
        desc_input.send_keys(description)
        
        # --- FIX UTAMA DI SINI ---
        # Cari tombol yang BENAR. Filament punya tombol "Create" dan "Create & create another".
        # Kita cari tombol yang type='submit' dan mengandung kata 'Create' tapi BUKAN 'another'
        create_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[@type='submit' and contains(., 'Create') and not(contains(., 'another'))]")
        ))
        
        # Gunakan safe_click
        self.safe_click(create_btn)
        
        # Tunggu notifikasi sukses
        print("Waiting for 'Created' notification...")
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Created')]")))
        print("Category Created!")

    def disable_html5_validation(self):
        """Inject JS untuk mematikan validasi required browser"""
        self.driver.execute_script(
            "var forms = document.querySelectorAll('form');"
            "for(var i=0; i<forms.length; i++){ forms[i].setAttribute('novalidate', 'true'); }"
        )

    def is_text_present(self, text):
        return text in self.driver.page_source

    # ==========================================
    # TEST CASES
    # ==========================================

    def test_01_check_page_title(self):
        self.assertIn("Categories", self.driver.title)

    def test_02_create_flow(self):
        name = f"Sel Cat {int(time.time())}"
        try:
            self.create_category_helper(name)
            
            # Verifikasi di list
            self.navigate_to_categories()
            # Gunakan wait explicit untuk search debounce
            search_input = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
            search_input.send_keys(name)
            time.sleep(2) # Tunggu livewire refresh table
            
            self.assertTrue(self.is_text_present(name), "Data tidak ditemukan di tabel")
        except Exception as e:
            self.driver.save_screenshot("error_create_flow.png")
            raise e

    def test_03_validation_required(self):
        print("Testing Validation...")
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        
        # Tunggu form siap
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        
        # Matikan validasi browser
        self.disable_html5_validation()
        
        # Klik Create (tombol utama)
        create_btn = self.driver.find_element(By.XPATH, "//button[@type='submit' and contains(., 'Create') and not(contains(., 'another'))]")
        self.safe_click(create_btn)
        
        try:
            # Tunggu pesan error muncul di bawah input
            # Filament biasanya meletakkan error di div dengan class text-danger atau semacamnya
            # Kita cari text spesifik
            error_msg = self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "//*[contains(text(), 'field is required') or contains(text(), 'wajib')]")
            ))
            self.assertTrue(error_msg.is_displayed())
            print("Validation Passed!")
        except TimeoutException:
            print("Validation Failed: Error message not found")
            self.driver.save_screenshot("error_validation.png")
            raise

if __name__ == "__main__":
    unittest.main()