// lib/utils/constants.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 🔍 Deteksi otomatis platform
/// - Web → kIsWeb == true
/// - Android emulator → pakai 10.0.2.2
/// - iOS simulator → pakai 127.0.0.1
/// - HP fisik → perlu ubah IP manual sesuai jaringan laptop
const bool isWeb = kIsWeb;

/// 🖥️ BASE_URL dinamis agar tidak perlu ubah manual terus
///
/// Gunakan pola ini:
/// - Flutter Web (Chrome/Edge): http://localhost:8000
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator: http://127.0.0.1:8000
/// - HP fisik: ganti dengan IP laptop kamu (cek `ipconfig`)
const String BASE_URL = kIsWeb
    ? 'http://localhost:8000' // Flutter Web
    : 'http://10.0.2.2:8000'; // Android Emulator (default)

// ⚙️ Endpoint utama API Laravel
const String API_URL = '$BASE_URL/api/v1';

// 📦 URL dasar untuk gambar yang disimpan di Laravel storage
const String IMAGE_URL = '$BASE_URL/storage/';

// 🌈 Warna utama tema aplikasi POS
const kPrimaryColor = Color(0xFFF9A825); // Kuning/Oranye Utama
const kSecondaryColor = Color(0xFF212121); // Abu-abu Gelap
const kLightGreyColor = Color(0xFFF5F5F5); // Abu Cerah untuk Input Field
const kBackgroundColor = Color(0xFFFFFFFF); // Putih Umum

// 🌟 Warna khusus Splash Screen
const kSplashBackgroundColor = Color(0xFFFEE8B7); // Kuning lembut
const kSplashCircleColor = Color(0xFFFDCB6F); // Kuning agak gelap

// 🔤 Gaya teks umum (opsional, bisa kamu pakai di seluruh app)
const TextStyle kHeadingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const TextStyle kSubTextStyle = TextStyle(
  fontSize: 16,
  color: kSecondaryColor,
);

// 🧱 Padding dan radius standar
const double kDefaultPadding = 16.0;
const double kDefaultRadius = 12.0;
