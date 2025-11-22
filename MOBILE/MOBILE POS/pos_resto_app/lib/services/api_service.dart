import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  
  // Ambil token dari storage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
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
        throw Exception('Gagal memuat menu: ${response.statusCode}');
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
        throw Exception('Gagal memuat kategori: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR - Meja
  Future<List<RestoTable>> fetchTables() async {
    try {
      final response = await http.get(Uri.parse('$API_URL/tables'));
      if (response.statusCode == 200) {
        return restoTableFromJson(response.body);
      } else {
        throw Exception('Gagal memuat meja: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk KASIR & DAPUR - SEMUA ORDERS (HAPUS DUPLIKASI)
  Future<List<Order>> fetchOrders([String statusQuery = '']) async {
    try {
      final url = '$API_URL/orders${statusQuery.isNotEmpty ? '?$statusQuery' : ''}';
      print('🔄 Fetching orders from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final orders = orderFromJson(response.body);
        print('✅ Orders loaded: ${orders.length}');
        return orders;
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Gagal memuat pesanan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
      throw Exception('Error koneksi: $e');
    }
  }

  // API UNTUK ACTIVE ORDERS (TAMBAHKAN HEADER)
  Future<List<Order>> fetchActiveOrders() async {
    try {
      print('🔄 Fetching ACTIVE orders');
      
      final response = await http.get(
        Uri.parse('$API_URL/orders/active'),
        headers: await _getHeaders(), // PASTIKAN PAKAI HEADER YANG SAMA
      );
      
      if (response.statusCode == 200) {
        final orders = orderFromJson(response.body);
        print('✅ Active orders loaded: ${orders.length}');
        return orders;
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Gagal memuat pesanan aktif: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network Error: $e');
      throw Exception('Error koneksi: $e');
    }
  }

  // API untuk DAPUR & KASIR - Update Status Order
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$API_URL/orders/$orderId/status'),
        headers: headers,
        body: json.encode({'status': newStatus}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Gagal update status: ${response.statusCode}');
      }
      
      print('✅ Order $orderId updated to: $newStatus');
    } catch (e) {
      throw Exception('Error update status: $e');
    }
  }

  // API untuk KASIR - Membuat Pesanan
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$API_URL/orders'),
        headers: headers,
        body: json.encode(orderData),
      );

      if (response.statusCode == 201) {
        print('✅ Order created successfully');
        return Order.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal membuat pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create order: $e');
    }
  }

  // API untuk KASIR - Membuat Transaksi
  Future<void> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$API_URL/transactions'),
        headers: headers,
        body: json.encode(transactionData),
      );

      if (response.statusCode != 201) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal membuat transaksi: ${response.statusCode}');
      }
      
      print('✅ Transaction created successfully');
    } catch (e) {
      throw Exception('Error create transaction: $e');
    }
  }

  // API untuk AUTENTIKASI - Login
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'), 
        headers: {
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
        final token = data['access_token'] ?? data['token'];
        await _storage.write(key: 'token', value: token); 
        print('✅ Login successful');
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Email atau password salah: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error login: $e');
    }
  }

  // API untuk AUTENTIKASI - Logout
  Future<void> logout() async {
    try {
      final headers = await _getHeaders(); 
      await http.post(
        Uri.parse('$API_URL/logout'),
        headers: headers,
      );
      print('✅ Logout successful');
    } catch (e) {
      print('⚠️ Error saat logout dari server: $e');
    } finally {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user');
    }
  }

  // API untuk AUTENTIKASI - Register
  Future<User> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$API_URL/register'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, 
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'] ?? data['token'];
        await _storage.write(key: 'token', value: token);
        print('✅ Registration successful');
        return User.fromJson(data['user']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal mendaftar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error register: $e');
    }
  }

  // API untuk KASIR - Update Status Meja
  Future<RestoTable> updateTableStatus(int tableId, String newStatus) async {
    try {
      final headers = await _getHeaders(); 
      final response = await http.patch( 
        Uri.parse('$API_URL/tables/$tableId/status'), 
        headers: headers,
        body: json.encode({ 
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Table $tableId updated to: $newStatus');
        return RestoTable.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Gagal update status meja: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error update table: $e');
    }
  }
}