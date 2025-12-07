// lib/providers/cart_provider.dart

import 'dart:convert'; // Tambahan untuk JSON
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Tambahan untuk Request API
import '../models/menu_model.dart';
import '../utils/constants.dart'; // Pastikan BASE_URL/API_URL ada disini

// 1. Definisikan Model untuk Item di Keranjang
class CartItem {
  final Menu menu;
  int quantity;

  CartItem({required this.menu, this.quantity = 1});

  // Helper untuk menambah harga item
  double get totalPrice => menu.price * quantity;
}

// 2. Buat Class Provider-nya
class CartProvider with ChangeNotifier {
  // --- STATE ---

  // Daftar privat untuk menyimpan item keranjang
  final Map<int, CartItem> _items = {};

  // Ambil nilai pajak & diskon dari desain Anda
  final double _taxPercent = 10.0;
  final double _discountPercent = 0.0;

  // --- GETTERS (Untuk dibaca oleh UI) ---

  // Getter publik untuk mengakses daftar item
  List<CartItem> get items {
    return _items.values.toList();
  }

  // Getter untuk jumlah item unik di keranjang
  int get itemCount {
    return _items.length;
  }

  // Getter untuk mengambil kuantitas item tertentu
  int getItemQuantity(int menuId) {
    return _items.containsKey(menuId) ? _items[menuId]!.quantity : 0;
  }

  // Getter untuk kalkulasi
  double get taxPercent => _taxPercent;
  double get discountPercent => _discountPercent;

  double get subtotal {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  double get total {
    final sub = subtotal;
    final taxAmount = sub * (_taxPercent / 100);
    final discountAmount = sub * (_discountPercent / 100);
    return sub + taxAmount - discountAmount;
  }

  // --- LOGIC TAMBAHAN: SYNC KE SERVER (UNTUK MIRROR DISPLAY) ---
  
  Future<void> _syncToServer() async {
    try {
      // 1. Siapkan data JSON yang menggambarkan isi keranjang saat ini
      // Struktur ini disesuaikan agar mudah dibaca oleh Controller Laravel 'update'
      final cartData = {
        "cart_items": _items.values.map((item) => {
          "product_name": item.menu.name,
          "quantity": item.quantity,
          "price": item.menu.price,
        }).toList(),
        "subtotal": subtotal,
        "total": total,
        // Kita bisa tambahkan info lain jika perlu
      };

      // 2. Kirim ke Endpoint Laravel (pastikan endpoint ini ada di api.php)
      // Endpoint ini hanya menyimpan data sementara di Cache server
      await http.post(
        Uri.parse('$API_URL/active-transaction/update'), 
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(cartData),
      );
      
      if (kDebugMode) {
        print("✅ Cart Synced to Server: ${_items.length} unique items");
      }
    } catch (e) {
      // Kita hanya print error di console agar tidak mengganggu flow kasir
      print("❌ Gagal Sync ke Mirror: $e");
    }
  }

  // --- ACTIONS (Fungsi untuk mengubah state) ---

  // Menambah item ke keranjang
  void addItem(Menu menu) {
    if (_items.containsKey(menu.id)) {
      _items.update(menu.id, (existingItem) {
        existingItem.quantity++;
        return existingItem;
      });
    } else {
      _items.putIfAbsent(menu.id, () => CartItem(menu: menu));
    }
    
    notifyListeners();
    _syncToServer(); // 🔥 Panggil Sync setelah update UI
  }

  // Mengurangi item dari keranjang
  void decreaseItem(int menuId) {
    if (!_items.containsKey(menuId)) return;

    if (_items[menuId]!.quantity > 1) {
      _items.update(menuId, (existingItem) {
        existingItem.quantity--;
        return existingItem;
      });
    } else {
      _items.remove(menuId);
    }
    
    notifyListeners();
    _syncToServer(); // 🔥 Panggil Sync setelah update UI
  }

  // Menghapus item dari keranjang
  void removeItem(int menuId) {
    _items.remove(menuId);
    
    notifyListeners();
    _syncToServer(); // 🔥 Panggil Sync setelah update UI
  }

  // Membersihkan keranjang
  void clearCart() {
    _items.clear();
    
    notifyListeners();
    _syncToServer(); // 🔥 Panggil Sync agar layar mirror juga bersih
  }

  // --- FUNGSI UNTUK PEMBAYARAN FINAL API ---

  Map<String, dynamic> createOrderJson({
    int? tableId,
    required String paymentMethod,
    required String customerName,
    required String status,
  }) {
    // Ubah daftar items menjadi format List<Map>
    List<Map<String, dynamic>> itemsJson = _items.values.map((cartItem) {
      return {
        'menu_id': cartItem.menu.id,
        'quantity': cartItem.quantity,
        'price_at_time': cartItem.menu.price,
      };
    }).toList();

    // Kembalikan Map lengkap sesuai ekspektasi Laravel TransactionController
    return {
      'resto_table_id': tableId, 
      'total_price': total,
      'items': itemsJson, // Sesuaikan key dengan validasi di Laravel
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'status': status,
    };
  }
}