import unittest
import time
import os
import tempfile
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException

# --- KONFIGURASI ---
BASE_URL = "http://127.0.0.1:8000"
ADMIN_EMAIL = "admin1@gmail.com"
ADMIN_PASSWORD = "admin1234"

class FilamentMenuSeleniumTest(unittest.TestCase):

    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        # options.add_argument("--headless") # Aktifkan jika ingin background process
        
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 20)
        
        try:
            self.login()
        except Exception as e:
            self.driver.save_screenshot("setup_error.png")
            raise e

    def tearDown(self):
        if self.driver:
            self.driver.quit()

    # --- HELPER FUNCTIONS ---
    def safe_click(self, element):
        """Mencoba klik biasa, jika gagal pakai JS Click"""
        try:
            self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", element)
            time.sleep(0.5) 
            element.click()
        except Exception:
            self.driver.execute_script("arguments[0].click();", element)

    def force_click(self, element):
        """Memaksa klik menggunakan JavaScript (Paling ampuh untuk tombol Submit)"""
        self.driver.execute_script("arguments[0].click();", element)

    def create_dummy_image(self):
        temp = tempfile.NamedTemporaryFile(suffix=".png", delete=False)
        temp.write(b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82')
        temp.close()
        return temp.name

    def login(self):
        self.driver.get(f"{BASE_URL}/admin/login")
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='email']"))).send_keys(ADMIN_EMAIL)
        self.driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys(ADMIN_PASSWORD)
        
        submit_btn = self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        self.safe_click(submit_btn)
        self.wait.until(lambda d: "/login" not in d.current_url)

    # ==========================================
    # TEST CRUD MENU (FIXED)
    # ==========================================

    def test_menu_crud_flow(self):
        timestamp = int(time.time())
        menu_name = f"Menu Py {timestamp}"
        updated_name = f"{menu_name} Edited"
        
        # ==========================================
        # 0. FUNGSI BANTUAN (DEFINISI ULANG)
        # ==========================================
        def fill_and_sync(selector, value):
            element = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, selector)))
            element.clear()
            element.send_keys(value)
            time.sleep(0.5) 
            # Paksa event agar Livewire sadar ada perubahan
            self.driver.execute_script("arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", element)
            self.driver.execute_script("arguments[0].dispatchEvent(new Event('change', { bubbles: true }));", element)
            time.sleep(1) # Tunggu sinkronisasi

        # ==========================================
        # 1. CREATE MENU (SUDAH SUKSES)
        # ==========================================
        print("--- STEP 1: CREATE MENU ---")
        self.driver.get(f"{BASE_URL}/admin/menus/create")
        self.wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        time.sleep(1)

        print(f"Mengisi Name: {menu_name}")
        fill_and_sync("input[id*='name']", menu_name)

        print("Memilih kategori 'Soda'...")
        try:
            dropdown_trigger = self.wait.until(EC.element_to_be_clickable(
                (By.XPATH, "//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., 'Category')]]//div[contains(@class, 'fi-input-wrp')]")
            ))
            self.safe_click(dropdown_trigger)
            time.sleep(0.5)
            
            actions = ActionChains(self.driver)
            actions.send_keys("Soda")
            actions.perform()
            
            soda_option = self.wait.until(EC.element_to_be_clickable(
                (By.XPATH, "//div[@role='option'][contains(., 'Soda')]")
            ))
            soda_option.click()
            time.sleep(1)
            
            # Verifikasi
            category_wrapper = self.driver.find_element(By.XPATH, "//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., 'Category')]]")
            if "Soda" in category_wrapper.text:
                print("Kategori Terpilih & Terverifikasi.")
            else:
                raise Exception("Kategori gagal dipilih")
        except Exception as e:
            self.driver.save_screenshot("error_category.png")
            raise e

        print("Mengisi Price & Stock...")
        fill_and_sync("input[id*='price']", "50000")
        fill_and_sync("input[id*='stock']", "100")

        print("Upload Gambar...")
        img_path = self.create_dummy_image()
        file_input = self.driver.find_element(By.CSS_SELECTOR, "input[type='file']")
        file_input.send_keys(img_path)
        self.wait.until(EC.visibility_of_element_located((By.XPATH, f"//*[contains(text(), '{os.path.basename(img_path)}')]")))
        time.sleep(2) 

        print("Mencoba klik Create...")
        self.driver.find_element(By.TAG_NAME, "h1").click() # Blur trigger
        time.sleep(1)

        create_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]")
        ))
        self.force_click(create_btn)

        try:
            self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "//*[contains(normalize-space(.), 'Created')]")
            ))
            print("✅ SUCCESS: Menu Created")
        except TimeoutException:
            self.driver.save_screenshot("error_create_submit.png")
            raise

        if os.path.exists(img_path): os.remove(img_path)

        # ==========================================
        # 2. READ MENU (VERIFIKASI)
        # ==========================================
        print("--- STEP 2: READ MENU ---")
        self.driver.get(f"{BASE_URL}/admin/menus")
        
        search_box = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search_box.clear()
        search_box.send_keys(menu_name)
        time.sleep(2) # Tunggu table reload

        self.assertIn(menu_name, self.driver.page_source)

        # ==========================================
        # 3. UPDATE MENU (PERBAIKAN DI SINI)
        # ==========================================
        print("--- STEP 3: UPDATE MENU ---")
        # Cari tombol edit
        edit_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, f"//tr[contains(., '{menu_name}')]//a[contains(@href, '/edit')]")
        ))
        self.safe_click(edit_btn)
        
        # TUNGGU FORM LOAD SEMPURNA
        self.wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        time.sleep(1)

        # --- GUNAKAN fill_and_sync DI SINI JUGA! ---
        print(f"Mengubah nama menjadi: {updated_name}")
        fill_and_sync("input[id*='name']", updated_name)
        
        # Trigger Blur (Klik Judul) agar input tersimpan ke state Livewire
        self.driver.find_element(By.TAG_NAME, "h1").click()
        time.sleep(1)
        
        # Klik Save Changes
        save_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(., 'Save changes')]")
        ))
        self.force_click(save_btn)
        
        # Tunggu notifikasi Saved
        try:
            self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "//*[contains(normalize-space(.), 'Saved')]")
            ))
            print("✅ SUCCESS: Menu Updated")
        except TimeoutException:
            print("❌ TIMEOUT: Gagal Update")
            self.driver.save_screenshot("error_update.png")
            raise

        # ==========================================
        # 4. DELETE MENU
        # ==========================================
        print("--- STEP 4: DELETE MENU ---")
        self.driver.get(f"{BASE_URL}/admin/menus")
        
        # Cari dengan nama BARU (Updated Name)
        search_box = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search_box.clear()
        search_box.send_keys(updated_name)
        time.sleep(2)

        # Klik Edit pada baris yang sesuai
        self.driver.find_element(By.XPATH, f"//tr[contains(., '{updated_name}')]//a[contains(., 'Edit')]").click()
        
        # Klik tombol Delete (biasanya ada di header action atau footer)
        # Kita cari tombol Delete yang berwarna merah/danger
        del_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(., 'Delete')]")
        ))
        self.safe_click(del_btn)
        
        # Konfirmasi Modal Delete
        print("Menunggu modal konfirmasi...")
        confirm_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//div[contains(@class, 'fi-modal')]//button[contains(., 'Delete')]")
        ))
        self.force_click(confirm_btn)
        
        # Validasi Deleted
        self.wait.until(EC.visibility_of_element_located(
            (By.XPATH, "//*[contains(normalize-space(.), 'Deleted')]")
        ))
        print("✅ FULL FLOW SUCCESS!")
        # ... (Lanjutkan Step READ, UPDATE, DELETE di sini jika Create berhasil) ...
if __name__ == "__main__":
    unittest.main()