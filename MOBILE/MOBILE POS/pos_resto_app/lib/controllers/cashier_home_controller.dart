// lib/screens/home/cashier_home_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home/cashier_payment_screen.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

enum NotificationType { success, error, warning, info }

class CashierHomeController extends ChangeNotifier {
  final BuildContext context;
  final ApiService _apiService = ApiService();

  List<Menu> _menus = [];
  List<Category> _categories = [];
  List<RestoTable> _tables = [];
  List<Order> _orders = [];

  int _selectedNavIndex = 0;
  bool _isRefreshing = false;

  List<Menu> get menus => _menus;
  List<Category> get categories => _categories;
  List<RestoTable> get tables => _tables;
  List<Order> get orders => _orders;
  int get selectedNavIndex => _selectedNavIndex;
  bool get isRefreshing => _isRefreshing;

  set selectedNavIndex(int index) {
    _selectedNavIndex = index;
  }

  CashierHomeController(this.context);

  Future<void> loadInitialData() async {
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

      _menus = results[0] as List<Menu>;
      _categories = results[1] as List<Category>;
      _tables = results[2] as List<RestoTable>;
      _orders = results[3] as List<Order>;

      showQuickToast('Data berhasil dimuat', color: Colors.green);
      notifyListeners();
    } catch (e) {
      showNotification(
        title: 'Gagal Memuat Data',
        message: 'Terjadi kesalahan: ${e.toString()}',
        type: NotificationType.error,
      );

      if (e.toString().contains("User tidak terautentikasi")) {
        logout();
      }
    }
  }

  Future<void> refreshData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      if (userId == null) {
        showQuickToast('User tidak terautentikasi', color: Colors.red);
        return;
      }

      final results = await Future.wait([
        _apiService.fetchMenus(),
        _apiService.fetchCategories(),
        _apiService.fetchTables(),
        _apiService.fetchOrders(userId.toString()),
      ]);

      _menus = results[0] as List<Menu>;
      _categories = results[1] as List<Category>;
      _tables = results[2] as List<RestoTable>;
      _orders = results[3] as List<Order>;

      showQuickToast('Data berhasil di-refresh', color: Colors.green);
    } catch (e) {
      showNotification(
        title: 'Refresh Gagal',
        message: 'Gagal refresh data: ${e.toString()}',
        type: NotificationType.error,
      );
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void logout() async {
    // showNotification(
    //   title: 'Konfirmasi Logout',
    //   message: 'Anda yakin ingin logout?',
    //   type: NotificationType.warning,
    //   duration: const Duration(seconds: 6),
    // );

    await Future.delayed(const Duration(seconds: 0));

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void showNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => NotificationPopup(
        title: title,
        message: message,
        type: type,
        onClose: () => Navigator.of(context).pop(),
      ),
    );

    Timer(duration, () {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void showQuickToast(String message, {Color color = kPrimaryColor}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getToastIcon(color), color: Colors.white, size: 24),
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
            label: ' ',
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

  String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Menu';
      case 1:
        return 'Transaksi';
      case 2:
        return 'Order';
      case 3:
        return 'Meja';
      default:
        return 'Menu';
    }
  }

  Future<void> showPaymentScreen(CartProvider cart) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CashierPaymentScreen(
          cart: cart,
          tables: _tables,
          apiService: _apiService,
          onOrderSuccess: () {
            refreshData();
            cart.clearCart();
          },
        ),
      ),
    );
  }

  List<Order> get filteredOrders {
    return _orders.where((o) => o.status.toLowerCase() != 'pending').toList();
  }

  // Uses ChangeNotifier.notifyListeners() from Flutter
}

// --- WIDGET NOTIFIKASI POPUP ---
class NotificationPopup extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback onClose;

  const NotificationPopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getColor(type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(type), color: _getColor(type), size: 32),
            ),
            const SizedBox(height: 20),
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
                  ' ',
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
