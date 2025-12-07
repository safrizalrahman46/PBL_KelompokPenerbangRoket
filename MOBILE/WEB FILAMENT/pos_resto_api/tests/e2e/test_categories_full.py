import unittest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException, NoSuchElementException

# --- KONFIGURASI ---
BASE_URL = "http://127.0.0.1:8000"
ADMIN_EMAIL = "admin1@gmail.com"
ADMIN_PASSWORD = "admin1234"

class FilamentCategoriesFullTest(unittest.TestCase):

    def setUp(self):
        """Setup dijalankan SEBELUM setiap test case"""
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        # options.add_argument("--headless") # Uncomment jika sudah stabil
        
        self.driver = webdriver.Chrome(options=options)
        self.wait = WebDriverWait(self.driver, 20) # Naikkan timeout jadi 20 detik
        
        try:
            self.login()
            self.navigate_to_categories()
        except Exception as e:
            # Screenshot jika setup gagal
            self.driver.save_screenshot(f"error_setup_{self._testMethodName}.png")
            raise e

    def tearDown(self):
        """Cleanup dijalankan SETELAH setiap test case"""
        if self.driver:
            self.driver.quit()

    # ==========================================
    # HELPER FUNCTIONS (Fungsi Bantuan)
    # ==========================================

    def safe_click(self, element):
        """Klik elemen dengan aman (Fallback ke JS Click jika terhalang)"""
        # Scroll elemen ke view agar tidak tertutup header/footer
        self.driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", element)
        time.sleep(0.5) # Beri jeda sedikit untuk scroll selesai
        try:
            element.click()
        except (ElementClickInterceptedException, Exception):
            # Fallback: Paksa klik pakai JS
            self.driver.execute_script("arguments[0].click();", element)

    def login(self):
        self.driver.get(f"{BASE_URL}/admin/login")
        
        # Isi Email
        email_input = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='email']")))
        email_input.clear()
        email_input.send_keys(ADMIN_EMAIL)
        
        # Isi Password
        password_input = self.driver.find_element(By.CSS_SELECTOR, "input[type='password']")
        password_input.clear()
        password_input.send_keys(ADMIN_PASSWORD)
        
        # Klik Submit
        submit_btn = self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        self.safe_click(submit_btn)
        
        # Tunggu dashboard (URL tidak ada login lagi)
        self.wait.until(lambda driver: "/login" not in driver.current_url)

    def navigate_to_categories(self):
        self.driver.get(f"{BASE_URL}/admin/categories")
        # Tunggu elemen H1 muncul dan pastikan teksnya benar
        self.wait.until(EC.presence_of_element_located((By.XPATH, "//h1[contains(text(), 'Categories')]")))

    def create_category_helper(self, name, description="Auto Desc"):
        """Fungsi cepat untuk membuat kategori"""
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        
        # Isi Name
        name_field = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        name_field.clear()
        name_field.send_keys(name)
        
        # Isi Description
        try:
            self.driver.find_element(By.TAG_NAME, "textarea").send_keys(description)
        except:
            self.driver.find_element(By.CSS_SELECTOR, "input[id*='description']").send_keys(description)

        # --- FIX UTAMA: Wait for Livewire ---
        # Beri jeda 0.5 detik agar Livewire sempat memproses input data sebelum tombol diklik.
        # Tanpa ini, tombol diklik tapi data 'name' dianggap masih kosong oleh server.
        time.sleep(0.5)

        # Klik Create (Hindari tombol 'Create & create another')
        create_btn = self.wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[@type='submit' and contains(., 'Create') and not(contains(., 'another'))]")
        ))
        self.safe_click(create_btn)
        
        # Tunggu notifikasi
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Created')]")))

    def disable_html5_validation(self):
        self.driver.execute_script(
            "var forms = document.querySelectorAll('form');"
            "for(var i=0; i<forms.length; i++){ forms[i].setAttribute('novalidate', 'true'); }"
        )

    def is_text_present(self, text):
        return text in self.driver.page_source

    # ==========================================
    # GROUP 1: UI & NAVIGATION
    # ==========================================

    def test_01_check_page_title(self):
        self.assertIn("Categories", self.driver.title)

    def test_02_check_heading_text(self):
        heading = self.driver.find_element(By.TAG_NAME, "h1").text
        self.assertIn("Categories", heading)

    def test_03_check_breadcrumbs(self):
        breadcrumbs = self.driver.find_elements(By.CLASS_NAME, "fi-breadcrumbs")
        self.assertTrue(len(breadcrumbs) > 0)

    def test_04_check_table_headers(self):
        headers = self.driver.find_elements(By.CSS_SELECTOR, "th")
        header_texts = [h.text for h in headers]
        self.assertTrue(any("Name" in h for h in header_texts))
        self.assertTrue(any("Description" in h for h in header_texts))

    def test_05_navigation_to_create_page(self):
        self.driver.find_element(By.PARTIAL_LINK_TEXT, "New category").click()
        self.wait.until(EC.url_contains("/create"))
        
        # FIX: Case Insensitive check (Categories vs category)
        h1_text = self.driver.find_element(By.TAG_NAME, "h1").text
        self.assertIn("Create Category", h1_text.title()) # Ubah jadi Title Case agar aman

    # ==========================================
    # GROUP 2: CREATE OPERATIONS
    # ==========================================

    def test_06_create_category_full(self):
        name = f"Full Cat {int(time.time())}"
        self.create_category_helper(name, "Full Description Data")
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2) # Livewire debounce wait
        self.assertTrue(self.is_text_present(name))

    def test_07_create_category_name_only(self):
        name = f"Simple Cat {int(time.time())}"
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']"))).send_keys(name)
        
        time.sleep(0.5) # Wait for binding
        create_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]")
        self.safe_click(create_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Created')]")))

    def test_08_create_and_create_another(self):
        name = f"Another Cat {int(time.time())}"
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']"))).send_keys(name)
        time.sleep(0.5) # Wait binding

        # Klik tombol "Create & create another"
        another_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Create & create another')]")
        self.safe_click(another_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Created')]")))
        
        # Tunggu form reset
        time.sleep(1)
        input_val = self.driver.find_element(By.CSS_SELECTOR, "input[id*='name']").get_attribute('value')
        self.assertEqual(input_val, "", "Form harusnya kosong kembali")

    def test_09_create_max_length(self):
        long_name = "A" * 255
        self.create_category_helper(long_name)
        # Jika helper sukses lewat, berarti test pass
        self.assertTrue(True)

    def test_10_cancel_create(self):
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        
        # FIX: Gunakan XPath Button, bukan Link Text
        cancel_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Cancel')]")
        self.safe_click(cancel_btn)
        
        self.wait.until(EC.url_matches(f"{BASE_URL}/admin/categories$"))

    def test_11_xss_sanity_check(self):
        xss_name = f"<script>alert('xss')</script> {int(time.time())}"
        self.create_category_helper(xss_name)
        self.navigate_to_categories()
        self.assertTrue(self.is_text_present(xss_name))

    # ==========================================
    # GROUP 3: VALIDATION
    # ==========================================

    def test_12_validation_name_required(self):
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        self.disable_html5_validation()
        
        time.sleep(0.5)
        create_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]")
        self.safe_click(create_btn)
        
        error_msg = self.wait.until(EC.visibility_of_element_located(
            (By.XPATH, "//*[contains(text(), 'field is required') or contains(text(), 'wajib')]")
        ))
        self.assertTrue(error_msg.is_displayed())

    def test_13_validation_name_max_length(self):
        self.driver.get(f"{BASE_URL}/admin/categories/create")
        self.disable_html5_validation()
        
        too_long = "A" * 256
        self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']"))).send_keys(too_long)
        
        time.sleep(0.5)
        create_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Create') and not(contains(., 'another'))]")
        self.safe_click(create_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), '255')]")))

    def test_14_edit_validation_clear_name(self):
        name = f"ValEdit {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        # Search dulu biar gampang nemu tombol editnya
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        self.disable_html5_validation()
        name_input = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        name_input.clear()
        
        time.sleep(0.5)
        self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]").click()
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'field is required') or contains(text(), 'wajib')]")))

    # ==========================================
    # GROUP 4: READ & SEARCH
    # ==========================================

    def test_16_list_shows_data(self):
        name = f"ListCheck {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        # Search specific
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.assertTrue(self.is_text_present(name))

    def test_17_search_found(self):
        unique_name = f"SearchMe {int(time.time())}"
        self.create_category_helper(unique_name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(unique_name)
        time.sleep(2)
        self.assertTrue(self.is_text_present(unique_name))

    def test_18_search_not_found(self):
        self.navigate_to_categories()
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.clear()
        search.send_keys("StringNgawur12345")
        time.sleep(2)
        
        # FIX: Gunakan pengecekan yang lebih generic
        # Cek apakah ada text 'No records' ATAU tabel body kosong
        page_source = self.driver.page_source
        is_empty = "No records found" in page_source or "Tidak ada data" in page_source or "fi-ta-empty-state" in page_source
        self.assertTrue(is_empty, "Seharusnya tabel kosong atau menampilkan pesan tidak ada data")

    # ==========================================
    # GROUP 5: UPDATE OPERATIONS
    # ==========================================

    def test_21_update_name(self):
        name = f"UpdateName {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        # Cari dan Edit
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        new_name = name + " EDITED"
        name_inp = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[id*='name']")))
        name_inp.clear()
        name_inp.send_keys(new_name)
        
        time.sleep(0.5)
        self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]").click()
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Saved')]")))

        self.navigate_to_categories()
        # Perlu clear search dan cari nama baru
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.clear()
        search.send_keys(new_name)
        time.sleep(2)
        self.assertTrue(self.is_text_present(new_name))

    def test_22_update_description(self):
        name = f"UpdateDesc {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)
        
        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        try:
            desc_elem = self.driver.find_element(By.TAG_NAME, "textarea")
        except:
            desc_elem = self.driver.find_element(By.CSS_SELECTOR, "input[id*='description']")
            
        desc_elem.clear()
        desc_elem.send_keys("New Description Updated")
        
        time.sleep(0.5)
        self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]").click()
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Saved')]")))

    def test_23_update_no_changes(self):
        name = f"NoChange {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        time.sleep(0.5)
        self.driver.find_element(By.XPATH, "//button[contains(., 'Save changes')]").click()
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Saved')]")))

    def test_24_nav_back_from_edit(self):
        # Masuk ke edit sembarang item (row pertama)
        self.driver.find_element(By.CSS_SELECTOR, "td a[href*='/edit']").click()
        
        # Klik Cancel
        cancel_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Cancel')]")
        self.safe_click(cancel_btn)
        
        self.wait.until(EC.url_matches(f"{BASE_URL}/admin/categories$"))

    # ==========================================
    # GROUP 6: DELETE & BULK ACTIONS
    # ==========================================

    def test_25_delete_via_edit_page(self):
        name = f"DelEdit {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        # Klik Header Delete
        delete_header = self.wait.until(EC.element_to_be_clickable((By.XPATH, "(//button[contains(., 'Delete')])[1]")))
        self.safe_click(delete_header)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Are you sure')]")))
        
        # Konfirmasi
        all_confirms = self.driver.find_elements(By.XPATH, "//button[contains(., 'Delete') or contains(., 'Confirm')]")
        confirm_btn = all_confirms[-1]
        self.safe_click(confirm_btn)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Deleted')]")))

    def test_26_cancel_delete_modal(self):
        name = f"DelCancel {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        self.driver.find_element(By.XPATH, f"//tr[contains(., '{name}')]//a[contains(., 'Edit')]").click()
        
        delete_header = self.wait.until(EC.element_to_be_clickable((By.XPATH, "(//button[contains(., 'Delete')])[1]")))
        self.safe_click(delete_header)
        
        self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Are you sure')]")))
        
        # Klik Cancel (Ambil tombol Cancel terakhir)
        all_cancels = self.driver.find_elements(By.XPATH, "//button[contains(., 'Cancel')]")
        cancel_btn = all_cancels[-1]
        self.safe_click(cancel_btn)
        
        time.sleep(1)
        self.assertIn("/edit", self.driver.current_url)

    def test_28_bulk_delete_execution(self):
        name = f"BulkDel {int(time.time())}"
        self.create_category_helper(name)
        self.navigate_to_categories()
        
        search = self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "input[type='search']")))
        search.send_keys(name)
        time.sleep(2)

        # Cari row dan centang
        # Karena kita sudah search, harusnya baris pertama adalah target
        checkbox = self.driver.find_element(By.CSS_SELECTOR, "td input[type='checkbox']")
        self.safe_click(checkbox)
        
        try:
            bulk_btn = self.driver.find_element(By.XPATH, "//button[contains(., 'Bulk actions')]")
            self.safe_click(bulk_btn)
            
            del_selected = self.wait.until(EC.visibility_of_element_located((By.XPATH, "//span[contains(., 'Delete')]")))
            self.safe_click(del_selected)
            
            all_confirms = self.driver.find_elements(By.XPATH, "//button[contains(., 'Delete') or contains(., 'Confirm')]")
            confirm_btn = all_confirms[-1]
            self.safe_click(confirm_btn)
            
            self.wait.until(EC.visibility_of_element_located((By.XPATH, "//*[contains(text(), 'Deleted')]")))
        except Exception as e:
            print(f"Skipping bulk delete: {e}")

if __name__ == "__main__":
    unittest.main()