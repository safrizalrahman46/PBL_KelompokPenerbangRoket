import 'dart:async';
import 'package:flutter/material.dart';

/// =======================
/// MODEL ITEM ORDER
/// =======================
class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

/// =======================
/// LOGIC MIRROR ORDER
/// =======================
class MirrorOrderLogic extends ChangeNotifier {

  // =======================
  // DATA CUSTOMER & PAYMENT
  // =======================
  String customerName = "Umum";
  String paymentMethod = "-";

  // =======================
  // FINANCIAL
  // =======================
  double subtotal = 0;
  double total = 0;
  double receivedAmount = 0;
  double changeAmount = 0;

  // =======================
  // ITEM LIST
  // =======================
  List<OrderItem> items = [];

  // =======================
  // STATE
  // =======================
  bool isLoading = true;

  Timer? _pollingTimer;

  // =======================
  // START / STOP POLLING
  // =======================
  void startPolling() {
    stopPolling(); // pastikan tidak dobel timer

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchMirrorData(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // =======================
  // SIMULASI FETCH DATA
  // (Nanti ganti API)
  // =======================
  void _fetchMirrorData() async {
    isLoading = true;
    notifyListeners();

    // ===== simulasi delay API =====
    await Future.delayed(const Duration(milliseconds: 500));

    /// ===== CONTOH DATA DARI KASIR / API =====
    customerName = "Budi Santoso";
    paymentMethod = "QRIS";

    items = [
      OrderItem(name: "Ayam Geprek", quantity: 1, price: 15000),
      OrderItem(name: "Es Teh Manis", quantity: 2, price: 5000),
    ];

    receivedAmount = 30000;

    _calculateTotal();

    isLoading = false;
    notifyListeners();
  }

  // =======================
  // HITUNG TOTAL
  // =======================
  void _calculateTotal() {
    subtotal = 0;

    for (final item in items) {
      subtotal += item.price * item.quantity;
    }

    total = subtotal;
    changeAmount = receivedAmount > total
        ? receivedAmount - total
        : 0;
  }

  // =======================
  // UPDATE DARI API REAL
  // =======================
  void updateFromApi(Map<String, dynamic> data) {
    customerName = data['customer_name'] ?? "Umum";
    paymentMethod = data['payment_method'] ?? "-";

    receivedAmount = (data['received'] ?? 0).toDouble();

    items = (data['items'] as List? ?? []).map((e) {
      return OrderItem(
        name: e['name'],
        quantity: e['qty'],
        price: (e['price']).toDouble(),
      );
    }).toList();

    _calculateTotal();

    isLoading = false;
    notifyListeners();
  }

  // =======================
  // HELPERS
  // =======================
  bool get hasOrder => items.isNotEmpty;

  String get safeCustomerName =>
      customerName.isNotEmpty ? customerName : "Umum";
}
