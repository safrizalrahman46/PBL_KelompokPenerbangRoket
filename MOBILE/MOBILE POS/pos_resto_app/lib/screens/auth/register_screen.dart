// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../home/cashier_home_screen.dart';
import '../home/kitchen_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  // Ubah daftar role agar label ≠ value
  final List<Map<String, String>> _roles = [
    {'label': 'Kasir', 'value': 'cashier'},
    {'label': 'Dapur', 'value': 'kitchen'},
    {'label': 'Admin', 'value': 'admin'},
  ];

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih Role'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);

      print('🟡 [REGISTER] Memulai proses registrasi...');
      print('📧 Email: ${_emailController.text}');
      print('👤 Username: ${_nameController.text}');
      print('🔑 Password: ${_passwordController.text}');
      print('🎭 Role dipilih: $_selectedRole');

      try {
        // Kirim request ke API
        await authService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole!, // Sudah dalam format API
        );

        print('✅ [REGISTER] Respons dari server: ${authService.user}');
        if (!mounted) return;

        // Arahkan ke halaman sesuai role
        print('🚀 [NAVIGASI] Mengarahkan berdasarkan role: ${authService.user!.role}');
        _navigateBasedOnRole(authService.user!.role);
      } catch (e) {
        print('❌ [REGISTER ERROR] $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget homeScreen;
    print('🧭 [ROLE CHECK] Role terdeteksi: $role');

    switch (role.toLowerCase()) {
      case 'cashier':
        homeScreen = const CashierHomeScreen();
        print('➡️ Navigasi ke CashierHomeScreen');
        break;
      case 'kitchen':
        homeScreen = const KitchenHomeScreen();
        print('➡️ Navigasi ke KitchenHomeScreen');
        break;
      case 'admin':
        homeScreen = const LoginScreen(); // nanti ganti halaman admin kalau sudah ada
        print('➡️ Navigasi sementara ke LoginScreen (Admin belum dibuat)');
        break;
      default:
        homeScreen = const LoginScreen();
        print('⚠️ Role tidak dikenali, kembali ke LoginScreen');
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => homeScreen),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                  "Mari Buat!",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Akun Baru Untuk Restoranmu",
                  style: TextStyle(
                    fontSize: 18,
                    color: kSecondaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Dropdown Role
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kLightGreyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text('Pilih Role'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih role';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    fillColor: kLightGreyColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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

                // Register Button
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            authService.isLoading ? null : _submitRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: authService.isLoading
                            ? const CircularProgressIndicator(
                                color: kBackgroundColor)
                            : const Text(
                                'Register',
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

                // Link ke Login
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Sudah Punya Akun? Mari ",
                      style: TextStyle(
                        fontSize: 16,
                        color: kSecondaryColor.withOpacity(0.7),
                      ),
                      children: const [
                        TextSpan(
                          text: "Masuk",
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
