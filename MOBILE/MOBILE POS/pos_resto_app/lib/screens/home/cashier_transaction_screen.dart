// lib/screens/home/cashier_transaction_screen.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class CashierTransactionScreen extends StatefulWidget {
  final List<Order> orders;

  const CashierTransactionScreen({
    super.key,
    required this.orders,
  });

  @override
  State<CashierTransactionScreen> createState() => _CashierTransactionScreenState();
}

class _CashierTransactionScreenState extends State<CashierTransactionScreen> {
  DateTime? _selectedDate;

  // --- PERBAIKAN DI FUNGSI INI ---
  Future<void> _pickDate() async {
    // Ambil waktu sekarang sekali saja agar konsisten
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      
      // 🔥 SOLUSI UTAMA: Paksa dialog muncul di layer paling atas
      // Ini mencegah dialog langsung tertutup di iPad/Tablet
      useRootNavigator: true, 

      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      
      // Tambahkan sedikit buffer waktu agar tidak error "initialDate must be on or before lastDate"
      // karena perbedaan milidetik saat eksekusi.
      lastDate: now.add(const Duration(seconds: 1)),
      
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryColor, 
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D), 
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2D2D2D), // Tambahan untuk background dialog
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // FILTER DATA
    List<Order> filteredList = widget.orders;
    
    if (_selectedDate != null) {
      filteredList = widget.orders.where((order) {
        return order.createdAt.year == _selectedDate!.year &&
               order.createdAt.month == _selectedDate!.month &&
               order.createdAt.day == _selectedDate!.day;
      }).toList();
    }

    // BALIK URUTAN
    final displayOrders = filteredList.reversed.toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Detail Transaksi",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kSecondaryColor,
                ),
              ),
              
              // TOMBOL FILTER
              Row(
                children: [
                  if (_selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton.icon(
                        onPressed: _resetFilter,
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          "Reset", 
                          style: TextStyle(color: Colors.red)
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_selectedDate == null 
                      ? "Pilih Tanggal" 
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          Expanded(
            child: displayOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDate == null 
                            ? 'Belum ada transaksi selesai.' 
                            : 'Tidak ada transaksi pada tanggal ini.',
                          style: const TextStyle(color: kSecondaryColor),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: displayOrders.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(displayOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Order order) {
    return Card(
      color: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER SECTION
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
              ],
            ),
            
            const SizedBox(height: 12),
            
            // DATE
            Text(
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            
            const SizedBox(height: 12),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),

            // TABLE HEADER
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    'Price',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ORDER ITEMS
            Expanded(
              child: order.orderItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No items',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: order.orderItems.length,
                      itemBuilder: (context, index) {
                        final item = order.orderItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 25,
                                child: Text(
                                  '${item.quantity}'.padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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

            // TOTAL PRICE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SubTotal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rp ${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}