// lib/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../home/cashier_home_screen.dart';
import '../home/kitchen_home_screen.dart';
import '../auth/login_screen.dart';
import '../../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bubbleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text Animation Controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Bubble Animation Controller
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Logo Animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text Animations
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Bubble floating animation
    _bubbleAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _startAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _startAnimations() async {
    await _logoController.forward();
    await _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Beri sedikit jeda agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));

    final authService = Provider.of<AuthService>(context, listen: false);

    // Panggil tryAutoLogin, yang sekarang kita tahu mengembalikan bool
    final bool isLoggedIn = await authService.tryAutoLogin();

    if (!mounted) return;

    // Cek hasil boolean-nya
    if (isLoggedIn) {
      // Jika true, ambil data user dari DALAM service
      // (Asumsi service Anda punya getter 'currentUser')
      final User? user = authService.user;

      if (user != null) {
        // Arahkan berdasarkan role dari user yang didapat
        _navigateBasedOnRole(user.role);
      } else {
        // Skenario aneh: login sukses tapi data user tidak ada
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      // Jika false (tidak ada token/gagal login), ke halaman Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
        homeScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => homeScreen),
    );
  }

  // Helper widget untuk membuat gelembung dengan animasi
  Widget _buildAnimatedBubble(
    double size, {
    double opacity = 1.0,
    double offsetMultiplier = 1.0,
  }) {
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _bubbleAnimation.value * offsetMultiplier,
            _bubbleAnimation.value * offsetMultiplier * 0.5,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: kSplashCircleColor.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kSplashBackgroundColor,
      body: Stack(
        children: [
          // Gelembung kiri atas dengan animasi
          Positioned(
            top: size.height * 0.1,
            left: -size.width * 0.15,
            child: _buildAnimatedBubble(
              size.width * 0.35,
              opacity: 0.7,
              offsetMultiplier: 1.5,
            ),
          ),

          // Gelembung kanan atas (lebih kecil)
          Positioned(
            top: size.height * 0.35,
            right: -size.width * 0.05,
            child: _buildAnimatedBubble(
              size.width * 0.25,
              opacity: 0.6,
              offsetMultiplier: -1.2,
            ),
          ),

          // Gelembung kanan bawah (besar)
          Positioned(
            bottom: -size.height * 0.05,
            right: -size.width * 0.2,
            child: _buildAnimatedBubble(
              size.width * 0.7,
              opacity: 0.5,
              offsetMultiplier: 0.8,
            ),
          ),

          // Gelembung kiri bawah
          Positioned(
            bottom: size.height * 0.05,
            left: -size.width * 0.1,
            child: _buildAnimatedBubble(
              size.width * 0.4,
              opacity: 0.6,
              offsetMultiplier: -1.0,
            ),
          ),

          // Konten Utama (Logo + Teks) dengan animasi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dengan animasi scale dan opacity
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/eato_logo.png',
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Teks dengan animasi slide dan fade
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _textSlideAnimation,
                      child: Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: const Text(
                          "Eat.o",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}