// lib/models/order_model.dart
import 'dart:convert';
import 'menu_model.dart'; // <-- Pastikan import ini benar

// --- JSON Helper Functions ---

List<Order> orderFromJson(String str) =>
    List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

List<RestoTable> restoTableFromJson(String str) =>
    List<RestoTable>.from(json.decode(str).map((x) => RestoTable.fromJson(x)));

// --- Model Class: Order ---

class Order {
  final int id;
  final double totalPrice;
  final String status;
  final String? customerName;
  final RestoTable? restoTable;
  final List<OrderItem> orderItems;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    this.customerName,
    this.restoTable,
    required this.orderItems,
    required this.createdAt,
  });

  // --- FACTORY YANG DIPERBAIKI (AMAN DARI NULL) ---
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"] ?? 0, // Aman
        totalPrice:
            double.tryParse(json["total_price"]?.toString() ?? '0.0') ?? 0.0,
        status: json["status"] ?? 'unknown', // Aman
        customerName: json["customer_name"],
        restoTable: json["resto_table"] == null
            ? null
            : RestoTable.fromJson(json["resto_table"]),
        orderItems: json["order_items"] == null
            ? []
            : List<OrderItem>.from(
                json["order_items"].map((x) => OrderItem.fromJson(x))),
        createdAt: json["created_at"] == null // Aman
            ? DateTime.now()
            : DateTime.parse(json["created_at"]),
      );
}

// --- Model Class: OrderItem ---

class OrderItem {
  final int id;
  final int quantity;
  final double priceAtTime;
  final Menu menu;

  OrderItem(
      {required this.id,
      required this.quantity,
      required this.priceAtTime,
      required this.menu});

  // --- FACTORY YANG DIPERBAIKI (AMAN DARI NULL) ---
  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"] ?? 0, // Aman
        quantity: json["quantity"] ?? 0, // Aman
        priceAtTime:
            double.tryParse(json["price_at_time"]?.toString() ?? '0.0') ?? 0.0,
        menu: json["menu"] == null
            ? Menu( // Fallback aman
                id: 0,
                name: 'Menu Dihapus',
                price: 0,
                stock: 0,
                categoryId: 0) // <-- Termasuk perbaikan 'categoryId'
            : Menu.fromJson(json["menu"]),
      );
}

// --- Model Class: RestoTable ---

class RestoTable {
  final int id;
  final String number; // Sesuai model Anda
  final String status;

  RestoTable({
    required this.id,
    required this.number,
    required this.status,
  });

  // --- FACTORY YANG DIPERBAIKI (AMAN DARI NULL) ---
  factory RestoTable.fromJson(Map<String, dynamic> json) => RestoTable(
        id: json["id"] ?? 0, // Aman
        number: json["name"] ?? '??', // Membaca "name" dari API, aman
        status: json["status"] ?? 'unknown', // Aman
      );
}