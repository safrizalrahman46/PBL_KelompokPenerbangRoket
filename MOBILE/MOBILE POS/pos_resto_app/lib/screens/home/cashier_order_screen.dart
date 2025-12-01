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
  
  // --- 1. FILTER STATUS (Chip) ---
  String _selectedStatusFilter = 'Semua';
  final List<String> _statusOptions = [
    'Semua',
    'Pending',
    'Disiapkan',
    'Siap',
    'Selesai',
  ];

  // --- 2. FILTER WAKTU (Dropdown) - BARU ---
  String _selectedTimeFilter = 'Hari Ini'; 
  final List<String> _timeOptions = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan Ini',
    'Semua',
  ];

  // 🔥 SNACKBAR FLOATING
  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: color ?? kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- LOGIKA CEK WAKTU (BARU) ---
  bool _checkTimeFilter(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(orderDate.year, orderDate.month, orderDate.day);

    switch (_selectedTimeFilter) {
      case 'Hari Ini':
        return dateToCheck.isAtSameMomentAs(today);
      case 'Kemarin':
        final yesterday = today.subtract(const Duration(days: 1));
        return dateToCheck.isAtSameMomentAs(yesterday);
      case '7 Hari Terakhir':
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return dateToCheck.isAfter(sevenDaysAgo) && 
               (dateToCheck.isBefore(today) || dateToCheck.isAtSameMomentAs(today));
      case 'Bulan Ini':
        return orderDate.year == now.year && orderDate.month == now.month;
      case 'Semua':
      default:
        return true;
    }
  }

  // --- LOGIKA FILTER STATUS (DIUPDATE UNTUK MENERIMA LIST) ---
  List<Order> _filterByStatus(List<Order> orders) {
    switch (_selectedStatusFilter) {
      case 'Pending':
        return orders.where((order) {
          final status = order.status.toLowerCase();
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
          return status == 'completed' ||
              status == 'done' ||
              status == 'finished';
        }).toList();

      default:
        return orders;
    }
  }

  String _getEmptyStateText() {
    switch (_selectedStatusFilter) {
      case 'Pending':
        return 'Tidak ada order pending';
      case 'Disiapkan':
        return 'Tidak ada order yang sedang disiapkan';
      case 'Siap':
        return 'Tidak ada order yang siap disajikan';
      case 'Selesai':
        return 'Tidak ada order yang selesai';
      default:
        return 'Belum ada order aktif';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. SORTING (Terbaru di atas)
    List<Order> sortedOrders = List.from(widget.orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 2. FILTER WAKTU (BARU)
    List<Order> timeFilteredOrders = sortedOrders.where((order) {
      return _checkTimeFilter(order.createdAt);
    }).toList();

    // 3. FILTER STATUS (Menggunakan hasil filter waktu)
    final finalFilteredOrders = _filterByStatus(timeFilteredOrders);

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
          
          // --- CHIP BAR STATUS ---
          _buildStatusFilterBar(),
          
          const SizedBox(height: 16),

          // --- DROPDOWN FILTER WAKTU (BARU) ---
          Row(
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimeFilter,
                    dropdownColor: const Color(0xFF2D2D2D),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                    items: _timeOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 16, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimeFilter = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "($_selectedTimeFilter: ${finalFilteredOrders.length} Pesanan)",
                style: TextStyle(
                  color: kSecondaryColor.withOpacity(0.6),
                  fontStyle: FontStyle.italic
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: finalFilteredOrders.isEmpty
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
                        Text(
                          "Periode: $_selectedTimeFilter",
                          style: TextStyle(
                            fontSize: 14,
                            color: kSecondaryColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.70,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: finalFilteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(finalFilteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterBar() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusOptions.length,
        itemBuilder: (context, index) {
          final filter = _statusOptions[index];
          final bool isSelected = _selectedStatusFilter == filter;

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
                  _selectedStatusFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusInfo = _getStatusInfo(order.status);

    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 400, maxHeight: 500),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          order.customerName ?? 'Nama Pelanggan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  ),

                  _buildStatusChip(
                    statusInfo['text']!,
                    statusInfo['icon']!,
                    statusInfo['color']!,
                  ),
                ],
              ),
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
                  '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 8),

            // LABEL TABLE HEADER
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Price',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ITEMS LIST
            Container(
              constraints: const BoxConstraints(maxHeight: 150, minHeight: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: order.orderItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No items',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: order.orderItems.length,
                      itemBuilder: (context, index) {
                        final item = order.orderItems[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 25,
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.menu.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Rp ${item.priceAtTime.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 8),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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

            const SizedBox(height: 12),
            _buildOrderActionButtons(order),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    status = status.toLowerCase();

    if (status == 'pending' || status == 'paid') {
      return {
        'text': 'Pending',
        'icon': Icons.hourglass_empty,
        'color': Colors.orange.shade300,
      };
    }
    if (status == 'preparing' || status == 'cooking') {
      return {
        'text': 'Disiapkan',
        'icon': Icons.kitchen,
        'color': Colors.blue.shade300,
      };
    }
    if (status == 'ready' || status == 'ready to serve') {
      return {
        'text': 'Siap',
        'icon': Icons.check_circle,
        'color': Colors.green.shade300,
      };
    }
    if (status == 'completed' || status == 'done' || status == 'finished') {
      return {
        'text': 'Selesai',
        'icon': Icons.done_all,
        'color': Colors.grey.shade300,
      };
    }

    return {
      'text': status.toUpperCase(),
      'icon': Icons.help_outline,
      'color': Colors.grey.shade300,
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
          const SizedBox(width: 8),
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
    String status = order.status.toLowerCase();

    if (status == 'ready' || status == 'ready to serve') {
      return SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            backgroundColor: kPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () => _showReadyOrderPopup(order),
          child: const Text(
            'Konfirmasi',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(height: 30);
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      await widget.apiService.updateOrderStatus(orderId, newStatus);

      if (mounted) {
        _showSnack(
          'Pesanan #$orderId diperbarui ke $newStatus',
          color: Colors.green,
        );
      }

      await widget.onRefresh();
    } catch (e) {
      if (mounted) {
        _showSnack('Gagal update status: $e', color: Colors.red);
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
        _showSnack('Gagal memutar audio: $e', color: Colors.red);
      }
    }
  }

  void _showReadyOrderPopup(Order order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF2D2D2D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 380, 
            ),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Konfirmasi Pesanan Siap",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Pesanan untuk Meja #${order.restoTable?.number ?? '??'} sudah siap?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (order.customerName != null)
                    Text(
                      'Atas nama: ${order.customerName!}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 18),

                  // DETAIL SUMMARY
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Items:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              '${order.orderItems.length} items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Harga:',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Rp ${order.totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BUTTONS
                  Row(
                    children: [
                      // CANCEL
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Batal'),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // CALL CUSTOMER
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            String customer = order.customerName ?? 'Pelanggan';
                            String table = order.restoTable?.number ?? '';

                            _speak(
                              'Atas nama $customer, di Meja $table, pesanan anda sudah siap.',
                            );
                            Navigator.pop(dialogContext);

                            _showSnack(
                              'Memanggil pelanggan Meja #$table',
                              color: Colors.blueAccent,
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volume_up,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Panggil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // SELESAI
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _updateOrderStatus(order.id, 'completed');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}