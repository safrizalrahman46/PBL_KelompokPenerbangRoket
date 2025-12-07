import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart'; // Pastikan BASE_URL/API_URL ada disini

// Model sederhana untuk parsing item (bisa dipisah ke file model)
class MirrorItem {
  final String name;
  final int quantity;
  final double price;

  MirrorItem({required this.name, required this.quantity, required this.price});

  factory MirrorItem.fromJson(Map<String, dynamic> json) {
    return MirrorItem(
      name: json['product_name'] ?? 'Item', // Sesuaikan key JSON dari Laravel
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }
}

class MirrorOrderLogic extends ChangeNotifier {
  // Data State
  List<MirrorItem> _items = [];
  double _subtotal = 0;
  double _total = 0;
  
  // Data Pembayaran
  double _receivedAmount = 0;
  double _changeAmount = 0;
  String _paymentMethod = "-";

  Timer? _timer;
  bool _isLoading = true;

  // Getters untuk UI
  List<MirrorItem> get items => _items;
  double get subtotal => _subtotal;
  double get total => _total;
  double get receivedAmount => _receivedAmount;
  double get changeAmount => _changeAmount;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;

  // --- LOGIC UTAMA ---

  // 1. Mulai Polling (Dipanggil di initState)
  void startPolling() {
    // Panggil langsung sekali biar gak nunggu 2 detik
    fetchMirrorData();
    
    // Ulangi setiap 2 detik
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      fetchMirrorData();
    });
  }

  // 2. Stop Polling (Dipanggil di dispose)
  void stopPolling() {
    _timer?.cancel();
  }

  // 3. Ambil Data dari Server
  Future<void> fetchMirrorData() async {
    try {
      // GANTI URL INI DENGAN ENDPOINT LARAVEL KAMU
      // Endpoint ini harus mengembalikan data transaksi yang sedang AKTIF (pending)
      final url = Uri.parse('$API_URL/active-transaction'); 
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Asumsi struktur JSON dari Laravel seperti ini:
        /*
        {
          "cart_items": [
            {"product_name": "Nasi Goreng", "quantity": 2, "price": 15000},
            {"product_name": "Es Teh", "quantity": 1, "price": 5000}
          ],
          "subtotal": 35000,
          "total": 35000,
          "payment": {
             "received": 50000,
             "change": 15000,
             "method": "CASH"
          }
        }
        */

        // Parsing Items
        List<dynamic> cartList = data['cart_items'] ?? [];
        _items = cartList.map((e) => MirrorItem.fromJson(e)).toList();

        // Parsing Totals
        _subtotal = double.tryParse(data['subtotal'].toString()) ?? 0;
        _total = double.tryParse(data['total'].toString()) ?? 0;

        // Parsing Payment Info (Jika ada)
        if (data['payment'] != null) {
          _receivedAmount = double.tryParse(data['payment']['received'].toString()) ?? 0;
          _changeAmount = double.tryParse(data['payment']['change'].toString()) ?? 0;
          _paymentMethod = data['payment']['method'] ?? "-";
        } else {
           _receivedAmount = 0;
           _changeAmount = 0;
           _paymentMethod = "-";
        }

        _isLoading = false;
        notifyListeners(); // Update UI
      }
    } catch (e) {
      print("Error Mirroring: $e");
    }
  }
}