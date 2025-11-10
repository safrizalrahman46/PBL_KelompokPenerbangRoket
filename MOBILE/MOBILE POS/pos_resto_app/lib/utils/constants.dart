// lib/utils/constants.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

/// 🔍 Fungsi deteksi BASE_URL sesuai platform / device
String getBaseUrl() {
  if (kIsWeb) {
    // Flutter Web
    return 'http://localhost:8000';
  }

  if (Platform.isAndroid) {
    // Cek apakah ini emulator atau HP fisik
    // Emulator Android biasanya memiliki IP 10.0.2.2 untuk host machine
    // HP fisik harus pakai IP lokal laptop
    // Sederhananya, jika kita ingin otomatis, kita bisa pakai 10.0.2.2 untuk emulator
    // dan ganti manual ke IP lokal untuk HP fisik jika diperlukan
    // (tidak ada cara 100% otomatis mendeteksi emulator vs fisik di Dart)
    
    // Ganti IP ini sesuai IP laptop kamu saat testing di HP fisik
    const String localLaptopIP = '192.168.75.16';
    
    // Gunakan 10.0.2.2 untuk emulator
    return 'http://10.0.2.2:8000'; // default emulator
    // Kalau HP fisik: return 'http://$localLaptopIP:8000';
  }

  if (Platform.isIOS) {
    // iOS simulator
    return 'http://127.0.0.1:8000';
  }

  // fallback
  return 'http://192.168.75.16:8000';
}

/// Endpoint utama API Laravel
// final String API_URL = '${getBaseUrl()}/api/v1';

final String API_URL = 'http://192.168.75.16:8000/api/v1';


/// URL dasar untuk gambar yang disimpan di Laravel storage
final String IMAGE_URL = '${getBaseUrl()}/storage/';

/// 🌈 Warna utama tema aplikasi POS
const kPrimaryColor = Color(0xFFF9A825); // Kuning/Oranye Utama
const kSecondaryColor = Color(0xFF212121); // Abu-abu Gelap
const kLightGreyColor = Color(0xFFF5F5F5); // Abu Cerah untuk Input Field
const kBackgroundColor = Color(0xFFFFFFFF); // Putih Umum

/// 🌟 Warna khusus Splash Screen
const kSplashBackgroundColor = Color(0xFFFEE8B7); // Kuning lembut
const kSplashCircleColor = Color(0xFFFDCB6F); // Kuning agak gelap

/// 🔤 Gaya teks umum
const TextStyle kHeadingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kPrimaryColor,
);

const TextStyle kSubTextStyle = TextStyle(
  fontSize: 16,
  color: kSecondaryColor,
);

/// 🧱 Padding dan radius standar
const double kDefaultPadding = 16.0;
const double kDefaultRadius = 12.0;
