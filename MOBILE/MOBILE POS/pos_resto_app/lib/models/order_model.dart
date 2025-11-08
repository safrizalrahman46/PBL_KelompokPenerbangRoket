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
  final RestoTable? restoTable; // Relasi ke RestoTable
  final List<OrderItem> orderItems;
  final DateTime createdAt; // Untuk tracking waktu

  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    this.customerName,
    this.restoTable,
    required this.orderItems,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        totalPrice:
            double.tryParse(json["total_price"]?.toString() ?? '0.0') ?? 0.0,
        status: json["status"],
        customerName: json["customer_name"],
        restoTable: json["resto_table"] == null
            ? null
            : RestoTable.fromJson(json["resto_table"]),
        orderItems: json["order_items"] == null
            ? []
            : List<OrderItem>.from(
                json["order_items"].map((x) => OrderItem.fromJson(x))),
        createdAt: DateTime.parse(json["created_at"]),
      );
}

// --- Model Class: OrderItem ---

class OrderItem {
  final int id;
  final int quantity;
  final double priceAtTime;
  final Menu menu; // Relasi ke Menu

  OrderItem({
    required this.id, 
    required this.quantity, 
    required this.priceAtTime,
    required this.menu
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json["id"],
        quantity: json["quantity"],
        priceAtTime: double.tryParse(json["price_at_time"]?.toString() ?? '0.0') ?? 0.0,
        menu: json["menu"] == null
            ? Menu(id: 0, name: 'Menu Dihapus', price: 0, stock: 0) // Fallback
            : Menu.fromJson(json["menu"]),
      );
}

// --- Model Class: RestoTable ---

class RestoTable {
  final int id;
  final String number;
  final String status; // misal: 'available', 'occupied'

  RestoTable({
    required this.id,
    required this.number,
    required this.status,
  });

  factory RestoTable.fromJson(Map<String, dynamic> json) => RestoTable(
        id: json["id"],
        number: json["number"],
        status: json["status"],
      );
}