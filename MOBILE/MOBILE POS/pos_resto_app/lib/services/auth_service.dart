import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  final String baseUrl = 'http://127.0.0.1:8000/api/v1';
  final _storage = const FlutterSecureStorage();

  String? _token;
  User? _user;

  bool _isLoading = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuth => _token != null && _user != null;
  String? get userRole => _user?.role;
  bool get isLoading => _isLoading;

  Future<void> _saveToken(String token, User user) async {
    print('💾 Menyimpan token dan user ke secure storage...');
    await _storage.write(key: 'token', value: token);
    await _storage.write(
      key: 'user',
      value: json.encode({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
      }),
    );
    _token = token;
    _user = user;
    print('✅ Token & user berhasil disimpan: ${user.email}');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    print('🔄 Mencoba auto login...');
    final token = await _storage.read(key: 'token');
    final userString = await _storage.read(key: 'user');

    if (token == null || userString == null) {
      print('⚠️ Token atau user tidak ditemukan');
      return false;
    }

    try {
      final userJson = json.decode(userString);
      _user = User.fromJson(userJson);
      _token = token;
      print('✅ Auto login berhasil: ${_user?.email}');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Gagal decode user dari storage: $e');
      return false;
    }
  }

  Future<String> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    print('🚀 Proses login dimulai...');
    print('📨 Email: $email | Password: (disembunyikan)');
    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      print('🔹 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug isi data JSON
        print('✅ Data dari server: $data');

        final userJson = data['user'];
        final token = data['token'] ?? data['access_token'];

        if (userJson == null) {
          throw Exception('User data tidak ditemukan di respons server.');
        }
        if (token == null) {
          throw Exception('Token tidak ditemukan di respons server.');
        }

        final user = User.fromJson(userJson);
        print('👤 User login: ${user.name} (${user.email}) | Role: ${user.role}');
        print('🔐 Token: $token');

        await _saveToken(token, user);
        return user.role;
      } else {
        final error = json.decode(response.body);
        print('❌ Login gagal: ${error['message'] ?? 'Login Gagal'}');
        throw Exception(error['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      print('💥 Exception di login: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 Login selesai.');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();
    print('📝 Proses registrasi dimulai...');

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

      print('🔹 Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      // 🔧 Tambahan utama di sini
      if (response.statusCode == 200 ||
          response.statusCode == 201 || // ← tambahkan ini
          response.statusCode == 204) {
        print('✅ Registrasi berhasil, lanjut login otomatis...');

        try {
          final data = json.decode(response.body);
          final token = data['access_token'] ?? data['token'];
          final userData = data['user'];

          // Kalau token & user langsung dikirim, simpan langsung tanpa login ulang
          if (token != null && userData != null) {
            final user = User.fromJson(userData);
            await _saveToken(token, user);
            print('✅ Token langsung diterima dari register.');
            return;
          }
        } catch (_) {
          // Jika format tidak cocok, lanjut login manual
        }

        await login(email, password);
      } else {
        try {
          final error = json.decode(response.body);
          if (error['errors'] != null) {
            final firstError = error['errors'].values.first[0];
            print('⚠️ Validasi gagal: $firstError');
            throw Exception(firstError);
          }
          throw Exception(error['message'] ?? 'Registrasi Gagal');
        } catch (jsonError) {
          print('❌ Respons bukan JSON valid: $jsonError');
          throw Exception('Registrasi Gagal. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('💥 Exception di register: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 Registrasi selesai.');
    }
  }

  Future<void> logout() async {
    print('🚪 Proses logout dimulai...');
    try {
      if (_token != null) {
        final response = await http.post(
          Uri.parse('$API_URL/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
        print('🔹 Logout server response: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Gagal logout di server: $e');
    } finally {
      await _storage.deleteAll();
      _token = null;
      _user = null;
      notifyListeners();
      print('✅ Logout selesai (local data dibersihkan)');
    }
  }
}
