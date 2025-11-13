import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
import '../../../utils/constants.dart';

class CashierOrderScreen extends StatefulWidget {
  final ApiService apiService;

  const CashierOrderScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<CashierOrderScreen> createState() => _CashierOrderScreenState();
}

class _CashierOrderScreenState extends State<CashierOrderScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await widget.apiService.fetchOrders(); // ✅ Sudah aman
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('❌ Fetch orders failed: $e\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada order aktif.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 50),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) =>
                              _buildOrderCard(_orders[index]),
                        ),
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
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Table Number
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Customer Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName ?? 'Nama Pelanggan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  statusInfo['text']!,
                  statusInfo['icon']!,
                  statusInfo['color']!,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // --- Date & Time ---
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
                  '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Divider(color: Colors.grey, height: 20),

            // --- Item List ---
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
                        Text(
                          '${item.quantity}'.padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.menu.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${item.priceAtTime.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Colors.grey, height: 20),

            // --- Subtotal ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SubTotal',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Rp ${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Action Button ---
            _buildOrderActionButtons(order),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    final lower = status.toLowerCase();
    if (lower == 'pending') {
      return {
        'text': 'Pending',
        'icon': Icons.hourglass_empty,
        'color': Colors.orange.shade300
      };
    } else if (lower == 'preparing') {
      return {
        'text': 'Disiapkan',
        'icon': Icons.kitchen,
        'color': Colors.blue.shade300
      };
    } else if (lower == 'ready') {
      return {
        'text': 'Siap',
        'icon': Icons.check_circle,
        'color': Colors.green.shade300
      };
    }
    return {
      'text': lower.toUpperCase(),
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
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActionButtons(Order order) {
    final status = order.status.toLowerCase();
    if (status == 'ready') {
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
          onPressed: () => _showReadyOrderPopup(order),
          child: const Text(
            'Konfirmasi',
            style: TextStyle(
              color: kBackgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 44);
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
      await _fetchOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status: $e'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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
          content: Text(
            'Pilih tindakan untuk Meja #${order.restoTable?.number ?? '??'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: kSecondaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                final customerName = order.customerName ?? 'Pelanggan';
                final tableNumber = order.restoTable?.number ?? '';
                _speak(
                  'Atas nama $customerName, di Meja $tableNumber, pesanan anda sudah siap diambil.',
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Panggil Pelanggan',
                style: TextStyle(color: kBackgroundColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _updateOrderStatus(order.id, 'completed');
              },
              child: const Text(
                'Tandai Selesai',
                style: TextStyle(color: kBackgroundColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
