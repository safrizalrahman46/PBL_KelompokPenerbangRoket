// lib/screens/home/kitchen_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Dibutuhkan untuk format waktu



import '../../models/order_model.dart'; // Import model Order Anda
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
    _loadOrdersFuture = _fetchOrders(); // Muat data saat pertama kali
    
    // Siapkan auto-refresh setiap 30 detik agar dapur selalu update
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Hentikan timer saat halaman ditutup
    super.dispose();
  }

  // Fungsi utama untuk mengambil data pesanan
  Future<void> _fetchOrders() async {
    try {
      // Ambil 2 jenis pesanan secara bersamaan
      final results = await Future.wait([
        _apiService.fetchOrders('status=pending'),
        _apiService.fetchOrders('status=preparing'),
        _apiService.fetchOrders('status=ready'),
      ]);
      
      if (mounted) {
        setState(() {
          _pendingOrders = results[0];
          _preparingOrders = results[1];
          _readyOrders = results[2];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data pesanan: $e')),
        );
      }
    }
  }

  // Fungsi untuk update status (dipanggil oleh tombol)
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
      // Ambil ulang data agar UI ter-update
      await _fetchOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi untuk logout
  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (mounted) {
      // Kembali ke login dan hapus semua halaman sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGreyColor.withOpacity(0.5),
      appBar: AppBar(
        title: const Text('Dapur Eat.o', style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: kSplashBackgroundColor, // Warna kuning cerah
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kSecondaryColor),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // UI Utama setelah data dimuat
          return RefreshIndicator(
            onRefresh: _fetchOrders, // Tarik untuk refresh manual
            color: kPrimaryColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom 1: Pesanan Baru (Pending)
                _buildOrdersColumn(
                  title: 'Pesanan Baru',
                  orders: _pendingOrders,
                  nextStatus: 'preparing',
                  buttonText: 'Mulai Siapkan',
                  buttonColor: kPrimaryColor,
                ),
                const VerticalDivider(width: 2, color: kSecondaryColor),
                // Kolom 2: Sedang Disiapkan (Preparing)
                _buildOrdersColumn(
                  title: 'Sedang Dimasak',
                  orders: _preparingOrders,
                  nextStatus: 'ready', // Harusnya 'ready' atau 'completed'? Sesuai kode Anda 'completed'
                  buttonText: 'Selesai',
                  buttonColor: Colors.green,
                ),
                const VerticalDivider(width: 2, color: kSecondaryColor),

                _buildOrdersColumn(
                  title: 'Selesai',
                  orders: _preparingOrders,
                  nextStatus: 'completed', // Harusnya 'ready' atau 'completed'? Sesuai kode Anda 'completed'
                  buttonText: 'Tandai Selesai',
                  buttonColor: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget untuk membuat satu kolom (Reusable)
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
          // Judul Kolom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: kBackgroundColor,
            child: Text(
              '$title (${orders.length})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kSecondaryColor,
              ),
            ),
          ),
          
          // Daftar Pesanan
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text('Tidak ada pesanan', style: TextStyle(fontSize: 18, color: kSecondaryColor.withOpacity(0.5))),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
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

  // Widget untuk membuat satu kartu pesanan
  Widget _buildOrderCard({
    required Order order,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Kartu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // 'Meja #${order.table.number}',
                  // 'Meja #${order.restoTable?.number ?? '??'}', // Asumsi order punya obj 'table'
                  'Meja #${order.restoTable?.number ?? '??'}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                Text(
                  // Format waktu, misal: 11:30
                  DateFormat('HH:mm').format(order.createdAt),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: kSecondaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Daftar Item Pesanan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.orderItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.menu.name, // Asumsi item punya 'menu'
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Tombol Aksi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _updateOrderStatus(order.id, nextStatus);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
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
    );
  }
}