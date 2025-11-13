import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_resto_app/services/auth_service.dart';
import 'package:pos_resto_app/utils/constants.dart';
import 'package:pos_resto_app/screens/home/cashier/cashier_home_screen.dart'; // PASTIKAN IMPORT INI
import 'package:pos_resto_app/screens/home/kitchen_home_screen.dart';
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

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? kPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        _showSnack('Proses login dimulai...');

        // 🔹 Login dan ambil role
        final String role = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        _showSnack('Login berhasil, role: $role', color: Colors.green);

        if (!mounted) return;
        _navigateBasedOnRole(role);
      } catch (e) {
        _showSnack(
          e.toString().replaceFirst('Exception: ', ''),
          color: Colors.red,
        );
      }
    } else {
      _showSnack('Form tidak valid, periksa input', color: Colors.orange);
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget homeScreen;
    switch (role.toLowerCase()) {
      case 'cashier':
        _showSnack('Mengalihkan ke halaman kasir...');
        homeScreen = const CashierHomeScreen(); // ✅ PASTIKAN INI
        break;
      case 'kitchen':
        _showSnack('Mengalihkan ke halaman dapur...');
        homeScreen = const KitchenHomeScreen();
        break;
      default:
        _showSnack('Role tidak dikenal, kembali ke login', color: Colors.red);
        return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeScreen),
      (route) => false,
    );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}