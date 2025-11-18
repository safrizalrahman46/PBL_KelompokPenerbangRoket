import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer.periodic
// Import sesuai lokasi file Anda
import '../../services/api_service.dart';
import '../../models/order_model.dart';
//import '../../utils/constants.dart'; // Untuk warna dan konstanta lain

class QueueDisplayScreen extends StatefulWidget {
  const QueueDisplayScreen({super.key});

  @override
  State<QueueDisplayScreen> createState() => _QueueDisplayScreenState();
}

class _QueueDisplayScreenState extends State<QueueDisplayScreen> {
  // Buat instance ApiService di dalam State
  final ApiService _apiService = ApiService();

  // --- Data untuk Tampilan ---
  List<Order> _pendingOrders = []; // Status: 'preparing'
  List<Order> _readyOrders = []; // Status: 'ready'

  // --- Timer untuk Auto-Refresh ---
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPollingOrders();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- Polling Data dari API ---
  void _startPollingOrders() {
    // Panggil pertama kali
    _fetchOrders();
    // Lalu panggil setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        // Tambahkan pengecekan mounted
        _fetchOrders();
      }
    });
  }

  Future<void> _fetchOrders() async {
    try {
      // Ambil semua order, lalu filter di Flutter
      // Menggunakan _apiService (instance lokal) bukan widget.apiService
      final List<Order> allOrders = await _apiService.fetchOrders("all");

      final newPendingOrders =
          allOrders.where((order) => order.status == 'preparing').toList();
      final newReadyOrders =
          allOrders.where((order) => order.status == 'completed').toList();

      // Pastikan widget masih ada sebelum setState
      if (mounted) {
        setState(() {
          _pendingOrders = newPendingOrders;
          _readyOrders = newReadyOrders;
        });
      }
    } catch (e) {
      print('Error fetching orders for display: $e');
      // Tampilkan pesan error di UI jika perlu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Kolom Kiri: Dalam Proses
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Column(
                  children: [
                    _buildHeader('Dalam Proses', const Color(0xFFFF9500)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ListView.builder(
                          itemCount: _pendingOrders.length,
                          itemBuilder: (context, index) {
                            final order = _pendingOrders[index];
                            final firstItem = order.orderItems.isNotEmpty
                                ? order.orderItems.first.menu.name
                                : 'No Items';

                            return _buildProcessItem(
                              order.customerName ?? 'Pelanggan',
                              firstItem,
                              order.id.toString().padLeft(2, '0'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Kolom Tengah: Order Antrian & Selesai
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E0),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Column(
                  children: [
                    _buildHeader('Order Antrian', const Color(0xFFFF9500)),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ListView.builder(
                          // Tampilkan 1 item jika list tidak kosong
                          itemCount: _readyOrders.isNotEmpty ? 1 : 0,
                          itemBuilder: (context, index) {
                            // Ambil item PERTAMA saja
                            final order = _readyOrders.first;
                            return _buildQueueNumber(
                              order.id.toString().padLeft(2, '0'),
                              order.customerName ?? 'Pelanggan',
                            );
                          },
                        ),
                      ),
                    ),
                    _buildHeader('Selesai', const Color(0xFFFF9500)),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ListView.builder(
                          // Tampilkan sisa item (jumlah total dikurangi 1)
                          itemCount: (_readyOrders.length > 1)
                              ? _readyOrders.length - 1
                              : 0,
                          itemBuilder: (context, index) {
                            // Ambil item mulai dari index KEDUA (index 1)
                            final order = _readyOrders[index + 1];
                            final firstItem = order.orderItems.isNotEmpty
                                ? order.orderItems.first.menu.name
                                : 'No Items';
                            return _buildFinishedItem(
                              order.customerName ?? 'Pelanggan',
                              firstItem,
                              order.id.toString().padLeft(2, '0'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Kolom Kanan: Iklan
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/bca_ad.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text(
                        'Iklan tidak tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Pembantu ---

  Widget _buildHeader(String title, Color backgroundColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessItem(
      String customerName, String itemName, String orderNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4226),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Order # $orderNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6B4226),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              orderNumber,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueNumber(String orderNumber, String customerName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            orderNumber,
            style: const TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedItem(
      String customerName, String itemName, String orderNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4226),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Order # $orderNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6B4226),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            constraints: const BoxConstraints(minWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              orderNumber,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}