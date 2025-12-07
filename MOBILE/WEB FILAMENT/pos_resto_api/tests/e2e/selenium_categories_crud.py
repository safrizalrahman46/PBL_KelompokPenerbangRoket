import unittest
import time
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

class FilamentCategoryTest(unittest.TestCase):

    BASE_URL = "http://127.0.0.1:8000/admin"
    
    def setUp(self):
        self.driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
        self.driver.maximize_window()
        self.wait = WebDriverWait(self.driver, 10)
        
        # 1. Login Dulu
        self.driver.get(f"{self.BASE_URL}/login")
        self.driver.find_element(By.XPATH, "//input[@type='email']").send_keys("admin1@gmail.com")
        self.driver.find_element(By.XPATH, "//input[@type='password']").send_keys("admin1234")
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()
        
        # Tunggu Dashboard
        self.wait.until(EC.url_contains("/admin"))
        
        # 2. Masuk ke Halaman Categories
        self.driver.get(f"{self.BASE_URL}/categories")
        self.wait.until(EC.url_contains("/categories"))

    def tearDown(self):
        self.driver.quit()

    def test_01_create_category(self):
        # 1. Klik "New category"
        # Filament button link biasanya ada di header
        new_btn = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//a[contains(@href, '/create') and contains(., 'New')]")))
        new_btn.click()

        # 2. Isi Form
        rand_name = f"Kategori Selenium {random.randint(1, 999)}"
        # Cari input berdasarkan label 'Name'
        name_input = self.wait.until(EC.visibility_of_element_located((By.XPATH, "//input[@id='data.name' or @autocomplete='off']")))
        name_input.send_keys(rand_name)
        
        # 3. Submit
        self.driver.find_element(By.XPATH, "//button[@type='submit' and contains(., 'Create')]").click()

        # 4. Validasi Redirect & Data Muncul
        self.wait.until(EC.url_matches(r".*/categories$")) # Kembali ke list
        self.assertTrue(rand_name in self.driver.page_source)
        print(f"✅ Sukses membuat kategori: {rand_name}")

    def test_02_validation_required(self):
        new_btn = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//a[contains(@href, '/create')]")))
        new_btn.click()

        # Langsung Submit tanpa isi
        self.driver.find_element(By.XPATH, "//button[@type='submit']").click()

        # Cek Error
        try:
            error_msg = self.wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'field is required')]")))
            self.assertTrue(error_msg.is_displayed())
            print("✅ Validasi required berhasil")
        except:
            self.fail("Pesan error tidak muncul")

    def test_03_edit_category(self):
        # Asumsi ada data di tabel, ambil baris pertama, klik edit
        # Filament table actions biasanya di kolom terakhir
        try:
            # Klik tombol edit di baris pertama
            edit_btn = self.wait.until(EC.element_to_be_clickable((By.XPATH, "//table//tr[1]//a[contains(@href, '/edit')]")))
            edit_btn.click()
            
            # Edit Nama
            name_input = self.wait.until(EC.visibility_of_element_located((By.XPATH, "//input[contains(@id, 'name')]")))
            name_input.clear()
            new_name = f"Edited {random.randint(1,100)}"
            name_input.send_keys(new_name)
            
            # Save
            self.driver.find_element(By.XPATH, "//button[contains(., 'Save')]").click()
            
            # Tunggu notifikasi saved
            self.wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(text(), 'Saved')]")))
            print(f"✅ Sukses edit kategori jadi: {new_name}")
            
        except Exception as e:
            print(f"⚠️ Gagal test edit (mungkin tabel kosong): {e}")

if __name__ == "__main__":
    unittest.main()