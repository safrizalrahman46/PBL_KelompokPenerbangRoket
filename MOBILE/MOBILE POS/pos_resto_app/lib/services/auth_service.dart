import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _token;
  User? _user;
  
  // --- 1. TAMBAHKAN VARIABEL INI ---
  bool _isLoading = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuth => _token != null && _user != null;
  String? get userRole => _user?.role;

  // --- 2. TAMBAHKAN GETTER INI ---
  bool get isLoading => _isLoading;

  Future<void> _saveToken(String token, User user) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(
        key: 'user',
        value: json.encode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role,
        }));
    _token = token;
    _user = user;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'token');
    final userString = await _storage.read(key: 'user');

    if (token == null || userString == null) {
      return false;
    }

    _token = token;
    _user = User.fromJson(json.decode(userString));
    notifyListeners();
    return true;
  }

  Future<String> login(String email, String password) async {
    // --- 3. TAMBAHKAN MANAJEMEN STATE ---
    _isLoading = true;
    notifyListeners();
    // ---------------------------------
    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'), // Gunakan API_URL
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        await _saveToken(data['token'], user);
        return user.role;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      // Pastikan 'e' diteruskan dengan benar
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      // --- 4. TAMBAHKAN MANAJEMEN STATE ---
      _isLoading = false;
      notifyListeners();
      // ---------------------------------
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // --- 5. TAMBAHKAN MANAJEMEN STATE ---
    _isLoading = true;
    notifyListeners();
    // ---------------------------------
    try {
      // Panggil Rute Registrasi Filament
      final response = await http.post(
        Uri.parse(
            '$BASE_URL/admin/register'), // Gunakan BASE_URL (bukan API_URL)
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      // Filament/Livewire mengembalikan 200 atau 204
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Jika registrasi berhasil, langsung login
        // 'login' akan menangani 'notifyListeners'
        await login(email, password);
      } else {
        // Tangani error validasi
        try {
          final error = json.decode(response.body);
          if (error['errors'] != null) {
            // Ambil pesan error validasi pertama
            throw Exception(error['errors'].values.first[0]);
          }
          throw Exception(error['message'] ?? 'Registrasi Gagal');
        } catch (jsonError) {
          // Jika respons bukan JSON (mungkin halaman HTML error)
          throw Exception('Registrasi Gagal. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Pastikan 'e' diteruskan dengan benar
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      // --- 6. TAMBAHKAN MANAJEMEN STATE ---
      // (Meskipun 'login' akan menanganinya, ini untuk keamanan)
      _isLoading = false;
      notifyListeners();
      // ---------------------------------
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$API_URL/logout'), // Gunakan API_URL
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Gagal logout di server, tapi tetap logout lokal
    } finally {
      await _storage.deleteAll();
      _token = null;
      _user = null;
      notifyListeners();
    }
  }
}