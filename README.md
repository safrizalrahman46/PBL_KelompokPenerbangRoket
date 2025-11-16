# PBL: Ekosistem POS Kelompok Penerbang Roket

# 🚀 Tim Kami
* Ahmad Hayyin Baihaqi (Manajemen Proyek)
* M Nazril Nur Rahman (flutter IOS version)
* M Faruq Burhanuddin (UI UX, Flutter Slicing)
* Safrizal Rahman (Web Backend, Flutter Android version, Project Manager)

## 🔧 Laravel Web Backend Progress
[![Watch the video](https://img.youtube.com/vi/Zz_vo05khe0/maxresdefault.jpg)](https://youtu.be/Zz_vo05khe0)
*(klik gambar untuk membuka video)*

---

## 📱 Flutter POS Apps Progress
[![Watch the video](https://img.youtube.com/vi/rhiaAwGf0dw/maxresdefault.jpg)](https://youtu.be/rhiaAwGf0dw)
*(klik gambar untuk membuka video)*

---


## Dokumentasi untuk WBS (Work Breakdown system), Pengajuan IDE

<img width="1600" height="1200" alt="Image" src="https://github.com/user-attachments/assets/05f64f9b-5727-4b2b-8b95-d559ca617515" />


<p align="center">
  <img src="https://img.shields.io/badge/Tech-Laravel-FF2D20?style=for-the-badge&logo=laravel" alt="Laravel">
  <img src="https://img.shields.io/badge/Tech-Filament-FF842A?style=for-the-badge" alt="Filament">
  <img src="https://img.shields.io/badge/Tech-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Tech-React-61DAFB?style=for-the-badge&logo=react" alt="React">
</p>

# 🍽️ Proyek POS Restoran **"Eat.o"**

Sebuah ekosistem Point of Sale (POS) modern untuk restoran, dibangun dengan arsitektur **headless** yang memisahkan backend API dan aplikasi frontend. Proyek ini menyediakan solusi lengkap untuk **kasir**, **dapur**, serta **panel admin** yang komprehensif.

---

## 🚀 Teknologi yang Digunakan

Proyek ini terbagi menjadi dua bagian utama:

### **1. Backend (Server-Side)**
- **Framework:** Laravel 11+
- **Admin Panel:** Filament 3
- **Fungsi:** Headless API — menangani logika bisnis, otentikasi, dan manajemen data
- **Database:** MySQL / PostgreSQL
- **Autentikasi:** Laravel Sanctum

### **2. Frontend (Client-Side)**
- **Framework:** Flutter
- **Target Platform:** Web (Chrome) & Tablet (Landscape Mode)
- **State Management:** Provider (ChangeNotifier)
- **Providers Utama:**
  - `AuthService` – mengelola status login & data user
  - `CartProvider` – mengelola item keranjang kasir

---

## ✨ Fitur Utama

Proyek bekerja berdasarkan sistem peran pengguna (Role-based Access).

---

# 🔐 Otentikasi & Role

- **Registrasi**: Endpoint custom Filament → `/admin/register`
- **Login API**: Token-based (Sanctum) → `/api/v1/login`
- **Role User**:
  - `cashier` (Kasir)
  - `kitchen` (Dapur)

---

# 🧾 1. Aplikasi Kasir (Role: cashier)

Antarmuka kasir dirancang dengan layout **3 kolom**, responsif dan mudah digunakan.

### **Fitur Utama Kasir**
#### ✔ Navigasi Samping
Sidebar berisi menu:
- Menu
- Transaksi
- Order
- Meja

#### ✔ Kolom Menu
- Menampilkan daftar menu dalam bentuk grid
- Mendukung **filter kategori** (Makanan, Minuman, dll)
- Real-time update via API

#### ✔ Kolom Keranjang & Pembayaran
- Tambah/kurangi/hapus item dari keranjang
- Mode pembayaran muncul saat menekan **Lanjutkan Transaksi**
- Input:
  - Pilih Meja
  - Metode Pembayaran: Cash / QRIS / Debit
  - Nama Pelanggan
- Menekan **Bayar Sekarang** → Mengirim pesanan ke backend

#### ✔ Manajemen Meja
- Menampilkan seluruh meja (grid)
- Status: **Tersedia** / **Terisi**
- Auto-refresh status meja
- Kasir dapat mengubah status meja secara manual

#### ✔ Daftar Order Aktif
- Menampilkan semua pesanan dengan status:  
  `pending`, `preparing`, `ready`
- Auto-refresh tiap interval

---

# 🍳 2. Aplikasi Dapur (Role: kitchen)

Aplikasi dapur dirancang seperti **Kanban Board** yang sederhana dan cepat diakses.

### **Fitur Utama Dapur**
#### ✔ Kolom Pesanan
- Kolom "Pesanan Baru" (pending)
- Kolom "Sedang Disiapkan" (preparing)

#### ✔ Sistem Auto-Refresh
- Menarik pesanan baru setiap 30 detik

#### ✔ Update Status Pesanan
- **Mulai Siapkan** → `preparing`
- **Selesai** → `completed`

---

# 🧠 3. Logika Bisnis Backend

### ✔ Manajemen Stok Real-time
- Ketika kasir membuat pesanan baru → stok berkurang otomatis.

### ✔ Pelepasan Meja Otomatis
- Jika dapur menekan **Selesai**, backend otomatis mengubah status meja menjadi **available**.

### ✔ Pelacakan Pemasukan
- Dasbor Filament hanya menghitung pesanan dengan status **paid**.

### ✔ Riwayat Transaksi
- Tersedia resource **Transaction** sebagai log historis berstatus read-only.
- Dibuat otomatis setiap kali transaksi dibayar.

---

## 📚 Daftar Isi

* [Arsitektur Sistem](#🏛️-arsitektur-sistem)
* [Fitur Utama](#✨-fitur-utama)
* [Galeri / Tampilan](#📸-galeri--tampilan)
* [Tumpukan Teknologi](#💻-tumpukan-teknologi)
* [Panduan Instalasi](#🛠️-instalasi--menjalankan-proyek)
* [Struktur Direktori](#🌳-struktur-direktori)
* [Lisensi](#📜-lisensi)

---

## 🏛️ Arsitektur Sistem

Proyek ini adalah **monorepo** yang mengintegrasikan tiga aplikasi utama untuk menciptakan satu ekosistem POS yang utuh:

1.  **`backend` (API & Admin Panel)**
    * **Teknologi:** Laravel & Filament
    * **Tujuan:** Menjadi otak dari seluruh operasi. Ini menyediakan REST API untuk aplikasi mobile dan web, serta panel admin yang *powerful* untuk mengelola seluruh data (produk, pesanan, pengguna).

2.  **`mobile` (Aplikasi Kasir / POS)**
    * **Teknologi:** Flutter
    * **Tujuan:** Aplikasi *client* yang digunakan oleh kasir di lapangan. Aplikasi ini digunakan untuk membuat pesanan, mengelola meja, dan memproses transaksi secara *real-time* dengan terhubung ke `backend`.

3.  **`web` (Web Promosi & Langganan)**
    * **Teknologi:** React
    * **Tujuan:** Situs web yang menghadap pelanggan. Berfungsi sebagai *landing page*, sarana promosi, dan tempat bagi pelanggan baru untuk mendaftar atau mengelola langganan mereka.



---

## 🌳 Struktur Direktori

1.  **`backend` (API & Admin Panel)**

#### backend/

<img width="445" height="544" alt="Image" src="https://github.com/user-attachments/assets/9ba2f352-de19-491e-ab57-aaeb4c93d159" />


2.  **`mobile` (Aplikasi Kasir / POS)**

#### backend/

<img width="431" height="217" alt="Image" src="https://github.com/user-attachments/assets/fb1779df-6eb7-4f15-9b57-b27dd47f9caf" />


3.  **`web` (Web Promosi & Langganan)**

<img width="472" height="233" alt="Image" src="https://github.com/user-attachments/assets/7947362c-8cd1-41fd-9643-a5175777ed60" />


---

## ✨ Fitur Utama

### 👨‍💼 Panel Admin (Filament)
* **Dashboard Statistik:** Grafik penjualan interaktif, ringkasan status, dan widget data (`PosSalesChart`, `AdvancedStatsOverviewWidget`).
* **Manajemen Restoran:** CRUD (Create, Read, Update, Delete) lengkap untuk Kategori, Menu, dan Meja (`CategoryResource`, `MenuResource`, `RestoTableResource`).
* **Manajemen Pesanan:** Melihat, membuat, mengedit, dan melacak status semua pesanan (`OrderResource`) beserta item di dalamnya (`OrderItemsRelationManager`).
* **Manajemen Pengguna:** Mengelola akun admin dan pengguna (`UserResource`).

### 📱 Mobile POS (Flutter)
* Otentikasi Pengguna (Login/Logout) ke API.
* Pembuatan Pesanan baru untuk meja tertentu.
* Tampilan daftar Menu dan Kategori yang dinamis dari API.
* Proses *Checkout* dan Transaksi.
* Manajemen status Meja (Tersedia/Terisi).

### 🌐 Web Promosi (React)
* *Landing page* yang menarik dan informatif.
* Fitur pendaftaran (registrasi) pengguna baru.
* Halaman untuk menampilkan paket langganan (subscription).

---

## 📸 Galeri / Tampilan UI MOBILE DAN APPS

### Splash Screen UI TAB/IPAD VERSION
<img width="856" height="416" alt="Image" src="https://github.com/user-attachments/assets/30c146a1-35f4-4683-ab22-5b4f2a8028c3" />

### Login Dan register UI TAB/IPAD VERSION
<img width="859" height="380" alt="Image" src="https://github.com/user-attachments/assets/3e2965f8-0274-40c6-94b6-07be901e1f8b" />

### Layout halaman Kasir UI TAB/IPAD VERSION
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/4067e80c-82b8-4682-a755-6061fa425b7c" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/39a22e60-7a85-47d0-9b87-9ff12fac27dd" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/f0f2edff-c27c-42d3-bc45-a55d83dc768c" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/9f999991-2b70-443d-b475-eb90b691411a" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/0282c582-a564-4d89-adba-2f1bb6212118" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/62d895e6-afd2-4466-a21c-e8791ae7ad97" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/cae2c690-d4c5-40f5-b82c-217c877edc0c" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/8955f29f-cfed-4a1b-bf3c-1edb0a69b3dd" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/9cc36d3e-8f40-453a-8a6d-5e86cf278294" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/2f53832f-e162-427c-b70b-0a856f483679" />
<img width="1367" height="1025" alt="Image" src="https://github.com/user-attachments/assets/f7e72293-c73b-490a-bf97-8682843db095" />

### Layout halaman Dapur UI TAB/IPAD VERSION
<img width="832" height="428" alt="Image" src="https://github.com/user-attachments/assets/9e87603e-086f-4949-b328-39231fe23cf3" />

---

## 💻 Tumpukan Teknologi

Berikut adalah daftar teknologi utama yang digunakan dalam proyek ini:

| Komponen | Teknologi | Detail |
| :--- | :--- | :--- |
| **Backend** | PHP | Bahasa pemrograman utama. |
| | Laravel | Framework PHP untuk membangun REST API. |
| | Filament | *Builder* panel admin TALL stack untuk Laravel. |
| **Mobile** | Flutter & Dart | Framework UI untuk membangun aplikasi *native*. |
| **Frontend** | React & JavaScript | Library untuk membangun antarmuka web. |
| **Database** | [MySQL/PostgreSQL/SQLite] | Sistem manajemen database. |
| **Tools** | Git & GitHub | Kontrol versi dan hosting repositori. |
| | Composer, NPM | Manajemen dependensi. |

---

## 🛠️ Instalasi & Menjalankan Proyek

### Prasyarat
* PHP 8.1+ & Composer
* Node.js 16+ & NPM
* Flutter SDK
* Server Database (misal: MySQL)

---

### 1. Backend (`backend/`)
```bash
# Masuk ke direktori backend
cd backend

# Install dependensi PHP
composer install

# Salin file environment
cp .env.example .env

# Buat kunci aplikasi
php artisan key:generate

# Konfigurasikan koneksi database Anda di file .env

# Jalankan migrasi dan seeder data
php artisan migrate --seed

# Buat user admin pertama
php artisan make:filament-user

# Jalankan server
php artisan serve

---## 📸 Jobdesk/ Progres Tim



