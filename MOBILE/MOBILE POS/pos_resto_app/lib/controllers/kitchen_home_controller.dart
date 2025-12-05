// lib/screens/home/kitchen_home_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class KitchenHomeController extends ChangeNotifier {
  final BuildContext context;
  final ApiService _apiService = ApiService();

  List<Order> _pendingOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _readyOrders = [];
  final Set<String> _checkedItemIds = {}; // Format: "orderId_itemId"

  Timer? refreshTimer;

  List<Order> get pendingOrders => _pendingOrders;
  List<Order> get preparingOrders => _preparingOrders;
  List<Order> get readyOrders => _readyOrders;
  Set<String> get checkedItemIds => _checkedItemIds;

  KitchenHomeController(this.context);

  Future<void> fetchOrders() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;
      if (userId == null) throw Exception("User tidak terautentikasi.");

      final List<Order> allOrders = await _apiService.fetchOrders(
        userId.toString(),
      );

      // Sorting terbaru diatas
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final List<Order> pending = [];
      final List<Order> preparing = [];
      final List<Order> ready = [];

      for (var order in allOrders) {
        final status = order.status.toLowerCase();
        if (status == 'pending' || status == 'paid') {
          pending.add(order);
        } else if (status == 'preparing' || status == 'cooking') {
          preparing.add(order);
        } else if (status == 'ready' || status == 'ready to serve') {
          ready.add(order);
        }
      }

      _pendingOrders = pending;
      _preparingOrders = preparing;
      _readyOrders = ready;

      notifyListeners();
    } catch (e) {
      // Error handling bisa ditambahkan di sini
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(orderId, newStatus);
      showSnack(
        "Pesanan #$orderId diperbarui ke $newStatus",
        color: Colors.green,
      );
      await fetchOrders();
    } catch (e) {
      showSnack("Gagal update status: $e", color: Colors.red);
    }
  }

  // Toggle centang item
  void toggleItemCheck(int orderId, int itemId) {
    final key = "${orderId}_$itemId";
    if (_checkedItemIds.contains(key)) {
      _checkedItemIds.remove(key);
    } else {
      _checkedItemIds.add(key);
    }
    notifyListeners();
  }

  // Cek apakah semua item dalam order sudah dicentang
  bool isAllItemsChecked(Order order) {
    for (var item in order.orderItems) {
      if (!_checkedItemIds.contains("${order.id}_${item.id}")) {
        return false;
      }
    }
    return true;
  }

  // Logout
  Future<void> logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
  }

  // Show snackbar
  void showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: color ?? kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Cleanup timer
  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // Start auto refresh
  void startAutoRefresh() {
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (context.mounted) {
        fetchOrders();
      }
    });
  }

  // Uses ChangeNotifier.notifyListeners()
}
