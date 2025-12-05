// lib/screens/auth/register_controller.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
// import '../../utils/constants.dart';

class RegisterController extends ChangeNotifier {
  final BuildContext context;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // State variables
  String selectedRole = 'kasir';
  bool isLoading = false;
  String? errorMessage;

  // Role options
  final List<Map<String, String>> roles = [
    {'value': 'kasir', 'label': 'Kasir'},
    {'value': 'dapur', 'label': 'Dapur'},
    {'value': 'admin', 'label': 'Admin'},
  ];

  RegisterController(this.context);

  // Set selected role
  void setRole(String? value) {
    if (value != null) {
      selectedRole = value;
      notifyListeners();
    }
  }

  // Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
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

  // Validate role
  String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Silakan pilih role';
    }
    return null;
  }

  // Submit register
  Future<String?> submitRegister() async {
    if (!validateForm()) {
      setError('Form tidak valid, periksa input');
      return null;
    }

    setLoading(true);
    setError(null);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Convert role to match API expectations
      final String apiRole;
      switch (selectedRole) {
        case 'kasir':
          apiRole = 'cashier';
          break;
        case 'dapur':
          apiRole = 'kitchen';
          break;
        case 'admin':
          apiRole = 'admin';
          break;
        default:
          apiRole = 'cashier';
      }

      // Register user (use named parameters expected by AuthService)
      await authService.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: apiRole,
      );

      setLoading(false);
      return selectedRole; // Return role for navigation
    } catch (e) {
      setLoading(false);
      setError(e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Cleanup controllers
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
