<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eat.o | Solusi POS Restoran Modern</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="{{ asset('css/landing.css') }}">

       <!-- Favicon -->
    <!-- Favicon -->
<link rel="icon" type="image/png" href="{{ asset('images/logo.png') }}">

</head>

<body class="bg-white text-gray-800">

    <header class="p-4 shadow-md sticky top-0 z-50 bg-white">
        <div class="max-w-7xl mx-auto flex justify-between items-center">
            <div class="flex items-center space-x-2">
                <img src="/images/logo.png" alt="Logo Eat.o" class="rounded-full">
                <h1 class="text-xl font-bold">Eat.o</h1>
            </div>
            <nav class="flex items-center space-x-4">
                <a href="#" class="text-orange-600 font-semibold hover:text-orange-800 px-3">Contact Us</a>
                <a href="#" class="orange-button">Download</a>
                <a href="/admin" class="orange-button">Login</a>
            </nav>
        </div>
    </header>

    <section class="bg-white py-16 md:py-24 text-center">
        <div class="max-w-7xl mx-auto px-4">
            <h2 class="text-4xl md:text-5xl font-extrabold mb-4 fade-on-scroll" data-animate="fade">Biar Kamu Fokus Masak,<br><span class="text-orange-600">eat.o Urus Sisanya</span></h2>
            <p class="text-lg text-gray-600 mb-8 max-w-4xl mx-auto fade-on-scroll" data-animate="fade">
                Semua proses berjalan otomatis sehingga timmu bisa bekerja lebih efisien. <br>
                Pantau performa restoran kapan saja dengan data real-time yang selalu akurat. <br>
                Dengan eat.o, operasional tetap lancar bahkan saat resto sedang ramai.
            </p>

            <div class="relative w-full max-w-4xl mx-auto h-[500px] md:h-[600px] mt-10">
                <img src="/images/kasir.png"
                    alt="Tampilan Menu Eat.o"
                    class="absolute bottom-4 left-0 w-3/5 rounded-xl shadow-2xl z-10 
                transform -translate-x-1/4 -rotate-3 fade-on-scroll"
                    data-animate="fade">

                <img src="/images/dashboardutama.png"
                    alt="Dashboard Eat.o"
                    class="absolute top-1/2 left-1/2 w-3/5 rounded-xl shadow-2xl z-30 
                transform -translate-x-1/2 -translate-y-1/2 rotate-3 fade-on-scroll"
                    data-animate="fade">

                <img src="/images/payment.png"
                    alt="Tampilan Pembayaran Eat.o"
                    class="absolute top-0 right-0 w-3/5 rounded-xl shadow-2xl z-20 
                transform translate-x-1/4 -rotate-2 fade-on-scroll"
                    data-animate="fade">
            </div>

        </div>
    </section>

    ---
    <section id="fitur-integrasi" class="py-16 md:py-24 bg-white">
        <div class="max-w-7xl mx-auto px-4">
            <div class="text-center mb-12">
                <span class="inline-block px-4 py-1 text-sm font-semibold rounded-full bg-orange-100 text-orange-600 mb-4 fade-on-scroll" data-animate="fade" data-order="0">
                    eat.o punya apa sih?
                </span>
                <h3 class="text-3xl md:text-4xl font-bold mb-4 fade-on-scroll" data-animate="fade" data-order="1">
                    Jelajahi fitur yang bikin operasional makin lancar.
                </h3>
                <p class="text-lg text-gray-600 max-w-4xl mx-auto fade-on-scroll" data-animate="fade" data-order="2">
                    Dengan integrasi otomatis antara kasir dan dapur, setiap pesanan dapat dilacak secara real-time.
                    Kamu bisa melihat progres pesanan—mulai dari dibuat, diproses, hingga siap disajikan—semua dalam
                    satu sistem yang rapi dan akurat.
                </p>
            </div>

            <!-- WRAPPER LAYOUT -->
            <div class="relative max-w-6xl mx-auto mt-20 h-[620px] flex items-center justify-center">

                <!-- PANAH-PANAH -->
                <div class="absolute inset-0 z-10 pointer-events-none">
                    <!-- panah kanan -->
                    <img src="/images/panahkanan.png"
                        class="absolute top-[85%] right-[-2%] w-[10%] object-contain panah-kanan">


                    <!-- panah kiri -->
                    <img src="/images/panahkiri.png"
                        class="absolute top-[50%] left-[-1%] w-[10%] object-contain panah-kiri">
                </div>

                <!-- DAPUR (KIRI) -->
                <div class="absolute left-[7%] top-[45%] -translate-y-[20%] w-[46%] z-20 fade-on-scroll slide-left" data-animate="fade" data-order="3">

                    <div class="text-center mb-8">
                        <span class="text-xl font-bold">Tampilan Dapur (KDS)</span>
                    </div>

                    <div class="rounded-[1.5rem] shadow-2xl overflow-hidden bg-white">
                        <img src="/images/dapur.png"
                            alt="Tampilan Dapur KDS"
                            class="w-full h-auto object-cover fade-on-scroll aspect-4-3" data-animate="fade" data-order="4">
                    </div>

                </div>

                <!-- KASIR (KANAN) -->
                <div class="absolute right-[7%] top-[35%] -translate-y-1/2 w-[46%] z-20 fade-on-scroll slide-right" data-animate="fade" data-order="5">
                    <div class="rounded-[1.5rem] shadow-2xl overflow-hidden bg-white">
                        <img src="/images/kasir.png"
                            alt="Tampilan Kasir POS"
                            class="w-full h-auto object-cover fade-on-scroll aspect-4-3" data-animate="fade" data-order="6">
                    </div>
                    <div class="text-center mt-12">
                        <span class="text-xl font-bold fade-on-scroll" data-animate="fade" data-order="7">Tampilan Kasir (POS)</span>
                    </div>
                </div>

            </div>
        </div>
    </section>

    ---

    <section class="py-20 bg-white">
        <div class="max-w-6xl mx-auto px-4">

            <!-- Badge -->
            <span class="inline-block px-4 py-1 text-sm font-semibold rounded-full bg-yellow-200 text-gray-800">
                Kenapa harus eat.o ?
            </span>

            <!-- Judul -->
            <h2 class="text-4xl md:text-5xl font-bold text-gray-900 mt-4 leading-tight">
                Terjangkau harganya,<br>
                premium kualitasnya.
            </h2>

            <!-- Deskripsi -->
            <p class="text-lg text-gray-600 mt-6 max-w-3xl">
                Dengan fitur lengkap dan performa stabil, eat.o memberikan pengalaman
                pengelolaan restoran yang terasa kelas atas tanpa biaya yang memberatkan.
                Kamu mendapatkan solusi POS modern yang kuat, efisien, dan siap menunjang
                bisnis di setiap kondisi operasional.
            </p>

            <!-- 3 Card -->
            <div class="grid md:grid-cols-3 gap-6 mt-12">

                <!-- Card 1 -->
                <div class="p-6 rounded-2xl border-2 border-orange-400 shadow-md fade-on-scroll" data-animate="fade">
                    <div class="text-orange-500 text-3xl mb-4">
                        🟠
                    </div>
                    <h3 class="font-bold text-xl mb-2">Berbagai Macam Fitur</h3>
                    <p class="text-gray-600 text-sm leading-relaxed">
                        eat.o menyediakan fitur lengkap untuk mempermudah setiap aspek operasional restoranmu.
                        Mulai dari pencatatan pesanan, manajemen meja, hingga pelaporan otomatis—semua tersedia
                        dalam satu aplikasi yang mudah digunakan.
                    </p>
                </div>

                <!-- Card 2 -->
                <div class="p-6 rounded-2xl border-2 border-orange-400 shadow-md fade-on-scroll" data-animate="fade">
                    <div class="text-orange-500 text-3xl mb-4">
                        🟠
                    </div>
                    <h3 class="font-bold text-xl mb-2">Berbagai Macam Fitur</h3>
                    <p class="text-gray-600 text-sm leading-relaxed">
                        eat.o menyediakan fitur lengkap untuk mempermudah setiap aspek operasional restoranmu.
                        Mulai dari pencatatan pesanan, manajemen meja, hingga pelaporan otomatis—semua tersedia
                        dalam satu aplikasi yang mudah digunakan.
                    </p>
                </div>

                <!-- Card 3 -->
                <div class="p-6 rounded-2xl border-2 border-orange-400 shadow-md fade-on-scroll" data-animate="fade">
                    <div class="text-orange-500 text-3xl mb-4">
                        👉
                    </div>
                    <h3 class="font-bold text-xl mb-2">Satu Apps, Semua Urusan</h3>
                    <p class="text-gray-600 text-sm leading-relaxed">
                        eat.o menggabungkan seluruh kebutuhan operasional restoran dalam satu aplikasi praktis.
                        Dari pesanan, dapur, pembayaran, hingga laporan—semuanya terhubung dan berjalan otomatis
                        tanpa repot.
                    </p>
                </div>

            </div>

        </div>
    </section>



    ---
    <section id="testimoni" class="py-16 md:py-24 bg-gray-50 overflow-hidden">
        <div class="max-w-7xl mx-auto px-4">
            <div class="text-center mb-12">
                <span class="inline-block px-4 py-1 text-sm font-semibold rounded-full bg-orange-100 text-orange-600 mb-4">Testimoni</span>
                <h3 class="text-3xl md:text-4xl font-bold mb-4">Cerita Para Pelanggan<br>yang Telah Mencoba eat.o</h3>
                <p class="text-lg text-gray-600 max-w-4xl mx-auto">
                    Temukan pengalaman nyata dari para pemilik restoran yang sudah merasakan kemudahan mengelola bisnis dengan eat.o.
                    Mulai dari operasional yang lebih rapi hingga pelayanan yang makin cepat—semua terlihat dari cerita mereka.
                </p>
            </div>
        </div>

        {{-- Container Utama Animasi - Lebar Penuh agar efek terlihat maksimal --}}
        <div class="w-full">

            {{-- LAYER 1: Bergeser ke KANAN --}}
            <div class="scrollable-layer mb-4">
                <div class="animated-track track-right">
                    {{-- Kumpulan Kartu Asli & Duplikat --}}

                    {{-- Card 1 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Operasional jadi lebih cepat dan rapi.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Sejak memakai eat.o, pesanan antara kasir dan dapur jadi jauh lebih teratur. Tim kami bisa bekerja tanpa tumpang tindih, dan pelanggan puas karena makanan lebih cepat sampai.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">A</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Andi Wijaya</span>
                                <span class="text-xs text-gray-500">Pemilik, Kopi Senja</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 2 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Laporan Penjualan Sangat Akurat!</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Saya tidak perlu lagi menghitung manual. Semua laporan, dari penjualan harian hingga stok, sudah otomatis. Waktu saya jadi lebih banyak untuk mengembangkan resep.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">B</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Budi Santoso</span>
                                <span class="text-xs text-gray-500">Pemilik, Warung Barokah</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 4; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                        <svg class="w-4 h-4 fill-current text-gray-300" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" />
                                        </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 3 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Interface yang Sangat User-Friendly.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Meskipun banyak fitur, tampilannya mudah dipahami, bahkan untuk karyawan baru. Proses onboarding jadi sangat cepat.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">C</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Citra Dewi</span>
                                <span class="text-xs text-gray-500">Manajer, Dapur Nusantara</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 1 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Operasional jadi lebih cepat dan rapi.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Sejak memakai eat.o, pesanan antara kasir dan dapur jadi jauh lebih teratur. Tim kami bisa bekerja tanpa tumpang tindih, dan pelanggan puas karena makanan lebih cepat sampai.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">A</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Andi Wijaya</span>
                                <span class="text-xs text-gray-500">Pemilik, Kopi Senja</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 2 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Laporan Penjualan Sangat Akurat!</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Saya tidak perlu lagi menghitung manual. Semua laporan, dari penjualan harian hingga stok, sudah otomatis. Waktu saya jadi lebih banyak untuk mengembangkan resep.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">B</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Budi Santoso</span>
                                <span class="text-xs text-gray-500">Pemilik, Warung Barokah</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 4; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                        <svg class="w-4 h-4 fill-current text-gray-300" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" />
                                        </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 3 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Interface yang Sangat User-Friendly.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Meskipun banyak fitur, tampilannya mudah dipahami, bahkan untuk karyawan baru. Proses onboarding jadi sangat cepat.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">C</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Citra Dewi</span>
                                <span class="text-xs text-gray-500">Manajer, Dapur Nusantara</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {{-- LAYER 2: Bergeser ke KIRI --}}
            <div class="scrollable-layer mb-4">
                <div class="animated-track track-left">

                    {{-- Card 4 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Integrasi Pembayaran Digital Cepat.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Transaksi digital berjalan mulus, mencatat semua jenis pembayaran dari QRIS hingga kartu. Pelanggan jadi lebih nyaman.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">D</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Dani Eko</span>
                                <span class="text-xs text-gray-500">Pemilik, Roti Manis</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 5 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Stok Bahan Baku Selalu Terkontrol.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Fitur manajemen inventori sangat membantu. Saya tidak pernah lagi kehabisan bahan utama saat jam sibuk.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">E</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Eva Lestari</span>
                                <span class="text-xs text-gray-500">Pemilik, Kedai Seafood</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 6 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Pelayanan Jauh Lebih Cepat.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Pesanan bisa langsung dikirim ke dapur dari tablet, menghilangkan kesalahan pencatatan. Antrean jadi lebih pendek!</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">F</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Fahri Guntur</span>
                                <span class="text-xs text-gray-500">Manajer, Chicken Mania</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 4 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Integrasi Pembayaran Digital Cepat.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Transaksi digital berjalan mulus, mencatat semua jenis pembayaran dari QRIS hingga kartu. Pelanggan jadi lebih nyaman.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">D</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Dani Eko</span>
                                <span class="text-xs text-gray-500">Pemilik, Roti Manis</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 5 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Stok Bahan Baku Selalu Terkontrol.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Fitur manajemen inventori sangat membantu. Saya tidak pernah lagi kehabisan bahan utama saat jam sibuk.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">E</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Eva Lestari</span>
                                <span class="text-xs text-gray-500">Pemilik, Kedai Seafood</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 6 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Pelayanan Jauh Lebih Cepat.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Pesanan bisa langsung dikirim ke dapur dari tablet, menghilangkan kesalahan pencatatan. Antrean jadi lebih pendek!</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">F</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Fahri Guntur</span>
                                <span class="text-xs text-gray-500">Manajer, Chicken Mania</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {{-- LAYER 3: Bergeser ke KANAN --}}
            <div class="scrollable-layer">
                <div class="animated-track track-right">

                    {{-- Card 7 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Menu Digital Memudahkan Pembeli.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Pelanggan bisa melihat foto dan deskripsi menu dengan jelas. Ini meningkatkan rata-rata transaksi per pelanggan.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">G</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Gita Amelia</span>
                                <span class="text-xs text-gray-500">Pemilik, The Pasta House</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 4; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                        <svg class="w-4 h-4 fill-current text-gray-300" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" />
                                        </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 8 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Jejak Audit Keuangan Rapi.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Semua transaksi tercatat secara digital dan terperinci. Ini sangat mempermudah saat melakukan rekap bulanan dan audit.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">H</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Hendra Irawan</span>
                                <span class="text-xs text-gray-500">Akuntan, Mitra eat.o</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 9 (Original) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Mudah Diakses Kapan Saja.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Karena berbasis cloud, saya bisa mengecek laporan penjualan dan stok dari mana saja, bahkan saat saya sedang tidak di restoran.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">I</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Indra Mulya</span>
                                <span class="text-xs text-gray-500">Pemilik, Minuman Segar</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 7 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Menu Digital Memudahkan Pembeli.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Pelanggan bisa melihat foto dan deskripsi menu dengan jelas. Ini meningkatkan rata-rata transaksi per pelanggan.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">G</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Gita Amelia</span>
                                <span class="text-xs text-gray-500">Pemilik, The Pasta House</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 4; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                        <svg class="w-4 h-4 fill-current text-gray-300" viewBox="0 0 20 20">
                                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" />
                                        </svg>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 8 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Jejak Audit Keuangan Rapi.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Semua transaksi tercatat secara digital dan terperinci. Ini sangat mempermudah saat melakukan rekap bulanan dan audit.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">H</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Hendra Irawan</span>
                                <span class="text-xs text-gray-500">Akuntan, Mitra eat.o</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Card 9 (DUPLICATE) - Diubah menjadi md:w-1/4 --}}
                    <div class="testimonial-card-new w-full md:w-1/4 flex-shrink-0">
                        <div class="flex justify-between items-start mb-4">
                            <h4 class="text-lg font-bold">Mudah Diakses Kapan Saja.</h4>
                            <svg class="w-8 h-8 text-orange-400 opacity-50" fill="currentColor" viewBox="0 0 24 24">
                                <path d="M12 11.55C11.66 11.23 11 10.74 11 10C11 9.38 11.4 8.79 12 8.36V7.5C9.79 7.5 8 9.3 8 11.5V16.5C8 18.7 9.79 20.5 12 20.5H19C21.21 20.5 23 18.7 23 16.5V11.5C23 9.3 21.21 7.5 19 7.5H17V8.36C17.6 8.79 18 9.38 18 10C18 10.74 17.34 11.23 17 11.55V16.5H12V11.55Z M5 11.55C4.66 11.23 4 10.74 4 10C4 9.38 4.4 8.79 5 8.36V7.5C2.79 7.5 1 9.3 1 11.5V16.5C1 18.7 2.79 20.5 5 20.5H12C14.21 20.5 16 18.7 16 16.5V11.5C16 9.3 14.21 7.5 12 7.5H10V8.36C10.6 8.79 11 9.38 11 10C11 10.74 10.34 11.23 10 11.55V16.5H5V11.55Z" />
                            </svg>
                        </div>
                        <p class="text-gray-600 mb-4 text-sm">Karena berbasis cloud, saya bisa mengecek laporan penjualan dan stok dari mana saja, bahkan saat saya sedang tidak di restoran.</p>
                        <div class="flex items-center">
                            <div class="w-10 h-10 bg-orange-500 rounded-full flex items-center justify-center mr-3 text-white font-bold text-sm">I</div>
                            <div>
                                <span class="font-bold text-gray-800 block">Indra Mulya</span>
                                <span class="text-xs text-gray-500">Pemilik, Minuman Segar</span>
                                <div class="flex text-yellow-500 text-xs mt-1">
                                    @for ($i = 0; $i < 5; $i++)
                                        <svg class="w-4 h-4 fill-current" viewBox="0 0 20 20">
                                        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 001.028.684l3.181.45a1 1 0 00.919-.592l1.07-3.292a1 1 0 00-1.07-.918l-3.182-.45a1 1 0 00-1.028-.684l-1.07-3.292a1 1 0 00-1.902 0l-1.07 3.292a1 1 0 00-1.028.684l-3.182.45a1 1 0 00-.919.592l1.07 3.292a1 1 0 001.07.918l3.182.45a1 1 0 001.028.684l1.07 3.292z" /></svg>
                                        @endfor
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </section>

    ---

    <section id="faq" class="py-16 md:py-24 bg-white">
        <div class="max-w-7xl mx-auto px-4">
            <div class="text-center mb-12">
                <span class="inline-block px-4 py-1 text-sm font-semibold rounded-full bg-orange-100 text-orange-600 mb-4">FAQ</span>
                <h3 class="text-3xl md:text-4xl font-extrabold mb-4"><span class="text-red-500 pr-1">?</span> Frequently Asked Questions</h3>
                <p class="text-lg text-gray-600 max-w-4xl mx-auto">
                    Temukan jawaban dari berbagai pertanyaan umum seputar penggunaan eat.o. Bagian ini membantu Anda memahami fitur, cara kerja, hingga dukungan yang tersedia, sehingga Anda bisa menggunakan eat.o dengan lebih maksimal.
                </p>
            </div>

            <div class="faq-section-container space-y-4">

                <div class="faq-item">
                    <div class="faq-header">
                        Apa itu eat.o?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        eat.o adalah aplikasi POS (Point of Sale) yang membantu restoran mengelola pesanan, meja, dapur, pembayaran, hingga laporan bisnis dalam satu sistem yang sederhana dan efisien.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Cocok untuk jenis usaha apa saja?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        eat.o cocok untuk berbagai jenis usaha F&B seperti restoran, kafe, warung makan, kedai minuman, food stall, hingga usaha kecil menengah.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Apakah eat.o sulit digunakan?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        eat.o adalah aplikasi POS (Point of Sale) yang membantu restoran mengelola pesanan, meja, dapur, pembayaran, hingga laporan bisnis dalam satu sistem yang sederhana dan efisien.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Bisakah menghubungkan kasir dengan dapur?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        Ya, fitur integrasi antar perangkat memungkinkan pesanan langsung masuk ke dapur tanpa perlu print, mempercepat proses dan mengurangi kesalahan.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Apakah eat.o menyediakan laporan penjualan?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        Ya, eat.o menyediakan laporan harian, mingguan, dan bulanan yang bisa Anda unduh atau lihat langsung di dashboard.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Apakah ada biaya berlangganan?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        Kami menyediakan paket gratis dan premium. Paket premium memberikan fitur tambahan seperti multi-outlet, analitik lanjutan, dan support prioritas.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Apakah eat.o tersedia untuk Android dan iOS?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        Saat ini aplikasi mobile hanya tersedia untuk Android. Versi iOS akan dirilis dalam waktu dekat.
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-header">
                        Bagaimana jika saya butuh bantuan teknis?
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </div>
                    <div class="faq-content">
                        Tim support kami siap membantu 24/7 melalui chat, email, atau telepon. Kunjungi halaman Contact Us untuk informasi lebih lanjut.
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="bg-white text-gray-800 py-8 border-t border-gray-200">
        <div class="max-w-7xl mx-auto px-4 text-center">
            <p>&copy; 2025 Eat.o. All rights reserved.</p>
            <div class="mt-4 space-x-4 text-sm">
                <a href="#" class="hover:text-orange-600">Kebijakan Privasi</a>
                <a href="#" class="hover:text-orange-600">Syarat & Ketentuan</a>
            </div>
        </div>
    </footer>

    <script>
        (function(){
            // Fade-in on scroll using IntersectionObserver
            const selector = '[data-animate="fade"], .testimonial-card-new';
            const options = { threshold: 0.12, rootMargin: '0px 0px -10% 0px' };

            function onIntersect(entries, observer){
                entries.forEach(entry => {
                    if(entry.isIntersecting){
                        entry.target.classList.add('is-visible');
                        observer.unobserve(entry.target);
                    }
                });
            }

            if('IntersectionObserver' in window){
                const io = new IntersectionObserver(onIntersect, options);
                document.querySelectorAll(selector).forEach(el => {
                    if(!el.classList.contains('fade-on-scroll')) el.classList.add('fade-on-scroll');
                    // allow per-element ordering via data-order attribute
                    const order = el.dataset.order;
                    if(order) el.style.setProperty('--order', order);
                    io.observe(el);
                });
            } else {
                // fallback: reveal all
                document.querySelectorAll(selector).forEach(el => el.classList.add('is-visible'));
            }
        })();

        // FAQ toggle with slide animation
        document.querySelectorAll('.faq-header').forEach(header => {
            header.addEventListener('click', () => {
                const content = header.nextElementSibling;
                const icon = header.querySelector('svg');

                const isOpen = content.classList.contains('show');

                if (isOpen) {
                    // Close: set max-height to current height, then to 0 to animate
                    content.style.maxHeight = content.scrollHeight + 'px';
                    // Force repaint then animate to 0
                    requestAnimationFrame(() => {
                        content.style.maxHeight = '0';
                        content.style.paddingTop = '0';
                        content.style.paddingBottom = '0';
                    });
                    content.classList.remove('show');
                    icon.style.transform = 'rotate(0deg)';
                } else {
                    // Open: set max-height to scrollHeight to animate
                    content.classList.add('show');
                    // restore padding if it was removed
                    content.style.paddingTop = '';
                    content.style.paddingBottom = '';
                    const height = content.scrollHeight;
                    content.style.maxHeight = height + 'px';
                    icon.style.transform = 'rotate(180deg)';

                    // After transition, remove max-height so content can resize naturally
                    const onTransitionEnd = (e) => {
                        if (e.propertyName === 'max-height') {
                            content.style.maxHeight = 'none';
                            content.removeEventListener('transitionend', onTransitionEnd);
                        }
                    };
                    content.addEventListener('transitionend', onTransitionEnd);
                }
            });
        });
    </script>
</body>

</html>