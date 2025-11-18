// lib/screens/home/kitchen_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class KitchenHomeScreen extends StatefulWidget {
  const KitchenHomeScreen({super.key});

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<void> _loadOrdersFuture;
  Timer? _refreshTimer;

  List<Order> _pendingOrders = [];
  List<Order> _preparingOrders = [];
  List<Order> _readyOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersFuture = _fetchOrders();

    // Auto refresh tiap 5 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // 🔥 SNACKBAR BARU — floating persegi panjang
  void _showSnack(String message, {Color? color}) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 20,
        ),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Fetch order
  Future<void> _fetchOrders() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) throw Exception("User tidak terautentikasi.");

      final List<Order> allOrders =
          await _apiService.fetchOrders(userId.toString());

      final List<Order> pending = [];
      final List<Order> preparing = [];
      final List<Order> ready = [];

      for (var order in allOrders) {
        final status = order.status.toLowerCase();
        if (status == 'pending' || status == 'paid') {
          pending.add(order);
        } else if (status == 'preparing') {
          preparing.add(order);
        } else if (status == 'ready') {
          ready.add(order);
        }
      }

      if (mounted) {
        setState(() {
          _pendingOrders = pending;
          _preparingOrders = preparing;
          _readyOrders = ready;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Gagal mengambil data pesanan: $e", color: Colors.red);
      }
    }
  }

  // Update status
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(orderId, newStatus);

      if (mounted) {
        _showSnack("Pesanan #$orderId diperbarui ke $newStatus",
            color: Colors.green);
      }

      await _fetchOrders();
    } catch (e) {
      if (mounted) {
        _showSnack("Gagal update status: $e", color: Colors.red);
      }
    }
  }

  // Logout
  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dapur Eat.o',
          style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kSplashBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kSecondaryColor),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchOrders,
            color: kPrimaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrdersColumn(
                  title: "Pesanan Baru",
                  orders: _pendingOrders,
                  nextStatus: "preparing",
                  buttonText: "Mulai Memasak",
                  buttonColor: const Color(0xFFFF9800),
                ),
                _buildOrdersColumn(
                  title: "Sedang Dimasak",
                  orders: _preparingOrders,
                  nextStatus: "ready",
                  buttonText: "Selesaikan",
                  buttonColor: const Color(0xFFFF9800),
                ),
                _buildOrdersColumn(
                  title: "Selesai",
                  orders: _readyOrders,
                  nextStatus: "",
                  buttonText: "",
                  buttonColor: const Color(0xFFFF9800),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Kolom pesanan
  Widget _buildOrdersColumn({
    required String title,
    required List<Order> orders,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        color: kSecondaryColor.withOpacity(0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(
                        order: order,
                        nextStatus: nextStatus,
                        buttonText: buttonText,
                        buttonColor: buttonColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Card pesanan
  Widget _buildOrderCard({
    required Order order,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.restoTable?.number.toString().padLeft(2, '0') ?? '01',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName ?? 'Tanpa Nama',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ITEMS
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                ...order.orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.quantity.toString().padLeft(2, '0'),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(item.menu.name),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // BUTTON
          if (buttonText.isEmpty)
            const SizedBox(height: 45 + 12)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    _updateOrderStatus(order.id, nextStatus);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 6), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
