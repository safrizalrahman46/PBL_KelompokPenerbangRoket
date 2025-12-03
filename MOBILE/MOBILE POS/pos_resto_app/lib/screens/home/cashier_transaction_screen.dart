// lib/screens/home/cashier_transaction_screen.dart

import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart';

class CashierTransactionScreen extends StatefulWidget {
  final List<Order> orders;
  final VoidCallback onRefresh;

  const CashierTransactionScreen({
    super.key,
    required this.orders,
    required this.onRefresh,
  });

  @override
  State<CashierTransactionScreen> createState() =>
      _CashierTransactionScreenState();
}

class _CashierTransactionScreenState extends State<CashierTransactionScreen> {
  // Pilihan Filter Waktu
  String _selectedFilter = 'Hari Ini'; // Default
  final List<String> _filterOptions = [
    'Hari Ini',
    'Kemarin',
    '7 Hari Terakhir',
    'Bulan Ini',
    'Semua',
  ];

  // Search Query
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // LOGIKA FILTER
  bool _checkDateFilter(DateTime orderDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(
      orderDate.year,
      orderDate.month,
      orderDate.day,
    );

    switch (_selectedFilter) {
      case 'Hari Ini':
        return dateToCheck.isAtSameMomentAs(today);
      case 'Kemarin':
        final yesterday = today.subtract(const Duration(days: 1));
        return dateToCheck.isAtSameMomentAs(yesterday);
      case '7 Hari Terakhir':
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return dateToCheck.isAfter(sevenDaysAgo) &&
            (dateToCheck.isBefore(today) ||
                dateToCheck.isAtSameMomentAs(today));
      case 'Bulan Ini':
        return orderDate.year == now.year && orderDate.month == now.month;
      case 'Semua':
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. FILTER LOGIC
    List<Order> filteredList = widget.orders.where((order) {
      // Filter A: Waktu
      bool passDate = _checkDateFilter(order.createdAt);

      // Filter B: Search
      bool passSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = order.customerName?.toLowerCase() ?? '';
        final id = order.id.toString();
        final table = order.restoTable?.number.toLowerCase() ?? '';
        passSearch =
            name.contains(query) || id.contains(query) || table.contains(query);
      }

      return passDate && passSearch;
    }).toList();

    // 2. SORTING (Terbaru di atas)
    final displayOrders = filteredList.reversed.toList();

    return Container(
      color: kBackgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER TITLE ---
          const Text(
            "Riwayat Transaksi",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 117, 117, 117),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              // 1. SEARCH BAR (Lebar diperbesar sedikit agar nyaman)
              Container(
                width: 280,
                height: 45,
                margin: const EdgeInsets.only(right: 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari ID, Nama, atau Meja...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                    filled: true,
                    fillColor: const Color(0xEEEEEEEE),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Lebih rounded
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // 2. DROPDOWN FILTER
              SizedBox(
                height: 45,
                width: 200,
                child: DropdownMenu<String>(
                  width: 200,
                  initialSelection: _selectedFilter,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    }
                  },

                  // STYLE INPUT
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: kPrimaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // STYLE POPUP ROUNDED
                  menuStyle: MenuStyle(
                    backgroundColor: const MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 255, 255),
                    ),
                    elevation: const MaterialStatePropertyAll(6),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    maximumSize: MaterialStatePropertyAll(
                      Size(270, double.infinity),
                    ),
                  ),

                  trailingIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),

                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  dropdownMenuEntries: _filterOptions.map((value) {
                    return DropdownMenuEntry<String>(
                      value: value,
                      label: value,
                      labelWidget: Text(
                        value,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                        ),
                      ),
                      leadingIcon: const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: kPrimaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          // INFO HASIL FILTER
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Menampilkan ${displayOrders.length} transaksi ($_selectedFilter)",
              style: TextStyle(
                color: kSecondaryColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),

          // --- LIST DATA ---
          Expanded(
            child: displayOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ditemukan transaksi: "$_searchQuery"'
                              : 'Tidak ada transaksi periode: "$_selectedFilter"',
                          style: const TextStyle(color: kSecondaryColor),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} • ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
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
                        style: TextStyle(color: Colors.white54, fontSize: 12),
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
                  style: TextStyle(color: Colors.white, fontSize: 14),
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
