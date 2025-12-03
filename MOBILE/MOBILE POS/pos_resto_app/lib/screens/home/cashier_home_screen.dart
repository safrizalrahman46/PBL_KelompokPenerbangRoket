// lib/screens/home/cashier_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

// Import screen
import 'cashier_menu_screen.dart';
import 'cashier_transaction_screen.dart';
import 'cashier_order_screen.dart';
import 'cashier_table_screen.dart';
import 'cashier_navigation_rail.dart';
import '../../controllers/cashier_home_controller.dart';

class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});
  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  late Future<void> _loadDataFuture;
  late CashierHomeController _controller;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = CashierHomeController(context);
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);
    _loadDataFuture = _controller.loadInitialData();
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _controller.removeListener(_controllerListener!);
    }
    super.dispose();
  }

  Widget _buildMainContent() {
    switch (_controller.selectedNavIndex) {
      case 0:
        return CashierMenuScreen(
          menus: _controller.menus,
          categories: _controller.categories,
          onRefresh: _controller.refreshData,
        );

      case 1:
        return CashierTransactionScreen(
          orders: _controller.filteredOrders,
          onRefresh: _controller.refreshData,
        );

      case 2:
        return CashierOrderScreen(
          orders: _controller.orders,
          onRefresh: _controller.refreshData,
          apiService: ApiService(),
        );

      case 3:
        return CashierTableScreen(
          tables: _controller.tables,
          onRefresh: _controller.refreshData,
          apiService: ApiService(),
        );

      default:
        return CashierMenuScreen(
          menus: _controller.menus,
          categories: _controller.categories,
          onRefresh: _controller.refreshData,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          }

          return Row(
            children: [
              CashierNavigationRail(
                selectedIndex: _controller.selectedNavIndex,
                onIndexChanged: (index) {
                  _controller.selectedNavIndex = index;
                  _controller.showQuickToast(
                    'Berpindah ke ${_controller.getPageTitle(index)}',
                    color: Colors.blue,
                  );
                  setState(() {});
                },
                onLogout: _controller.logout,
              ),
              Expanded(flex: 3, child: _buildMainContent()),
              Expanded(flex: 2, child: _buildCartSidebar()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSidebar() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          color: kLightGreyColor.withOpacity(0.5),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pesanan Saat Ini",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: kSecondaryColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Keranjang kosong",
                              style: TextStyle(
                                fontSize: 16,
                                color: kSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cart.items[index];
                          return _buildCartItem(cartItem, cart);
                        },
                      ),
              ),
              const SizedBox(height: 24),
              _buildCartSummary(cart),
              const SizedBox(height: 24),
              _buildCartButtons(cart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (item.menu.imageUrl == null || item.menu.imageUrl!.isEmpty)
                ? Container(
                    width: 60,
                    height: 60,
                    color: kBackgroundColor,
                    child: const Icon(Icons.image_not_supported),
                  )
                : Image.network(
                    item.menu.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Rp ${item.menu.price.toStringAsFixed(0)}",
                  style: const TextStyle(color: kSecondaryColor),
                ),
              ],
            ),
          ),
          Text(
            "x${item.quantity}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () {
              cart.removeItem(item.menu.id);
              _controller.showQuickToast(
                '${item.menu.name} dihapus dari keranjang',
                color: Colors.orange,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            "Sub total",
            "Rp ${cart.subtotal.toStringAsFixed(0)}",
          ),
          _buildSummaryRow("Diskon", "${cart.discountPercent}%"),
          _buildSummaryRow("Pajak", "${cart.taxPercent}%"),
          const Divider(),
          _buildSummaryRow(
            "Total",
            "Rp ${cart.total.toStringAsFixed(0)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: kSecondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? kPrimaryColor : kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButtons(CartProvider cart) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: cart.items.isEmpty
                ? null
                : () => _controller.showPaymentScreen(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Lanjutkan Transaksi',
              style: TextStyle(
                color: kBackgroundColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: TextButton(
            onPressed: () {
              if (cart.items.isNotEmpty) {
                _controller.showNotification(
                  title: 'Batalkan Transaksi',
                  message: 'Yakin ingin membatalkan semua item di keranjang?',
                  type: NotificationType.warning,
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  cart.clearCart();
                  _controller.showQuickToast(
                    'Transaksi dibatalkan',
                    color: Colors.red,
                  );
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Batalkan Transaksi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
