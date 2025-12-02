// lib/screens/home/cashier_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_model.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

// Import screen
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

  int _selectedNavIndex = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadInitialData();
  }

  // --- POPUP NOTIFIKASI ---
  void _showNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => _NotificationPopup(
        title: title,
        message: message,
        type: type,
        onClose: () => Navigator.of(context).pop(),
      ),
    );

    // Auto close setelah duration
    Timer(duration, () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  // --- SIMPLE QUICK TOAST (fixed) ---
  void _showQuickToast(String message, {Color color = kPrimaryColor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getToastIcon(color),
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Tutup',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
  }

  IconData _getToastIcon(Color color) {
    if (color == Colors.green) return Icons.check_circle;
    if (color == Colors.red) return Icons.error_outline;
    if (color == Colors.orange) return Icons.warning;
    if (color == Colors.blue) return Icons.info;
    return Icons.notifications;
  }

  Future<void> _loadInitialData() async {
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
      ]);

      setState(() {
        _menus = results[0] as List<Menu>;
        _categories = results[1] as List<Category>;
        _tables = results[2] as List<RestoTable>;
        _orders = results[3] as List<Order>;
      });

      _showQuickToast('Data berhasil dimuat', color: Colors.green);
    } catch (e) {
      if (!mounted) return;
      
      _showNotification(
        title: 'Gagal Memuat Data',
        message: 'Terjadi kesalahan: ${e.toString()}',
        type: NotificationType.error,
      );

      if (e.toString().contains("User tidak terautentikasi")) {
        _logout();
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) {
        _showQuickToast('User tidak terautentikasi', color: Colors.red);
        return;
      }

      final results = await Future.wait([
        _apiService.fetchMenus(),
        _apiService.fetchCategories(),
        _apiService.fetchTables(),
        _apiService.fetchOrders(userId.toString()),
      ]);

      if (!mounted) return;

      setState(() {
        _menus = results[0] as List<Menu>;
        _categories = results[1] as List<Category>;
        _tables = results[2] as List<RestoTable>;
        _orders = results[3] as List<Order>;
      });

      _showQuickToast('Data berhasil di-refresh', color: Colors.green);
    } catch (e) {
      if (!mounted) return;
      
      _showNotification(
        title: 'Refresh Gagal',
        message: 'Gagal refresh data: ${e.toString()}',
        type: NotificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _logout() async {
    // Tampilkan konfirmasi logout
    _showNotification(
      title: 'Konfirmasi Logout',
      message: 'Anda yakin ingin logout?',
      type: NotificationType.warning,
      duration: const Duration(seconds: 5),
    );
    
    // Tunggu sebentar sebelum logout
    await Future.delayed(const Duration(seconds: 1));
    
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
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
          orders: _orders
              .where((o) => o.status.toLowerCase() != 'pending')
              .toList(),
          onRefresh: _refreshData,
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
                selectedIndex: _selectedNavIndex,
                onIndexChanged: (index) {
                  setState(() => _selectedNavIndex = index);
                  _showQuickToast(
                    'Berpindah ke ${_getPageTitle(index)}',
                    color: Colors.blue,
                  );
                },
                onLogout: _logout,
              ),
              Expanded(flex: 3, child: _buildMainContent()),
              Expanded(flex: 2, child: _buildCartSidebar()),
            ],
          );
        },
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0: return 'Menu';
      case 1: return 'Transaksi';
      case 2: return 'Order';
      case 3: return 'Meja';
      default: return 'Menu';
    }
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
              _showQuickToast(
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
                : () => _showPaymentScreen(cart),
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
                _showNotification(
                  title: 'Batalkan Transaksi',
                  message: 'Yakin ingin membatalkan semua item di keranjang?',
                  type: NotificationType.warning,
                );
                // Setelah notifikasi, baru clear cart
                Future.delayed(const Duration(milliseconds: 500), () {
                  cart.clearCart();
                  _showQuickToast('Transaksi dibatalkan', color: Colors.red);
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashierPaymentScreen(
          cart: cart,
          tables: _tables,
          apiService: _apiService,
          onOrderSuccess: () {
            _refreshData();
            cart.clearCart();
            _showNotification(
              title: 'Transaksi Berhasil!',
              message: 'Pesanan telah berhasil diproses.',
              type: NotificationType.success,
            );
          },
        ),
      ),
    );
  }
}

// --- ENUM UNTUK TIPE NOTIFIKASI ---
enum NotificationType {
  success,
  error,
  warning,
  info,
}

// --- WIDGET NOTIFIKASI POPUP ---
class _NotificationPopup extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback onClose;

  const _NotificationPopup({
    required this.title,
    required this.message,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon berdasarkan tipe
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getColor(type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(type),
                color: _getColor(type),
                size: 32,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(type),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}