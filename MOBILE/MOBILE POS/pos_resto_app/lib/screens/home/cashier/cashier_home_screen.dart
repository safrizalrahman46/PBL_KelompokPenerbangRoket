import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/menu_model.dart';
import '../../../models/order_model.dart' hide RestoTable;
import '../../../models/table_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../auth/login_screen.dart';

// Import halaman-halaman
import 'cashier_menu_screen.dart';
import 'cashier_transaksi_screen.dart';
import 'cashier_order_screen.dart';
import 'cashier_payment_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.user?.id;

      // Kalau API tidak butuh userId, hapus parameter ini
      final results = await Future.wait([
        _apiService.fetchMenus(),
        _apiService.fetchCategories(),
        _apiService.fetchTables(),
        _apiService.fetchOrders(),
      ]);

      setState(() {
        _menus = results[0] as List<Menu>;
        _categories = results[1] as List<Category>;
        _tables = results[2] as List<RestoTable>;
        _orders = results[3] as List<Order>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchTables(),
        _apiService.fetchOrders(),
      ]);

      setState(() {
        _tables = results[0] as List<RestoTable>;
        _orders = results[1] as List<Order>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal refresh data: $e')),
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

  // ✅ Navigasi ke PaymentScreen
  void _navigateToPayment(CartProvider cart) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          cart: cart,
          tables: _tables,
          apiService: _apiService,
          onOrderSuccess: () {
            _refreshData();
            _showSuccessOrderDialog(context);
          },
        ),
      ),
    );
  }

  void _showSuccessOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          height: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: kPrimaryColor, size: 80),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text(
                  'Lanjutkan Transaksi',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              _buildNavRail(),
              Expanded(flex: 3, child: _buildMainContent()),
              Expanded(flex: 2, child: _buildCartSidebar()),
            ],
          );
        },
      ),
    );
  }

  // 🧭 Sidebar Navigasi
  Widget _buildNavRail() {
    return Container(
      width: 110,
      color: kSplashBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          const Text(
            "Eat.o",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 40),
          _buildNavRailItem(Icons.restaurant_menu, "Menu", 0),
          _buildNavRailItem(Icons.receipt_long, "Transaksi", 1),
          _buildNavRailItem(Icons.list_alt, "Order", 2),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: kSecondaryColor, size: 30),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildNavRailItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 30,
                color: isSelected ? kBackgroundColor : kSecondaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kBackgroundColor : kSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Konten utama berdasarkan menu
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
          orders: _getCompletedOrders(),
          onRefresh: _refreshData,
        );
      case 2:
        return CashierOrderScreen(apiService: _apiService);
      default:
        return const Center(child: Text("Coming soon..."));
    }
  }

  List<Order> _getCompletedOrders() {
    return _orders
        .where((order) => order.status.toLowerCase() != 'pending')
        .toList();
  }

  // 🛒 Sidebar Keranjang
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
                    color: kSecondaryColor),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text("Keranjang kosong",
                            style: TextStyle(
                                fontSize: 16, color: kSecondaryColor)))
                    : ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) =>
                            _buildCartItem(cart.items[index], cart),
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
                    child: const Icon(Icons.image_not_supported))
                : Image.network(item.menu.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: kBackgroundColor,
                        child: const Icon(Icons.image_not_supported))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menu.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Rp ${item.menu.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 14, color: kSecondaryColor)),
              ],
            ),
          ),
          Text("x${item.quantity}",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => cart.removeItem(item.menu.id),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kBackgroundColor, borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, bool isChange = false}) {
    final Color valueColor =
        isChange ? Colors.blueAccent : (isTotal ? kPrimaryColor : kSecondaryColor);
    final Color labelColor =
        isChange ? Colors.blueAccent : kSecondaryColor.withOpacity(0.8);
    final double fontSize = (isTotal || isChange) ? 18 : 16;
    final FontWeight fontWeight =
        (isTotal || isChange) ? FontWeight.bold : FontWeight.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: labelColor)),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
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
            onPressed: cart.items.isEmpty ? null : () => _navigateToPayment(cart),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
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
            onPressed: () => cart.clearCart(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            child: const Text('Batalkan Transaksi',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
