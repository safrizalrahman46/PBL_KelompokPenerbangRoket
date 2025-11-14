// lib/screens/home/cashier_order_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CashierOrderScreen extends StatefulWidget {
  final List<Order> orders;
  final Future<void> Function() onRefresh;
  final ApiService apiService;

  const CashierOrderScreen({
    super.key,
    required this.orders,
    required this.onRefresh,
    required this.apiService,
  });

  @override
  State<CashierOrderScreen> createState() => _CashierOrderScreenState();
}

class _CashierOrderScreenState extends State<CashierOrderScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedFilter = 'Semua'; // Default filter

  // List filter options
  final List<String> _filterOptions = [
    'Semua',
    'Pending',
    'Disiapkan', 
    'Siap',
    'Selesai'
  ];

  @override
  Widget build(BuildContext context) {
    // Filter orders berdasarkan status yang dipilih
    final filteredOrders = _filterOrders(widget.orders);

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
          const SizedBox(height: 16),
          
          // Filter Chip Bar
          _buildFilterChipBar(),
          
          const SizedBox(height: 16),
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: kSecondaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyStateText(),
                          style: TextStyle(
                            fontSize: 18,
                            color: kSecondaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget untuk filter chip bar
  Widget _buildFilterChipBar() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final bool isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : kSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              backgroundColor: kLightGreyColor,
              selectedColor: kPrimaryColor,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk memfilter orders berdasarkan status
  List<Order> _filterOrders(List<Order> orders) {
    switch (_selectedFilter) {
      case 'Pending':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          // Pending termasuk status: pending, paid (sudah bayar tapi belum diproses)
          return status == 'pending' || status == 'paid';
        }).toList();
      
      case 'Disiapkan':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'preparing' || status == 'cooking';
        }).toList();
      
      case 'Siap':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'ready' || status == 'ready to serve';
        }).toList();
      
      case 'Selesai':
        return orders.where((order) {
          final status = order.status.toLowerCase();
          return status == 'completed' || status == 'done' || status == 'finished';
        }).toList();
      
      case 'Semua':
      default:
        return orders;
    }
  }

  // Fungsi untuk teks empty state berdasarkan filter
  String _getEmptyStateText() {
    switch (_selectedFilter) {
      case 'Pending':
        return 'Tidak ada order pending';
      case 'Disiapkan':
        return 'Tidak ada order yang sedang disiapkan';
      case 'Siap':
        return 'Tidak ada order yang siap disajikan';
      case 'Selesai':
        return 'Tidak ada order yang selesai';
      case 'Semua':
      default:
        return 'Belum ada order aktif';
    }
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
            _buildOrderActionButtons(order),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    status = status.toLowerCase();
    
    // Mapping status yang lebih komprehensif
    if (status == 'pending' || status == 'paid') {
      return {
        'text': 'Pending', 
        'icon': Icons.hourglass_empty, 
        'color': Colors.orange.shade300
      };
    }
    if (status == 'preparing' || status == 'cooking') {
      return {
        'text': 'Disiapkan', 
        'icon': Icons.kitchen, 
        'color': Colors.blue.shade300
      };
    }
    if (status == 'ready' || status == 'ready to serve') {
      return {
        'text': 'Siap', 
        'icon': Icons.check_circle, 
        'color': Colors.green.shade300
      };
    }
    if (status == 'completed' || status == 'done' || status == 'finished') {
      return {
        'text': 'Selesai', 
        'icon': Icons.done_all, 
        'color': Colors.grey.shade300
      };
    }
    
    return {
      'text': status.toUpperCase(), 
      'icon': Icons.help_outline, 
      'color': Colors.grey.shade300
    };
  }

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

  Widget _buildOrderActionButtons(Order order) {
    String status = order.status.toLowerCase();
    
    // Tombol aksi berdasarkan status
    if (status == 'ready' || status == 'ready to serve') {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            _showReadyOrderPopup(order);
          },
          child: const Text(
            'Konfirmasi', 
            style: TextStyle(
              color: kBackgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
        ),
      );
    } 
   
   // dibuang oleh safrizal
    else {
      return const SizedBox(height: 44);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await widget.apiService.updateOrderStatus(orderId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #$orderId diperbarui ke $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.setLanguage("id-ID");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar audio: $e'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  void _showReadyOrderPopup(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pesanan Siap'),
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
                String customerName = order.customerName ?? 'Pelanggan';
                String tableNumber = order.restoTable?.number ?? '';
                _speak('Atas nama $customerName, di Meja $tableNumber, pesanan anda sudah siap diambil.');
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text('Tandai Selesai', style: TextStyle(color: kBackgroundColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updateOrderStatus(order.id, 'completed');
              },
            ),
          ],
        );
      },
    );
  }
}