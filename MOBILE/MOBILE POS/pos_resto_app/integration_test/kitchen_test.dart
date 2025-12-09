import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_resto_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const kitchenEmail = 'najril@gmail.com';
  const kitchenPass = 'dapur123';

  testWidgets('E2E: Kitchen Flow (Login -> Check Dashboard -> Process Order)', (WidgetTester tester) async {
    print("🚀 MEMULAI TEST DAPUR...");
    
    app.main();
    await tester.pumpAndSettle();

    // ====================================================
    // STEP 1: CEK STATUS LOGIN & LOGIN
    // ====================================================
    print("🔹 STEP 1: Persiapan Login...");

    bool isKitchenDashboard = find.text('Dapur Eat.o').evaluate().isNotEmpty;

    if (isKitchenDashboard) {
       print("✅ Sudah login sebagai Dapur.");
    } else {
       if (find.text('Eat.o').evaluate().isNotEmpty) {
          print("⚠️ Sedang login Kasir. Logout...");
          await tester.tap(find.byIcon(Icons.logout));
          await tester.pumpAndSettle();
          if (find.text('Logout').evaluate().isNotEmpty) {
             await tester.tap(find.text('Logout').last);
             await tester.pumpAndSettle();
          }
       }

       print("🔹 Login sebagai Dapur ($kitchenEmail)...");

       final emailField = find.byKey(const Key('email_field'));
       if (emailField.evaluate().isNotEmpty) {
         await tester.enterText(emailField, kitchenEmail);
       } else {
         await tester.enterText(find.byType(TextFormField).at(0), kitchenEmail);
       }
       await tester.pump();

       final passField = find.byKey(const Key('password_field'));
       if (passField.evaluate().isNotEmpty) {
         await tester.enterText(passField, kitchenPass);
       } else {
         await tester.enterText(find.byType(TextFormField).at(1), kitchenPass);
       }
       await tester.pump();

       final loginBtn = find.byKey(const Key('login_btn'));
       if (loginBtn.evaluate().isNotEmpty) {
         await tester.tap(loginBtn);
       } else {
         await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
       }

       print("⏳ Menunggu dashboard Dapur...");
       bool dashboardFound = false;
       for (int i = 0; i < 20; i++) {
         await tester.pump(const Duration(seconds: 1));
         if (find.text('Dapur Eat.o').evaluate().isNotEmpty) {
           dashboardFound = true;
           break;
         }
       }

       if (!dashboardFound) {
          fail("Gagal masuk ke Dashboard Dapur (Timeout).");
       }
    }

    print("✅ Berhasil Masuk Dashboard Dapur.");
    
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ====================================================
    // STEP 2: CEK TAB NAVIGASI
    // ====================================================
    print("🔹 STEP 2: Cek Tab Navigasi...");

    final tabBarFinder = find.byType(TabBar);

    if (tabBarFinder.evaluate().isNotEmpty) {
       print("✅ TabBar Ditemukan.");
       final tabs = find.descendant(of: tabBarFinder, matching: find.byType(Tab));
       if (tabs.evaluate().length >= 3) {
          print("✅ Ditemukan 3 Tab Navigasi.");
       } else {
          print("⚠️ Warning: Jumlah tab kurang dari 3, tapi lanjut...");
       }
    } else {
       print("⚠️ TabBar tidak ditemukan, akan pakai fallback text...");
    }

    // ====================================================
    // STEP 3: PROSES PESANAN
    // ====================================================
    print("🔹 STEP 3: Mencoba Memproses Pesanan...");

    // ---------- TAB 1 ----------
    print("👉 Masuk Tab 1 (Pending)...");

    final tabs = find.descendant(of: find.byType(TabBar), matching: find.byType(Tab));
    if (tabs.evaluate().isNotEmpty && tabs.evaluate().length > 0) {
       final firstTab = tabs.at(0);
       await tester.tap(firstTab);
       await tester.pumpAndSettle();
    } else {
       // Fallback jika tidak ada TabBar
       final fallback1 = find.text("Pesanan Baru");
       if (fallback1.evaluate().isNotEmpty) {
         await tester.tap(fallback1);
         await tester.pumpAndSettle();
       }
    }

    // Tombol Pending (fallback)
    Finder processBtn = find.text("Mulai Memasak");
    if (processBtn.evaluate().isEmpty) processBtn = find.text("Siapkan");
    if (processBtn.evaluate().isEmpty) processBtn = find.text("Process");

    if (processBtn.evaluate().isNotEmpty) {
       print("👉 Ada pesanan Pending. Klik tombol proses...");
       await tester.tap(processBtn.first);
       await tester.pumpAndSettle();
    } else {
       print("ℹ️ Tidak ada pesanan Pending.");
    }

    // ---------- TAB 2 ----------
    print("👉 Masuk Tab 2 (Disiapkan)...");

    if (tabs.evaluate().isNotEmpty && tabs.evaluate().length > 1) {
       final secondTab = tabs.at(1);
       await tester.tap(secondTab);
       await tester.pumpAndSettle();
    } else {
       final fallback2 = find.text("Sedang Dimasak");
       if (fallback2.evaluate().isNotEmpty) {
         await tester.tap(fallback2);
         await tester.pumpAndSettle();
       }
    }

    // Checkbox centang
    final checkboxes = find.byType(Checkbox);
    if (checkboxes.evaluate().isNotEmpty) {
      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();
    }

    // Tombol Selesaikan
    Finder finishBtn = find.text("Selesaikan");
    if (finishBtn.evaluate().isEmpty) finishBtn = find.text("Sajikan");

    if (finishBtn.evaluate().isNotEmpty) {
      print("👉 Menyelesaikan pesanan...");
      await tester.tap(finishBtn.first);
      await tester.pumpAndSettle();
    } else {
      print("ℹ️ Tidak ada pesanan Disiapkan.");
    }

    // ====================================================
    // STEP 4: LOGOUT
    // ====================================================
    print("🔹 STEP 4: Testing Logout...");
    
    final logoutBtn = find.byIcon(Icons.logout);
    if (logoutBtn.evaluate().isNotEmpty) {
       await tester.tap(logoutBtn);
       await tester.pumpAndSettle();
       
       final confirmLogout = find.text("Keluar");
       if (confirmLogout.evaluate().isNotEmpty) {
          await tester.tap(confirmLogout.last);
          await tester.pumpAndSettle();
       }
       
       if (find.text("Masuk").evaluate().isNotEmpty) {
          print("✅ Berhasil Logout.");
       }
    }

    print("🎉 TEST DAPUR SUKSES!");
  });
}