import 'package:flutter/material.dart';

// PENTING: Gunakan 10.0.2.2 untuk Android Emulator
// Ganti dengan IP asli laptop Anda (cek di cmd 'ipconfig') jika pakai HP fisik
// const String BASE_URL = 'http://10.0.2.2:8000';
const String BASE_URL = 'https://nonpertinent-unfenestral-reece.ngrok-free.dev';
const String API_URL = '$BASE_URL/api/v1';

// Warna Tema dari Desain Anda
const kPrimaryColor = Color(0xFFF9A825); // Oranye Utama
const kSecondaryColor = Color(0xFF212121); // Abu-abu Gelap (Dark Grey)
const kLightGreyColor = Color(0xFFF5F5F5); // Latar Belakang Abu-abu Cerah
const kBackgroundColor = Color(0xFFFFFFFF); // Putih

class ApiConfig {
  static const String baseUrl = "http://192.168.1.7:8000/api/v1";
}

// class ApiConfig {
//   static const String baseUrl = "http://10.0.2.2:8000/api/v1";
// }
