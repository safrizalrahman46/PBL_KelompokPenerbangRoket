// lib/screens/home/cashier_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/menu_model.dart';
import '../../models/order_model.dart';

// --- TAMBAHKAN IMPOR INI ---
import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// --- SELESAI PENAMBAHAN ---

import 'package:flutter_tts/flutter_tts.dart';

import '../../models/menu_model.dart';

// BARU: Impor model Transaction
import '../../models/transactions_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // BARU: Impor AuthService
import '../../utils/constants.dart';
import '../auth/login_screen.dart';

class CashierHomeScreen extends StatefulWidget {
  const CashierHomeScreen({super.key});

  @override
  State<CashierHomeScreen> createState() => _CashierHomeScreenState();
}

class _CashierHomeScreenState extends State<CashierHomeScreen> {
  late Future<void> _loadDataFuture;
  final ApiService _apiService = ApiService();

  final FlutterTts _flutterTts = FlutterTts();

  List<Menu> _menus = [];
  List<Category> _categories = [];
  List<RestoTable> _tables = [];
  
  // BARU: State untuk menampung data order & transaksi
  List<Order> _orders = [];
  List<Transaction> _transactions = []; // Sekarang class Transaction dikenali

  int _selectedNavIndex = 0;
  int? _selectedCategoryId = null;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  // DIUBAH: Memperbaiki _loadData
 // DIUBAH: Memperbaiki _loadData
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
        // PERBAIKAN: Ubah int userId menjadi String
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
  
  // DIUBAH: Fungsi untuk me-refresh data setelah order
  Future<void> _refreshData() async {
     try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final userId = authService.user?.id;

      if (userId == null) {
        throw Exception("User tidak terautentikasi.");
      }

      final results = await Future.wait([
        _apiService.fetchTables(),
        // PERBAIKAN: Ubah int userId menjadi String
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
    // ... (Fungsi ini tidak berubah) ...
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
    // ... (Fungsi ini tidak berubah) ...
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

  Widget _buildNavRail() {
    // ... (Fungsi ini tidak berubah) ...
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
          _buildNavRailItem(Icons.table_restaurant, "Meja", 3),
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
    // ... (Fungsi ini tidak berubah) ...
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
            Icon(
              icon,
              size: 30,
              color: isSelected ? kBackgroundColor : kSecondaryColor,
            ),
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

  // DIUBAH: Mengganti placeholder dengan halaman baru
  Widget _buildMainContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildMenuPageContent();
      case 1:
        // REQ 6: Halaman Transaksi
        return _buildTransactionPage();
      case 2:
        // REQ 7: Halaman Order
        return _buildOrderPage();
      case 3:
        return _buildTableManagementPage();
      default:
        return _buildMenuPageContent();
    }
  }

  Widget _buildMenuPageContent() {
    // ... (Fungsi ini tidak berubah) ...
    final displayedMenus = _selectedCategoryId == null
        ? _menus
        : _menus.where((menu) => menu.categoryId == _selectedCategoryId).toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilterBar(),
          const SizedBox(height: 24),
          const Text(
            "Semua Menu Kami",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: displayedMenus.length,
              itemBuilder: (context, index) {
                return _buildMenuCard(displayedMenus[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    // ... (Fungsi ini tidak berubah) ...
    List<Category> allCategories = [
      Category(id: -1, name: "All", menusCount: _menus.length),
      ..._categories,
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final bool isSelected = (category.id == -1 && _selectedCategoryId == null) ||
                                  (category.id == _selectedCategoryId);

          IconData icon;
          switch (category.name.toLowerCase()) {
            case 'main course':
              icon = Icons.restaurant;
              break;
            case 'snack':
              icon = Icons.fastfood;
              break;
            case 'makanan':
              icon = Icons.restaurant;
              break;
            case 'minuman':
              icon = Icons.local_cafe;
              break;
            default:
              icon = Icons.category;
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = category.id == -1 ? null : category.id;
              });
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : kLightGreyColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isSelected ? kBackgroundColor : kSecondaryColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kBackgroundColor : kSecondaryColor,
                          ),
                        ),
                        Text(
                          "${category.menusCount ?? 0} Items",
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? kBackgroundColor.withOpacity(0.8) : kSecondaryColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(Menu menu) {
    // ... (Fungsi ini tidak berubah) ...
    final cart = Provider.of<CartProvider>(context, listen: false);
    final int itemCountInCart = context.watch<CartProvider>().getItemQuantity(menu.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (menu.imageUrl == null || menu.imageUrl!.isEmpty)
              ? Container(
                  height: 120,
                  width: double.infinity,
                  color: kLightGreyColor,
                  child: const Icon(Icons.image_not_supported, color: kSecondaryColor),
                )
              : Image.network(
                  menu.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: kLightGreyColor,
                    child: const Icon(Icons.image_not_supported, color: kSecondaryColor),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  menu.description ?? 'Tidak ada deskripsi',
                  style: TextStyle(fontSize: 12, color: kSecondaryColor.withOpacity(0.6)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${menu.price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: kPrimaryColor),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cart.decreaseItem(menu.id);
                          },
                          iconSize: 22,
                        ),
                        Text(
                          itemCountInCart.toString(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: kPrimaryColor),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cart.addItem(menu);
                          },
                          iconSize: 22,
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- HALAMAN TRANSAKSI (BARU - REQ 6) ---
  Widget _buildTransactionPage() {
    // Tampilkan order yang sudah 'completed' atau 'paid'
    final paidOrders = _orders.where((order) {
      final status = order.status.toLowerCase();
      return status == 'completed' || status == 'paid';
    }).toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Transaksi", // Sesuai gambar
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: paidOrders.isEmpty
                ? const Center(child: Text('Belum ada transaksi selesai.'))
                : ListView.builder(
                    itemCount: paidOrders.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(paidOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Order order) {
    // Dibuat mirip dengan (iPad Pro 12.9_ - 5.png)
    return Align( 
      alignment: Alignment.centerLeft,
      child: Card(
        color: const Color(0xFF2D2D2D), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 450, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          order.restoTable?.number ?? '??',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // PERBAIKAN: Handle String?
                          order.customerName ?? 'Nama Pelanggan',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Order #${order.id}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  // TODO: Format tanggal lebih baik
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const Divider(color: Colors.grey, height: 32),
                // Header List
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text('Qty', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                      const SizedBox(width: 16),
                      Expanded(child: Text('Items', style: TextStyle(color: Colors.white.withOpacity(0.7)))),
                      Text('Price', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                // Daftar Item
                ...order.orderItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text('${item.quantity}'.padLeft(2, '0'),
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(item.menu.name, // menu tidak null di model Anda
                                style: const TextStyle(color: Colors.white)),
                          ),
                          Text('Rp ${item.priceAtTime.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
                const Divider(color: Colors.grey, height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SubTotal',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Text(
                        'Rp ${order.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HALAMAN ORDER (BARU - REQ 7) ---
  Widget _buildOrderPage() {
    // Tampilkan order yang BELUM selesai
    final activeOrders = _orders.where((o) {
      final status = o.status.toLowerCase();
      return status != 'completed' && status != 'paid';
    }).toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order List",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: activeOrders.isEmpty
                ? const Center(child: Text('Belum ada order aktif.'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, 
                      childAspectRatio: 0.7, 
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(activeOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusInfo = _getStatusInfo(order.status);

    return Card(
      color: const Color(0xFF2D2D2D), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          order.restoTable?.number ?? '??',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // PERBAIKAN: Handle String?
                          order.customerName ?? 'Nama Pelanggan',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Order #${order.id}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusChip(
                    statusInfo['text']!, statusInfo['icon']!, statusInfo['color']!),
              ],
            ),
            const SizedBox(height: 8),
            // Waktu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${order.createdAt.hour.toString().padLeft(2,'0')}:${order.createdAt.minute.toString().padLeft(2,'0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 20),

            // Header List Item
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text('Qty',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Items',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ),
                  Text('Price',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            // Daftar Item
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: order.orderItems.length,
                itemBuilder: (context, index) {
                  final item = order.orderItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        Text('${item.quantity}'.padLeft(2, '0'),
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item.menu.name,
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                        Text('Rp ${item.priceAtTime.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.grey, height: 20),
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SubTotal',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('Rp ${order.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // Tombol Aksi
            _buildOrderActionButtons(order),
          ],
        ),
      ),
    );
  }

  // Helper untuk status di Order Card
  // Map<String, dynamic> _getStatusInfo(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'ready':
  //     case 'ready to serve':
  //       return {'text': 'Ready to serve', 'icon': Icons.check_circle, 'color': Colors.green};
  //     case 'cooking':
  //     case 'cooking now':
  //       return {'text': 'Cooking Now', 'icon': Icons.fireplace, 'color': Colors.orange};
  //     case 'in process':
  //     case 'in the kitchen':
  //       return {'text': 'In the Kitchen', 'icon': Icons.kitchen, 'color': Colors.pink};
  //     case 'completed':
  //     case 'paid':
  //       return {'text': 'Completed', 'icon': Icons.check, 'color': Colors.blue};
  //     default:
  //       return {'text': 'Pending', 'icon': Icons.pending, 'color': Colors.grey};
  //   }
  // }

  Map<String, dynamic> _getStatusInfo(String status) {
    status = status.toLowerCase();
    if (status == 'pending') {
      return {'text': 'Pending', 'icon': Icons.hourglass_empty, 'color': Colors.orange.shade300};
    }
    if (status == 'preparing') {
      return {'text': 'Disiapkan', 'icon': Icons.kitchen, 'color': Colors.blue.shade300};
    }
    if (status == 'ready') {
      return {'text': 'Siap', 'icon': Icons.check_circle, 'color': Colors.green.shade300};
    }
    return {'text': status.toUpperCase(), 'icon': Icons.help_outline, 'color': Colors.grey.shade300};
  }

  // Widget _buildStatusChip(String text, IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.2),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: color, size: 14),
  //         const SizedBox(width: 4),
  //         Text(text, style: TextStyle(color: color, fontSize: 11)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatusChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper untuk tombol aksi di Order Card
  // Widget _buildOrderActionButtons(Order order) {
  //   // Logika tombol berdasarkan status
  //   switch (order.status.toLowerCase()) {
  //     case 'pending':
  //       return SizedBox(
  //         width: double.infinity,
  //         height: 40,
  //         child: ElevatedButton(
  //           onPressed: () { /* TODO: API call untuk update status ke 'cooking' */ 
            
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
  //           child: const Text('Confirm', style: TextStyle(color: kBackgroundColor)),
  //         ),
  //       );
  //     case 'ready':
  //     case 'ready to serve':
  //     case 'cooking':
  //     case 'cooking now':
  //     case 'in process':
  //     case 'in the kitchen':
  //       return Row(
  //         children: [
  //           IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: kPrimaryColor)),
  //           IconButton(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.red)),
  //           const Spacer(),
  //           Expanded(
  //             flex: 2,
  //             child: SizedBox(
  //               height: 40,
  //               child: ElevatedButton(
  //                 onPressed: () { /* TODO: API call untuk update status 'completed' atau langsung bayar */ },
  //                 style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
  //                 child: const Text('Pay Bill', style: TextStyle(color: kBackgroundColor)),
  //               ),
  //             ),
  //           ),
  //         ],
  //       );
  //     case 'completed':
  //     case 'paid':
  //       return SizedBox(
  //         width: double.infinity,
  //         height: 40,
  //         child: ElevatedButton(
  //           onPressed: null, // Sudah dibayar
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
  //           child: const Text('Bill Paid', style: TextStyle(color: kBackgroundColor)),
  //         ),
  //       );
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

Widget _buildOrderActionButtons(Order order) {
    String status = order.status.toLowerCase();
    
    // REQUEST 2: Tampilkan tombol HANYA jika status 'ready'
    if (status == 'ready') {
      return SizedBox(
        width: double.infinity,
        height: 44, // Sesuaikan tinggi tombol
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor, // Warna primer Anda
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            // REQUEST 3: Panggil popup audio
            _showReadyOrderPopup(order); 
          },
          child: const Text(
            'Konfirmasi', 
            style: TextStyle(
              color: kBackgroundColor, // Asumsi teks tombol kontras
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
        ),
      );
    } else {
      // REQUEST 2: Tidak ada tombol untuk 'pending' atau 'preparing'
      // Beri SizedBox agar tinggi card tetap konsisten
      return const SizedBox(height: 44); 
    }
  }

  // --- SIDEBAR KERANJANG & PEMBAYARAN ---

  Widget _buildCartSidebar() {
    // ... (Fungsi ini tidak berubah) ...
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
    // ... (Fungsi ini tidak berubah) ...
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
    // ... (Fungsi ini tidak berubah) ...
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

  // DIUBAH: Menambahkan 'isChange' untuk Req 1
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
    // ... (Fungsi ini tidak berubah) ...
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

  // --- TAMPILAN PEMBAYARAN (DIUBAH) ---
// GANTI FUNGSI INI DI cashier_home_screen.dart

  // --- TAMPILAN PEMBAYARAN (Req 1, 2, 3, 4, 5, 9) ---
  Future<void> _showPaymentScreen(CartProvider cart) async {
    int? selectedTableId;
    String? selectedPaymentMethod;
    final receivedController = TextEditingController();
    final customerNameController = TextEditingController(text: 'Udean');
    bool isSubmitting = false;
    
    final BuildContext homeScreenContext = context;

    if (_tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal memuat daftar meja. Tidak bisa membuat pesanan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setPaymentState) {
            double received = double.tryParse(receivedController.text) ?? 0;
            double change = (received > cart.total) ? received - cart.total : 0;

            return Scaffold(
              backgroundColor: kBackgroundColor,

            //Penamabahan tombol kembali
            // appBar: AppBar(
            //         leading: IconButton(
            //           icon: const Icon(Icons.arrow_back, color: kSecondaryColor),
            //           onPressed: () => Navigator.of(context).pop(),
            //         ),
            //         title: const Text(
            //           'Detail Pembayaran',
            //           style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold),
            //         ),
            //         backgroundColor: kBackgroundColor,
            //         elevation: 0,
            //       ),



              body: Stack(
                children: [

                  Row(
                    children: [
                  // KOLOM KIRI - Order Details
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: kLightGreyColor.withOpacity(0.3),
                      padding: const EdgeInsets.only(
                        top: 24.0,    // <-- Padding atas tetap
                        left: 72.0,   // <-- Geser ke kanan untuk memberi ruang tombol
                        right: 24.0, 
                        bottom: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedTableId == null
                                        ? 'Pilih Meja'
                                        : 'Meja ${_tables.firstWhere((t) => t.id == selectedTableId).number}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 250, 
                                    child: TextField(
                                      controller: customerNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama Pelanggan',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4.0),
                                        border: UnderlineInputBorder(),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: kSecondaryColor,
                                      ),
                                      onChanged: (value) {
                                        setPaymentState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: kPrimaryColor, size: 28),
                                onPressed: () {
                                  // Memanggil dialog yang memfilter meja (Req 2)
                                  _showTableSelectionDialog(
                                    context,
                                    selectedTableId,
                                    (newTableId) {
                                      setPaymentState(() {
                                        selectedTableId = newTableId;
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Expanded(
                            child: ListView.builder(
                              itemCount: cart.items.length,
                              itemBuilder: (context, index) {
                                final item = cart.items[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: kPrimaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}'.padLeft(2, '0'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
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
                                              'x ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: kSecondaryColor.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Subtotal', 'Rp ${cart.subtotal.toStringAsFixed(0)}'),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Tax 10%', 'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}'),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Tip', 'Rp 500'), // Hardcoded
                                const Divider(height: 24, thickness: 1),
                                _buildSummaryRow('Total', 'Rp ${cart.total.toStringAsFixed(0)}', isTotal: true),
                                if (change > 0 && selectedPaymentMethod == 'cash')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: _buildSummaryRow(
                                      'Kembalian', 
                                      'Rp ${change.toStringAsFixed(0)}',
                                      isChange: true,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummaryRow('Recieved', 'Rp ${received.toStringAsFixed(0)}'),
                                const SizedBox(height: 24),
                                const Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPaymentMethodButton(
                                        'Cash',
                                        Icons.money,
                                        'cash',
                                        selectedPaymentMethod,
                                        (method) {
                                          setPaymentState(() {
                                            selectedPaymentMethod = method;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPaymentMethodButton(
                                        'Debit Card',
                                        Icons.credit_card,
                                        'debit',
                                        selectedPaymentMethod,
                                        (method) {
                                          setPaymentState(() {
                                            selectedPaymentMethod = method;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPaymentMethodButton(
                                        'E-Wallet',
                                        Icons.account_balance_wallet,
                                        'qris',
                                        selectedPaymentMethod,
                                        (method) {
                                          setPaymentState(() {
                                            selectedPaymentMethod = method;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // --- PERBAIKAN POIN 3 ADA DI SINI ---
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (selectedTableId == null || 
                                          selectedPaymentMethod == null || 
                                          customerNameController.text.isEmpty || 
                                          isSubmitting)
                                  ? null
                                  : () async {
                                      if (selectedPaymentMethod == 'debit' || selectedPaymentMethod == 'qris') {
                                        final bool? isConfirmed = await _showPaymentConfirmationDialog(
                                          context, 
                                          selectedPaymentMethod!,
                                        );
                                        
                                        if (isConfirmed != true) {
                                          return; 
                                        }
                                      }

                                      setPaymentState(() {
                                        isSubmitting = true;
                                      });

                                      try {

                                        final orderData = cart.createOrderJson(
                                          tableId: selectedTableId!,
                                          paymentMethod: selectedPaymentMethod!,
                                          customerName: customerNameController.text, 
                                        );
                                        
                                        // --- PERBAIKAN POIN 3 DIMULAI ---
                                        // Ini adalah perbaikan untuk Poin 3 Anda.
                                        // Ini mengasumsikan ApiService Anda sudah diubah:
                                        // 1. createOrder() me-return 'Order'
                                        // 2. createTransaction() sudah ada
                                        
                                        // 1. Buat Order dan DAPATKAN ID-nya
                                        final Order newOrder = await _apiService.createOrder(orderData);
                                        
                                        // 2. Buat Transaksi menggunakan ID order
                                        await _apiService.createTransaction({
                                          'order_id': newOrder.id,
                                          'payment_method': selectedPaymentMethod!,
                                          'amount_paid': received > 0 ? received : cart.total,
                                        });
                                        

                                        // 3. BARU: UPDATE STATUS MEJA MENJADI 'occupied'
                                        //    Tombol 'Order Completed' sudah memastikan selectedTableId != null
                                        await _apiService.updateTableStatus(selectedTableId!, 'occupied');
                                        // --- PERBAIKAN POIN 3 SELESAI ---

                                        // --- LOGIKA SUKSES ---
                                        cart.clearCart();
                                        Navigator.of(context).pop(); 
                                        _showSuccessOrderDialog(homeScreenContext);
                                        
                                        _refreshData(); 
                                        
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          setPaymentState(() {
                                              isSubmitting = false;
                                          });
                                        }
                                      } 
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: kBackgroundColor,
                                      ),
                                    )
                                  : const Text(
                                      'Order Completed',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: kBackgroundColor,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // KOLOM KANAN
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: kBackgroundColor,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Uang Pembayaran',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: kSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: kLightGreyColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Rp ${received.toStringAsFixed(0)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                              children: [
                                _buildCalculatorButton('1', receivedController, setPaymentState),
                                _buildCalculatorButton('2', receivedController, setPaymentState),
                                _buildCalculatorButton('3', receivedController, setPaymentState),
                                _buildCalculatorButton('4', receivedController, setPaymentState),
                                _buildCalculatorButton('5', receivedController, setPaymentState),
                                _buildCalculatorButton('6', receivedController, setPaymentState),
                                _buildCalculatorButton('7', receivedController, setPaymentState),
                                _buildCalculatorButton('8', receivedController, setPaymentState),
                                _buildCalculatorButton('9', receivedController, setPaymentState),
                                _buildCalculatorButton('0', receivedController, setPaymentState),
                                _buildCalculatorButton('X', receivedController, setPaymentState, isDelete: true),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    _printReceipt(
                                      context,
                                      cart,
                                      customerNameController.text,
                                      selectedTableId,
                                      selectedPaymentMethod,
                                      received,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: kPrimaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Buat Nota',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setPaymentState(() {
                                      receivedController.text = cart.total.toStringAsFixed(0);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: kPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kBackgroundColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
            top: 16.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: kBackgroundColor.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: kSecondaryColor, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
                ],
              ),
            );
          },
        ),
      ),
    );

    receivedController.dispose();
    customerNameController.dispose();
  }

  // --- FUNGSI BARU UNTUK REQUEST 3 ---

  // Fungsi 1: Untuk tombol "Tandai Selesai"
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiService.updateOrderStatus(orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #${orderId} diperbarui ke $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Ambil ulang data agar UI ter-update (pesanan hilang dari tab 'Siap')
      await _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi 2: Untuk tombol "Panggil Pelanggan" (Audio)
  Future<void> _speak(String text) async {
    try {
      await _flutterTts.setLanguage("id-ID"); // Set bahasa Indonesia
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi 3: Popup dialog
  void _showReadyOrderPopup(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Konfirmasi Pesanan Siap'),
          content: Text('Pilih tindakan untuk Meja #${order.restoTable?.number ?? '??'}'),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: kSecondaryColor)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Panggil Pelanggan', style: TextStyle(color: kBackgroundColor)),
              onPressed: () {
                // Panggil audio
                String customerName = order.customerName ?? 'Pelanggan';
                String tableNumber = order.restoTable?.number ?? '';
                
                // Teks yang akan diucapkan
                _speak('Atas nama $customerName, di Meja $tableNumber, pesanan anda sudah siap diambil.');
                
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text('Tandai Selesai', style: TextStyle(color: kBackgroundColor)),
              onPressed: () {
                // Update status jadi 'completed'
                Navigator.of(dialogContext).pop();
                _updateOrderStatus(order.id, 'completed');
              },
            ),
          ],
        );
      },
    );
  }
  // --- SELESAI FUNGSI BARU ---

  Widget _buildCalculatorButton(
    // ... (Fungsi ini tidak berubah) ...
    String value,
    TextEditingController controller,
    StateSetter setState, {
    bool isDelete = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isDelete) {
            if (controller.text.isNotEmpty) {
              controller.text = controller.text.substring(0, controller.text.length - 1);
            }
          } else {
            controller.text += value;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete ? kPrimaryColor : const Color(0xFFFFF4E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDelete ? kBackgroundColor : kSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    // ... (Fungsi ini tidak berubah) ...
    String label,
    IconData icon,
    String method,
    String? selectedMethod,
    Function(String) onSelect,
  ) {
    final bool isSelected = selectedMethod == method;
    return InkWell(
      onTap: () => onSelect(method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryColor : kLightGreyColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : kSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableSelectionDialog(
    // ... (Fungsi ini tidak berubah) ...
    BuildContext context,
    int? currentTableId,
    Function(int) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {

        // --- TAMBAHKAN INI ---
        // 1. Buat daftar baru yang HANYA berisi meja 'available'
        final List<RestoTable> availableTables = _tables
            .where((t) => t.status.toLowerCase() == 'available')
            .toList();
        // --- SELESAI PENAMBAHAN ---

        return AlertDialog(
          title: const Text('Pilih Meja'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              // itemCount: _tables.length, lama
              itemCount: availableTables.length,
              itemBuilder: (context, index) {

                // final table = _tables[index]; Lama
                final table = availableTables[index];
                final isSelected = table.id == currentTableId;
                return ListTile(
                  leading: Icon(
                    Icons.table_restaurant,
                    color: isSelected ? kPrimaryColor : kSecondaryColor,
                  ),
                  title: Text(
                    'Meja ${table.number}',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? kPrimaryColor : kSecondaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: kPrimaryColor)
                      : null,
                  onTap: () {
                    onSelect(table.id);
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableManagementPage() {
    // ... (Fungsi ini tidak berubah) ...
    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manajemen Meja",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData, // Panggil _refreshData
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // DIUBAH agar lebih banyak
                  childAspectRatio: 1.1, // DIUBAH agar pas
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  _tables.sort((a, b) => a.number.compareTo(b.number));
                  final table = _tables[index];
                  return _buildTableCard(table);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DIUBAH: _buildTableCard (Req 8: Kuning & Merah)
 // DIUBAH: _buildTableCard (Sesuai gambar: Abu-abu & Merah)
 // DIUBAH: _buildTableCard (Sesuai gambar: Abu-abu & Merah)
  Widget _buildTableCard(RestoTable table) {
    // Sesuai gambar: "Kosong" (Abu-abu), "Telah diisi" (Merah)
    final bool isAvailable = table.status.toLowerCase() == 'available';
    
    // WARNA KARTU: Abu-abu jika tersedia (Kosong), Merah jika terisi (Telah diisi)
    final Color cardColor = isAvailable ? Colors.grey.shade500 : Colors.red.shade600; 
    
    // WARNA TEKS: Gelap di atas abu-abu, Terang di atas merah
    final Color textColor = isAvailable ? kSecondaryColor : Colors.white;
    final Color statusColor = isAvailable ? kSecondaryColor.withOpacity(0.8) : Colors.white.withOpacity(0.8);
    
    final String statusText = isAvailable ? 'Tersedia' : 'Terisi';

    return GestureDetector(
      onTap: () {
        _showUpdateStatusDialog(table);
      },
      child: Card(
        elevation: 4,
        color: cardColor, // Warna dinamis
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.number, // Tampilkan nomor saja
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor, // Warna teks dinamis
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor, // Warna teks dinamis
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateStatusDialog(RestoTable table) async {
    // ... (Fungsi ini tidak berubah) ...
    final bool isAvailable = table.status.toLowerCase() == 'available';
    final String newStatus = isAvailable ? 'occupied' : 'available';
    final String newStatusText = isAvailable ? 'Terisi' : 'Tersedia';

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Ubah Status'),
          content: Text('Ubah status "Meja ${table.number}" menjadi "$newStatusText"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedTable = await _apiService.updateTableStatus(table.id, newStatus);
                  
                  setState(() {
                    final index = _tables.indexWhere((t) => t.id == table.id);
                    if (index != -1) {
                      _tables[index] = updatedTable;
                    }
                  });
                  
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status Meja ${table.number} berhasil diubah!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal update: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ubah'),
            ),
          ],
        );
      },
    );
  }
  
  // --- HELPER BARU UNTUK REQ 2, 3, 4, 6, 7 ---
  
  // HELPER BARU UNTUK PDF (Letakkan di atas _printReceipt)
  pw.Widget _buildPdfSummaryRow(String label, String value, {bool isTotal = false, bool isChange = false}) {
    final style = pw.TextStyle(
      fontWeight: (isTotal || isChange) ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: (isTotal || isChange) ? 12 : 10,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  // HELPER BARU UNTUK PDF (Letakkan di atas _printReceipt)
  Future<Uint8List> _generatePdfReceipt(
    CartProvider cart,
    String customerName,
    String tableName,
    String paymentMethod,
    double received,
    double change,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      // Ukuran kertas nota (thermal) kecil, misal 80mm
      // Ubah ke PdfPageFormat.a4 jika ingin ukuran A4
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Eat.o Nota', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Nama: $customerName'),
              pw.Text('Meja: $tableName'),
              pw.Divider(height: 15),
              // Daftar Item
              for (final item in cart.items)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${item.quantity}x ${item.menu.name}'),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}'),
                        ]
                      )
                    ],
                  ),
                ),
              pw.Divider(height: 15),
              // Ringkasan
              _buildPdfSummaryRow('Subtotal', 'Rp ${cart.subtotal.toStringAsFixed(0)}'),
              _buildPdfSummaryRow('Tax 10%', 'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}'),
              _buildPdfSummaryRow('Tip', 'Rp 500'), // Hardcoded
              pw.Divider(),
              _buildPdfSummaryRow('Total', 'Rp ${cart.total.toStringAsFixed(0)}', isTotal: true),
              pw.Divider(),
              _buildPdfSummaryRow('Metode', paymentMethod.toUpperCase()),
              _buildPdfSummaryRow('Diterima', 'Rp ${received.toStringAsFixed(0)}'),
              if (change > 0 && paymentMethod == 'cash')
                _buildPdfSummaryRow('Kembali', 'Rp ${change.toStringAsFixed(0)}', isChange: true),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Terima kasih!')),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // BARU: Fungsi baru untuk Req 4: Buat Nota
  void _printReceipt(
    BuildContext context,
    CartProvider cart,
    String customerName,
    int? tableId,
    String? paymentMethod,
    double received,
  ) {
    if (tableId == null || paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih meja dan metode pembayaran dulu.')),
      );
      return;
    }
    
    final String tableName = _tables.firstWhere((t) => t.id == tableId).number;
    final double change = (received > cart.total) ? received - cart.total : 0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nota Pesanan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama: $customerName'),
                Text('Meja: $tableName'),
                const Divider(),
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.quantity}x ${item.menu.name}')),
                      Text('Rp ${(item.menu.price * item.quantity).toStringAsFixed(0)}'),
                    ],
                  ),
                )),
                const Divider(),
                _buildSummaryRow('Subtotal', 'Rp ${cart.subtotal.toStringAsFixed(0)}'),
                _buildSummaryRow('Tax 10%', 'Rp ${(cart.subtotal * cart.taxPercent / 100).toStringAsFixed(0)}'),
                _buildSummaryRow('Tip', 'Rp 500'), // Hardcoded
                const Divider(),
                _buildSummaryRow('Total', 'Rp ${cart.total.toStringAsFixed(0)}', isTotal: true),
                const Divider(),
                _buildSummaryRow('Metode', paymentMethod.toUpperCase()),
                _buildSummaryRow('Diterima', 'Rp ${received.toStringAsFixed(0)}'),
                if (change > 0 && paymentMethod == 'cash')
                  _buildSummaryRow('Kembali', 'Rp ${change.toStringAsFixed(0)}', isChange: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
            // ElevatedButton(
            //   onPressed: () { 
            //     // TODO: Tambahkan logika print sesungguhnya (misal: pakai package 'printing')
            //     Navigator.of(dialogContext).pop();
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Mencetak nota... (simulasi)')),
            //     );
            //   },
            //   child: const Text('Print'),
            // ),
            // ... (di dalam _printReceipt, di dalam actions:)
            ElevatedButton(
              onPressed: () async { // <-- 1. Jadikan 'async'
                try {
                  // 2. Panggil fungsi generator PDF yang baru
                  final Uint8List pdfData = await _generatePdfReceipt(
                    cart,
                    customerName,
                    tableName,
                    paymentMethod,
                    received,
                    change,
                  );
                  
                  // 3. Panggil dialog print dari package 'printing'
                  // Ini akan membuka dialog print di browser/OS
                  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
                  
                  if (mounted) {
                     Navigator.of(dialogContext).pop();
                  }
                  
                } catch (e) {
                  // 4. Tangani jika ada error
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membuat PDF: $e')),
                    );
                  }
                }
              },
              child: const Text('Print'),
            ),
// ...
          ],
        );
      },
    );
  }

  // BARU: Fungsi baru untuk Req 2 & 3: Popup Debit/QRIS
  Future<bool?> _showPaymentConfirmationDialog(BuildContext context, String method) async {
    final bool isDebit = method == 'debit';
    final String title = isDebit ? 'Pembayaran Debit' : 'Pembayaran E-Wallet';
    // Gunakan Icon sebagai placeholder gambar
    final Widget imageWidget = isDebit
        ? const Icon(Icons.credit_card, size: 100, color: kPrimaryColor)
        : const Icon(Icons.qr_code_2, size: 100, color: kPrimaryColor); // Simbol QRIS
        
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User harus memilih
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              const SizedBox(height: 16),
              Text(
                isDebit 
                  ? 'Silakan gesek kartu debit. Tekan "Selesai" jika berhasil.'
                  : 'Silakan pindai QRIS. Tekan "Selesai" jika berhasil.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false), // 'Tidak'
              child: const Text('Batalkan'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true), // 'Selesai'
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  // BARU: Fungsi baru untuk popup sukses (iPad Pro 12.9_ - 12.jpg)
  void _showSuccessOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimaryColor, // Background oranye
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
                  child: const Icon(
                    Icons.check,
                    color: kPrimaryColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  ),
                  child: const Text(
                    'Lanjutkan Transaksi', // Sesuai gambar
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}