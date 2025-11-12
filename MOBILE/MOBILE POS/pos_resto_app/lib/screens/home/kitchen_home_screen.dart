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
      // Ambil 3 jenis pesanan secara bersamaan
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
            content: Text('Pesanan #$orderId diperbarui ke $newStatus'),
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
      backgroundColor: const Color(0xFFFFF8E1), // Background krem seperti di gambar
      appBar: AppBar(
        title: const Text('Dapur Eat.o', style: TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: kSplashBackgroundColor,
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
                  buttonText: 'Mulai Memasak',
                  buttonColor: const Color(0xFFFF9800),
                ),
                // Kolom 2: Sedang Disiapkan (Preparing)
                _buildOrdersColumn(
                  title: 'Sedang Dimasak',
                  orders: _preparingOrders,
                  nextStatus: 'ready',
                  buttonText: 'Selesaikan',
                  buttonColor: const Color(0xFFFF9800),
                ),
                // Kolom 3: Selesai (Ready)
                _buildOrdersColumn(
                  title: 'Selesai',
                  orders: _readyOrders,
                  nextStatus: 'completed',
                  buttonText: 'Selesai',
                  buttonColor: const Color(0xFFFF9800),
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
          // Judul Kolom dengan styling baru
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800), // Orange sesuai gambar
              borderRadius: BorderRadius.circular(30.0), // Border radius melengkung
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text putih
              ),
            ),
          ),
          
          // Daftar Pesanan
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada pesanan', 
                      style: TextStyle(
                        fontSize: 18, 
                        color: kSecondaryColor.withOpacity(0.5)
                      )
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

  // Widget untuk membuat satu kartu pesanan
  Widget _buildOrderCard({
    required Order order,
    required String nextStatus,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD), // Background kuning muda
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
          // Header dengan badge orange
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Badge nomor orange
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                // Info order
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Udean',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Container putih untuk items dengan table layout
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header table
                Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                // Items list
                ...order.orderItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            item.quantity.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.menu.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Tombol Aksi dengan border radius penuh
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // Border radius melengkung penuh
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