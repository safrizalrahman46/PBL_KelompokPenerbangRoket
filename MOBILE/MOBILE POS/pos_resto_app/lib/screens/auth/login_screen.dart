import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../home/cashier_home_screen.dart';
import '../home/kitchen_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        print('🚀 Proses login dimulai...');
        print('📧 Email: ${_emailController.text}');
        print('🔑 Password: ${_passwordController.text}');

        // 🔹 Panggil login DAN TANGKAP role yang dikembalikan
        final String role = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        print('✅ Login berhasil, role dari server: $role');

        if (!mounted) return;

        // 🔹 Navigasi berdasarkan role
        _navigateBasedOnRole(role);
      } catch (e) {
        print('❌ Login gagal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('⚠️ Form tidak valid, periksa input');
    }
  }

  // 🔹 Navigasi berdasarkan role user
  void _navigateBasedOnRole(String role) {
    print('🧭 Navigasi berdasarkan role: $role');
    Widget homeScreen;

    switch (role.toLowerCase()) {
      case 'cashier':
        print('➡️ Mengarahkan ke halaman kasir');
        homeScreen = const CashierHomeScreen();
        break;
      case 'kitchen':
        print('➡️ Mengarahkan ke halaman dapur');
        homeScreen = const KitchenHomeScreen();
        break;
      default:
        print('⚠️ Role tidak dikenal: $role, kembali ke login');
        homeScreen = const LoginScreen();
    }

    if (!mounted) return;

    // 🔁 Gunakan pushReplacement agar tidak bisa kembali ke login
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
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
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mari Kita Kelola Restoranmu",
                  style: TextStyle(
                    fontSize: 18,
                    color: kSecondaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // 🔹 Input Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
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
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🔹 Input Password
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

                // 🔹 Tombol Login
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authService.isLoading ? null : _submitLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
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

                // 🔹 Link ke Register
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

                // --- TOMBOL LIHAT ANTRIAN (VERSI KECIL) ---
                    const SizedBox(height: 24), // Memberi jarak dari link register
                    TextButton.icon(
                       icon: const Icon(Icons.tv_rounded, size: 18), // Ikon lebih kecil
                       label: const Text(
                         'Lihat Layar Antrian',
                         style: TextStyle(
                            fontSize: 16, // Font lebih kecil
                            fontWeight: FontWeight.w600, 
                            color: kPrimaryColor,
                         ),
                       ),
                       onPressed: () {
                         // Navigasi ke rute yang sudah didaftarkan di main.dart
                         Navigator.of(context).pushNamed('/queue_display');
                       },
                style: TextButton.styleFrom(
                         foregroundColor: kPrimaryColor, // Warna teks dan ikon
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
