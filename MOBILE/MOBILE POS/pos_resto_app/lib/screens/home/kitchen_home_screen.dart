// lib/screens/home/kitchen_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../../controllers/kitchen_home_controller.dart';

class KitchenHomeScreen extends StatefulWidget {
  const KitchenHomeScreen({super.key});

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen> {
  late Future<void> _loadOrdersFuture;
  late KitchenHomeController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = KitchenHomeController(context);
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
    _loadOrdersFuture = _controller.fetchOrders();
    _controller.startAutoRefresh();
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    _controller.dispose();
    super.dispose();
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
            onPressed: () async {
              await _controller.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
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
            onRefresh: _controller.fetchOrders,
            color: kPrimaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrdersColumn(
                  title: "Pesanan Baru",
                  orders: _controller.pendingOrders,
                  nextStatus: "preparing",
                  buttonText: "Mulai Memasak",
                  buttonColor: const Color(0xFFFF9800),
                  isChecklistMode: false,
                ),
                _buildOrdersColumn(
                  title: "Sedang Dimasak",
                  orders: _controller.preparingOrders,
                  nextStatus: "ready",
                  buttonText: "Selesaikan",
                  buttonColor: const Color(0xFFFF9800),
                  isChecklistMode: true,
                ),
                _buildOrdersColumn(
                  title: "Selesai",
                  orders: _controller.readyOrders,
                  nextStatus: "",
                  buttonText: "",
                  buttonColor: Colors.grey,
                  isChecklistMode: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersColumn({
    required String title,
    required List<Order> orders,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
    required bool isChecklistMode,
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
                      return _buildOrderCard(
                        order: orders[index],
                        nextStatus: nextStatus,
                        buttonText: buttonText,
                        buttonColor: buttonColor,
                        isChecklistMode: isChecklistMode,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required Order order,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
    required bool isChecklistMode,
  }) {
    // Cek apakah semua item sudah dicentang
    bool allItemsChecked = true;
    if (isChecklistMode) {
      allItemsChecked = _controller.isAllItemsChecked(order);
    }

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
          // HEADER CARD
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.restoTable?.number.toString().padLeft(2, '0') ?? '??',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName ?? 'Tanpa Nama',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Order #${order.id}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // LIST ITEMS
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header Table
                if (!isChecklistMode)
                  const Row(
                    children: [
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
                if (!isChecklistMode) const Divider(height: 16),

                // ITEMS LIST
                ...order.orderItems.map((item) {
                  final key = "${order.id}_${item.id}";
                  final isChecked = _controller.checkedItemIds.contains(key);

                  if (isChecklistMode) {
                    // TAMPILAN CHECKLIST
                    return InkWell(
                      onTap: () =>
                          _controller.toggleItemCheck(order.id, item.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            // Checkbox Custom
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isChecked ? Colors.green : Colors.white,
                                border: Border.all(
                                  color: isChecked ? Colors.green : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            // Qty
                            Text(
                              "${item.quantity}x ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isChecked ? Colors.grey : Colors.black,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            // Nama Menu
                            Expanded(
                              child: Text(
                                item.menu.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isChecked ? Colors.grey : Colors.black,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // TAMPILAN NORMAL
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
                          Expanded(flex: 3, child: Text(item.menu.name)),
                        ],
                      ),
                    );
                  }
                }).toList(),
              ],
            ),
          ),

          // BUTTON ACTION
          if (buttonText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (isChecklistMode && !allItemsChecked) {
                      _controller.showSnack(
                        "Harap selesaikan semua menu terlebih dahulu!",
                        color: Colors.orange,
                      );
                    } else {
                      _controller.updateOrderStatus(order.id, nextStatus);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isChecklistMode && !allItemsChecked)
                        ? Colors.grey
                        : buttonColor,
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
