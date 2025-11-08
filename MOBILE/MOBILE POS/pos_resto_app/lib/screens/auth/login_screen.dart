// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart'; // Import constants Anda
import '../home/cashier_home_screen.dart'; // Import halaman utama kasir
import '../home/kitchen_home_screen.dart'; // Import halaman utama dapur
import 'register_screen.dart'; // Import halaman register

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        // 1. Panggil login DAN TANGKAP role yang dikembalikan
        final String role = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        // Cek jika widget masih ada sebelum navigasi
        if (!mounted) return;

        // 2. Gunakan 'role' yang sudah kita dapatkan
        _navigateBasedOnRole(role);
      } catch (e) {
        // Tampilkan pesan error jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ), // Bersihkan pesan exception
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget homeScreen;
    switch (role.toLowerCase()) {
      case 'kasir':
        homeScreen = const CashierHomeScreen();
        break;
      case 'dapur':
        homeScreen = const KitchenHomeScreen();
        break;
      default:
        homeScreen =
            const LoginScreen(); // Default ke login jika role tidak dikenal
    }

    // Gunakan pushReplacement untuk mencegah kembali ke halaman login
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendengarkan perubahan loading state dari AuthService
    return Scaffold(
      backgroundColor: kBackgroundColor, // Warna background dari constants
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor, // Warna primer dari constants
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mari Kita Kelola Restoranmu",
                  style: TextStyle(
                    fontSize: 18,
                    color: kSecondaryColor.withOpacity(
                      0.7,
                    ), // Warna sekunder dari constants
                  ),
                ),
                const SizedBox(height: 48),

                // Username/Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText:
                        'Email', // Ganti ke Email sesuai standar otentikasi
                    fillColor: kLightGreyColor, // Warna input dari constants
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    fillColor: kLightGreyColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Login Button
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authService.isLoading
                            ? null
                            : _submitLogin, // Disable saat loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              kPrimaryColor, // Warna primer dari constants
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: authService.isLoading
                            ? const CircularProgressIndicator(
                                color: kBackgroundColor,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kBackgroundColor,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Link ke Register
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Belum Punya Akun? Mari Buat ",
                      style: TextStyle(
                        fontSize: 16,
                        color: kSecondaryColor.withOpacity(0.7),
                      ),
                      children: const [
                        TextSpan(
                          text: "Akun Baru",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
