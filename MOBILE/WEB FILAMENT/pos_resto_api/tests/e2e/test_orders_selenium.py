import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# ==========================================
# KONFIGURASI
# ==========================================
BASE_URL = "http://127.0.0.1:8000"
ADMIN_EMAIL = "admin1@gmail.com"
ADMIN_PASSWORD = "admin1234"

# DATA SESUAI REQUEST
DATA_KASIR = "Yaya"
DATA_MEJA = "A1"         
DATA_MENU = "Mie Bakar"  
STATUS_AWAL = "Pending"

class FilamentOrderSeleniumTest(unittest.TestCase):

    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        # options.add_argument("--headless") 
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 20)
        self.login()

    def tearDown(self):
        if self.driver:
            self.driver.save_screenshot("last_state.png")
            self.driver.quit()

    # ==========================================
    # HELPER FUNCTIONS
    # ==========================================
    def force_click(self, element):
        """Klik paksa via Javascript (Anti gagal)"""
        self.driver.execute_script("arguments[0].click();", element)

    def select_dropdown(self, label_text, search_text):
        """Memilih Dropdown Filament V3 (Searchable)"""
        print(f"   -> Memilih '{search_text}' pada '{label_text}'...")
        try:
            # Cari Wrapper Input Dropdown berdasarkan Label
            trigger = self.wait.until(EC.element_to_be_clickable(
                (By.XPATH, f"//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., '{label_text}')]]//div[contains(@class, 'fi-input-wrp')]")
            ))
            trigger.click()
            time.sleep(0.5)

            # Ketik Kata Kunci
            actions = ActionChains(self.driver)
            actions.send_keys(search_text)
            actions.perform()
            time.sleep(2.5) # WAJIB TUNGGU SEARCH AJAX

            # Klik Pilihan yang Muncul (role='option')
            # exact search dulu, kalau gagal baru contains
            try:
                option = self.wait.until(EC.element_to_be_clickable(
                    (By.XPATH, f"//div[@role='option'][normalize-space(.)='{search_text}']")
                ))
            except:
                option = self.wait.until(EC.element_to_be_clickable(
                    (By.XPATH, f"//div[@role='option'][contains(., '{search_text}')]")
                ))
            
            option.click()
            time.sleep(1) 
            
        except Exception as e:
            print(f"   ⚠️ Gagal memilih '{search_text}'. Pastikan data ada di database!")
            self.driver.save_screenshot("error_dropdown.png")
            raise e

    def login(self):
        print("Log in...")
        self.driver.get(f"{BASE_URL}/admin/login")
        
        # Isi Email
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='email']"))).send_keys(ADMIN_EMAIL)
        # Isi Password
        self.driver.find_element(By.CSS_SELECTOR, "input[type='password']").send_keys(ADMIN_PASSWORD)
        
        # Klik Tombol Sign In (Cari tombol apa saja yang tipe submit)
        sign_in_btn = self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        self.force_click(sign_in_btn)
        
        # Tunggu Masuk Dashboard
        try:
            self.wait.until(EC.url_contains("/admin"))
            print("✅ Login Berhasil")
        except:
            print("❌ Login Gagal atau lama. Cek screenshot.")
            self.driver.save_screenshot("login_failed.png")
            raise

    # ==========================================
    # MAIN TEST
    # ==========================================
    def test_crud_order_yaya(self):
        print("\n=== MULAI TEST SELENIUM: ORDER YAYA ===")

        # --- STEP 1: CREATE ---
        print("\n--- STEP 1: CREATE ---")
        self.driver.get(f"{BASE_URL}/admin/orders/create")
        
        # DEBUG: Cek URL saat ini (apakah dilempar balik ke dashboard?)
        time.sleep(2) # Tunggu redirect jika ada
        print(f"Current URL: {self.driver.current_url}")
        
        if "create" not in self.driver.current_url:
            print("❌ ERROR: Tidak berada di halaman Create! Mungkin Permission Error.")
            self.fail("Gagal masuk halaman Create.")

        # 1. Isi Customer Name (SMART SELECTOR)
        print(f"Mengisi Customer: {DATA_KASIR}")
        try:
            # Coba 1: Cari input text apapun yang visible pertama kali (Biasanya Customer Name paling atas)
            name_input = self.wait.until(EC.visibility_of_element_located(
                (By.XPATH, "(//div[contains(@class, 'fi-fo-field-wrp')]//input[@type='text'])[1]")
            ))
            # Coba 2: Kalau mau spesifik ID (Backup)
            # name_input = self.wait.until(EC.visibility_of_element_located((By.XPATH, "//input[contains(@id, 'customer_name')]")))
            
            name_input.clear()
            name_input.send_keys(DATA_KASIR)
        except Exception as e:
            print("❌ Gagal menemukan input Customer Name.")
            self.driver.save_screenshot("error_input_customer.png")
            raise e

        # 2. Pilih Meja (A1)
        try:
            self.select_dropdown("Resto table", DATA_MEJA)
        except:
            print("   ⚠️ Skip Meja (Mungkin label beda atau data kosong)")

        # 3. Pilih Menu (Mie Bakar) - REPEATER
        print(f"Memilih Menu: {DATA_MENU}")
        try:
            # Selector khusus untuk dropdown di dalam repeater (Label 'Menu')
            menu_trigger = self.wait.until(EC.element_to_be_clickable(
                (By.XPATH, "//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., 'Menu')]]//div[contains(@class, 'fi-input-wrp')]")
            ))
            menu_trigger.click()
            time.sleep(0.5)
            
            # Ketik
            ActionChains(self.driver).send_keys(DATA_MENU).perform()
            time.sleep(2.5) # WAJIB TUNGGU SEARCH
            
            # Pilih
            self.wait.until(EC.element_to_be_clickable(
                (By.XPATH, f"//div[@role='option'][contains(., '{DATA_MENU}')]")
            )).click()
        except Exception:
            print(f"❌ Gagal pilih menu! Pastikan stok '{DATA_MENU}' > 0")
            self.driver.save_screenshot("error_menu.png")
            raise

        # 4. Validasi Harga (Tunggu harga muncul)
        print("Menunggu harga otomatis...")
        try:
            # Cari input price_at_time dan tunggu sampai valuenya tidak 0
            WebDriverWait(self.driver, 10).until(lambda d: d.find_element(By.XPATH, "//input[contains(@id, 'price_at_time')]").get_attribute("value") not in [None, "", "0"])
            print("   -> Harga muncul.")
        except:
            print("   ⚠️ Harga belum muncul atau 0. Tetap lanjut...")

        # 5. Isi Quantity (1)
        print("Mengisi Qty: 1")
        # Cari input quantity (biasanya input type number pertama atau kedua di repeater)
        qty_input = self.driver.find_element(By.XPATH, "//input[contains(@id, 'quantity')]")
        qty_input.clear()
        qty_input.send_keys("1")

        # 6. TRIGGER TOTAL (PENTING: KLIK JUDUL)
        self.driver.find_element(By.TAG_NAME, "h1").click()
        time.sleep(2) # Tunggu kalkulasi total price

        # 7. Klik Create
        print("Klik tombol Create...")
        create_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]")
        self.force_click(create_btn)

        # 8. Validasi Sukses
        try:
            # Tunggu notifikasi Created atau redirect ke index
            self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Created')]")))
            print("✅ Order Created Successfully")
        except:
            print("❌ Gagal Create. Cek screenshot 'error_create.png'")
            # Cek apakah ada pesan error validasi
            errors = self.driver.find_elements(By.CLASS_NAME, "text-danger-600")
            for err in errors:
                print(f"   -> Error Validasi: {err.text}")
            self.driver.save_screenshot("error_create.png")
            raise

        # --- STEP 2: READ & UPDATE ---
        print("\n--- STEP 2: READ & UPDATE ---")
        self.driver.get(f"{BASE_URL}/admin/orders")
        
        # Search Yaya
        search_box = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search_box.clear()
        search_box.send_keys(DATA_KASIR)
        time.sleep(2.5) # Tunggu filter

        # Klik Edit
        print("Klik Edit...")
        try:
            edit_btn = self.driver.find_element(By.XPATH, f"//tr[contains(., '{DATA_KASIR}')]//a[contains(@href, '/edit')]")
            self.force_click(edit_btn)
        except:
            print("❌ Tidak bisa menemukan data di tabel. Screenshot 'error_table.png'")
            self.driver.save_screenshot("error_table.png")
            raise

        # Update Nama
        print("Update nama...")
        # Cari input text pertama lagi (Customer Name)
        name_input = self.wait.until(EC.visibility_of_element_located((By.XPATH, "(//div[contains(@class, 'fi-fo-field-wrp')]//input[@type='text'])[1]")))
        name_input.send_keys(" Updated")

        # Update Status (Kalau dropdown ada)
        try:
            self.select_dropdown("Status", "Preparing")
        except:
            pass

        # Klik H1 biar blur
        self.driver.find_element(By.TAG_NAME, "h1").click()
        time.sleep(1)

        # Save
        print("Klik Save...")
        save_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]")
        self.force_click(save_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Saved')]")))
        print("✅ Order Updated Successfully")

        # --- STEP 3: DELETE ---
        print("\n--- STEP 3: DELETE ---")
        # Klik Delete (Header)
        del_btn = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(., 'Delete')]")))
        self.force_click(del_btn)
        
        # Konfirmasi Modal (PENTING)
        print("Konfirmasi Hapus...")
        time.sleep(1) # Tunggu modal animasi
        confirm_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//div[contains(@class, 'fi-modal')]//button[contains(., 'Delete')]")
        ))
        self.force_click(confirm_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Deleted')]")))
        print("✅ Order Deleted Successfully")

if __name__ == "__main__":
    unittest.main()