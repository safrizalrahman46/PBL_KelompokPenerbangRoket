// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services
import 'package:provider/provider.dart';

// Import semua Service dan Provider
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';

// Import semua Halaman
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// tambahan
import 'screens/home/queue_display_screen.dart';
import 'screens/home/mirror_order.dart';

import 'services/api_service.dart';
import 'controllers/cashier_payment_controller.dart';
import 'controllers/mirror_order_logic.dart'; // <--- TAMBAHKAN INI

// Anda tidak perlu import Cashier/Kitchen di sini karena Splash/Login
// yang akan menanganinya.

// Import Constants
import 'utils/constants.dart';

void main() {
  // Pastikan Flutter siap
  WidgetsFlutterBinding.ensureInitialized();

  // KUNCI APLIKASI KE MODE LANDSCAPE (MIRING)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    // Jalankan aplikasi setelah orientasi di-set
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // ChangeNotifierProxyProvider<CartProvider, CashierPaymentController>(
        //   create: (context) => CashierPaymentController(
        //     context: context,
        //     cart: Provider.of<CartProvider>(context, listen: false),
        //     tables: [], // Perlu dihandle nnti
        //     apiService: ApiService(), // Sesuaikan
        //     onOrderSuccess: () {},
        //   ),
        //   update: (context, cart, previous) =>
        //       previous!..cart = cart, // Update cart ref
        // ),

        ChangeNotifierProvider(create: (_) => MirrorOrderLogic()),
      ],
      child: MaterialApp(
        title: 'Eat.o POS',
        debugShowCheckedModeBanner: false,

        // --- TEMA ANDA (Sangat bagus, kita pertahankan) ---
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: kBackgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimaryColor,
            primary: kPrimaryColor,
            secondary: kSecondaryColor,
            background: kLightGreyColor,
          ),
          fontFamily:
              'Inter', // Pastikan Anda sudah menambahkan file font 'Inter' ke assets
          appBarTheme: const AppBarTheme(
            backgroundColor: kBackgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: kSecondaryColor),
            titleTextStyle: TextStyle(
              color: kSecondaryColor,
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
              fontFamily: 'Inter',
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
              fontFamily: 'Inter',
            ),
          ),
        ),

        // --- INI PERUBAHAN UTAMANYA ---
        // Kita mulai dari SplashScreen, yang akan menangani
        // logika "apakah sudah login atau belum".
        home: const SplashScreen(),
        // ---------------------------------

        // Kita tetap sediakan Rute ini agar
        // LoginScreen bisa menavigasi ke RegisterScreen
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),

          // Tambahan safrizal
          '/queue_display': (context) => const QueueDisplayScreen(),
          '/mirror_order': (context) => const MirrorOrderScreen(
            // customerName: "",
            // queueNumber: 0,
            // items: [],
            // total: 0,
          ),
        },
      ),
    );
  }
}
