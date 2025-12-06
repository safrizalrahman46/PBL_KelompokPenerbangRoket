// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../home/cashier_home_screen.dart';
import '../home/kitchen_home_screen.dart';
import 'login_screen.dart';
import '../../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController(context);
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    _controller.dispose();
    super.dispose();
  }

  // Show snackbar (UI only)
  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: color ?? kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Navigate based on role (UI only)
  void _navigateBasedOnRole(String role) {
    Widget homeScreen;

    switch (role.toLowerCase()) {
      case 'kasir':
        _showSnack('Masuk sebagai Kasir...');
        homeScreen = const CashierHomeScreen();
        break;
      case 'dapur':
        _showSnack('Masuk sebagai Dapur...');
        homeScreen = const KitchenHomeScreen();
        break;
      case 'admin':
        _showSnack('Masuk sebagai Admin (sementara kembali ke login)');
        homeScreen = const LoginScreen();
        break;
      default:
        _showSnack('Role tidak dikenali, kembali ke Login', color: Colors.red);
        homeScreen = const LoginScreen();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _controller.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                const Text(
                  "Buat Akun Baru!",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kelola restoranmu dengan mudah",
                  style: TextStyle(
                    fontSize: 18,
                    color: kSecondaryColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),

                // Role Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kLightGreyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _controller.selectedRole,
                    hint: const Text('Pilih Role'),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: _controller.roles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role['value'],
                        child: Text(role['label']!),
                      );
                    }).toList(),
                    onChanged: _controller.setRole,
                    validator: _controller.validateRole,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Input
                TextFormField(
                  controller: _controller.nameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
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
                  validator: _controller.validateName,
                ),
                const SizedBox(height: 16),

                // Email Input
                TextFormField(
                  controller: _controller.emailController,
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
                  validator: _controller.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _controller.passwordController,
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
                  validator: _controller.validatePassword,
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading
                        ? null
                        : () async {
                            _showSnack('Memproses registrasi...');
                            final role = await _controller.submitRegister();
                            if (role != null) {
                              _showSnack(
                                'Registrasi berhasil! Selamat datang 👋',
                                color: Colors.green,
                              );
                              _navigateBasedOnRole(role);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _controller.isLoading
                        ? const CircularProgressIndicator(
                            color: kBackgroundColor,
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kBackgroundColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
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
