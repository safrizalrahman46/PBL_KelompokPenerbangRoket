// lib/screens/auth/login_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../screens/home/cashier_home_screen.dart';
import '../../screens/home/kitchen_home_screen.dart';
import '../screens/auth/register_screen.dart';
import '../../utils/constants.dart';

class LoginController extends ChangeNotifier {
  final BuildContext context;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginController(this.context);

  // Show snackbar
  void showSnack(String message, {Color? color}) {
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
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 7),
      ),
    );
  }

  // Submit login
  Future<void> submitLogin() async {
    if (formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        showSnack('Proses login dimulai...');

        // Login dan ambil role
        final String role = await authService.login(
          emailController.text,
          passwordController.text,
        );

        showSnack('Login berhasil, role: $role', color: Colors.green);

        if (!context.mounted) return;
        await navigateBasedOnRole(role);
      } catch (e) {
        showSnack(
          e.toString().replaceFirst('Exception: ', ''),
          color: Colors.red,
        );
      }
    } else {
      showSnack('Form tidak valid, periksa input', color: Colors.orange);
    }
  }

  // Navigate based on user role
  Future<void> navigateBasedOnRole(String role) async {
    Widget homeScreen;
    switch (role.toLowerCase()) {
      case 'cashier':
        showSnack('Mengalihkan ke halaman kasir...');
        homeScreen = const CashierHomeScreen();
        break;
      case 'kitchen':
        showSnack('Mengalihkan ke halaman dapur...');
        homeScreen = const KitchenHomeScreen();
        break;
      default:
        showSnack('Role tidak dikenal, kembali ke login', color: Colors.red);
        return;
    }

    if (!context.mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeScreen),
      (route) => false,
    );
  }

  // Navigate to register screen
  void navigateToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // Navigate to queue display
  void navigateToQueueDisplay() {
    Navigator.of(context).pushNamed('/queue_display');
  }

    // Navigate to queue display
  void navigateToMirrorDisplay() {
    Navigator.of(context).pushNamed('/mirror_order');
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!value.contains('@')) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // Cleanup controllers
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
