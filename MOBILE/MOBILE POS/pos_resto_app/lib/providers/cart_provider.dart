// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/menu_model.dart'; // Import model Menu Anda

// 1. Definisikan Model untuk Item di Keranjang
//    Model ini menggabungkan Menu dengan kuantitasnya
class CartItem {
  final Menu menu;
  int quantity;

  CartItem({
    required this.menu,
    this.quantity = 1,
  });

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
  // (Digunakan oleh _buildMenuCard di home screen)
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
    
    // Sesuai perhitungan di desain Anda: 125.000 + 10% = 137.500
    return sub + taxAmount - discountAmount;
  }
  

  // --- ACTIONS (Fungsi untuk mengubah state) ---

  // Menambah item ke keranjang (dipanggil dari _buildMenuCard)
  void addItem(Menu menu) {
    if (_items.containsKey(menu.id)) {
      // Jika sudah ada, tambah kuantitasnya
      _items.update(menu.id, (existingItem) {
        existingItem.quantity++;
        return existingItem;
      });
    } else {
      // Jika belum ada, tambahkan sebagai item baru
      _items.putIfAbsent(menu.id, () => CartItem(menu: menu));
    }
    // Beri tahu semua widget yang mendengarkan!
    notifyListeners();
  }

  // Mengurangi item dari keranjang (dipanggil dari _buildMenuCard)
  void decreaseItem(int menuId) {
    if (!_items.containsKey(menuId)) return; // Tidak ada item, abaikan

    if (_items[menuId]!.quantity > 1) {
      // Jika kuantitas > 1, kurangi
      _items.update(menuId, (existingItem) {
        existingItem.quantity--;
        return existingItem;
      });
    } else {
      // Jika kuantitas == 1, hapus dari keranjang
      _items.remove(menuId);
    }
    notifyListeners();
  }

  // Menghapus item dari keranjang (dipanggil dari _buildCartItem)
  void removeItem(int menuId) {
    _items.remove(menuId);
    notifyListeners();
  }

  // Membersihkan keranjang (dipanggil dari "Batalkan Transaksi")
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Di dalam file lib/providers/cart_provider.dart
// Di dalam class CartProvider

  // ... (setelah fungsi clearCart() )

  // --- FUNGSI BARU UNTUK API ---
  
  Map<String, dynamic> createOrderJson(int tableId) {
    // Ubah daftar items menjadi format List<Map>
    List<Map<String, dynamic>> itemsJson = _items.values.map((cartItem) {
      return {
        'menu_id': cartItem.menu.id,
        'quantity': cartItem.quantity,
        'price': cartItem.menu.price, // Kirim harga saat itu
      };
    }).toList();

    // Kembalikan Map lengkap sesuai ekspektasi Laravel
    return {
      'resto_table_id': tableId, // atau 'table_id' sesuai API Anda
      'total_price': total,
      'items': itemsJson,
    };
  }
}