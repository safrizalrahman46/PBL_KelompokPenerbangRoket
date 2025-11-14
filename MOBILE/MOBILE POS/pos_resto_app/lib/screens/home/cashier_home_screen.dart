// lib/screens/home/cashier_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_model.dart';
import '../../models/order_model.dart';
import '../../models/transactions_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

// Import screen yang dipisahkan
import 'cashier_menu_screen.dart';
import 'cashier_transaction_screen.dart';
import 'cashier_order_screen.dart';
import 'cashier_table_screen.dart';
import 'cashier_payment_screen.dart';
import 'cashier_navigation_rail.dart';

class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  late Future<void> _loadDataFuture;
  final ApiService _apiService = ApiService();

  List<Menu> _menus = [];
  List<Category> _categories = [];
  List<RestoTable> _tables = [];
  List<Order> _orders = [];
  List<Transaction> _transactions = [];

  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) {
        throw Exception("User tidak terautentikasi. Silakan login ulang.");
      }

      final results = await Future.wait([
        _apiService.fetchMenus(),
        _apiService.fetchCategories(),
        _apiService.fetchTables(),
        _apiService.fetchOrders(userId.toString()),
        Future.value(<Transaction>[]),
      ]);

      setState(() {
        _menus = results[0] as List<Menu>;
        _categories = results[1] as List<Category>;
        _tables = results[2] as List<RestoTable>;
        _orders = results[3] as List<Order>;
        _transactions = results[4] as List<Transaction>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
        if (e.toString().contains("User tidak terautentikasi")) {
          _logout();
        }
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) {
        throw Exception("User tidak terautentikasi.");
      }

      final results = await Future.wait([
        _apiService.fetchTables(),
        _apiService.fetchOrders(userId.toString()),
      ]);

      setState(() {
        _tables = results[0] as List<RestoTable>;
        _orders = results[1] as List<Order>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal refresh data: ${e.toString()}')),
      );
    }
  }

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

  Widget _buildMainContent() {
    switch (_selectedNavIndex) {
      case 0:
        return CashierMenuScreen(
          menus: _menus,
          categories: _categories,
          onRefresh: _refreshData,
        );
      case 1:
        return CashierTransactionScreen(
          orders: _orders.where((order) => order.status.toLowerCase() != 'pending').toList(),
        );
      case 2:
        return CashierOrderScreen(
          orders: _orders,
          onRefresh: _refreshData,
          apiService: _apiService,
        );
      case 3:
        return CashierTableScreen(
          tables: _tables,
          onRefresh: _refreshData,
          apiService: _apiService,
        );
      default:
        return CashierMenuScreen(
          menus: _menus,
          categories: _categories,
          onRefresh: _refreshData,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Row(
            children: [
              CashierNavigationRail(
                selectedIndex: _selectedNavIndex,
                onIndexChanged: (index) {
                  setState(() => _selectedNavIndex = index);
                },
                onLogout: _logout,
              ),
              Expanded(
                flex: 3,
                child: _buildMainContent(),
              ),
              Expanded(
                flex: 2,
                child: _buildCartSidebar(),
              ),
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
                        child: Text(
                          "Keranjang kosong",
                          style: TextStyle(fontSize: 16, color: kSecondaryColor),
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
            borderRadius: BorderRadius.circular(8.0),
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: kBackgroundColor,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${item.menu.price.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 14, color: kSecondaryColor),
                ),
              ],
            ),
          ),
          Text(
            "x${item.quantity}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () {
              cart.removeItem(item.menu.id);
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
          _buildSummaryRow("Sub total", "Rp ${cart.subtotal.toStringAsFixed(0)}"),
          _buildSummaryRow("Diskon", "${cart.discountPercent}%"),
          _buildSummaryRow("Pajak", "${cart.taxPercent}%"),
          const Divider(thickness: 1, height: 24),
          _buildSummaryRow("Total", "Rp ${cart.total.toStringAsFixed(0)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isChange = false}) {
    final Color valueColor = isChange ? Colors.blueAccent : (isTotal ? kPrimaryColor : kSecondaryColor);
    final Color labelColor = isChange ? Colors.blueAccent : kSecondaryColor.withOpacity(0.8);
    final double fontSize = (isTotal || isChange) ? 18 : 16;
    final FontWeight fontWeight = (isTotal || isChange) ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: labelColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: valueColor,
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
          height: 56,
          child: ElevatedButton(
            onPressed: cart.items.isEmpty ? null : () => _showPaymentScreen(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Lanjutkan Transaksi',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kBackgroundColor),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: () {
              cart.clearCart();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
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

  Future<void> _showPaymentScreen(CartProvider cart) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CashierPaymentScreen(
          cart: cart,
          tables: _tables,
          apiService: _apiService,
          onOrderSuccess: () {
            _refreshData();
            cart.clearCart();
          },
        ),
      ),
    );
  }
}