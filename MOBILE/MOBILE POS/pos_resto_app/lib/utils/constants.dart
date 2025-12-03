import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const bool isWeb = kIsWeb;

// 🔥 Ubah ke URL server deploy kamu
const String BASE_URL = "http://203.194.114.3:8190";

// Endpoint API Laravel
const String API_URL = "$BASE_URL/api/v1";

// URL gambar (opsional)
const String IMAGE_URL = "$BASE_URL/storage/";

// Warna tema
const kPrimaryColor = Color(0xFFF9A825);
const kSecondaryColor = Color(0xFF212121);
const kLightGreyColor = Color(0xFFF5F5F5);
const kBackgroundColor = Color(0xFFFFFFFF);

const kSplashBackgroundColor = Color(0xFFFEE8B7);
const kSplashCircleColor = Color(0xFFFDCB6F);
