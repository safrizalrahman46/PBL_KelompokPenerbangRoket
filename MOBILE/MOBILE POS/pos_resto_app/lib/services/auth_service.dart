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

  bool _isLoading = false;

  String? get token => _token;
  User? get user => _user;
  bool get isAuth => _token != null && _user != null;
  String? get userRole => _user?.role;
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
      }),
    );
    _token = token;
    _user = user;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'token');
    final userString = await _storage.read(key: 'user');

    if (token == null || userString == null) return false;

    try {
      final userJson = json.decode(userString);
      _user = User.fromJson(userJson);
      _token = token;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userJson = data['user'];
        final token = data['token'] ?? data['access_token'];

        if (userJson == null || token == null) {
          throw Exception('Data login tidak valid');
        }

        final user = User.fromJson(userJson);
        await _saveToken(token, user);
        return user.role;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login gagal');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
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

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        
        try {
          final data = json.decode(response.body);
          final token = data['access_token'] ?? data['token'];
          final userData = data['user'];

          if (token != null && userData != null) {
            final user = User.fromJson(userData);
            await _saveToken(token, user);
            return;
          }
        } catch (_) {}

        await login(email, password);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$API_URL/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (_) {}

    await _storage.deleteAll();
    _token = null;
    _user = null;
    notifyListeners();
  }
}
