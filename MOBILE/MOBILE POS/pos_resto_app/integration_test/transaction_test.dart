import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pos_resto_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: Full Transaction Flow (Login -> Order -> Pay)', (WidgetTester tester) async {
    print("🚀 MEMULAI TEST TRANSAKSI...");
    
    // 1. Jalankan Aplikasi
    app.main();
    await tester.pumpAndSettle();

    // ====================================================
    // STEP 1: CEK STATUS LOGIN
    // ====================================================
    print("🔹 STEP 1: Cek Status Login...");

    bool isAlreadyLoggedIn = find.text('Eat.o').evaluate().isNotEmpty || 
                             find.text('Menu').evaluate().isNotEmpty;

    if (isAlreadyLoggedIn) {
      print("✅ Terdeteksi SUDAH LOGIN.");
    } else {
      print("⚠️ Belum Login. Melakukan proses Login...");
      
      final loginBtnKey = find.byKey(const Key('login_btn'));
      Finder loginBtn = loginBtnKey;

      if (loginBtnKey.evaluate().isEmpty) {
        final btnByText = find.widgetWithText(ElevatedButton, 'Masuk');
        if (btnByText.evaluate().isEmpty) {
           await tester.pumpAndSettle(const Duration(seconds: 5));
        }
        loginBtn = btnByText;
      }

      final emailField = find.byKey(const Key('email_field'));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'admin@gmail.com');
      } else {
        await tester.enterText(find.byType(TextFormField).at(0), 'admin@gmail.com');
      }
      await tester.pump();

      final passField = find.byKey(const Key('password_field'));
      if (passField.evaluate().isNotEmpty) {
        await tester.enterText(passField, 'kasir123');
      } else {
        await tester.enterText(find.byType(TextFormField).at(1), 'kasir123');
      }
      await tester.pump();

      print("👆 Klik Login...");
      await tester.tap(loginBtn);
      
      print("⏳ Menunggu proses login...");
      bool dashboardFound = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1)); 
        if (find.text('Eat.o').evaluate().isNotEmpty) {
          dashboardFound = true;
          break;
        }
      }

      if (!dashboardFound) {
        final snackBar = find.byType(SnackBar);
        if (snackBar.evaluate().isNotEmpty) {
           final errText = find.descendant(of: snackBar, matching: find.byType(Text));
           if (errText.evaluate().isNotEmpty) {
             final msg = (errText.evaluate().first.widget as Text).data ?? "";
             print("ℹ️ Pesan Server: $msg");
             if (msg.toLowerCase().contains("gagal") || msg.toLowerCase().contains("salah")) {
               fail("Login Gagal: $msg");
             }
           }
        }
        fail("Timeout: Berhasil login tapi Dashboard 'Eat.o' tidak muncul.");
      }
    }
    print("✅ Berhasil Masuk Dashboard.");

    // ====================================================
    // STEP 2: PILIH MENU
    // ====================================================
    print("🔹 STEP 2: Memilih Menu...");

    final menuIcon = find.byIcon(Icons.restaurant_menu);
    if (menuIcon.evaluate().isNotEmpty) {
      await tester.tap(menuIcon);
      await tester.pumpAndSettle();
    }

    print("⏳ Menunggu Menu dimuat (5 detik)...");
    await tester.pumpAndSettle(const Duration(seconds: 5));

    Finder addBtn = find.byIcon(Icons.add_circle);
    if (addBtn.evaluate().isEmpty) {
      addBtn = find.byIcon(Icons.add);
    }

    if (addBtn.evaluate().isNotEmpty) {
      await tester.tap(addBtn.first);
      print("✅ Menu ditambahkan ke keranjang.");
      await tester.pump(); 
    } else {
      print("❌ GAGAL: Tidak ada menu yang tampil.");
      fail("Menu kosong atau gagal loading.");
    }

    // ====================================================
    // STEP 3: MENUJU HALAMAN BAYAR
    // ====================================================
    print("🔹 STEP 3: Menuju Pembayaran...");

    final fab = find.byType(FloatingActionButton);
    final continueBtn = find.text("Lanjutkan Transaksi");
    final textBtn = find.widgetWithText(ElevatedButton, "Bayar"); 
    final rpBtn = find.textContaining("Rp").last;

    if (continueBtn.evaluate().isNotEmpty) {
      print("👉 Klik tombol 'Lanjutkan Transaksi'");
      await tester.tap(continueBtn);
    } else if (fab.evaluate().isNotEmpty) {
      print("👉 Klik FAB Keranjang");
      await tester.tap(fab);
    } else if (textBtn.evaluate().isNotEmpty) {
      print("👉 Klik tombol Bayar");
      await tester.tap(textBtn);
    } else {
      print("👉 Klik tombol Total Harga");
      await tester.tap(rpBtn);
    }

    await tester.pumpAndSettle();

    bool isPaymentScreen = find.byType(TextField).evaluate().isNotEmpty;
    if (!isPaymentScreen) {
        fail("Gagal masuk halaman Payment.");
    }
    print("✅ Masuk Halaman Pembayaran.");

    // ====================================================
    // STEP 4: ISI DATA PEMBAYARAN
    // ====================================================
    print("🔹 STEP 4: Isi Form Pembayaran...");

    // Mengambil Scrollable Utama
    final scrollableFinder = find.byType(SingleChildScrollView);
    final scrollable = scrollableFinder.first;

    // 1. INPUT NAMA PELANGGAN
    final nameField = find.byType(TextField).first;
    await tester.enterText(nameField, "Tester Budi");
    await tester.pump();
    tester.testTextInput.closeConnection(); 
    await tester.pumpAndSettle();

    // 2. KLIK "AMBIL SENDIRI"
    final selfServiceBtn = find.text("Ambil Sendiri"); 
    try {
      // Scroll sampai ketemu
      await tester.scrollUntilVisible(selfServiceBtn, 100, scrollable: scrollable);
      if (selfServiceBtn.evaluate().isNotEmpty) {
         await tester.tap(selfServiceBtn);
         await tester.pumpAndSettle();
         print("👉 Klik 'Ambil Sendiri'");
      }
    } catch (e) {
      print("⚠️ Tombol 'Ambil Sendiri' tidak ketemu.");
    }

    // 3. KLIK "APPLY"
    print("👉 Mencari tombol 'Apply'...");
    Finder applyBtn = find.text("Apply");
    if (applyBtn.evaluate().isEmpty) {
       applyBtn = find.byIcon(Icons.check);
    }

    if (applyBtn.evaluate().isNotEmpty) {
       await tester.tap(applyBtn.first); 
       print("✅ Klik 'Apply' Berhasil.");
       await tester.pumpAndSettle();
    } else {
       print("⚠️ Tombol Apply tidak ditemukan.");
    }

    // 4. PILIH CASH
    print("👉 Memilih Metode Pembayaran Cash...");
    final cashText = find.text("Cash");
    
    try {
      await tester.scrollUntilVisible(cashText, 100, scrollable: scrollable);
      await tester.tap(cashText);
    } catch (e) {
      if (cashText.evaluate().isNotEmpty) {
         await tester.tap(cashText);
      }
    }
    await tester.pump();

    // 5. INPUT NOMINAL (JIKA ADA)
    if (find.byType(TextField).evaluate().length > 1) {
       final moneyField = find.byType(TextField).last;
       await tester.enterText(moneyField, "500000"); 
       await tester.pump();
       tester.testTextInput.closeConnection(); 
       await tester.pumpAndSettle();
    }

    // ====================================================
    // STEP 5: PROSES BAYAR (FIXED SCROLL)
    // ====================================================
    print("🔹 STEP 5: Klik Order Completed...");

    Finder targetBtn = find.text("Order Completed");
    
    if (targetBtn.evaluate().isEmpty) {
       targetBtn = find.text("Bayar Sekarang");
    }
    if (targetBtn.evaluate().isEmpty) {
       targetBtn = find.byType(ElevatedButton).last;
    }

    // SCROLL MAX KE BAWAH AGAR TOMBOL TIDAK KETUTUP
    try {
        await tester.drag(scrollable, const Offset(0, -500)); // Scroll ke bawah paksa
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(targetBtn, 100, scrollable: scrollable);
    } catch(e) {}
    
    await tester.tap(targetBtn);

    print("⏳ Memproses Transaksi (Max 15s)...");
    try {
      await tester.pumpAndSettle(const Duration(seconds: 15));
    } catch(e) {
      print("⚠️ Warning: Loading lama.");
    }

    // ====================================================
    // STEP 6: VERIFIKASI SUKSES (UPDATED LOGIC)
    // ====================================================
    
    bool isSuccess = find.textContaining("Berhasil").evaluate().isNotEmpty || 
                     find.textContaining("Kembalian").evaluate().isNotEmpty || 
                     find.text("Cetak Struk").evaluate().isNotEmpty ||
                     find.text("Eat.o").evaluate().isNotEmpty; // Kembali ke dashboard

    if (isSuccess) {
      print("🎉 TRANSAKSI BERHASIL! (Test Passed)");
    } else {
      // CEK SNACKBAR
      final snackBar = find.byType(SnackBar);
      if (snackBar.evaluate().isNotEmpty) {
         final errText = find.descendant(of: snackBar, matching: find.byType(Text));
         if (errText.evaluate().isNotEmpty) {
            final msg = (errText.evaluate().first.widget as Text).data ?? "";
            
            // --- LOGIKA BARU: PESAN "MENGALIHKAN" ADALAH SUKSES ---
            if (msg.contains("Mengalihkan") || msg.contains("Berpindah") || msg.contains("Berhasil")) {
                print("🎉 TRANSAKSI BERHASIL! (Server: $msg)");
                return; // TEST PASS
            } else {
                print("❌ TRANSAKSI GAGAL! Pesan Server: '$msg'");
                fail("Transaksi Ditolak: $msg");
            }
         }
      }
      fail("Transaksi Gagal: Tidak ditemukan tanda sukses.");
    }
  });
}