// lib/screens/home/queue_display_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';

class QueueDisplayController extends ChangeNotifier {
  final BuildContext context;
  final ApiService apiService;

  List<Order> _pendingOrders = [];
  List<Order> _readyOrders = [];
  Timer? _timer;

  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get readyOrders => _readyOrders;

  QueueDisplayController({required this.context, required this.apiService});

  // Start polling orders
  void startPollingOrders() {
    // Panggil pertama kali
    fetchOrders();
    // Lalu panggil setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (context.mounted) {
        fetchOrders();
      }
    });
  }

  // Fetch orders from API
  Future<void> fetchOrders() async {
    try {
      // Ambil semua order, lalu filter di Flutter
      final List<Order> allOrders = await apiService.fetchOrders("all");

      final newPendingOrders = allOrders
          .where((order) => order.status == 'preparing')
          .toList();
      final newReadyOrders = allOrders
          .where((order) => order.status == 'completed')
          .toList();

      if (context.mounted) {
        _pendingOrders = newPendingOrders;
        _readyOrders = newReadyOrders;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching orders for display: $e');
      // Handle error jika perlu
      if (context.mounted) {
        notifyListeners(); // Tetap panggil untuk update UI jika ada
      }
    }
  }

  // Get queue number (order pertama yang ready)
  Order? getQueueNumberOrder() {
    if (_readyOrders.isNotEmpty) {
      return _readyOrders.first;
    }
    return null;
  }

  // Get finished orders (semua ready kecuali pertama)
  List<Order> getFinishedOrders() {
    if (_readyOrders.length > 1) {
      return _readyOrders.sublist(1);
    }
    return [];
  }

  // Get first item name from order
  String getFirstItemName(Order order) {
    if (order.orderItems.isNotEmpty) {
      return order.orderItems.first.menu.name;
    }
    return 'No Items';
  }

  // Cleanup timer
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
