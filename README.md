# PBL: Ekosistem POS Kelompok Penerbang Roket

# 🚀 Tim Kami
* Ahmad Hayyin Baihaqi (Manajemen Proyek)
* M Nazril Nur Rahman (flutter IOS version)
* M Faruq Burhanuddin (UI UX, Flutter Slicing)
* Safrizal Rahman (Web Backend, Flutter Android version, Project Manager)

## 🔧 Laravel Web Backend Progress
[![Watch the video](https://i.sstatic.net/Vp2cE.png)](https://youtu.be/Zz_vo05khe0)
*(klik gambar untuk membuka video)*

---

## 📱 Flutter POS Apps Progress
[![Watch the video](https://i.sstatic.net/Vp2cE.png)](https://youtu.be/rhiaAwGf0dw)
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

## Proyek POS Restoran "Eat.o"

Sebuah ekosistem Point of Sale (POS) modern yang dirancang untuk restoran, dibangun dengan arsitektur headless yang memisahkan backend API dan frontend aplikasi klien. Proyek ini menyediakan solusi lengkap mulai dari aplikasi kasir tablet, layar monitor dapur, hingga panel admin yang komprehensif.

### 🚀 Teknologi yang Digunakan

Arsitektur proyek ini terbagi menjadi dua bagian utama:

#### 1. Backend (Server-Side)

Framework: Laravel 11+

Admin Panel: Filament 3

Fungsi: Berfungsi sebagai headless API yang menangani semua logika bisnis, otentikasi, dan manajemen data.

Database (Tersirat): MySQL/PostgreSQL

#### 2. Frontend (Client-Side)

Framework: Flutter

Target Platform: Web (Chrome) / Tablet, dioptimalkan untuk Mode Landscape.

State Management: Provider (ChangeNotifier)

AuthService: Mengelola status login dan data pengguna.

CartProvider: Mengelola keranjang belanja kasir.

## ✨ Fitur Utama

Proyek ini memiliki alur kerja yang jelas berdasarkan peran pengguna.

Otentikasi & Peran

Registrasi Kustom: Pengguna mendaftar melalui endpoint API Filament (/admin/register) [cite: Register.php]

Login API: Otentikasi token (Sanctum) melalui endpoint /api/v1/login [cite: api.php].

Berbasis Peran: Aplikasi memiliki dua peran utama: cashier (Kasir) dan kitchen (Dapur) [cite: UserResource.php].

### 1. Aplikasi Kasir (Role: cashier)

Antarmuka utama untuk kasir, dirancang sebagai dasbor 3-kolom [cite: iPad Pro 12.9_ - 4.jpg]:

Navigasi: Sidebar kiri untuk berpindah halaman (Menu, Transaksi, Order, Meja).

Kolom Menu: Menampilkan semua menu dalam format grid.

Filter Kategori: Menu dapat difilter secara real-time berdasarkan kategori (Makanan, Minuman, dll) [cite: image_3662e1.jpg].

Kolom Keranjang/Pembayaran:

Kasir dapat menambah/mengurangi/menghapus item dari keranjang (CartProvider).

Saat "Lanjutkan Transaksi", UI berubah menjadi Mode Pembayaran [cite: iPad Pro 12.9_ - 11.png].

Kasir dapat memilih Meja, Metode Pembayaran (Cash, QRIS, Debit), dan memasukkan Nama Pelanggan.

Menekan "Bayar Sekarang" akan mengirim pesanan ke backend.

Manajemen Meja:

Menampilkan status semua meja (Tersedia / Terisi) dalam format grid [cite: halaman meja.png].

Status meja diperbarui secara real-time via auto-refresh timer.

Kasir dapat secara manual mengubah status meja dengan menekannya.

Daftar Order Aktif:

Menampilkan daftar semua pesanan yang sedang berjalan (pending, preparing, ready) [cite: image_158569.png].

Status pesanan diperbarui secara real-time via auto-refresh timer.

#### 2. Aplikasi Dapur (Role: kitchen)

UI Kanban: Layar Dapur menampilkan dua kolom: "Pesanan Baru" (pending) dan "Sedang Disiapkan" (preparing) [cite: kitchen_home_screen.dart].

Auto-Refresh: Layar otomatis me-refresh setiap 30 detik untuk menarik pesanan baru dari kasir.

Update Status: Koki dapat menekan tombol "Mulai Siapkan" (mengubah status ke preparing) atau "Selesai" (mengubah status ke completed).

#### 3. Logika Bisnis (Backend)

Manajemen Stok Real-time: Endpoint API (dan panel Filament [cite: CreateOrder.php]) secara otomatis mengecek dan mengurangi stok menu setiap kali pesanan baru dibuat.

Pelepasan Meja Otomatis: Saat Dapur menekan "Selesai" (status completed), backend secara otomatis dipanggil untuk mengubah status meja terkait menjadi available [cite: kitchen_home_screen.dart].

Pelacakan Pemasukan: Dasbor admin Filament [cite: PosStatsOverview.php] secara cerdas hanya menghitung pemasukan dari pesanan yang statusnya sudah paid.

Riwayat Transaksi: Backend memiliki resource Transaction [cite: TransactionResource.php] yang berfungsi sebagai log "Hanya-Baca" [cite: ListTransactions.php], kemungkinan besar dibuat secara otomatis saat pesanan dibayar.


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

backend/
├── app/
│   ├── Filament/                     # Logika untuk Admin Panel
│   │   ├── Resources/                # CRUD Pages: Menu, Order, User
│   │   └── Widgets/                  # Dashboard Widgets: Charts, Stats
│   ├── Http/
│   │   └── Controllers/
│   │       ├── Api/
│   │       │   └── V1/               # REST API untuk Flutter / React
│   │       │       ├── AuthController.php
│   │       │       ├── CategoryController.php
│   │       │       ├── MenuController.php
│   │       │       └── OrderController.php
│   │       └── Controller.php
│   ├── Models/                       # Model Eloquent: User, Order, Menu
│   └── Providers/
│       └── Filament/
│           └── AdminPanelProvider.php # Konfigurasi Filament Admin Panel
│
├── config/                           # File konfigurasi aplikasi
├── database/
│   ├── migrations/                   # Struktur tabel database
│   └── seeders/                      # Data awal (dummy / default)
│
├── routes/
│   ├── api.php                       # Definisi rute API (/api/v1)
│   └── web.php                       # Definisi rute Web (/admin)
│
├── storage/                          # File upload dan cache Laravel
├── tests/                            # Unit dan feature tests
└── composer.json                     # Dependensi backend (Laravel)


2.  **`mobile` (Aplikasi Kasir / POS)**

#### backend/

mobile/
├── lib/
│   ├── main.dart                     # Titik awal aplikasi Flutter
│   ├── models/                       # Model data (Menu, Order, User)
│   ├── providers/                    # State management (Provider / Bloc)
│   ├── screens/                      # Halaman UI (Login, Home, POS)
│   ├── services/                     # Logika bisnis & pemanggilan API
│   └── widgets/                      # Komponen UI kustom (Button, Card)
│
├── assets/                           # Gambar, ikon, font, dsb.
├── pubspec.yaml                      # Daftar dependensi Flutter
└── analysis_options.yaml             # Aturan linting & analisis kode


3.  **`web` (Web Promosi & Langganan)**

web/
├── public/                           # File publik (index.html, favicon)
├── src/
│   ├── assets/                       # Gambar, ikon, dan font
│   ├── components/                   # Komponen UI (Button, Navbar, Card)
│   ├── pages/                        # Halaman (Home, Register, Pricing)
│   ├── services/                     # Pemanggilan API (Axios)
│   ├── App.js                        # Entry utama React
│   └── index.js                      # Inisialisasi aplikasi React
│
├── package.json                      # Dependensi Node.js / React
└── vite.config.js                    # Konfigurasi build (jika pakai Vite)



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



