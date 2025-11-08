import 'package:flutter/material.dart';

// PENTING: Gunakan 10.0.2.2 untuk Android Emulator
// Ganti dengan IP asli laptop Anda (cek di cmd 'ipconfig') jika pakai HP fisik
// uri lama
// const String BASE_URL = 'http://10.0.2.2:8000';
// uri baru
// const String BASE_URL = 'http://localhost:8000';
// baru lagi
const BASE_URL = 'http://127.0.0.1:8000';

const String API_URL = '$BASE_URL/api/v1';

// // Warna Tema dari Desain Anda
// const kPrimaryColor = Color(0xFFF9A825); // Oranye Utama
// const kSecondaryColor = Color(0xFF212121); // Abu-abu Gelap (Dark Grey)
// const kLightGreyColor = Color(0xFFF5F5F5); // Latar Belakang Abu-abu Cerah
// const kBackgroundColor = Color(0xFFFFFFFF); // Putih

// Warna Tema dari Desain Anda
const kPrimaryColor = Color(0xFFF9A825); // Oranye Utama (untuk tombol, dll)
const kSecondaryColor = Color(0xFF212121); // Abu-abu Gelap (Dark Grey)
const kLightGreyColor = Color(0xFFF5F5F5); // Latar Belakang Abu-abu Cerah (untuk input)
const kBackgroundColor = Color(0xFFFFFFFF); // Putih (untuk sebagian besar background)

// Warna Spesifik untuk Splash Screen
const kSplashBackgroundColor = Color(0xFFFEE8B7); // Kuning cerah dari gambar
const kSplashCircleColor = Color(0xFFFDCB6F); // Kuning sedikit lebih gelap untuk lingkaran