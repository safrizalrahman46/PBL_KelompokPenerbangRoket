import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // API untuk KASIR - Menu
  Future<List<Menu>> fetchMenus() async {
    try {
      final response = await http.get(Uri.parse('$API_URL/menu'));
      if (response.statusCode == 200) {
        return menuFromJson(response.body);
      } else {
        throw Exception('Gagal memuat menu');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR - Kategori
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$API_URL/categories'));
      if (response.statusCode == 200) {
        return categoryFromJson(response.body);
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR - Meja
  Future<List<RestoTable>> fetchTables() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse('$API_URL/tables'), headers: headers);
      if (response.statusCode == 200) {
        return restoTableFromJson(response.body);
      } else {
        throw Exception('Gagal memuat meja');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR & DAPUR
  Future<List<Order>> fetchOrders(String statusQuery) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$API_URL/orders?$statusQuery'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return orderFromJson(response.body);
      } else {
        throw Exception('Gagal memuat pesanan');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk DAPUR & KASIR
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$API_URL/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal update status');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR (Membuat Pesanan)
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$API_URL/orders'),
        headers: headers,
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        return; // Sukses
      } else {
        // Tangani error stok habis dari Laravel
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ... (Lanjutkan di dalam file api_service.dart, di dalam class ApiService)

  // API untuk AUTENTIKASI - Login
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'), // Endpoint login dari Laravel
        headers: {
          // Login tidak perlu token, jadi kita pakai header khusus
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 1. Simpan token ke storage
        // Pastikan key-nya 'token', sesuai dengan _getHeaders()
        await _storage.write(key: 'token', value: data['token']); 

        // 2. Kembalikan data User menggunakan model Anda
        // Kita asumsikan Laravel mengembalikan {'token': '...', 'user': {...}}
        return User.fromJson(data['user']);
      } else {
        // Jika gagal (password salah, dll)
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Email atau password salah');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk AUTENTIKASI - Logout
  Future<void> logout() async {
    try {
      final headers = await _getHeaders(); // Logout perlu token
      await http.post(
        Uri.parse('$API_URL/logout'), // Endpoint logout dari Laravel
        headers: headers,
      );
    } catch (e) {
      // Biarpun request API gagal (misal: token expired),
      // kita tetap harus menghapus token di sisi klien.
      print('Error saat logout dari server: $e');
    } finally {
      // Selalu hapus token dari storage saat logout
      await _storage.delete(key: 'token');
    }
  }

  // API untuk AUTENTIKASI - Register (Opsional, jika Anda butuh)
  Future<User> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/register'), // Endpoint register dari Laravel
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Laravel sering butuh ini
          'role': role, // Sesuai dengan model User Anda
        }),
      );

      if (response.statusCode == 201) { // 201 = Created
        final data = json.decode(response.body);
        
        // Setelah register, biasanya langsung login
        await _storage.write(key: 'token', value: data['token']);
        
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal mendaftar');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // Di dalam class ApiService di lib/services/api_service.dart

// ... (fungsi Anda yang lain seperti createOrder)

// --- TAMBAHKAN FUNGSI INI ---
Future<RestoTable> updateTableStatus(int tableId, String newStatus) async {
  try {
    final headers = await _getHeaders(); // <-- Sekarang ini akan dikenali

    final response = await http.patch( // <-- 'http' akan dikenali
      Uri.parse('$API_URL/tables/$tableId/status'), 
      headers: headers,
      body: json.encode({ // <-- 'json' akan dikenali
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      return RestoTable.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Gagal update status meja');
    }
  } catch (e) {
    throw Exception('Error koneksi: $e');
  }
}
// ---------------------------------
}