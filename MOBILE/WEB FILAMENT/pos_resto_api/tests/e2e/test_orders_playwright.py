import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- KONFIGURASI ---
BASE_URL = "http://127.0.0.1:8000"
ADMIN_EMAIL = "admin1@gmail.com"
ADMIN_PASSWORD = "admin1234"

# --- DATA TEST ---
TARGET_MENU = "Mie Bakar"
TARGET_MEJA = "A1"
NAMA_KASIR_CUSTOMER = "Yaya" # Kita isi di Customer Name
TARGET_STATUS = "Pending"

class OrderSeleniumTest(unittest.TestCase):

    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 15)
        self.login()

    def tearDown(self):
        if self.driver:
            self.driver.quit()

    # --- HELPER ---
    def login(self):
        self.driver.get(f"{BASE_URL}/admin/login")
        self.wait.until(EC.visibility_of_element_located((By.ID, "data.email"))).send_keys(ADMIN_EMAIL)
        self.driver.find_element(By.ID, "data.password").send_keys(ADMIN_PASSWORD)
        self.driver.find_element(By.TAG_NAME, "button").click()
        self.wait.until(lambda d: "/login" not in d.current_url)

    def select_dropdown(self, label, search_text):
        """Memilih dropdown Filament yang searchable"""
        print(f"   -> Memilih '{search_text}' di '{label}'...")
        # Klik wrapper dropdown
        trigger = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, f"//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., '{label}')]]//div[contains(@class, 'fi-input-wrp')]")
        ))
        self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", trigger)
        time.sleep(0.5)
        trigger.click()
        
        # Ketik & Tunggu
        actions = ActionChains(self.driver)
        actions.send_keys(search_text)
        actions.perform()
        time.sleep(2) # Tunggu Loading Server
        
        # Klik Opsi
        option = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, f"//div[@role='option'][contains(., '{search_text}')]")
        ))
        option.click()
        time.sleep(1)

    def test_crud_order_yaya(self):
        print("\n=== MULAI TEST SELENIUM: ORDER YAYA ===")
        
        # 1. CREATE
        print("--- STEP 1: CREATE ---")
        self.driver.get(f"{BASE_URL}/admin/orders/create")
        self.wait.until(EC.presence_of_element_located((By.XPATH, "//input[contains(@id, 'customer_name')]")))
        
        # Isi Nama Kasir/Customer
        print(f"Mengisi Customer: {NAMA_KASIR_CUSTOMER}")
        name_input = self.driver.find_element(By.XPATH, "//input[contains(@id, 'customer_name')]")
        name_input.clear()
        name_input.send_keys(NAMA_KASIR_CUSTOMER)

        # Pilih Meja A1
        try:
            self.select_dropdown("Resto table", TARGET_MEJA)
        except:
            print("   ⚠️ Gagal memilih meja (Mungkin labelnya beda atau data A1 tidak ada).")

        # Pilih Menu Mie Bakar (Repeater)
        print(f"Memilih Menu: {TARGET_MENU}")
        menu_trigger = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//div[contains(@class, 'fi-fo-field-wrp')][.//label[contains(., 'Menu')]]//div[contains(@class, 'fi-input-wrp')]")
        ))
        menu_trigger.click()
        
        ActionChains(self.driver).send_keys(TARGET_MENU).perform()
        time.sleep(2) # Tunggu search
        
        self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, f"//div[@role='option'][contains(., '{TARGET_MENU}')]")
        )).click()
        time.sleep(2) # Tunggu harga muncul

        # Isi Quantity
        qty_input = self.driver.find_element(By.XPATH, "//input[contains(@id, 'quantity')]")
        qty_input.clear()
        qty_input.send_keys("2")

        # Klik Judul (Blur) untuk hitung total
        self.driver.find_element(By.TAG_NAME, "h1").click()
        time.sleep(1)

        # Klik Create
        print("Klik Create...")
        self.driver.find_element(By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]").click()
        
        # Validasi
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Created')]")))
        print("✅ Order Created Successfully")

        # 2. READ & UPDATE
        print("--- STEP 2: READ & UPDATE ---")
        self.driver.get(f"{BASE_URL}/admin/orders")
        
        # Search Yaya
        search = self.wait.until(EC.visibility_of_element_located((By.TAG_NAME, "input")))
        search.send_keys(NAMA_KASIR_CUSTOMER)
        time.sleep(2)
        
        # Klik Edit
        self.driver.find_element(By.XPATH, f"//tr[contains(., '{NAMA_KASIR_CUSTOMER}')]//a[contains(@href, '/edit')]").click()
        
        # Ubah Status
        print("Mengubah data...")
        name_input = self.wait.until(EC.visibility_of_element_located((By.XPATH, "//input[contains(@id, 'customer_name')]")))
        name_input.send_keys(" Updated")
        
        # Save
        self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]").click()
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Saved')]")))
        print("✅ Order Updated Successfully")

        # 3. DELETE
        print("--- STEP 3: DELETE ---")
        # Delete via tombol di halaman edit
        self.driver.find_element(By.XPATH, "//button[contains(., 'Delete')]").click()
        time.sleep(0.5)
        # Konfirmasi modal
        self.driver.find_element(By.XPATH, "//div[contains(@class, 'fi-modal')]//button[contains(., 'Delete')]").click()
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(., 'Deleted')]")))
        print("✅ Order Deleted Successfully")

if __name__ == "__main__":
    unittest.main()